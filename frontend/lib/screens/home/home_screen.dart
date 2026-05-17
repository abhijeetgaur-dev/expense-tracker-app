import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../providers/expense_provider.dart';

class SummaryBar extends ConsumerWidget {
  const SummaryBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseNotifierProvider);
    final now = DateTime.now();

    double todaySpend = 0;
    double weekSpend = 0;
    double monthSpend = 0;

    for (final e in expenses) {
      if (e.date.year == now.year && e.date.month == now.month) {
        monthSpend += e.amount;
        if (e.date.day == now.day) {
          todaySpend += e.amount;
        }
        if (now.difference(e.date).inDays <= 7) {
          weekSpend += e.amount;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStat('Today', todaySpend),
          _buildStat('7 Days', weekSpend),
          _buildStat('Month', monthSpend),
        ],
      ),
    );
  }

  Widget _buildStat(String label, double amount) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text('\$${amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ],
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _captureImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    
    if (pickedFile != null && context.mounted) {
      context.push('/add-expense', extra: pickedFile.path);
    }
  }

  void _showCameraOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: const Icon(Icons.camera_alt, size: 28),
                title: const Text('Take a Photo', style: TextStyle(fontSize: 18)),
                onTap: () {
                  Navigator.pop(context);
                  _captureImage(context, ImageSource.camera);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: const Icon(Icons.photo_library, size: 28),
                title: const Text('Choose from Gallery', style: TextStyle(fontSize: 18)),
                onTap: () {
                  Navigator.pop(context);
                  _captureImage(context, ImageSource.gallery);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredExpenses = ref.watch(filteredExpenseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Column(
        children: [
          const SummaryBar(), // Bonus: Summary Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
              decoration: InputDecoration(
                hintText: 'Search category or notes...',
                prefixIcon: const Icon(Icons.search), // Bonus: Search
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredExpenses.isEmpty
                ? const Center(
                    child: Text('No expenses found.', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = filteredExpenses[index];
                      return ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(File(expense.localImagePath)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Text(
                          '\$${expense.amount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Text('${expense.category} • ${DateFormat.yMMMd().format(expense.date)}'),
                        trailing: expense.syncStatus == 'pending'
                            ? const Icon(Icons.cloud_upload_outlined, color: Colors.grey, size: 20)
                            : const Icon(Icons.cloud_done, color: Colors.green, size: 20),
                        onTap: () {
                          // Tap to enter detail view
                          context.push('/expense/${expense.id}');
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.large(
        onPressed: () => _showCameraOptions(context),
        elevation: 6,
        child: const Icon(Icons.camera_alt, size: 36),
      ),
    );
  }
}
