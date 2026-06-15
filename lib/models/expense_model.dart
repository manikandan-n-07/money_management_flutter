// lib/models/expense_model.dart
// Hive model for expenses

import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 0)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String category; // category id string

  @HiveField(3)
  String place;

  @HiveField(4)
  String notes;

  @HiveField(5)
  DateTime dateTime;

  @HiveField(6)
  List<String> tags;

  @HiveField(7)
  String currency; // currency symbol e.g. ₹

  @HiveField(8)
  String currencyCode; // e.g. INR

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.place,
    required this.notes,
    required this.dateTime,
    this.tags = const [],
    this.currency = '₹',
    this.currencyCode = 'INR',
  });

  /// Create a copy with modified fields
  ExpenseModel copyWith({
    String? id,
    double? amount,
    String? category,
    String? place,
    String? notes,
    DateTime? dateTime,
    List<String>? tags,
    String? currency,
    String? currencyCode,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      place: place ?? this.place,
      notes: notes ?? this.notes,
      dateTime: dateTime ?? this.dateTime,
      tags: tags ?? this.tags,
      currency: currency ?? this.currency,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }

  /// Convert to JSON (for backup)
  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'category': category,
        'place': place,
        'notes': notes,
        'dateTime': dateTime.toIso8601String(),
        'tags': tags,
        'currency': currency,
        'currencyCode': currencyCode,
      };

  /// Create from JSON (for restore)
  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        category: json['category'] as String,
        place: json['place'] as String? ?? '',
        notes: json['notes'] as String? ?? '',
        dateTime: DateTime.parse(json['dateTime'] as String),
        tags: List<String>.from(json['tags'] as List? ?? []),
        currency: json['currency'] as String? ?? '₹',
        currencyCode: json['currencyCode'] as String? ?? 'INR',
      );
}
