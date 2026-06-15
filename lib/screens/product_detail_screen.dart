import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final Function(Product) onToggleFavorite;
  final Function(Product) onAddToCart;

  const ProductDetailScreen({super.key, required this.product, required this.isFavorite, required this.onToggleFavorite, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: Colors.white,
            leading: Container(margin: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)]), child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context))),
            actions: [
              Container(margin: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)]), child: IconButton(icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.grey), onPressed: () => onToggleFavorite(product))),
            ],
            flexibleSpace: FlexibleSpaceBar(background: Hero(tag: 'product_${product.id}', child: Image.network(product.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[200])))),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(product.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.2))), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Text('В наличии', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)))]),
                  const SizedBox(height: 12),
                  Text('${product.price.toStringAsFixed(0)} ₽', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF9C27B0))),
                  const SizedBox(height: 24),
                  const Text('Описание', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('Свежие цветы с доставкой на дом. Идеальный подарок для любого повода. Гарантия свежести 7 дней. Бережная упаковка и быстрая доставка по всему городу.', style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.6)),
                  const SizedBox(height: 40),
                  SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: () { onAddToCart(product); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27B0), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('Добавить в корзину', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}