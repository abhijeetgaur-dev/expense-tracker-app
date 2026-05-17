import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/expense/add_expense_screen.dart';
import '../screens/expense/expense_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login', // Will integrate with Riverpod auth state later
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/add-expense',
        name: 'add-expense',
        builder: (context, state) {
          final imagePath = state.extra as String;
          return AddExpenseScreen(imagePath: imagePath);
        },
      ),
      GoRoute(
        path: '/expense/:id',
        name: 'expense-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ExpenseDetailScreen(id: id);
        },
      ),
    ],
  );
});
