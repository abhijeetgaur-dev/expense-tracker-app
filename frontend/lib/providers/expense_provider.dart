import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../services/local_db_service.dart';
import '../services/sync_service.dart';

final localDbProvider = Provider<LocalDbService>((ref) {
  throw UnimplementedError('Initialized in main');
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(localDbProvider);
  return SyncService(db);
});

final expenseNotifierProvider = StateNotifierProvider<ExpenseNotifier, List<Expense>>((ref) {
  final db = ref.watch(localDbProvider);
  final syncService = ref.watch(syncServiceProvider);
  return ExpenseNotifier(db, syncService);
});

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  final LocalDbService _db;
  final SyncService _syncService;

  ExpenseNotifier(this._db, this._syncService) 
      : super(_db.getAllExpenses().where((e) => e.syncStatus != 'deleted').toList()) {
    _triggerSync();
  }

  Future<void> addExpense({
    required double amount,
    required String category,
    String? note,
    required DateTime date,
    required String localImagePath,
  }) async {
    final expense = Expense(
      id: const Uuid().v4(),
      amount: amount,
      category: category,
      note: note,
      date: date,
      localImagePath: localImagePath,
    );

    await _db.saveExpense(expense);
    _refresh();
    _triggerSync();
  }

  Future<void> deleteExpense(String id) async {
    await _db.deleteExpense(id);
    _refresh();
    _triggerSync();
  }

  void _refresh() {
    state = _db.getAllExpenses().where((e) => e.syncStatus != 'deleted').toList();
  }

  Future<void> _triggerSync() async {
    await _syncService.syncPendingExpenses();
    _refresh(); 
  }
}

// --- Search and Filtering Logic ---
final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredExpenseProvider = Provider<List<Expense>>((ref) {
  final expenses = ref.watch(expenseNotifierProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  if (query.isEmpty) return expenses;

  return expenses.where((expense) {
    final categoryMatch = expense.category.toLowerCase().contains(query);
    final noteMatch = expense.note?.toLowerCase().contains(query) ?? false;
    return categoryMatch || noteMatch;
  }).toList();
});
