-- ════════════════════════════════════════
-- SECURE WALLET / GIFT-CARD RPCs
-- ════════════════════════════════════════
-- Wallet balance is money; mutating it from the client is tamper-prone and
-- racy. These SECURITY DEFINER functions perform the read-check-write as one
-- atomic, row-locked unit and are the only sanctioned way to move balance.

-- ── Redeem a gift card into the caller's wallet ──
CREATE OR REPLACE FUNCTION redeem_gift_card(p_code TEXT)
RETURNS NUMERIC AS $$
DECLARE
  v_uid UUID := auth.uid();
  v_card RECORD;
  v_balance NUMERIC;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  -- Lock the card row so two redemptions can't race.
  SELECT * INTO v_card FROM gift_cards
  WHERE code = upper(trim(p_code)) AND redeemed_by IS NULL
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'invalid_gift_card';
  END IF;
  IF v_card.expires_at IS NOT NULL AND v_card.expires_at < NOW() THEN
    RAISE EXCEPTION 'invalid_gift_card';
  END IF;

  UPDATE gift_cards SET redeemed_by = v_uid, redeemed_at = NOW() WHERE id = v_card.id;

  UPDATE profiles SET wallet_balance = wallet_balance + v_card.amount
  WHERE id = v_uid
  RETURNING wallet_balance INTO v_balance;

  INSERT INTO wallet_transactions (user_id, amount, type, description, reference_type, reference_id, balance_after)
  VALUES (v_uid, v_card.amount, 'credit', 'Gift card redemption', 'gift_card', v_card.id, v_balance);

  RETURN v_card.amount;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ── Debit the caller's wallet for an order payment ──
CREATE OR REPLACE FUNCTION debit_wallet(p_amount NUMERIC, p_reference_id UUID DEFAULT NULL)
RETURNS NUMERIC AS $$
DECLARE
  v_uid UUID := auth.uid();
  v_balance NUMERIC;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;
  IF p_amount IS NULL OR p_amount <= 0 THEN
    RETURN NULL;
  END IF;

  SELECT wallet_balance INTO v_balance FROM profiles WHERE id = v_uid FOR UPDATE;
  IF v_balance < p_amount THEN
    RAISE EXCEPTION 'insufficient_balance';
  END IF;

  v_balance := v_balance - p_amount;
  UPDATE profiles SET wallet_balance = v_balance WHERE id = v_uid;

  INSERT INTO wallet_transactions (user_id, amount, type, description, reference_type, reference_id, balance_after)
  VALUES (v_uid, p_amount, 'debit', 'Order payment', 'order', p_reference_id, v_balance);

  RETURN v_balance;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
