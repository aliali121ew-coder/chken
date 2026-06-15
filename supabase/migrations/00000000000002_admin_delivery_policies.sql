-- ════════════════════════════════════════
-- ROLE HELPERS
-- ════════════════════════════════════════
-- A policy on `profiles` that sub-selects from `profiles` causes infinite
-- recursion ("infinite recursion detected in policy for relation profiles").
-- These SECURITY DEFINER helpers read the caller's role while bypassing RLS,
-- so they're safe to use inside any policy — including ones on `profiles`.
CREATE OR REPLACE FUNCTION current_role_name()
RETURNS TEXT AS $$
  SELECT role FROM profiles WHERE id = auth.uid();
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
  SELECT current_role_name() = 'admin';
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- ADMIN POLICIES
-- Admins (role = 'admin') get full management access to platform-wide
-- tables that otherwise have no policy granting them visibility.
CREATE POLICY "profiles_admin_all" ON profiles FOR ALL USING (is_admin());

CREATE POLICY "stores_admin_all" ON stores FOR ALL USING (is_admin());

CREATE POLICY "orders_admin_all" ON orders FOR ALL USING (is_admin());

CREATE POLICY "order_items_admin_read" ON order_items FOR SELECT USING (is_admin());

CREATE POLICY "banners_admin_all" ON banners FOR ALL USING (is_admin());

CREATE POLICY "audit_logs_admin_read" ON audit_logs FOR SELECT USING (is_admin());

CREATE POLICY "categories_admin_manage" ON categories FOR ALL USING (is_admin());

-- DELIVERY POLICIES
-- Delivery agents can see unassigned orders ready for pickup, and any
-- order already assigned to them (read + status updates).
CREATE POLICY "orders_delivery_available" ON orders FOR SELECT USING (
  status = 'ready' AND delivery_agent_id IS NULL AND current_role_name() = 'delivery'
);

CREATE POLICY "orders_delivery_assigned_read" ON orders FOR SELECT USING (
  auth.uid() = delivery_agent_id
);

CREATE POLICY "order_items_delivery_read" ON order_items FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM orders
    WHERE orders.id = order_items.order_id
    AND (orders.delivery_agent_id = auth.uid() OR (orders.status = 'ready' AND orders.delivery_agent_id IS NULL))
  )
);
