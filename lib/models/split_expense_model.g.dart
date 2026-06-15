// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_expense_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SplitExpenseModelAdapter extends TypeAdapter<SplitExpenseModel> {
  @override
  final int typeId = 4;

  @override
  SplitExpenseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SplitExpenseModel(
      id: fields[0] as String,
      payer: fields[1] as PayerType,
      friendName: fields[2] as String?,
      totalAmount: fields[3] as double,
      description: fields[4] as String,
      dateTime: fields[5] as DateTime,
      members: (fields[6] as List).cast<SplitMemberModel>(),
      status: fields[7] as SplitStatus,
      isEqualSplit: fields[8] as bool,
      currency: fields[9] as String,
      currencyCode: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SplitExpenseModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.payer)
      ..writeByte(2)
      ..write(obj.friendName)
      ..writeByte(3)
      ..write(obj.totalAmount)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.dateTime)
      ..writeByte(6)
      ..write(obj.members)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.isEqualSplit)
      ..writeByte(9)
      ..write(obj.currency)
      ..writeByte(10)
      ..write(obj.currencyCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplitExpenseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SplitStatusAdapter extends TypeAdapter<SplitStatus> {
  @override
  final int typeId = 2;

  @override
  SplitStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SplitStatus.pending;
      case 1:
        return SplitStatus.partiallyPaid;
      case 2:
        return SplitStatus.settled;
      default:
        return SplitStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, SplitStatus obj) {
    switch (obj) {
      case SplitStatus.pending:
        writer.writeByte(0);
        break;
      case SplitStatus.partiallyPaid:
        writer.writeByte(1);
        break;
      case SplitStatus.settled:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplitStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PayerTypeAdapter extends TypeAdapter<PayerType> {
  @override
  final int typeId = 3;

  @override
  PayerType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PayerType.me;
      case 1:
        return PayerType.friend;
      default:
        return PayerType.me;
    }
  }

  @override
  void write(BinaryWriter writer, PayerType obj) {
    switch (obj) {
      case PayerType.me:
        writer.writeByte(0);
        break;
      case PayerType.friend:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PayerTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
