import 'package:dio/dio.dart';
import 'dart:io';
import '../models/expense.dart';
import 'local_db_service.dart';

class SyncService {
  final Dio _dio;
  final LocalDbService _localDb;
  // Use 10.0.2.2 for Android emulator, 127.0.0.1 for iOS simulator
  final String _baseUrl = 'http://10.0.2.2:3000'; 

  SyncService(this._localDb) : _dio = Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  Future<String?> _getToken() async {
    // Placeholder for actual Firebase Auth JWT Retrieval
    // e.g., return await FirebaseAuth.instance.currentUser?.getIdToken();
    return 'demo-jwt-token'; 
  }

  Future<void> syncPendingExpenses() async {
    final pendingExpenses = _localDb.getPendingSync();
    if (pendingExpenses.isEmpty) return;

    final token = await _getToken();
    if (token == null) return; // Unauthenticated, skip sync

    for (final expense in pendingExpenses) {
      if (expense.syncStatus == 'pending') {
        await _uploadExpense(expense, token);
      } else if (expense.syncStatus == 'deleted') {
        await _deleteRemoteExpense(expense, token);
      }
    }
  }

  Future<void> _uploadExpense(Expense expense, String token) async {
    try {
      final file = File(expense.localImagePath);
      String fileName = file.path.split('/').last;

      FormData formData = FormData.fromMap({
        'id': expense.id,
        'amount': expense.amount.toString(),
        'category': expense.category,
        'note': expense.note ?? '',
        'date': expense.date.toIso8601String(),
      });

      if (await file.exists()) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(file.path, filename: fileName),
        ));
      }

      final response = await _dio.post(
        '/expenses',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 201) {
        // Success! Update local DB to mark as synced
        final updatedExpense = expense.copyWith(
          syncStatus: 'synced',
          remoteImageUrl: response.data['imageUrl'],
        );
        await _localDb.saveExpense(updatedExpense);
        print('✅ Synced expense: ${expense.id}');
      }
    } catch (e) {
      print('❌ Failed to sync expense: ${expense.id}. Will retry later. Error: $e');
    }
  }

  Future<void> _deleteRemoteExpense(Expense expense, String token) async {
    try {
      final response = await _dio.delete(
        '/expenses/${expense.id}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('✅ Deleted remote expense: ${expense.id}');
        // Optional: Perform hard delete in local DB here if desired.
      }
    } catch (e) {
      print('❌ Failed to delete remote expense: ${expense.id}. Error: $e');
    }
  }
}
