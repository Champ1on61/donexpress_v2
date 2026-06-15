import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/rate_dialog.dart'; // 🔥 Новый импорт
import '../utils/app_data.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  int _selectedCategory = 0;
  String _searchQuery = '';
  
  List<Product> cartItems = [];
  List<Product> favorites = [];

  final List<Product> demoFlowers = [
    Product(id: 'd1', title: 'Розы красные (15 см)', price: 2500.0, image: 'https://images.unsplash.com/photo-1518621736915-f3b1c41bfd00?w=400', category: 'Розы'),
    Product(id: 'd2', title: 'Пионы белые', price: 3500.0, image: 'https://images.unsplash.com/photo-1563241527-3004b7be0ee9?w=400', category: 'Пионы'),
    Product(id: 'd3', title: 'Тюльпаны микс', price: 1800.0, image: 'https://images.unsplash.com/photo-1520763185298-1b434c0f82c9?w=400', category: 'Тюльпаны'),
  ];

  final List<Map<String, dynamic>> categories = [
    {'name': 'Все цветы', 'filter': null},
    {'name': 'Розы', 'filter': 'Розы'},
    {'name': 'Пионы', 'filter': 'Пионы'},
    {'name': 'Тюльпаны', 'filter': 'Тюльпаны'},
    {'name': 'Букеты', 'filter': 'Букеты'},
  ];

  @override
  void initState() {
    super.initState();
    _loadCart();
    _checkForUnratedOrders(); // 🔥 Проверяем, нужно ли оценить заказ
  }

  // 🔥 ПРОВЕРКА НА НЕОЦЕНЕННЫЕ ЗАКАЗЫ
  void _checkForUnratedOrders() {
    final unratedOrder = AppData().getFirstUnratedCompletedOrder();
    if (unratedOrder != null && mounted) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => RateDialog(
              orderId: unratedOrder.id,
              targetName: unratedOrder.courierName ?? 'Продавец',
              targetRole: unratedOrder.courierName != null ? 'courier' : 'seller',
            ),
          );
        }
      });
    }
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    
    final cartString = prefs.getString('my_cart');
    if (cartString != null) {
      List<dynamic> decoded = jsonDecode(cartString);
      cartItems = decoded.map((e) => Product.fromJson(e)).toList();
    }

    final favString = prefs.getString('my_favorites');
    if (favString != null) {
      List<dynamic> decoded = jsonDecode(favString);
      favorites = decoded.map((e) => Product.fromJson(e)).toList();
    }

    if (mounted) setState(() {});
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartEncoded = jsonEncode(cartItems.map((e) => e.toJson()).toList());
    await prefs.setString('my_cart', cartEncoded);
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favEncoded = jsonEncode(favorites.map((e) => e.toJson()).toList());
    await prefs.setString('my_favorites', favEncoded);
  }

  List<Product> get _allProducts {
    final marketplace = AppData().marketplaceProducts;
    return marketplace.isEmpty ? demoFlowers : marketplace;
  }

  List<Product> get filteredFlowers {
    final base = _allProducts;
    return base.where((flower) {
      final matchesCategory = _selectedCategory == 0 || flower.category == categories[_selectedCategory]['filter'];
      final matchesSearch = flower.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _toggleFavorite(Product product) {
    setState(() {
      favorites.contains(product) ? favorites.remove(product) : favorites.add(product);
    });
    _saveFavorites();
  }

  void _addToCart(Product product) {
    setState(() => cartItems.add(product));
    _saveCart();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Добавлено: ${product.title}'), duration: const Duration(seconds: 1), backgroundColor: Colors.green),
    );
  }

  void _removeFromCart(Product product) {
    setState(() => cartItems.remove(product));
    _saveCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFFE91E63)]),
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                          ),
                          child: TextField(
                            onChanged: (value) => setState(() => _searchQuery = value),
                            decoration: InputDecoration(
                              hintText: '🔍 Найти цветы',
                              prefixIcon: const Icon(Icons.search, color: Color(0xFF9C27B0)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: categories.length,
                          itemBuilder: (context, index) => _buildCategoryChip(categories[index]['name'], index),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: filteredFlowers.isEmpty
                ? const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(Icons.local_florist, size: 60, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Ничего не найдено', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final flower = filteredFlowers[index];
                        return ProductCard(
                          product: flower,
                          isFavorite: favorites.contains(flower),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(
                                  product: flower,
                                  isFavorite: favorites.contains(flower),
                                  onToggleFavorite: _toggleFavorite,
                                  onAddToCart: _addToCart,
                                ),
                              ),
                            );
                          },
                          onToggleFavorite: () => _toggleFavorite(flower),
                        );
                      },
                      childCount: filteredFlowers.length,
                    ),
                  ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CartScreen(
              cartItems: cartItems, 
              onRemove: _removeFromCart,
            )));
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FavoritesScreen(
                  favorites: favorites,
                  onToggleFavorite: _toggleFavorite,
                  onAddToCart: _addToCart,
                ),
              ),
            );
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
          } else {
            setState(() => _navIndex = index);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF9C27B0),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Корзина'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Избранное'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, int index) {
    final isSelected = _selectedCategory == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) => setState(() => _selectedCategory = index),
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF9C27B0).withOpacity(0.2),
        checkmarkColor: const Color(0xFF9C27B0),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF9C27B0) : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}