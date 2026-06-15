import 'package:flutter/material.dart';
import '../utils/app_data.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9C27B0),
        elevation: 0,
        title: const Text('Уведомления', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            onPressed: () {
              AppData().clearCompletedRequests();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Завершённые заказы удалены'), backgroundColor: Colors.green));
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: AppData(),
        builder: (context, _) {
          final requests = AppData().deliveryRequests;
          if (requests.isEmpty) {
            return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.notifications_off, size: 60, color: Colors.grey), SizedBox(height: 16), Text('Нет уведомлений', style: TextStyle(fontSize: 18, color: Colors.grey))]));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              final isNew = req.status == 'new';
              final isAccepted = req.status == 'accepted';
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isNew ? const Color(0xFF9C27B0) : Colors.grey.shade300, width: 2),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(isNew ? Icons.circle_notifications : isAccepted ? Icons.check_circle : Icons.done_all, color: isNew ? const Color(0xFF9C27B0) : Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text(req.address, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${req.distance} км', style: TextStyle(color: Colors.grey[600])),
                        Text('${req.price.toStringAsFixed(0)} ₽', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF9C27B0))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (isNew)
                      SizedBox(width: double.infinity, height: 40, child: ElevatedButton(onPressed: () { AppData().acceptRequest(req.id); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Заказ принят!'), backgroundColor: Colors.green)); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27B0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Принять заказ', style: TextStyle(fontWeight: FontWeight.bold)))),
                    if (isAccepted)
                      SizedBox(width: double.infinity, height: 40, child: OutlinedButton(onPressed: () { AppData().completeRequest(req.id); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Доставка завершена!'), backgroundColor: Colors.green)); }, style: OutlinedButton.styleFrom(foregroundColor: Colors.green, side: const BorderSide(color: Colors.green), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Завершить доставку', style: TextStyle(fontWeight: FontWeight.bold)))),
                    if (req.status == 'completed')
                      const Text('✅ Доставлено', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}