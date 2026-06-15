import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product.dart';
import '../models/order.dart';
import '../models/review.dart';

class UserAccount {
  final String name;
  final String phone;
  final String role;
  final String? shopName;

  UserAccount({required this.name, required this.phone, required this.role, this.shopName});

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'role': role,
        'shopName': shopName,
      };

  factory UserAccount.fromJson(Map<String, dynamic> json) => UserAccount(
        name: json['name'],
        phone: json['phone'],
        role: json['role'],
        shopName: json['shopName'],
      );
}

class DeliveryRequest {
  final String id;
  final String address;
  final double price;
  final String distance;
  String status;
  DeliveryRequest({required this.id, required this.address, required this.price, required this.distance, this.status = 'new'});
}

class AppData extends ChangeNotifier {
  static final AppData _instance = AppData._internal();
  factory AppData() => _instance;
  
  AppData._internal() {
    print('🔹 AppData: инициализация...');
    _loadUser();
    _loadReviews();
  }

  UserAccount? _currentUser;
  UserAccount? get currentUser => _currentUser;
  UserAccount? get user => _currentUser;

  final List<UserAccount> _users = [];
  List<UserAccount> get users => List.unmodifiable(_users);

  final List<Product> _marketplaceProducts = [];
  List<Product> get marketplaceProducts => List.unmodifiable(_marketplaceProducts);

  final List<DeliveryRequest> _deliveryRequests = [];
  List<DeliveryRequest> get deliveryRequests => List.unmodifiable(_deliveryRequests);
  int get newRequestsCount => _deliveryRequests.where((r) => r.status == 'new').length;

  final List<Order> _orders = [];
  List<Order> get orders => List.unmodifiable(_orders);

  // 🔥 ОТЗЫВЫ
  final List<Review> _reviews = [];
  List<Review> get reviews => List.unmodifiable(_reviews);
  final Set<String> _ratedOrderIds = {};

  Future<void> _loadUser() async {
    print('🔹 AppData: загрузка текущего пользователя...');
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('currentUser');
      
      if (userJson != null) {
        _currentUser = UserAccount.fromJson(jsonDecode(userJson));
        print('✅ AppData: пользователь загружен: ${_currentUser!.name}');
        notifyListeners();
      } else {
        print('⚠️ AppData: нет сохранённого пользователя');
      }
    } catch (e) {
      print('❌ AppData: ошибка загрузки: $e');
    }
  }

  Future<void> _loadUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString('allUsers');
      
      if (usersJson != null) {
        final List<dynamic> usersList = jsonDecode(usersJson);
        _users.clear();
        _users.addAll(usersList.map((u) => UserAccount.fromJson(u)));
        print('✅ AppData: загружено ${_users.length} пользователей');
      }
    } catch (e) {
      print('❌ AppData: ошибка загрузки пользователей: $e');
    }
  }

  Future<void> _saveCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentUser != null) {
        await prefs.setString('currentUser', jsonEncode(_currentUser!.toJson()));
        print('✅ AppData: текущий пользователь сохранён');
      }
    } catch (e) {
      print('❌ AppData: ошибка сохранения: $e');
    }
  }

  Future<bool> register(String name, String phone, String role, {String? shopName}) async {
    await _loadUsers();
    
    final existingUser = _users.firstWhere(
      (u) => u.phone == phone,
      orElse: () => UserAccount(name: '', phone: '', role: '', shopName: null),
    );
    
    if (existingUser.phone.isNotEmpty) {
      print('❌ AppData: пользователь с таким телефоном уже существует');
      return false;
    }
    
    final newUser = UserAccount(name: name, phone: phone, role: role, shopName: shopName);
    _users.add(newUser);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('allUsers', jsonEncode(_users.map((u) => u.toJson()).toList()));
    
    _currentUser = newUser;
    await _saveCurrentUser();
    
    print('✅ AppData: пользователь зарегистрирован: $name');
    notifyListeners();
    return true;
  }

  Future<bool> login(String phone) async {
    await _loadUsers();
    
    final user = _users.firstWhere(
      (u) => u.phone == phone,
      orElse: () => UserAccount(name: '', phone: '', role: '', shopName: null),
    );
    
    if (user.phone.isEmpty) {
      print('❌ AppData: пользователь не найден');
      return false;
    }
    
    _currentUser = user;
    await _saveCurrentUser();
    
    print('✅ AppData: вход выполнен: ${user.name}');
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    print('🔹 AppData: выход');
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
    notifyListeners();
  }

  // 🔥 ЛОГИКА ОТЗЫВОВ
  Future<void> _loadReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reviewsJson = prefs.getString('reviews');
      if (reviewsJson != null) {
        _reviews.addAll((jsonDecode(reviewsJson) as List).map((e) => Review.fromJson(e)));
      }
      final ratedJson = prefs.getString('rated_orders');
      if (ratedJson != null) {
        _ratedOrderIds.addAll(List<String>.from(jsonDecode(ratedJson)));
      }
    } catch (e) {
      print('❌ AppData: ошибка загрузки отзывов: $e');
    }
  }

  void addReview(Review review) {
    _reviews.add(review);
    _ratedOrderIds.add(review.orderId);
    _saveReviews();
    notifyListeners();
  }

  bool isOrderRated(String orderId) => _ratedOrderIds.contains(orderId);

  Order? getFirstUnratedCompletedOrder() {
    for (var order in _orders) {
      if (order.status == 'completed' && !_ratedOrderIds.contains(order.id)) {
        return order;
      }
    }
    return null;
  }

  Future<void> _saveReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('reviews', jsonEncode(_reviews.map((r) => r.toJson()).toList()));
      await prefs.setString('rated_orders', jsonEncode(_ratedOrderIds.toList()));
    } catch (e) {
      print('❌ AppData: ошибка сохранения отзывов: $e');
    }
  }

  // 🔥 ПРОДУКТЫ
  void addProduct(Product product) {
    _marketplaceProducts.add(product);
    notifyListeners();
  }

  void removeProduct(Product product) {
    _marketplaceProducts.remove(product);
    notifyListeners();
  }

  // 🔥 ЗАКАЗЫ
  void addDeliveryRequest(DeliveryRequest request) {
    _deliveryRequests.insert(0, request);
    notifyListeners();
  }

  void acceptRequest(String id) {
    final req = _deliveryRequests.firstWhere((r) => r.id == id);
    req.status = 'accepted';
    notifyListeners();
  }

  void completeRequest(String id) {
    final req = _deliveryRequests.firstWhere((r) => r.id == id);
    req.status = 'completed';
    notifyListeners();
  }

  void clearCompletedRequests() {
    _deliveryRequests.removeWhere((r) => r.status == 'completed');
    notifyListeners();
  }

  void createOrder(Order order) {
    _orders.insert(0, order);
    notifyListeners();
  }

  void updateOrderStatus(String orderId, String newStatus) {
    try {
      final order = _orders.firstWhere((o) => o.id == orderId);
      order.status = newStatus;
      notifyListeners();
    } catch (e) {
      print('Order not found');
    }
  }

  void assignCourier(String orderId, String courierName) {
    try {
      final order = _orders.firstWhere((o) => o.id == orderId);
      order.courierName = courierName;
      notifyListeners();
    } catch (e) {
      print('Order not found');
    }
  }

  // 🔥🔥🔥 НОВЫЕ МЕТОДЫ ДЛЯ РЕЙТИНГА ТОВАРОВ 🔥🔥🔥
  
  // Возвращает рейтинг и количество отзывов для товара
  Map<String, dynamic> getProductRating(String productId) {
    // Для демо: генерируем реалистичные данные на основе ID товара
    final hash = productId.hashCode.abs();
    
    // 30% товаров новые (без рейтинга)
    if (hash % 100 < 30) {
      return {'rating': 0.0, 'reviewCount': 0};
    }
    
    // Остальные: случайный рейтинг 3.8 - 5.0 и количество отзывов 5-150
    final rating = 3.8 + (hash % 12) / 10.0; // 3.8, 3.9, 4.0 ... 4.9
    final reviewCount = 5 + (hash % 146); // 5-150 отзывов
    
    return {
      'rating': double.parse(rating.toStringAsFixed(1)),
      'reviewCount': reviewCount,
    };
  }

  // Обновляет рейтинг товара после нового отзыва (для будущего)
  void recalculateProductRating(String productId) {
    // В реальном приложении здесь будет логика:
    // 1. Найти все отзывы, связанные с этим товаром
    // 2. Посчитать средний рейтинг
    // 3. Обновить продукт в _marketplaceProducts
    // 4. Сохранить изменения
    // 5. notifyListeners()
    
    // Для демо просто уведомляем об изменении
    notifyListeners();
  }

  // Получить топ товаров по рейтингу
  List<Product> getTopRatedProducts({int limit = 10}) {
    final rated = _marketplaceProducts.where((p) {
      final rating = getProductRating(p.id);
      return rating['reviewCount'] > 0;
    }).toList();
    
    rated.sort((a, b) {
      final ratingA = getProductRating(a.id)['rating'] as double;
      final ratingB = getProductRating(b.id)['rating'] as double;
      return ratingB.compareTo(ratingA); // По убыванию
    });
    
    return rated.take(limit).toList();
  }
}