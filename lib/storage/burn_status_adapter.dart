import 'package:hive_flutter/hive_flutter.dart';

import '../models/burn_status.dart';

class BurnStatusAdapter extends TypeAdapter<BurnStatus> {
  @override
  final int typeId = 0;

  @override
  BurnStatus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return BurnStatus(statusType: fields[0] as BurnStatusType, lastUpdated: fields[1] as DateTime);
  }

  @override
  void write(BinaryWriter writer, BurnStatus obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.statusType)
      ..writeByte(1)
      ..write(obj.lastUpdated);
  }
}
