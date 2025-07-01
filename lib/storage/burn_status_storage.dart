import 'package:hive/hive.dart';

import '../models/burn_status.dart';

class BurnStatusStorage {
  static const _kStorageName = 'BurnStatusStorage';
  static BurnStatusStorage? _statusStorage;
  static late Box _staticBox;

  static Future<void> init() async => _staticBox = await Hive.openBox(_kStorageName);

  static Future<void> close() async => await _staticBox.close();

  static BurnStatusStorage get box {
    _statusStorage ??= BurnStatusStorage._(_staticBox);
    return _statusStorage!;
  }

  final Box _box;
  BurnStatusStorage._(this._box);

  Future<void> erase() async {
    await _box.deleteAll(_box.keys);
  }

  static const String _kLastBurnStatus = 'burnStatus';
  BurnStatus get lastBurnStatus => _box.get(
    _kLastBurnStatus,
    defaultValue: BurnStatus(statusType: BurnStatusType.unknown, lastUpdated: DateTime.now()),
  );
  set lastBurnStatus(BurnStatus value) => _box.put(_kLastBurnStatus, value);

  static const String _kStatusBarActive = 'statusBarActive';
  bool get statusBarActive => _box.get(_kStatusBarActive, defaultValue: false);
  set statusBarActive(bool value) => _box.put(_kStatusBarActive, value);
}
