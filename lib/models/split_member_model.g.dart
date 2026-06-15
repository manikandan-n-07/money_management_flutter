// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_member_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SplitMemberModelAdapter extends TypeAdapter<SplitMemberModel> {
  @override
  final int typeId = 1;

  @override
  SplitMemberModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SplitMemberModel(
      name: fields[0] as String,
      shareAmount: fields[1] as double,
      isPaid: fields[2] as bool,
      paidAt: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SplitMemberModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.shareAmount)
      ..writeByte(2)
      ..write(obj.isPaid)
      ..writeByte(3)
      ..write(obj.paidAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplitMemberModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
