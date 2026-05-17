import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'theme/app_theme.dart';
import 'routes/app_router.dart';
import 'services/local_db_service.dart';
import 'providers/expense_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(); // Uncomment after setting up flutterfire config

  final localDb = LocalDbService();
  await localDb.init();

  runApp(
    ProviderScope(
      overrides: [
        localDbProvider.overrideWithValue(localDb),
      ],
      child: const ExpenseTrackerApp(),
    ),
  );
}

class ExpenseTrackerApp extends ConsumerWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Camera-First Expense Tracker',
      theme: AppTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
