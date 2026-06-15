/// Domain entity mirroring a row of the `reviews` table.
class Review {
  const Review({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.productRating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String? customerId;
  final String? customerName;
  final int productRating;
  final String? comment;
  final DateTime createdAt;
}
