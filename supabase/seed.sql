-- ════════════════════════════════════════
-- MarketX — Seed data
-- ════════════════════════════════════════
-- Safe to run immediately after the migrations: this file only inserts data
-- that has NO foreign-key dependency on auth.users (categories, banners).
--
-- Store / product / role data DOES depend on real auth users, so it lives in
-- the commented template at the bottom — fill in the UUIDs after creating the
-- users in Supabase Auth, then run that section.
--
-- Re-runnable: uses fixed UUIDs + ON CONFLICT so importing twice is harmless.

-- ── CATEGORIES ──────────────────────────────────────────────────────────
INSERT INTO categories (id, name_ar, name_en, sort_order, is_active) VALUES
  ('11111111-1111-1111-1111-111111111101', 'مطاعم',       'Restaurants',  1, TRUE),
  ('11111111-1111-1111-1111-111111111102', 'بقالة',        'Groceries',    2, TRUE),
  ('11111111-1111-1111-1111-111111111103', 'إلكترونيات',   'Electronics',  3, TRUE),
  ('11111111-1111-1111-1111-111111111104', 'أزياء',        'Fashion',      4, TRUE),
  ('11111111-1111-1111-1111-111111111105', 'صحة وجمال',    'Health & Beauty', 5, TRUE),
  ('11111111-1111-1111-1111-111111111106', 'منزل ومطبخ',   'Home & Kitchen',  6, TRUE),
  ('11111111-1111-1111-1111-111111111107', 'صيدلية',       'Pharmacy',     7, TRUE),
  ('11111111-1111-1111-1111-111111111108', 'حلويات',       'Sweets',       8, TRUE)
ON CONFLICT (id) DO UPDATE SET
  name_ar = EXCLUDED.name_ar,
  name_en = EXCLUDED.name_en,
  sort_order = EXCLUDED.sort_order,
  is_active = EXCLUDED.is_active;

-- ── BANNERS ─────────────────────────────────────────────────────────────
INSERT INTO banners (id, title_ar, title_en, image_url, link_type, sort_order, is_active) VALUES
  ('22222222-2222-2222-2222-222222222201', 'عروض اليوم',   'Today''s Deals',  'https://picsum.photos/seed/marketx1/800/400', 'none', 1, TRUE),
  ('22222222-2222-2222-2222-222222222202', 'توصيل مجاني',  'Free Delivery',   'https://picsum.photos/seed/marketx2/800/400', 'none', 2, TRUE),
  ('22222222-2222-2222-2222-222222222203', 'الأكثر مبيعاً', 'Best Sellers',    'https://picsum.photos/seed/marketx3/800/400', 'none', 3, TRUE)
ON CONFLICT (id) DO UPDATE SET
  title_ar = EXCLUDED.title_ar,
  title_en = EXCLUDED.title_en,
  image_url = EXCLUDED.image_url,
  is_active = EXCLUDED.is_active;


-- ════════════════════════════════════════════════════════════════════════
-- TEMPLATE: store + products + roles (requires real auth users)
-- ════════════════════════════════════════════════════════════════════════
-- STEP 1 — Create users in Supabase Studio → Authentication → Add user
--          (e.g. admin@marketx.test, vendor@marketx.test). Copy their UUIDs.
--
-- STEP 2 — Replace the placeholder UUIDs below and run this block.
--
-- Uncomment from here:
--
-- DO $$
-- DECLARE
--   v_admin_id  UUID := '00000000-0000-0000-0000-000000000000'; -- ← admin user UUID
--   v_vendor_id UUID := '00000000-0000-0000-0000-000000000000'; -- ← vendor user UUID
--   v_store_id  UUID := '33333333-3333-3333-3333-333333333301';
-- BEGIN
--   -- Promote roles (profile rows are auto-created on signup by the app).
--   UPDATE profiles SET role = 'admin'  WHERE id = v_admin_id;
--   UPDATE profiles SET role = 'vendor', full_name = 'متجر التجربة' WHERE id = v_vendor_id;
--
--   -- An approved, active store owned by the vendor.
--   INSERT INTO stores (id, owner_id, name, name_en, description, category,
--                       delivery_fee, min_order_amount, is_active, is_approved, approved_at)
--   VALUES (v_store_id, v_vendor_id, 'متجر التجربة', 'Demo Store',
--           'متجر تجريبي للعرض', 'Groceries', 2.50, 10, TRUE, TRUE, NOW())
--   ON CONFLICT (id) DO NOTHING;
--
--   -- A few products in that store.
--   INSERT INTO products (store_id, category_id, name_ar, name_en, base_price,
--                         discount_percentage, stock_quantity, is_active, is_featured)
--   VALUES
--     (v_store_id, '11111111-1111-1111-1111-111111111102', 'حليب طازج',  'Fresh Milk',   3.00, 0,  50, TRUE, TRUE),
--     (v_store_id, '11111111-1111-1111-1111-111111111102', 'خبز عربي',   'Arabic Bread', 1.00, 10, 80, TRUE, FALSE),
--     (v_store_id, '11111111-1111-1111-1111-111111111108', 'بقلاوة',     'Baklava',      8.00, 15, 20, TRUE, TRUE);
--
--   -- A coupon for the store.
--   INSERT INTO coupons (store_id, code, type, value, min_order_amount, is_active)
--   VALUES (v_store_id, 'WELCOME10', 'percentage', 10, 15, TRUE)
--   ON CONFLICT (code) DO NOTHING;
-- END $$;
