/// Một chuyến thuê đã hoàn thành mà khách chưa đánh giá.
class PendingReview {
  final int bookingId;
  final String vehicleName;
  final String imageUrl;
  final String from;
  final String to;

  const PendingReview({
    required this.bookingId,
    required this.vehicleName,
    required this.imageUrl,
    required this.from,
    required this.to,
  });
}

/// Một đánh giá khách đã viết.
class MyReview {
  final int id;
  final String vehicleName;
  final int rating; // 1 đến 5 sao
  final String comment;
  final String createdAt;

  const MyReview({
    required this.id,
    required this.vehicleName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}