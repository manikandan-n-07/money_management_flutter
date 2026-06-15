// lib/providers/split_provider.dart
// Riverpod providers for split expense state

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/split_expense_model.dart';
import '../models/split_member_model.dart';
import '../services/split_service.dart';

class SplitNotifier extends StateNotifier<List<SplitExpenseModel>> {
  SplitNotifier() : super(SplitService.getAllSplits());

  void refresh() {
    state = SplitService.getAllSplits();
  }

  Future<void> addSplit({
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
    await SplitService.addSplit(
      payer: payer,
      friendName: friendName,
      totalAmount: totalAmount,
      description: description,
      dateTime: dateTime,
      members: members,
      isEqualSplit: isEqualSplit,
      currency: currency,
      currencyCode: currencyCode,
    );
    refresh();
  }

  Future<void> updateSplit(SplitExpenseModel split) async {
    await SplitService.updateSplit(split);
    refresh();
  }

  Future<void> deleteSplit(String id) async {
    await SplitService.deleteSplit(id);
    refresh();
  }

  Future<void> markMemberPaid(String splitId, int memberIndex) async {
    await SplitService.markMemberPaid(splitId, memberIndex);
    refresh();
  }

  Future<void> markMemberUnpaid(String splitId, int memberIndex) async {
    await SplitService.markMemberUnpaid(splitId, memberIndex);
    refresh();
  }
}

final splitNotifierProvider =
    StateNotifierProvider<SplitNotifier, List<SplitExpenseModel>>((ref) {
  return SplitNotifier();
});

final allSplitsProvider = Provider<List<SplitExpenseModel>>((ref) {
  return ref.watch(splitNotifierProvider);
});

final pendingSplitsProvider = Provider<List<SplitExpenseModel>>((ref) {
  return ref.watch(splitNotifierProvider)
      .where((s) => s.derivedStatus != SplitStatus.settled)
      .toList();
});

final totalSplitAmountProvider = Provider<double>((ref) {
  return ref.watch(allSplitsProvider)
      .fold(0.0, (s, e) => s + e.totalAmount);
});

final totalPendingAmountProvider = Provider<double>((ref) {
  return ref.watch(pendingSplitsProvider)
      .fold(0.0, (s, e) => s + e.pendingAmount);
});

final splitSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredSplitsProvider = Provider<List<SplitExpenseModel>>((ref) {
  final splits = ref.watch(allSplitsProvider);
  final query = ref.watch(splitSearchQueryProvider);
  if (query.isEmpty) return splits;
  final q = query.toLowerCase();
  return splits.where((s) {
    return s.description.toLowerCase().contains(q) ||
        (s.friendName?.toLowerCase().contains(q) ?? false) ||
        s.members.any((m) => m.name.toLowerCase().contains(q)) ||
        s.totalAmount.toString().contains(q);
  }).toList();
});
