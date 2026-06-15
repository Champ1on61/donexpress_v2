import 'package:flutter/material.dart';
import '../models/product.dart';

class FavoritesScreen extends StatelessWidget {
  final List<Product> favorites;
  final Function(Product) onToggleFavorite;
  final Function(Product) onAddToCart;

  const FavoritesScreen({super.key, required this.favorites, required this.onToggleFavorite, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9C27B0),
        elevation: 0,
        title: const Text('Избранное', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: favorites.isEmpty
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.favorite_border, size: 80, color: Colors.grey), SizedBox(height: 16), Text('В избранном пока пусто', style: TextStyle(fontSize: 18, color: Colors.grey))]))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.68, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final product = favorites[index];
                return Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10)]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(fit: StackFit.expand, children: [
                          ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), child: Image.network(product.image, fit: BoxFit.cover)),
                          Positioned(top: 8, right: 8, child: GestureDetector(onTap: () => onToggleFavorite(product), child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.favorite, color: Colors.red, size: 20)))),
                        ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text('${product.price.toStringAsFixed(0)} ₽', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF9C27B0))),
                            const SizedBox(height: 8),
                            SizedBox(width: double.infinity, height: 36, child: ElevatedButton(onPressed: () => onAddToCart(product), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27B0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('В корзину', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)))),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}