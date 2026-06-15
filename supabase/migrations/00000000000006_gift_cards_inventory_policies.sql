-- GIFT CARDS
-- A user can read cards they purchased or redeemed, plus any not-yet-redeemed
-- card (so a code can be looked up for redemption). Redemption is an UPDATE
-- that claims an unredeemed card for the current user.
CREATE POLICY "gift_cards_select" ON gift_cards FOR SELECT USING (
  redeemed_by IS NULL OR
  purchased_by = auth.uid() OR
  redeemed_by = auth.uid()
);

CREATE POLICY "gift_cards_redeem" ON gift_cards FOR UPDATE USING (
  redeemed_by IS NULL
) WITH CHECK (
  redeemed_by = auth.uid()
);

-- INVENTORY LOGS: vendors read/write logs for stores they own; admins read all.
CREATE POLICY "inventory_logs_vendor_read" ON inventory_logs FOR SELECT USING (
  EXISTS (SELECT 1 FROM stores WHERE id = store_id AND owner_id = auth.uid())
);

CREATE POLICY "inventory_logs_vendor_insert" ON inventory_logs FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM stores WHERE id = store_id AND owner_id = auth.uid())
);

CREATE POLICY "inventory_logs_admin_read" ON inventory_logs FOR SELECT USING (
  (SELECT role FROM profiles WHERE id = auth.uid()) = 'admin'
);
