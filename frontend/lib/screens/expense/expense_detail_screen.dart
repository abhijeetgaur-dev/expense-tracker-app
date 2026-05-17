import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart';
import '../../providers/expense_provider.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  final String id;
  const ExpenseDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseNotifierProvider);
    // Find expense safely
    final expenseIndex = expenses.indexWhere((e) => e.id == id);
    if (expenseIndex == -1) {
      return const Scaffold(body: Center(child: Text('Expense not found')));
    }
    final expense = expenses[expenseIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: ClipRect(
              child: PhotoView(
                imageProvider: FileImage(File(expense.localImagePath)),
                backgroundDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                ),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10, offset: const Offset(0, -5))
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('\$${expense.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.category, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Text(expense.category, style: const TextStyle(fontSize: 20, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Text(DateFormat.yMMMMEEEEd().format(expense.date), style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                  if (expense.note != null && expense.note!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Note', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(expense.note!, style: const TextStyle(fontSize: 18, color: Colors.white)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Delete Expense?'),
        content: const Text('Are you sure you want to delete this expense? It will be removed from your device and the cloud.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              ref.read(expenseNotifierProvider.notifier).deleteExpense(id);
              Navigator.pop(ctx); // Close dialog
              context.pop();      // Go back to feed
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
