import '../core/api_client.dart';
import '../core/config.dart';
import 'review_models.dart';

/// Đánh giá xe. HIỆN TẠI chỉ có dữ liệu giả: phần Back-end của đánh giá làm sau,
/// vì cần có đơn đặt xe hoàn thành (module của Mẫn) mới biết khách nào được đánh giá xe nào.
class ReviewService {
  static final List<PendingReview> _pending = [
    const PendingReview(bookingId: 5001, vehicleName: 'Kia Carnival 2023', imageUrl: 'https://picsum.photos/seed/vrs11/640/400', from: '2026-10-10', to: '2026-10-13'),
    const PendingReview(bookingId: 5002, vehicleName: 'VinFast VF e34', imageUrl: 'https://picsum.photos/seed/vrs12/640/400', from: '2026-09-28', to: '2026-09-30'),
  ];

  static final List<MyReview> _mine = [
    const MyReview(id: 1, vehicleName: 'Toyota Innova 2020', rating: 5, comment: 'Xe sạch, chủ xe thân thiện, giao nhận đúng giờ. Sẽ thuê lại!', createdAt: '2026-08-15'),
    const MyReview(id: 2, vehicleName: 'Hyundai Accent 2021', rating: 4, comment: 'Xe ổn, chỉ hơi hao xăng một chút so với mô tả.', createdAt: '2026-07-02'),
  ];
  static int _seq = 3;

  static Exception _noApi() => Exception('API đánh giá chưa có (làm sau khi có phần đơn đặt xe)');

  static Future<List<PendingReview>> pending() async {
    if (!AppConfig.useMocks) throw _noApi();
    await delay();
    return List.of(_pending);
  }

  static Future<List<MyReview>> mine() async {
    if (!AppConfig.useMocks) throw _noApi();
    await delay();
    return List.of(_mine);
  }

  /// Gửi đánh giá cho một chuyến thuê: chuyến đó chuyển từ "chờ đánh giá" sang "đánh giá của tôi".
  static Future<void> submit(int bookingId, int rating, String comment) async {
    if (!AppConfig.useMocks) throw _noApi();
    await delay();
    final p = _pending.firstWhere((x) => x.bookingId == bookingId, orElse: () => throw Exception('Chuyến thuê không còn chờ đánh giá'));
    _pending.remove(p);
    _mine.insert(0, MyReview(
      id: _seq++,
      vehicleName: p.vehicleName,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now().toIso8601String().substring(0, 10),
    ));
  }
}