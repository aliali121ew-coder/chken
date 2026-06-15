-- ════════════════════════════════════════
-- ORDER LIFECYCLE TRIGGERS
-- ════════════════════════════════════════
-- These move stock, loyalty, store-stat and coupon mutations from the client
-- into the database so they run atomically inside the order transaction and
-- cannot be tampered with. All functions are SECURITY DEFINER because the
-- acting customer has no RLS rights on products / other users' profiles /
-- inventory_logs / loyalty_transactions.

-- ── 1. On each order_item: decrement stock, bump total_sold, log the sale ──
CREATE OR REPLACE FUNCTION on_order_item_insert()
RETURNS TRIGGER AS $$
DECLARE
  v_store_id UUID;
  v_customer_id UUID;
  v_stock_after INTEGER;
BEGIN
  -- Resolve the owning store and the order's customer.
  SELECT store_id INTO v_store_id FROM products WHERE id = NEW.product_id;
  SELECT customer_id INTO v_customer_id FROM orders WHERE id = NEW.order_id;

  -- Decrement stock (never below zero) and count the sale.
  UPDATE products
  SET stock_quantity = GREATEST(0, stock_quantity - NEW.quantity),
      total_sold = total_sold + NEW.quantity
  WHERE id = NEW.product_id
  RETURNING stock_quantity INTO v_stock_after;

  IF v_store_id IS NOT NULL THEN
    INSERT INTO inventory_logs (product_id, store_id, change_amount, stock_after, reason, reference_id, created_by)
    VALUES (NEW.product_id, v_store_id, -NEW.quantity, COALESCE(v_stock_after, 0), 'sale', NEW.order_id, v_customer_id);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER order_items_after_insert
  AFTER INSERT ON order_items
  FOR EACH ROW EXECUTE FUNCTION on_order_item_insert();

-- ── 2. On order insert: bump store order count and coupon usage ──
CREATE OR REPLACE FUNCTION on_order_insert()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.store_id IS NOT NULL THEN
    UPDATE stores SET total_orders = total_orders + 1 WHERE id = NEW.store_id;
  END IF;

  IF NEW.coupon_id IS NOT NULL THEN
    UPDATE coupons SET used_count = used_count + 1 WHERE id = NEW.coupon_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER orders_after_insert
  AFTER INSERT ON orders
  FOR EACH ROW EXECUTE FUNCTION on_order_insert();

-- ── 3. On delivery: award loyalty points and stamp delivered_at ──
CREATE OR REPLACE FUNCTION on_order_delivered()
RETURNS TRIGGER AS $$
DECLARE
  v_points INTEGER;
  v_balance INTEGER;
BEGIN
  -- Only when transitioning into 'delivered'.
  IF NEW.status = 'delivered' AND OLD.status IS DISTINCT FROM 'delivered' THEN
    NEW.delivered_at := COALESCE(NEW.delivered_at, NOW());

    v_points := calculate_loyalty_points(NEW.total_amount);
    IF v_points > 0 AND NEW.customer_id IS NOT NULL THEN
      UPDATE profiles
      SET loyalty_points = loyalty_points + v_points
      WHERE id = NEW.customer_id
      RETURNING loyalty_points INTO v_balance;

      INSERT INTO loyalty_transactions (user_id, order_id, points_earned, balance_after, description)
      VALUES (NEW.customer_id, NEW.id, v_points, COALESCE(v_balance, v_points), 'Order delivered');
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- BEFORE UPDATE so the delivered_at assignment on NEW persists.
CREATE TRIGGER orders_before_update_delivered
  BEFORE UPDATE OF status ON orders
  FOR EACH ROW EXECUTE FUNCTION on_order_delivered();
