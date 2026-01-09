import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_state.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/product/presentation/product_detail_page.dart';
import '../features/cart/presentation/cart_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final from = state.uri.queryParameters['from'];
          return LoginPage(from: from);
        },
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailPage(id: id);
        },
      ),
      GoRoute(path: '/cart', builder: (context, state) => const CartPage()),
    ],
    redirect: (context, state) {
      final isLoggedIn = auth.isLoggedIn;

      final goingToCart = state.matchedLocation == '/cart';
      final loggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && goingToCart) {
        return '/login?from=/cart';
      }

      if (isLoggedIn && loggingIn) {
        return '/';
      }

      return null;
    },
  );
});
