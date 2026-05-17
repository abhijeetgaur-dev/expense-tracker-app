import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';

class LocalDbService {
  static const String _boxName = 'expenses';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ExpenseAdapter());
    await Hive.openBox<Expense>(_boxName);
  }

  Box<Expense> get _box => Hive.box<Expense>(_boxName);

  List<Expense> getAllExpenses() {
    final expenses = _box.values.toList();
    expenses.sort((a, b) => b.date.compareTo(a.date)); // Newest first
    return expenses;
  }

  Future<void> saveExpense(Expense expense) async {
    await _box.put(expense.id, expense);
  }

  Future<void> deleteExpense(String id) async {
    final expense = _box.get(id);
    if (expense != null) {
      // Soft delete for background sync logic
      final deletedExpense = expense.copyWith(syncStatus: 'deleted');
      await _box.put(id, deletedExpense);
    }
  }

  List<Expense> getPendingSync() {
    return _box.values.where((e) => e.syncStatus == 'pending' || e.syncStatus == 'deleted').toList();
  }
}
