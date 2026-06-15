-- ORDER ITEMS POLICIES
-- order_items has no owning user/store column directly; access is derived
-- from the parent order's customer/vendor/delivery-agent relationship.
CREATE POLICY "order_items_read" ON order_items FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM orders
    WHERE orders.id = order_items.order_id
    AND (
      orders.customer_id = auth.uid() OR
      orders.delivery_agent_id = auth.uid() OR
      EXISTS (SELECT 1 FROM stores WHERE stores.id = orders.store_id AND stores.owner_id = auth.uid())
    )
  )
);

CREATE POLICY "order_items_customer_insert" ON order_items FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM orders
    WHERE orders.id = order_items.order_id
    AND orders.customer_id = auth.uid()
  )
);
