import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../utils/app_data.dart';

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({super.key});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  int _tabIndex = 0;

  final _titleCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _selectedCategory = 'Розы';
  final List<String> _categories = ['Розы', 'Пионы', 'Тюльпаны', 'Букеты', 'Другое'];
  
  File? _pickedImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() => _pickedImage = File(image.path));
    }
  }

  Widget _buildImageWidget(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.local_florist, size: 50, color: Colors.grey),
      );
    } else {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
      );
    }
  }

  void _showAddDialog() {
    _pickedImage = null;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Добавить цветок'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_pickedImage != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _pickedImage!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                OutlinedButton.icon(
                  onPressed: () async {
                    await _pickImage();
                    setDialogState(() {});
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: Text(_pickedImage == null ? '📸 Выбрать фото' : 'Заменить фото'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Название', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Цена (₽)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Категория', border: OutlineInputBorder()),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setDialogState(() => _selectedCategory = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_titleCtrl.text.isEmpty || _priceCtrl.text.isEmpty || _pickedImage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Заполните всё и добавьте фото'), backgroundColor: Colors.red),
                  );
                  return;
                }
                AppData().addProduct(Product(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _titleCtrl.text,
                  price: double.tryParse(_priceCtrl.text) ?? 0,
                  image: _pickedImage!.path,
                  category: _selectedCategory,
                ));
                _titleCtrl.clear();
                _priceCtrl.clear();
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27B0)),
              child: const Text('Добавить', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9C27B0),
        elevation: 0,
        title: const Text('Кабинет продавца', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              AppData().logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _tabIndex = 0),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _tabIndex == 0 ? const Color(0xFF9C27B0) : Colors.grey[200],
                      foregroundColor: _tabIndex == 0 ? Colors.white : Colors.black,
                    ),
                    child: const Text('🌸 Товары'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _tabIndex = 1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _tabIndex == 1 ? const Color(0xFF9C27B0) : Colors.grey[200],
                      foregroundColor: _tabIndex == 1 ? Colors.white : Colors.black,
                    ),
                    child: const Text('📦 Заказы'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _tabIndex == 0 ? _buildProductsTab() : _buildOrdersTab()),
        ],
      ),
      floatingActionButton: _tabIndex == 0
          ? FloatingActionButton(
              onPressed: _showAddDialog,
              backgroundColor: const Color(0xFF9C27B0),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildProductsTab() {
    final products = AppData().marketplaceProducts;
    if (products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_shopping_cart, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('Товаров пока нет', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: _buildImageWidget(p.image),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${p.price.toStringAsFixed(0)} ₽',
                      style: const TextStyle(color: Color(0xFF9C27B0), fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      height: 30,
                      child: OutlinedButton(
                        onPressed: () => AppData().removeProduct(p),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text('Удалить', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrdersTab() {
    return ListenableBuilder(
      listenable: AppData(),
      builder: (context, _) {
        final myOrders = AppData().orders;
        if (myOrders.isEmpty) {
          return const Center(child: Text('Заказов нет'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: myOrders.length,
          itemBuilder: (context, index) {
            final order = myOrders[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF9C27B0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Заказ #${order.id.substring(order.id.length - 4)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      _buildStatusChip(order.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Покупатель: ${order.buyerName}'),
                  Text('Адрес: ${order.address}'),
                  const SizedBox(height: 8),
                  Text('Товары: ${order.itemNames.join(', ')}'),
                  Text(
                    'Сумма: ${order.totalAmount.toStringAsFixed(0)} ₽',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (order.status == 'new')
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () => AppData().updateOrderStatus(order.id, 'ready_for_courier'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27B0)),
                        child: const Text('Принять и передать курьеру'),
                      ),
                    ),
                  if (order.status == 'ready_for_courier')
                    const Text('⏳ Ожидает курьера', style: TextStyle(color: Colors.orange)),
                  if (order.status == 'delivering')
                    Text('🚴 Курьер ${order.courierName ?? 'В пути'}...', style: TextStyle(color: Colors.blue)),
                  if (order.status == 'completed')
                    const Text('✅ Доставлено', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    switch (status) {
      case 'new':
        color = Colors.red;
        text = 'Новый';
        break;
      case 'ready_for_courier':
        color = Colors.orange;
        text = 'Готов';
        break;
      case 'delivering':
        color = Colors.blue;
        text = 'Доставка';
        break;
      case 'completed':
        color = Colors.green;
        text = 'Выполнен';
        break;
      default:
        color = Colors.grey;
        text = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}