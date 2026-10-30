import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/theme.dart';
import '../review/review_models.dart';
import '../review/review_service.dart';
import '../widgets/star_rating.dart';

const _hints = ['', 'Rất tệ', 'Chưa tốt', 'Bình thường', 'Hài lòng', 'Tuyệt vời'];

/// Đánh giá chuyến thuê: danh sách chuyến chờ đánh giá + các đánh giá đã viết.
class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  List<PendingReview>? _pending;
  List<MyReview> _mine = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final pending = await ReviewService.pending();
      final mine = await ReviewService.mine();
      if (!mounted) return;
      setState(() { _pending = pending; _mine = mine; _loading = false; _error = null; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = errorMessage(e); _loading = false; });
    }
  }

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _write(PendingReview p) async {
    final result = await showModalBottomSheet<({int rating, String comment})>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ReviewForm(vehicleName: p.vehicleName),
    );
    if (result == null || !mounted) return;
    try {
      await ReviewService.submit(p.bookingId, result.rating, result.comment);
      if (!mounted) return;
      _toast('Cảm ơn bạn đã đánh giá!');
      _load();
    } catch (e) {
      if (mounted) _toast(errorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đánh giá chuyến thuê')),
      body: _body(),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_pending == null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_error ?? 'Không tải được dữ liệu', style: const TextStyle(color: AppColors.danger), textAlign: TextAlign.center),
          TextButton(
            onPressed: () { setState(() { _loading = true; _error = null; }); _load(); },
            child: const Text('Thử lại'),
          ),
        ]),
      );
    }
    final pending = _pending!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _title('Chờ bạn đánh giá (${pending.length})'),
        if (pending.isEmpty) const Text('Bạn đã đánh giá hết các chuyến thuê.', style: TextStyle(color: AppColors.muted)),
        for (final p in pending) _pendingCard(p),
        const SizedBox(height: 20),
        _title('Đánh giá của tôi (${_mine.length})'),
        if (_mine.isEmpty) const Text('Bạn chưa viết đánh giá nào.', style: TextStyle(color: AppColors.muted)),
        for (final r in _mine) _reviewCard(r),
      ],
    );
  }

  Widget _title(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
  );

  Widget _pendingCard(PendingReview p) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  p.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: AppColors.brandSoft, child: const Icon(Icons.broken_image, color: AppColors.muted)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.vehicleName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('${p.from} → ${p.to}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                  TextButton.icon(
                    onPressed: () => _write(p),
                    icon: const Icon(Icons.rate_review_outlined, size: 18),
                    label: const Text('Viết đánh giá'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewCard(MyReview r) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text(r.vehicleName, style: const TextStyle(fontWeight: FontWeight.w600))),
              Text(r.createdAt, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            ]),
            const SizedBox(height: 4),
            StarRating(value: r.rating, size: 18),
            const SizedBox(height: 6),
            Text(r.comment),
          ],
        ),
      ),
    );
  }
}

/// Bảng viết đánh giá: chọn sao + nhận xét. Bấm Gửi thì trả về (số sao, nhận xét).
class _ReviewForm extends StatefulWidget {
  final String vehicleName;
  const _ReviewForm({required this.vehicleName});

  @override
  State<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<_ReviewForm> {
  final _form = GlobalKey<FormState>();
  final _comment = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  void _send() {
    if (!_form.currentState!.validate()) return;
    Navigator.pop(context, (rating: _rating, comment: _comment.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Đánh giá ${widget.vehicleName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            const SizedBox(height: 14),
            StarRating(value: _rating, size: 40, onChanged: (n) => setState(() => _rating = n)),
            const SizedBox(height: 4),
            Text(_hints[_rating], style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 14),
            TextFormField(
              controller: _comment,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Nhận xét của bạn',
                hintText: 'Xe sạch không? Chủ xe có thân thiện? Giao nhận đúng hẹn?',
                alignLabelWithHint: true,
              ),
              validator: (v) => (v ?? '').trim().length < 10 ? 'Nhận xét tối thiểu 10 ký tự' : null,
            ),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _send, child: const Text('Gửi đánh giá'))),
          ],
        ),
      ),
    );
  }
}