import 'package:flutter/material.dart';
import '../utils/app_data.dart';

class BuyerOrdersScreen extends StatelessWidget {
  const BuyerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AppData().user;
    // Фильтруем заказы только для текущего покупателя
    final myOrders = AppData().orders.where((o) => o.buyerPhone == user?.phone).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9C27B0),
        elevation: 0,
        title: const Text('Мои заказы', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: myOrders.isEmpty
          ? const Center(child: Text('История заказов пуста', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myOrders.length,
              itemBuilder: (context, index) {
                final order = myOrders[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Заказ #${order.id.substring(order.id.length - 4)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${order.totalAmount.toStringAsFixed(0)} ₽', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9C27B0))),
                      ]),
                      const SizedBox(height: 8),
                      Text(order.itemNames.join(', '), style: TextStyle(color: Colors.grey[700])),
                      const SizedBox(height: 8),
                      Row(children: [Icon(_getStatusIcon(order.status), color: _getStatusColor(order.status), size: 16), const SizedBox(width: 6), Text(_getTextStatus(order.status), style: TextStyle(fontWeight: FontWeight.w500))]),
                    ],
                  ),
                );
              },
            ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'new': return Icons.pending;
      case 'ready_for_courier': return Icons.local_shipping;
      case 'delivering': return Icons.directions_bike;
      case 'completed': return Icons.check_circle;
      default: return Icons.info;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'new': return Colors.orange;
      case 'ready_for_courier': return Colors.blue;
      case 'delivering': return Colors.purple;
      case 'completed': return Colors.green;
      default: return Colors.grey;
    }
  }

  String _getTextStatus(String status) {
    switch (status) {
      case 'new': return 'Принят продавцом';
      case 'ready_for_courier': return 'Ожидает курьера';
      case 'delivering': return 'В пути (Курьер: ${AppData().orders.firstWhere((o) => o.status == 'delivering' || o.status == 'completed').courierName ?? '...'})';
      case 'completed': return 'Доставлен';
      default: return status;
    }
  }
}