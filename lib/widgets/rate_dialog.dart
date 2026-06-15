import 'package:flutter/material.dart';
import '../models/review.dart';
import '../utils/app_data.dart';

class RateDialog extends StatefulWidget {
  final String orderId;
  final String targetName;
  final String targetRole;

  const RateDialog({
    super.key,
    required this.orderId,
    required this.targetName,
    required this.targetRole,
  });

  @override
  State<RateDialog> createState() => _RateDialogState();
}

class _RateDialogState extends State<RateDialog> {
  int _rating = 0;
  final _commentCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        children: [
          Icon(Icons.star_rate, color: Colors.amber, size: 40),
          const SizedBox(height: 8),
          Text('Оцените ${widget.targetRole == 'seller' ? 'продавца' : 'курьера'}'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Заказ #${widget.orderId.substring(widget.orderId.length - 4)}', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              return IconButton(
                icon: Icon(
                  starValue <= _rating ? Icons.star : Icons.star_border,
                  color: starValue <= _rating ? Colors.amber : Colors.grey[400],
                  size: 36,
                ),
                onPressed: () => setState(() => _rating = starValue),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Комментарий (необязательно)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Пропустить')),
        ElevatedButton(
          onPressed: _rating == 0 ? null : () {
            AppData().addReview(Review(
              orderId: widget.orderId,
              reviewerName: AppData().user?.name ?? 'Покупатель',
              targetName: widget.targetName,
              targetRole: widget.targetRole,
              rating: _rating,
              comment: _commentCtrl.text.trim(),
            ));
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Спасибо за оценку! ⭐️'), backgroundColor: Colors.green),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Отправить'),
        ),
      ],
    );
  }
}