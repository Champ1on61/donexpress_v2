import 'package:flutter/material.dart';
import '../utils/app_data.dart';
import 'notifications_screen.dart';
import 'buyer_orders_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AppData().user;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF9C27B0),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFFE91E63)]),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.person, size: 40, color: Color(0xFF9C27B0)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.name ?? 'Гость',
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user?.phone ?? '',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      if (user?.role != null)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user!.role == 'seller' ? '🌸 Продавец' : 
                            user.role == 'courier' ? '🚴 Курьер' : '🛍️ Покупатель',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (user?.role == 'courier')
                    _buildProfileMenuItem(
                      Icons.notifications,
                      'Уведомления о заказах',
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
                    ),
                  if (user?.role == 'buyer')
                    _buildProfileMenuItem(
                      Icons.history,
                      'Мои заказы',
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BuyerOrdersScreen())),
                    ),
                  _buildProfileMenuItem(
                    Icons.shopping_bag,
                    'Адреса доставки',
                    () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Раздел в разработке'), backgroundColor: Colors.orange),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 🔥 ИСПРАВЛЕННЫЙ ВЫХОД с async/await
                  _buildProfileMenuItemAsync(
                    Icons.logout,
                    'Выйти',
                    () async {
                      await AppData().logout();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                      }
                    },
                    isLogout: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Обычный метод для кнопок без async
  Widget _buildProfileMenuItem(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: ListTile(
        leading: Icon(icon, color: isLogout ? Colors.red : const Color(0xFF9C27B0)),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isLogout ? Colors.red : Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // 🔥 Новый метод для кнопок с async (для выхода)
  Widget _buildProfileMenuItemAsync(IconData icon, String title, Future<void> Function() onTap, {bool isLogout = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: ListTile(
        leading: Icon(icon, color: isLogout ? Colors.red : const Color(0xFF9C27B0)),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isLogout ? Colors.red : Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}