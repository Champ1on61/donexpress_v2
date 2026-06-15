import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../utils/app_data.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Product> cartItems;
  final double total;

  const CheckoutScreen({super.key, required this.cartItems, required this.total});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedTime = 'Как можно скорее';
  bool _isLoading = false;

  void _submitOrder() {
    if (_addressController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Заполните адрес и телефон'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _isLoading = true);
    
    Future.delayed(const Duration(seconds: 1), () {
      final buyer = AppData().user;
      // Создаем заказ
      AppData().createOrder(Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        buyerName: buyer?.name ?? 'Гость',
        buyerPhone: buyer?.phone ?? _phoneController.text,
        address: _addressController.text,
        itemNames: widget.cartItems.map((p) => p.title).toList(),
        totalAmount: widget.total,
        status: 'new',
      ));

      setState(() => _isLoading = false);
      if (!mounted) return;
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(
          builder: (context) => OrderSuccessScreen(
            orderNumber: AppData().orders.isNotEmpty ? AppData().orders.first.id.substring(AppData().orders.first.id.length - 6) : 'Unknown'
          )
        )
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9C27B0),
        elevation: 0,
        title: const Text('Оформление заказа', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(' Адрес доставки'),
                  const SizedBox(height: 8),
                  TextField(controller: _addressController, decoration: InputDecoration(hintText: 'Улица, дом, квартира', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white)),
                  const SizedBox(height: 24),
                  _buildSectionTitle(' Номер телефона'),
                  const SizedBox(height: 8),
                  TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: InputDecoration(hintText: '+7 (999) 123-45-67', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white)),
                  const SizedBox(height: 24),
                  _buildSectionTitle('⏰ Время доставки'),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: ['Как можно скорее', 'Сегодня с 18:00 до 20:00', 'Завтра утром'].map((time) {
                    return ChoiceChip(label: Text(time), selected: _selectedTime == time, onSelected: (val) => setState(() => _selectedTime = time), selectedColor: const Color(0xFF9C27B0).withOpacity(0.2), checkmarkColor: const Color(0xFF9C27B0));
                  }).toList()),
                  const SizedBox(height: 24),
                  _buildSectionTitle('📦 Ваш заказ'),
                  const SizedBox(height: 8),
                  Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Column(children: widget.cartItems.map((item) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(item.title, style: const TextStyle(fontSize: 14)), Text('${item.price.toStringAsFixed(0)} ₽', style: const TextStyle(fontWeight: FontWeight.bold))]))).toList())),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Итого:', style: TextStyle(fontSize: 18, color: Colors.grey)), Text('${widget.total.toStringAsFixed(0)} ₽', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))]),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _isLoading ? null : _submitOrder, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27B0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Подтвердить заказ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87));
}