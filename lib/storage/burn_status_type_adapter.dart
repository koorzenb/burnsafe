import 'package:hive_flutter/hive_flutter.dart';

import '../models/burn_status.dart';

class BurnStatusTypeAdapter extends TypeAdapter<BurnStatusType> {
  @override
  final int typeId = 1;

  @override
  BurnStatusType read(BinaryReader reader) {
    return BurnStatusType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, BurnStatusType obj) {
    writer.writeByte(obj.index);
  }
}
