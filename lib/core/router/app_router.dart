import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/rooms/presentation/rooms_list_screen.dart';
import '../../features/rooms/presentation/room_detail_screen.dart';
import '../../features/booking/presentation/booking_screen.dart';
import '../../features/booking/presentation/my_bookings_screen.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/admin/presentation/admin_rooms_screen.dart';
import '../../features/admin/presentation/admin_add_room_screen.dart';
import '../../features/admin/presentation/admin_bookings_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.value?.session != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/rooms', builder: (_, __) => const RoomsListScreen()),
      GoRoute(
        path: '/rooms/:id',
        builder: (_, state) => RoomDetailScreen(roomId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/booking/:roomId',
        builder: (_, state) => BookingScreen(roomId: state.pathParameters['roomId']!),
      ),
      GoRoute(path: '/my-bookings', builder: (_, __) => const MyBookingsScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      // Admin routes
      GoRoute(path: '/admin', builder: (_, __) => const AdminDashboardScreen()),
      GoRoute(path: '/admin/rooms', builder: (_, __) => const AdminRoomsScreen()),
      GoRoute(path: '/admin/rooms/add', builder: (_, __) => const AdminAddRoomScreen()),
      GoRoute(
        path: '/admin/rooms/edit/:id',
        builder: (_, state) => AdminAddRoomScreen(roomId: state.pathParameters['id']),
      ),
      GoRoute(path: '/admin/bookings', builder: (_, __) => const AdminBookingsScreen()),
    ],
  );
});