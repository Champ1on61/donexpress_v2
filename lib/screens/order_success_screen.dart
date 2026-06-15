import 'package:flutter/material.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderNumber;
  const OrderSuccessScreen({super.key, required this.orderNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.check_circle, size: 80, color: Colors.green)),
              const SizedBox(height: 24),
              const Text('Заказ успешно оформлен!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Номер заказа: #$orderNumber', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
              const SizedBox(height: 32),
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]), child: const Column(children: [Text('⏱ Ориентировочное время доставки', style: TextStyle(color: Colors.grey)), SizedBox(height: 8), Text('45-60 минут', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF9C27B0)))])),
              const SizedBox(height: 40),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () => Navigator.popUntil(context, (route) => route.isFirst), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27B0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Вернуться на главную', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
            ],
          ),
        ),
      ),
    );
  }
}