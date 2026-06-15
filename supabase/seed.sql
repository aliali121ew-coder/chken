-- ════════════════════════════════════════
-- MarketX — DEMO SEED DATA
-- ════════════════════════════════════════
-- Fills every screen (categories, banners, stores, products, a coupon) with
-- one paste — no manual UUIDs, no auth dependency: demo stores have
-- owner_id = NULL and are approved+active so they're publicly browsable.
--
-- All rows use fixed UUID ranges (1111… categories, 2222… banners,
-- 3333… stores, 4444… products) so seed_cleanup.sql can remove them exactly.
-- Re-runnable: ON CONFLICT keeps a second run harmless.

-- ── CATEGORIES (1111…) ──────────────────────────────────────
INSERT INTO categories (id, name_ar, name_en, sort_order, is_active) VALUES
  ('11111111-1111-1111-1111-111111111101', 'مطاعم',       'Restaurants',     1, TRUE),
  ('11111111-1111-1111-1111-111111111102', 'بقالة',        'Groceries',       2, TRUE),
  ('11111111-1111-1111-1111-111111111103', 'إلكترونيات',   'Electronics',     3, TRUE),
  ('11111111-1111-1111-1111-111111111104', 'أزياء',        'Fashion',         4, TRUE),
  ('11111111-1111-1111-1111-111111111105', 'صحة وجمال',    'Health & Beauty', 5, TRUE),
  ('11111111-1111-1111-1111-111111111106', 'منزل ومطبخ',   'Home & Kitchen',  6, TRUE)
ON CONFLICT (id) DO UPDATE SET
  name_ar = EXCLUDED.name_ar, name_en = EXCLUDED.name_en,
  sort_order = EXCLUDED.sort_order, is_active = EXCLUDED.is_active;

-- ── BANNERS (2222…) ─────────────────────────────────────────
INSERT INTO banners (id, title_ar, title_en, image_url, link_type, sort_order, is_active) VALUES
  ('22222222-2222-2222-2222-222222222201', 'عروض اليوم',    'Today''s Deals', 'https://picsum.photos/seed/marketx1/800/400', 'none', 1, TRUE),
  ('22222222-2222-2222-2222-222222222202', 'توصيل مجاني',   'Free Delivery',  'https://picsum.photos/seed/marketx2/800/400', 'none', 2, TRUE)
ON CONFLICT (id) DO UPDATE SET
  title_ar = EXCLUDED.title_ar, image_url = EXCLUDED.image_url, is_active = EXCLUDED.is_active;

-- ── STORES (3333…) — approved & active, no owner required ────
INSERT INTO stores (id, owner_id, name, name_en, description, description_en, category,
                    gradient_start, gradient_end, primary_color, secondary_color,
                    delivery_fee, min_order_amount, rating, total_reviews,
                    is_active, is_approved, approved_at) VALUES
  ('33333333-3333-3333-3333-333333333301', NULL, 'متجر التقنية', 'Tech Store',
   'أحدث الأجهزة الإلكترونية', 'Latest electronics', 'إلكترونيات',
   '#1565C0', '#0D47A1', '#1565C0', '#0D47A1', 5.0, 20.0, 4.6, 128, TRUE, TRUE, NOW()),
  ('33333333-3333-3333-3333-333333333302', NULL, 'سوبر ماركت الأهلي', 'Al-Ahli Market',
   'بقالة ومواد غذائية', 'Groceries & food', 'بقالة',
   '#2E7D32', '#1B5E20', '#2E7D32', '#1B5E20', 3.0, 10.0, 4.3, 86, TRUE, TRUE, NOW())
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name, is_active = EXCLUDED.is_active, is_approved = EXCLUDED.is_approved;

-- ── PRODUCTS (4444…) ────────────────────────────────────────
INSERT INTO products (id, store_id, category_id, name_ar, name_en, description_ar,
                      base_price, discount_percentage, stock_quantity, images,
                      is_featured, is_active, total_sold) VALUES
  -- Tech Store
  ('44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301',
   '11111111-1111-1111-1111-111111111103', 'سماعات لاسلكية', 'Wireless Headphones',
   'سماعات بلوتوث عالية الجودة', 45.0, 15, 30,
   '[{"url":"https://picsum.photos/seed/headphones/600","type":"image"}]'::jsonb, TRUE, TRUE, 64),
  ('44444444-4444-4444-4444-444444444402', '33333333-3333-3333-3333-333333333301',
   '11111111-1111-1111-1111-111111111103', 'شاحن سريع 65 واط', 'Fast Charger 65W',
   'شاحن سريع لجميع الأجهزة', 18.0, 0, 100,
   '[{"url":"https://picsum.photos/seed/charger/600","type":"image"}]'::jsonb, FALSE, TRUE, 120),
  ('44444444-4444-4444-4444-444444444403', '33333333-3333-3333-3333-333333333301',
   '11111111-1111-1111-1111-111111111103', 'ساعة ذكية', 'Smart Watch',
   'ساعة رياضية بشاشة AMOLED', 120.0, 20, 15,
   '[{"url":"https://picsum.photos/seed/watch/600","type":"image"}]'::jsonb, TRUE, TRUE, 40),
  -- Supermarket
  ('44444444-4444-4444-4444-444444444404', '33333333-3333-3333-3333-333333333302',
   '11111111-1111-1111-1111-111111111102', 'زيت زيتون 1 لتر', 'Olive Oil 1L',
   'زيت زيتون بكر ممتاز', 12.5, 10, 50,
   '[{"url":"https://picsum.photos/seed/oliveoil/600","type":"image"}]'::jsonb, TRUE, TRUE, 200),
  ('44444444-4444-4444-4444-444444444405', '33333333-3333-3333-3333-333333333302',
   '11111111-1111-1111-1111-111111111102', 'أرز بسمتي 5 كغ', 'Basmati Rice 5kg',
   'أرز بسمتي فاخر', 22.0, 0, 40,
   '[{"url":"https://picsum.photos/seed/rice/600","type":"image"}]'::jsonb, FALSE, TRUE, 150),
  ('44444444-4444-4444-4444-444444444406', '33333333-3333-3333-3333-333333333302',
   '11111111-1111-1111-1111-111111111102', 'عسل طبيعي 500غ', 'Natural Honey 500g',
   'عسل جبلي طبيعي', 30.0, 5, 25,
   '[{"url":"https://picsum.photos/seed/honey/600","type":"image"}]'::jsonb, TRUE, TRUE, 90)
ON CONFLICT (id) DO UPDATE SET
  base_price = EXCLUDED.base_price, stock_quantity = EXCLUDED.stock_quantity, is_active = EXCLUDED.is_active;

-- ── COUPON ──────────────────────────────────────────────────
INSERT INTO coupons (store_id, code, type, value, min_order_amount, is_active)
SELECT '33333333-3333-3333-3333-333333333302', 'WELCOME10', 'percentage', 10, 15, TRUE
WHERE NOT EXISTS (SELECT 1 FROM coupons WHERE code = 'WELCOME10');
