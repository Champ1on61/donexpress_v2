import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/order.dart'; // 🔥 Добавили для карты
import 'checkout_screen.dart';
import 'delivery_map_screen.dart'; // 🔥 Добавили импорт карты

class CartScreen extends StatefulWidget {
  final List<Product> cartItems;
  final Function(Product) onRemove;

  const CartScreen({super.key, required this.cartItems, required this.onRemove});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double get totalPrice => widget.cartItems.fold(0.0, (sum, item) => sum + item.price);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9C27B0),
        elevation: 0,
        title: const Text('Корзина', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: widget.cartItems.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey), SizedBox(height: 16), Text('Корзина пуста', style: TextStyle(fontSize: 18, color: Colors.grey))]))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.cartItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]),
                        child: Row(
                          children: [
                            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(item.image, width: 60, height: 60, fit: BoxFit.cover)),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text('${item.price.toStringAsFixed(0)} ₽', style: const TextStyle(color: Color(0xFF9C27B0), fontWeight: FontWeight.bold))])),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.grey), onPressed: () => setState(() => widget.onRemove(item))),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // 🔥 КНОПКА КАРТЫ (появляется если есть товары)
                if (widget.cartItems.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Создаём тестовый заказ для демо карты
                          final testOrder = Order(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            buyerName: 'Покупатель',
                            address: 'Москва, ул. Примерная, 123',
                            totalAmount: totalPrice,
                            itemNames: widget.cartItems.map((item) => item.title).toList(),
                            courierName: 'Иван Курьеров',
                            status: 'delivering', buyerPhone: '',
                          );
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeliveryMapScreen(order: testOrder),
                            ),
                          );
                        },
                        icon: const Icon(Icons.map, color: Color(0xFF9C27B0)),
                        label: const Text('📍 Показать доставку на карте', style: TextStyle(color: Color(0xFF9C27B0))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF9C27B0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 8),
                
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Итого:', style: TextStyle(fontSize: 18, color: Colors.grey)), Text('${totalPrice.toStringAsFixed(0)} ₽', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black))]),
                      const SizedBox(height: 16),
                      SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutScreen(cartItems: widget.cartItems, total: totalPrice)));
                      }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27B0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Оформить заказ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}