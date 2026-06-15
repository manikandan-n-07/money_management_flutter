// lib/models/split_member_model.dart
// Hive model for individual split members

import 'package:hive/hive.dart';

part 'split_member_model.g.dart';

@HiveType(typeId: 1)
class SplitMemberModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double shareAmount;

  @HiveField(2)
  bool isPaid;

  @HiveField(3)
  DateTime? paidAt;

  SplitMemberModel({
    required this.name,
    required this.shareAmount,
    this.isPaid = false,
    this.paidAt,
  });

  SplitMemberModel copyWith({
    String? name,
    double? shareAmount,
    bool? isPaid,
    DateTime? paidAt,
  }) {
    return SplitMemberModel(
      name: name ?? this.name,
      shareAmount: shareAmount ?? this.shareAmount,
      isPaid: isPaid ?? this.isPaid,
      paidAt: paidAt ?? this.paidAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'shareAmount': shareAmount,
        'isPaid': isPaid,
        'paidAt': paidAt?.toIso8601String(),
      };

  factory SplitMemberModel.fromJson(Map<String, dynamic> json) =>
      SplitMemberModel(
        name: json['name'] as String,
        shareAmount: (json['shareAmount'] as num).toDouble(),
        isPaid: json['isPaid'] as bool? ?? false,
        paidAt: json['paidAt'] != null
            ? DateTime.parse(json['paidAt'] as String)
            : null,
      );
}
