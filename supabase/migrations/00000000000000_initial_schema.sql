-- ════════════════════════════════════════
-- MarketX — Initial Database Schema
-- ════════════════════════════════════════

-- ════════════════════════════════════════
-- ENABLE EXTENSIONS
-- ════════════════════════════════════════
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ════════════════════════════════════════
-- TABLE 1: PROFILES (Users)
-- ════════════════════════════════════════
CREATE TABLE profiles (
  id UUID REFERENCES auth.users PRIMARY KEY,
  role TEXT CHECK (role IN ('customer','vendor','delivery','admin')) NOT NULL DEFAULT 'customer',
  full_name TEXT,
  phone TEXT,
  avatar_url TEXT,
  wallet_balance DECIMAL(10,2) DEFAULT 0,
  loyalty_points INTEGER DEFAULT 0,
  loyalty_tier TEXT DEFAULT 'bronze' CHECK (loyalty_tier IN ('bronze','silver','gold')),
  referral_code TEXT UNIQUE DEFAULT substr(md5(random()::text), 0, 9),
  preferred_language TEXT DEFAULT 'ar' CHECK (preferred_language IN ('ar','en')),
  preferred_currency TEXT DEFAULT 'USD',
  fcm_token TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ════════════════════════════════════════
-- TABLE 2: STORES
-- ════════════════════════════════════════
CREATE TABLE stores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  name_en TEXT,
  description TEXT,
  description_en TEXT,
  logo_url TEXT,
  banner_url TEXT,
  -- Dynamic theming colors
  gradient_start TEXT DEFAULT '#4CAF50',
  gradient_end TEXT DEFAULT '#2E7D32',
  primary_color TEXT DEFAULT '#4CAF50',
  secondary_color TEXT DEFAULT '#2E7D32',
  custom_icon_url TEXT,
  -- Business info
  category TEXT,
  registration_type TEXT CHECK (registration_type IN ('simple','commercial')),
  commercial_docs_url TEXT,
  -- Location
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),
  address TEXT,
  delivery_radius_km DECIMAL(5,2) DEFAULT 10,
  delivery_policy TEXT,
  -- Operating hours: {"mon":{"open":"09:00","close":"22:00","closed":false}, ...}
  store_hours JSONB DEFAULT '{}',
  -- Financial
  min_order_amount DECIMAL(10,2) DEFAULT 0,
  delivery_fee DECIMAL(10,2) DEFAULT 0,
  wallet_balance DECIMAL(10,2) DEFAULT 0,
  -- Stats
  rating DECIMAL(3,2) DEFAULT 0,
  total_reviews INTEGER DEFAULT 0,
  total_orders INTEGER DEFAULT 0,
  -- Status
  is_active BOOLEAN DEFAULT TRUE,
  is_approved BOOLEAN DEFAULT FALSE,
  approved_at TIMESTAMPTZ,
  approved_by UUID REFERENCES profiles(id),
  suspended_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE INDEX stores_owner_idx ON stores(owner_id);
CREATE INDEX stores_location_idx ON stores(latitude, longitude);
CREATE INDEX stores_approved_idx ON stores(is_approved, is_active);

-- ════════════════════════════════════════
-- TABLE 3: CATEGORIES
-- ════════════════════════════════════════
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name_ar TEXT NOT NULL,
  name_en TEXT,
  icon_url TEXT,
  parent_id UUID REFERENCES categories(id),
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ════════════════════════════════════════
-- TABLE 4: PRODUCTS
-- ════════════════════════════════════════
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
  category_id UUID REFERENCES categories(id),
  name_ar TEXT NOT NULL,
  name_en TEXT,
  description_ar TEXT,
  description_en TEXT,
  base_price DECIMAL(10,2) NOT NULL,
  discount_percentage INTEGER DEFAULT 0 CHECK (discount_percentage BETWEEN 0 AND 100),
  final_price DECIMAL(10,2) GENERATED ALWAYS AS (
    ROUND(base_price * (1 - discount_percentage::DECIMAL/100), 2)
  ) STORED,
  stock_quantity INTEGER DEFAULT 0,
  low_stock_threshold INTEGER DEFAULT 5,
  -- Media: array of {url, type: 'image'|'video'|'ar'}
  images JSONB DEFAULT '[]',
  video_url TEXT,
  ar_model_url TEXT,
  -- Variants: [{name:"Size", options:[{label:"L", price_modifier:0, stock:10}]}]
  variants JSONB DEFAULT '[]',
  tags TEXT[] DEFAULT '{}',
  weight_kg DECIMAL(6,3),
  is_featured BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  total_sold INTEGER DEFAULT 0,
  -- Full-text search
  search_vector tsvector GENERATED ALWAYS AS (
    setweight(to_tsvector('simple', coalesce(name_ar,'')), 'A') ||
    setweight(to_tsvector('simple', coalesce(name_en,'')), 'B') ||
    setweight(to_tsvector('simple', coalesce(description_ar,'')), 'C')
  ) STORED,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE INDEX products_store_idx ON products(store_id);
CREATE INDEX products_category_idx ON products(category_id);
CREATE INDEX products_search_idx ON products USING GIN(search_vector);
CREATE INDEX products_featured_idx ON products(is_featured, is_active);
CREATE INDEX products_price_idx ON products(final_price);

-- ════════════════════════════════════════
-- TABLE 5: ADDRESSES
-- ════════════════════════════════════════
CREATE TABLE addresses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  label TEXT DEFAULT 'Home',
  full_address TEXT NOT NULL,
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),
  city TEXT,
  country TEXT DEFAULT 'IQ',
  is_default BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX addresses_user_idx ON addresses(user_id);

-- ════════════════════════════════════════
-- TABLE 6: CART ITEMS
-- ════════════════════════════════════════
CREATE TABLE cart_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
  selected_variant JSONB,
  special_request TEXT,
  added_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, product_id, selected_variant)
);

CREATE INDEX cart_user_idx ON cart_items(user_id);

-- ════════════════════════════════════════
-- TABLE 7: ORDERS
-- ════════════════════════════════════════
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_number TEXT UNIQUE DEFAULT 'ORD-' || UPPER(substr(md5(random()::text), 0, 9)),
  customer_id UUID REFERENCES profiles(id),
  store_id UUID REFERENCES stores(id),
  delivery_agent_id UUID REFERENCES profiles(id),
  address_id UUID REFERENCES addresses(id),
  status TEXT CHECK (status IN (
    'pending','confirmed','preparing','ready',
    'picked_up','on_way','delivered','cancelled','refunded'
  )) DEFAULT 'pending',
  delivery_type TEXT CHECK (delivery_type IN ('immediate','scheduled','pickup')) DEFAULT 'immediate',
  scheduled_at TIMESTAMPTZ,
  -- Financials
  subtotal DECIMAL(10,2) NOT NULL,
  delivery_fee DECIMAL(10,2) DEFAULT 0,
  discount_amount DECIMAL(10,2) DEFAULT 0,
  loyalty_points_used INTEGER DEFAULT 0,
  total_amount DECIMAL(10,2) NOT NULL,
  -- Payment
  payment_method TEXT CHECK (payment_method IN ('cash','stripe','wallet')) NOT NULL,
  payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending','paid','failed','refunded')),
  stripe_payment_intent_id TEXT,
  -- References
  coupon_id UUID,
  -- Customer notes
  special_request TEXT,
  notes TEXT,
  -- Tracking
  estimated_delivery_at TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ,
  cancelled_at TIMESTAMPTZ,
  cancellation_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE INDEX orders_customer_idx ON orders(customer_id);
CREATE INDEX orders_store_idx ON orders(store_id);
CREATE INDEX orders_status_idx ON orders(status);
CREATE INDEX orders_agent_idx ON orders(delivery_agent_id);

-- ════════════════════════════════════════
-- TABLE 8: ORDER ITEMS
-- ════════════════════════════════════════
CREATE TABLE order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id),
  product_name TEXT NOT NULL,
  product_image_url TEXT,
  quantity INTEGER NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  selected_variant JSONB,
  subtotal DECIMAL(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED
);

CREATE INDEX order_items_order_idx ON order_items(order_id);

-- ════════════════════════════════════════
-- TABLE 9: DELIVERY TRACKING
-- ════════════════════════════════════════
CREATE TABLE delivery_tracking (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  agent_id UUID REFERENCES profiles(id),
  latitude DECIMAL(10,8) NOT NULL,
  longitude DECIMAL(11,8) NOT NULL,
  recorded_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX tracking_order_idx ON delivery_tracking(order_id, recorded_at DESC);

-- ════════════════════════════════════════
-- TABLE 10: COUPONS
-- ════════════════════════════════════════
CREATE TABLE coupons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
  code TEXT UNIQUE NOT NULL,
  type TEXT CHECK (type IN ('percentage','fixed')) NOT NULL,
  value DECIMAL(10,2) NOT NULL,
  min_order_amount DECIMAL(10,2) DEFAULT 0,
  max_uses INTEGER,
  used_count INTEGER DEFAULT 0,
  per_user_limit INTEGER DEFAULT 1,
  expires_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ════════════════════════════════════════
-- TABLE 11: LOYALTY TRANSACTIONS
-- ════════════════════════════════════════
CREATE TABLE loyalty_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  order_id UUID REFERENCES orders(id),
  points_earned INTEGER DEFAULT 0,
  points_spent INTEGER DEFAULT 0,
  balance_after INTEGER NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX loyalty_user_idx ON loyalty_transactions(user_id);

-- ════════════════════════════════════════
-- TABLE 12: REVIEWS
-- ════════════════════════════════════════
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(id),
  customer_id UUID REFERENCES profiles(id),
  store_id UUID REFERENCES stores(id),
  product_id UUID REFERENCES products(id),
  product_rating INTEGER CHECK (product_rating BETWEEN 1 AND 5),
  delivery_rating INTEGER CHECK (delivery_rating BETWEEN 1 AND 5),
  comment TEXT,
  image_url TEXT,
  is_approved BOOLEAN DEFAULT TRUE,
  is_reported BOOLEAN DEFAULT FALSE,
  report_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE INDEX reviews_store_idx ON reviews(store_id);
CREATE INDEX reviews_product_idx ON reviews(product_id);

-- Auto-update store rating after review
CREATE OR REPLACE FUNCTION update_store_rating()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE stores SET
    rating = (SELECT ROUND(AVG(product_rating::DECIMAL), 2) FROM reviews WHERE store_id = NEW.store_id AND deleted_at IS NULL),
    total_reviews = (SELECT COUNT(*) FROM reviews WHERE store_id = NEW.store_id AND deleted_at IS NULL)
  WHERE id = NEW.store_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reviews_update_store_rating
  AFTER INSERT OR UPDATE ON reviews
  FOR EACH ROW EXECUTE FUNCTION update_store_rating();

-- ════════════════════════════════════════
-- TABLE 13: CHAT MESSAGES
-- ════════════════════════════════════════
CREATE TABLE chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL,
  sender_id UUID REFERENCES profiles(id),
  receiver_id UUID REFERENCES profiles(id),
  store_id UUID REFERENCES stores(id),
  message TEXT,
  message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text','image','order_ref')),
  attachment_url TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX chat_conversation_idx ON chat_messages(conversation_id, created_at DESC);
CREATE INDEX chat_receiver_idx ON chat_messages(receiver_id, is_read);

-- ════════════════════════════════════════
-- TABLE 14: NOTIFICATIONS
-- ════════════════════════════════════════
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  title_ar TEXT NOT NULL,
  title_en TEXT,
  body_ar TEXT,
  body_en TEXT,
  type TEXT CHECK (type IN (
    'order_status','new_message','price_alert','back_in_stock',
    'coupon','loyalty','referral','system','promotion'
  )),
  data JSONB DEFAULT '{}',
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX notifications_user_idx ON notifications(user_id, is_read);

-- ════════════════════════════════════════
-- TABLE 15: WISHLISTS
-- ════════════════════════════════════════
CREATE TABLE wishlists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- ════════════════════════════════════════
-- TABLE 16: GIFT CARDS
-- ════════════════════════════════════════
CREATE TABLE gift_cards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL DEFAULT UPPER(substr(md5(random()::text), 0, 13)),
  amount DECIMAL(10,2) NOT NULL,
  type TEXT CHECK (type IN ('digital','physical')) DEFAULT 'digital',
  purchased_by UUID REFERENCES profiles(id),
  redeemed_by UUID REFERENCES profiles(id),
  redeemed_at TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ════════════════════════════════════════
-- TABLE 17: WALLET TRANSACTIONS
-- ════════════════════════════════════════
CREATE TABLE wallet_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  amount DECIMAL(10,2) NOT NULL,
  type TEXT CHECK (type IN ('credit','debit')) NOT NULL,
  description TEXT,
  reference_id UUID,
  reference_type TEXT,
  balance_after DECIMAL(10,2),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX wallet_user_idx ON wallet_transactions(user_id, created_at DESC);

-- ════════════════════════════════════════
-- TABLE 18: REFERRALS
-- ════════════════════════════════════════
CREATE TABLE referrals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  referrer_id UUID REFERENCES profiles(id),
  referred_id UUID REFERENCES profiles(id),
  referral_code TEXT NOT NULL,
  reward_given BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(referred_id)
);

-- ════════════════════════════════════════
-- TABLE 19: PRICE ALERTS
-- ════════════════════════════════════════
CREATE TABLE price_alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  target_price DECIMAL(10,2),
  alert_type TEXT CHECK (alert_type IN ('price_drop','back_in_stock')) NOT NULL,
  is_triggered BOOLEAN DEFAULT FALSE,
  triggered_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ════════════════════════════════════════
-- TABLE 20: AUDIT LOGS
-- ════════════════════════════════════════
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id),
  action TEXT NOT NULL,
  table_name TEXT,
  record_id UUID,
  old_data JSONB,
  new_data JSONB,
  ip_address TEXT,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX audit_user_idx ON audit_logs(user_id, created_at DESC);
CREATE INDEX audit_table_idx ON audit_logs(table_name, record_id);

-- ════════════════════════════════════════
-- TABLE 21: CMS BANNERS
-- ════════════════════════════════════════
CREATE TABLE banners (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title_ar TEXT,
  title_en TEXT,
  image_url TEXT NOT NULL,
  link_type TEXT CHECK (link_type IN ('store','product','category','url','none')),
  link_value TEXT,
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  starts_at TIMESTAMPTZ,
  ends_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ════════════════════════════════════════
-- TABLE 22: INVENTORY LOGS
-- ════════════════════════════════════════
CREATE TABLE inventory_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  store_id UUID REFERENCES stores(id),
  change_amount INTEGER NOT NULL,
  stock_after INTEGER NOT NULL,
  reason TEXT CHECK (reason IN ('sale','restock','adjustment','return','damage')),
  reference_id UUID,
  created_by UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ════════════════════════════════════════
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ════════════════════════════════════════

-- Enable RLS on ALL tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE delivery_tracking ENABLE ROW LEVEL SECURITY;
ALTER TABLE coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE loyalty_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE wishlists ENABLE ROW LEVEL SECURITY;
ALTER TABLE gift_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE referrals ENABLE ROW LEVEL SECURITY;
ALTER TABLE price_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE banners ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_logs ENABLE ROW LEVEL SECURITY;

-- PROFILES POLICIES
CREATE POLICY "profiles_select_own" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "profiles_update_own" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "profiles_insert_own" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- STORES POLICIES
CREATE POLICY "stores_public_read" ON stores FOR SELECT USING (is_active = TRUE AND is_approved = TRUE);
CREATE POLICY "stores_vendor_manage" ON stores FOR ALL USING (
  auth.uid() = owner_id AND
  (SELECT role FROM profiles WHERE id = auth.uid()) = 'vendor'
);

-- PRODUCTS POLICIES
CREATE POLICY "products_public_read" ON products FOR SELECT USING (
  is_active = TRUE AND deleted_at IS NULL AND
  EXISTS (SELECT 1 FROM stores WHERE id = store_id AND is_approved = TRUE AND is_active = TRUE)
);
CREATE POLICY "products_vendor_manage" ON products FOR ALL USING (
  EXISTS (SELECT 1 FROM stores WHERE id = store_id AND owner_id = auth.uid())
);

-- CART POLICIES
CREATE POLICY "cart_own" ON cart_items FOR ALL USING (auth.uid() = user_id);

-- ORDERS POLICIES
CREATE POLICY "orders_customer_read" ON orders FOR SELECT USING (auth.uid() = customer_id);
CREATE POLICY "orders_vendor_read" ON orders FOR SELECT USING (
  EXISTS (SELECT 1 FROM stores WHERE id = store_id AND owner_id = auth.uid())
);
CREATE POLICY "orders_customer_insert" ON orders FOR INSERT WITH CHECK (auth.uid() = customer_id);
CREATE POLICY "orders_status_update" ON orders FOR UPDATE USING (
  auth.uid() = customer_id OR
  EXISTS (SELECT 1 FROM stores WHERE id = store_id AND owner_id = auth.uid()) OR
  auth.uid() = delivery_agent_id
);

-- ADDRESSES POLICIES
CREATE POLICY "addresses_own" ON addresses FOR ALL USING (auth.uid() = user_id);

-- REVIEWS POLICIES
CREATE POLICY "reviews_public_read" ON reviews FOR SELECT USING (deleted_at IS NULL AND is_approved = TRUE);
CREATE POLICY "reviews_customer_write" ON reviews FOR INSERT WITH CHECK (auth.uid() = customer_id);

-- CHAT POLICIES
CREATE POLICY "chat_participants" ON chat_messages FOR ALL USING (
  auth.uid() = sender_id OR auth.uid() = receiver_id
);

-- NOTIFICATIONS POLICIES
CREATE POLICY "notifications_own" ON notifications FOR ALL USING (auth.uid() = user_id);

-- WISHLISTS POLICIES
CREATE POLICY "wishlists_own" ON wishlists FOR ALL USING (auth.uid() = user_id);

-- BANNERS: public read
CREATE POLICY "banners_public_read" ON banners FOR SELECT USING (
  is_active = TRUE AND
  (starts_at IS NULL OR starts_at <= NOW()) AND
  (ends_at IS NULL OR ends_at >= NOW())
);

-- CATEGORIES: public read
CREATE POLICY "categories_public_read" ON categories FOR SELECT USING (is_active = TRUE);

-- ════════════════════════════════════════
-- DATABASE FUNCTIONS
-- ════════════════════════════════════════

-- Calculate loyalty points for an order
CREATE OR REPLACE FUNCTION calculate_loyalty_points(order_amount DECIMAL)
RETURNS INTEGER AS $$
BEGIN
  RETURN FLOOR(order_amount / 10)::INTEGER; -- 1 point per $10
END;
$$ LANGUAGE plpgsql;

-- Process referral reward
CREATE OR REPLACE FUNCTION process_referral_reward(referrer UUID, referee UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE profiles SET loyalty_points = loyalty_points + 50 WHERE id = referrer;
  UPDATE profiles SET loyalty_points = loyalty_points + 20 WHERE id = referee;
  UPDATE referrals SET reward_given = TRUE WHERE referrer_id = referrer AND referred_id = referee;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update loyalty tier based on points
CREATE OR REPLACE FUNCTION update_loyalty_tier()
RETURNS TRIGGER AS $$
BEGIN
  NEW.loyalty_tier = CASE
    WHEN NEW.loyalty_points >= 1000 THEN 'gold'
    WHEN NEW.loyalty_points >= 500 THEN 'silver'
    ELSE 'bronze'
  END;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER profiles_loyalty_tier
  BEFORE UPDATE OF loyalty_points ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_loyalty_tier();

-- ════════════════════════════════════════
-- REALTIME — ENABLE FOR THESE TABLES
-- ════════════════════════════════════════
-- Run in Supabase Dashboard > Database > Replication:
-- Enable realtime for: orders, chat_messages, notifications, delivery_tracking

-- ════════════════════════════════════════
-- AUTOMATED DAILY BACKUP
-- ════════════════════════════════════════
-- Enable in Supabase Dashboard > Settings > Backups
-- Frequency: Daily at 02:00 UTC
-- Retention: 30 days
