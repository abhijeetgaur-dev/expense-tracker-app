import 'package:hive/hive.dart';

class Expense {
  final String id;
  final double amount;
  final String category;
  final String? note;
  final DateTime date;
  final String localImagePath;
  final String? remoteImageUrl;
  final String syncStatus;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    this.note,
    required this.date,
    required this.localImagePath,
    this.remoteImageUrl,
    this.syncStatus = 'pending',
  });

  Expense copyWith({
    String? id,
    double? amount,
    String? category,
    String? note,
    DateTime? date,
    String? localImagePath,
    String? remoteImageUrl,
    String? syncStatus,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      date: date ?? this.date,
      localImagePath: localImagePath ?? this.localImagePath,
      remoteImageUrl: remoteImageUrl ?? this.remoteImageUrl,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 0;

  @override
  Expense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Expense(
      id: fields[0] as String,
      amount: fields[1] as double,
      category: fields[2] as String,
      note: fields[3] as String?,
      date: DateTime.fromMillisecondsSinceEpoch(fields[4] as int),
      localImagePath: fields[5] as String,
      remoteImageUrl: fields[6] as String?,
      syncStatus: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer.writeByte(8);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.amount);
    writer.writeByte(2);
    writer.write(obj.category);
    writer.writeByte(3);
    writer.write(obj.note);
    writer.writeByte(4);
    writer.write(obj.date.millisecondsSinceEpoch);
    writer.writeByte(5);
    writer.write(obj.localImagePath);
    writer.writeByte(6);
    writer.write(obj.remoteImageUrl);
    writer.writeByte(7);
    writer.write(obj.syncStatus);
  }
}
