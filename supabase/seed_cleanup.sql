-- ════════════════════════════════════════
-- MarketX — REMOVE DEMO SEED DATA
-- ════════════════════════════════════════
-- Deletes ONLY the demo rows created by seed.sql (fixed UUID ranges + the
-- WELCOME10 coupon). Real accounts (auth.users / profiles) and any genuine
-- store/product data are left untouched.
-- Order respects foreign keys: children first.

-- Carts / order items referencing demo products
DELETE FROM cart_items  WHERE product_id::text LIKE '44444444-%';
DELETE FROM order_items WHERE product_id::text LIKE '44444444-%';

-- Coupon, products, stores, banners, categories
DELETE FROM coupons  WHERE code = 'WELCOME10';
DELETE FROM products WHERE id::text LIKE '44444444-%';
DELETE FROM stores   WHERE id::text LIKE '33333333-%';
DELETE FROM banners  WHERE id::text LIKE '22222222-%';
DELETE FROM categories WHERE id::text LIKE '11111111-%';
