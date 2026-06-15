// lib/models/split_expense_model.dart
// Hive model for split expenses

import 'package:hive/hive.dart';
import 'split_member_model.dart';

part 'split_expense_model.g.dart';

/// Status of a split expense
@HiveType(typeId: 2)
enum SplitStatus {
  @HiveField(0)
  pending,

  @HiveField(1)
  partiallyPaid,

  @HiveField(2)
  settled,
}

/// Who paid for the split expense
@HiveType(typeId: 3)
enum PayerType {
  @HiveField(0)
  me,

  @HiveField(1)
  friend,
}

@HiveType(typeId: 4)
class SplitExpenseModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  PayerType payer;

  @HiveField(2)
  String? friendName; // set if payer == friend

  @HiveField(3)
  double totalAmount;

  @HiveField(4)
  String description;

  @HiveField(5)
  DateTime dateTime;

  @HiveField(6)
  List<SplitMemberModel> members;

  @HiveField(7)
  SplitStatus status;

  @HiveField(8)
  bool isEqualSplit;

  @HiveField(9)
  String currency;

  @HiveField(10)
  String currencyCode;

  SplitExpenseModel({
    required this.id,
    required this.payer,
    this.friendName,
    required this.totalAmount,
    required this.description,
    required this.dateTime,
    required this.members,
    this.status = SplitStatus.pending,
    this.isEqualSplit = true,
    this.currency = '₹',
    this.currencyCode = 'INR',
  });

  /// Total amount paid by members
  double get paidAmount =>
      members.where((m) => m.isPaid).fold(0, (s, m) => s + m.shareAmount);

  /// Total pending amount
  double get pendingAmount => totalAmount - paidAmount;

  /// How many members have paid
  int get paidCount => members.where((m) => m.isPaid).length;

  /// Derived status based on payment
  SplitStatus get derivedStatus {
    if (paidAmount >= totalAmount) return SplitStatus.settled;
    if (paidAmount > 0) return SplitStatus.partiallyPaid;
    return SplitStatus.pending;
  }

  int get memberCount => members.length;

  SplitExpenseModel copyWith({
    String? id,
    PayerType? payer,
    String? friendName,
    double? totalAmount,
    String? description,
    DateTime? dateTime,
    List<SplitMemberModel>? members,
    SplitStatus? status,
    bool? isEqualSplit,
    String? currency,
    String? currencyCode,
  }) {
    return SplitExpenseModel(
      id: id ?? this.id,
      payer: payer ?? this.payer,
      friendName: friendName ?? this.friendName,
      totalAmount: totalAmount ?? this.totalAmount,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      members: members ?? this.members,
      status: status ?? this.status,
      isEqualSplit: isEqualSplit ?? this.isEqualSplit,
      currency: currency ?? this.currency,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'payer': payer.name,
        'friendName': friendName,
        'totalAmount': totalAmount,
        'description': description,
        'dateTime': dateTime.toIso8601String(),
        'members': members.map((m) => m.toJson()).toList(),
        'status': status.name,
        'isEqualSplit': isEqualSplit,
        'currency': currency,
        'currencyCode': currencyCode,
      };

  factory SplitExpenseModel.fromJson(Map<String, dynamic> json) {
    return SplitExpenseModel(
      id: json['id'] as String,
      payer: PayerType.values.firstWhere(
        (e) => e.name == json['payer'],
        orElse: () => PayerType.me,
      ),
      friendName: json['friendName'] as String?,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      description: json['description'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      members: (json['members'] as List)
          .map((m) => SplitMemberModel.fromJson(m as Map<String, dynamic>))
          .toList(),
      status: SplitStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SplitStatus.pending,
      ),
      isEqualSplit: json['isEqualSplit'] as bool? ?? true,
      currency: json['currency'] as String? ?? '₹',
      currencyCode: json['currencyCode'] as String? ?? 'INR',
    );
  }
}
