import '../entities/price_alert.dart';

/// The signed-in user's product price / stock alerts.
abstract class PriceAlertRepository {
  Future<List<PriceAlert>> getMyAlerts();

  /// The active alert for [productId], or `null` if none exists.
  Future<PriceAlert?> getAlertForProduct(String productId);

  Future<void> createAlert({
    required String productId,
    required String alertType,
    double? targetPrice,
  });

  Future<void> deleteAlert(String id);
}
