-- COUPONS: any authenticated user can read active, unexpired coupons in
-- order to validate a code at checkout. Vendors manage their own coupons.
CREATE POLICY "coupons_public_read" ON coupons FOR SELECT USING (
  is_active = TRUE AND
  (expires_at IS NULL OR expires_at >= NOW())
);

CREATE POLICY "coupons_vendor_manage" ON coupons FOR ALL USING (
  EXISTS (SELECT 1 FROM stores WHERE id = store_id AND owner_id = auth.uid())
);

-- LOYALTY TRANSACTIONS: users read their own ledger.
CREATE POLICY "loyalty_own_read" ON loyalty_transactions FOR SELECT USING (
  auth.uid() = user_id
);

-- WALLET TRANSACTIONS: users read their own ledger.
CREATE POLICY "wallet_own_read" ON wallet_transactions FOR SELECT USING (
  auth.uid() = user_id
);
