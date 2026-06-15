// lib/services/split_service.dart
// CRUD + analytics for split expenses

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/split_expense_model.dart';
import '../models/split_member_model.dart';
import 'hive_service.dart';

class SplitService {
  SplitService._();
  static const _uuid = Uuid();

  static Box<SplitExpenseModel> get _box => HiveService.splitBox;

  // === CRUD ===

  static Future<SplitExpenseModel> addSplit({
    required PayerType payer,
    String? friendName,
    required double totalAmount,
    required String description,
    required DateTime dateTime,
    required List<SplitMemberModel> members,
    bool isEqualSplit = true,
    String currency = '₹',
    String currencyCode = 'INR',
  }) async {
    final split = SplitExpenseModel(
      id: _uuid.v4(),
      payer: payer,
      friendName: friendName,
      totalAmount: totalAmount,
      description: description,
      dateTime: dateTime,
      members: members,
      status: SplitStatus.pending,
      isEqualSplit: isEqualSplit,
      currency: currency,
      currencyCode: currencyCode,
    );
    await _box.put(split.id, split);
    return split;
  }

  static Future<void> updateSplit(SplitExpenseModel split) async {
    // Update status based on payments
    final updated = split.copyWith(status: split.derivedStatus);
    await _box.put(updated.id, updated);
  }

  static Future<void> deleteSplit(String id) async {
    await _box.delete(id);
  }

  static List<SplitExpenseModel> getAllSplits() {
    final splits = _box.values.toList();
    splits.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return splits;
  }

  static SplitExpenseModel? getSplit(String id) => _box.get(id);

  // === Member Settlement ===

  /// Mark a member as paid
  static Future<void> markMemberPaid(String splitId, int memberIndex) async {
    final split = getSplit(splitId);
    if (split == null) return;
    final updatedMembers = List<SplitMemberModel>.from(split.members);
    updatedMembers[memberIndex] = updatedMembers[memberIndex].copyWith(
      isPaid: true,
      paidAt: DateTime.now(),
    );
    final updated = split.copyWith(members: updatedMembers);
    await updateSplit(updated);
  }

  /// Mark a member as unpaid
  static Future<void> markMemberUnpaid(String splitId, int memberIndex) async {
    final split = getSplit(splitId);
    if (split == null) return;
    final updatedMembers = List<SplitMemberModel>.from(split.members);
    updatedMembers[memberIndex] = updatedMembers[memberIndex].copyWith(
      isPaid: false,
      paidAt: null,
    );
    final updated = split.copyWith(members: updatedMembers);
    await updateSplit(updated);
  }

  // === Analytics ===

  static double getTotalSplitAmount() {
    return getAllSplits().fold(0.0, (s, e) => s + e.totalAmount);
  }

  static double getTotalPendingAmount() {
    return getAllSplits().fold(0.0, (s, e) => s + e.pendingAmount);
  }

  static List<SplitExpenseModel> getPendingSplits() {
    return getAllSplits()
        .where((s) => s.derivedStatus != SplitStatus.settled)
        .toList();
  }

  static List<SplitExpenseModel> getSettledSplits() {
    return getAllSplits()
        .where((s) => s.derivedStatus == SplitStatus.settled)
        .toList();
  }

  static List<SplitExpenseModel> search(String query) {
    if (query.isEmpty) return getAllSplits();
    final q = query.toLowerCase();
    return getAllSplits().where((s) {
      return s.description.toLowerCase().contains(q) ||
          (s.friendName?.toLowerCase().contains(q) ?? false) ||
          s.members.any((m) => m.name.toLowerCase().contains(q)) ||
          s.totalAmount.toString().contains(q);
    }).toList();
  }
}
