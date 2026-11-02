import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'auth/auth_provider.dart';
import 'screens/account_screen.dart';
import 'screens/address_book_screen.dart';
import 'screens/admin_home_screen.dart';
import 'screens/home_screen.dart';
import 'screens/audit_logs_screen.dart';
import 'screens/login_screen.dart';
import 'screens/maintenance_screen.dart';
import 'screens/my_vehicles_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/reviews_screen.dart';
import 'screens/vehicle_detail_screen.dart';
import 'screens/vehicle_form_screen.dart';
import 'widgets/coming_soon.dart';

/// Cấu trúc: Khách (xem được không cần đăng nhập) → Người dùng (cần đăng nhập) → Admin (cần vai trò ADMIN).
/// Thêm màn hình mới: import màn hình rồi thêm 1 GoRoute vào đúng nhóm bên dưới.
/// Tab ở thanh dưới: thay ComingSoon(...) bằng màn hình thật khi làm xong.
GoRouter buildRouter(AuthProvider auth) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: auth,
    redirect: (context, state) {
      if (auth.loading) return null;
      final loc = state.matchedLocation;
      final needLogin = loc.startsWith('/bookings') || loc.startsWith('/my-vehicles') || loc.startsWith('/me/');
      if (needLogin && !auth.isLoggedIn) return '/login';
      if (loc.startsWith('/admin') && !auth.isAdmin) return auth.isLoggedIn ? '/' : '/login';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      // --- Màn hình Khách (không bọc thanh dưới): thêm ở đây ---
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      // --- Màn hình Người dùng (cần đăng nhập, không bọc thanh dưới) ---
      GoRoute(path: '/me/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/me/addresses', builder: (_, __) => const AddressBookScreen()),
      GoRoute(path: '/me/reviews', builder: (_, __) => const ReviewsScreen()),
      GoRoute(path: '/me/vehicles', builder: (_, __) => const MyVehiclesScreen()),
      GoRoute(path: '/me/vehicles/new', builder: (_, __) => const VehicleFormScreen()),
      GoRoute(path: '/me/vehicles/:id/edit', builder: (_, s) => VehicleFormScreen(vehicleId: s.pathParameters['id'])),
      GoRoute(path: '/me/vehicles/:id', builder: (_, s) => VehicleDetailScreen(vehicleId: s.pathParameters['id']!)),
      GoRoute(path: '/me/vehicles/:id/maintenance', builder: (_, s) => MaintenanceScreen(vehicleId: s.pathParameters['id']!)),

      GoRoute(path: '/admin', builder: (_, __) => const AdminHomeScreen()),
      GoRoute(path: '/admin/audit', builder: (_, __) => const AuditLogsScreen()),
      // --- Màn hình Admin: thêm ở đây ---

      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _MainShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/', builder: (_, __) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/vehicles', builder: (_, __) => const ComingSoon('Tìm xe'))]),
          StatefulShellBranch(routes: [GoRoute(path: '/bookings', builder: (_, __) => const ComingSoon('Đơn của tôi'))]),
          StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (_, __) => const AccountScreen())]),
        ],
      ),
    ],
  );
}

class _MainShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const _MainShell({required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Trang chủ'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Tìm xe'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Đơn của tôi'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Tài khoản'),
        ],
      ),
    );
  }
}
