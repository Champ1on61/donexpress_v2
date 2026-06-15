import 'dart:async';
import 'package:donexpress_v2/models/order.dart';
import 'package:flutter/material.dart';
import '../utils/app_data.dart';
import 'notifications_screen.dart';

class CourierDashboard extends StatefulWidget {
  const CourierDashboard({super.key});

  @override
  State<CourierDashboard> createState() => _CourierDashboardState();
}

class _CourierDashboardState extends State<CourierDashboard> {
  @override
  void initState() {
    super.initState();
    // Симуляция: через 5 сек после входа появляется тестовый заказ, если их нет
    Timer(const Duration(seconds: 5), () {
      if (AppData().orders.isEmpty) {
        AppData().createOrder(Order(
          id: 'TEST-001',
          buyerName: 'Иван Тестов',
          buyerPhone: '+79990000000',
          address: 'ул. Пушкина, д. 10, кв. 5',
          itemNames: ['Розы красные'],
          totalAmount: 2500.0,
          status: 'ready_for_courier', // Сразу готов к доставке
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9C27B0),
        elevation: 0,
        title: const Text('Кабинет курьера', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: () { AppData().logout(); Navigator.pushReplacementNamed(context, '/'); }),
        ],
      ),
      body: ListenableBuilder(
        listenable: AppData(),
        builder: (context, _) {
          // Курьер видит заказы, которые готовы к доставке или уже в пути
          final availableOrders = AppData().orders.where((o) => o.status == 'ready_for_courier' || o.status == 'delivering').toList();
          
          if (availableOrders.isEmpty) {
            return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.directions_bike, size: 60, color: Colors.grey), SizedBox(height: 16), Text('Нет доступных заказов', style: TextStyle(fontSize: 18, color: Colors.grey))]));
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: availableOrders.length,
            itemBuilder: (context, index) {
              final order = availableOrders[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Заказ на доставку', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${order.totalAmount.toStringAsFixed(0)} ₽', style: const TextStyle(color: Color(0xFF9C27B0), fontWeight: FontWeight.bold, fontSize: 18)),
                    ]),
                    const SizedBox(height: 8),
                    Text('Адрес: ${order.address}', style: const TextStyle(fontSize: 15)),
                    Text('Покупатель: ${order.buyerName} (${order.buyerPhone})', style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 12),
                    if (order.status == 'ready_for_courier')
                      SizedBox(width: double.infinity, height: 45, child: ElevatedButton(onPressed: () {
                        AppData().assignCourier(order.id, AppData().user?.name ?? 'Курьер');
                        AppData().updateOrderStatus(order.id, 'delivering');
                      }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27B0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Забрать заказ', style: TextStyle(fontWeight: FontWeight.bold)))),
                    if (order.status == 'delivering')
                      SizedBox(width: double.infinity, height: 45, child: ElevatedButton(onPressed: () {
                        AppData().updateOrderStatus(order.id, 'completed');
                      }, style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Доставлено', style: TextStyle(fontWeight: FontWeight.bold)))),
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