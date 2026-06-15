import 'package:flutter/material.dart';
import '../utils/app_data.dart';
import 'home_screen.dart';
import 'seller_dashboard.dart';
import 'courier_dashboard.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _shopCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController(); // Для будущего использования
  String _selectedRole = 'buyer';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await AppData().register(
      _nameCtrl.text.trim(),
      _phoneCtrl.text.trim(),
      _selectedRole,
      shopName: _selectedRole == 'seller' ? _shopCtrl.text.trim() : null,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      _navigateToDashboard(_selectedRole);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пользователь с таким телефоном уже существует'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _login() async {
    if (_phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите телефон'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await AppData().login(_phoneCtrl.text.trim());

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      final user = AppData().currentUser;
      _navigateToDashboard(user!.role);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пользователь не найден. Зарегистрируйтесь.'), backgroundColor: Colors.red),
      );
    }
  }

  void _navigateToDashboard(String role) {
    Widget nextScreen;
    if (role == 'seller') {
      nextScreen = const SellerDashboard();
    } else if (role == 'courier') {
      nextScreen = const CourierDashboard();
    } else {
      nextScreen = const HomeScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            // Логотип
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.local_florist, size: 80, color: Color(0xFF9C27B0)),
                  const SizedBox(height: 16),
                  const Text('DonExpress', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Доставка цветов', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                ],
              ),
            ),
            // Вкладки
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFF9C27B0),
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: const Color(0xFF9C27B0),
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                tabs: const [
                  Tab(text: ' Вход'),
                  Tab(text: '📝 Регистрация'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Контент вкладок
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLoginTab(),
                  _buildRegisterTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('С возвращением!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Введите ваш телефон для входа', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 32),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Телефон',
              hintText: '+7 (999) 123-45-67',
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Войти', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Создать аккаунт', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Заполните данные для регистрации', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: 'Ваше имя',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Телефон',
              hintText: '+7 (999) 123-45-67',
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            decoration: InputDecoration(
              labelText: 'Роль',
              prefixIcon: const Icon(Icons.badge),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            items: const [
              DropdownMenuItem(value: 'buyer', child: Text('🛍️ Покупатель')),
              DropdownMenuItem(value: 'seller', child: Text('🌸 Продавец')),
              DropdownMenuItem(value: 'courier', child: Text('🚴 Курьер')),
            ],
            onChanged: (val) => setState(() => _selectedRole = val!),
          ),
          if (_selectedRole == 'seller') ...[
            const SizedBox(height: 16),
            TextField(
              controller: _shopCtrl,
              decoration: InputDecoration(
                labelText: 'Название магазина',
                prefixIcon: const Icon(Icons.store),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Зарегистрироваться', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}