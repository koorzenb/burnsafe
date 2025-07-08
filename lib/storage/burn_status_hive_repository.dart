import 'dart:async';

import 'package:hive/hive.dart';

import '../burn_status_repository.dart';
import '../models/burn_status.dart';

/// GoF Adapter Pattern: Adapts the Hive Box interface to the BurnStatusRepository interface.
class BurnStatusHiveRepository implements BurnStatusRepository {
  final Box<BurnStatus> _box;
  final _controller = StreamController<BurnStatus?>.broadcast();
  static const String _statusKey = 'burnStatus';

  BurnStatusHiveRepository(this._box) {
    // Listen to changes in the Hive box and add them to our stream
    _box.watch(key: _statusKey).listen((event) {
      // event.value can be the object or null if it was deleted.
      _controller.add(event.value as BurnStatus?);
    });
  }

  @override
  Future<BurnStatus?> getStatus() async {
    return _box.get(_statusKey);
  }

  @override
  Future<void> saveStatus(BurnStatus status) async {
    await _box.put(_statusKey, status);
    // Manually trigger an update on the stream after saving,
    // as the watch stream only fires on *changes* from other isolates or processes.
    _controller.add(status);
  }

  @override
  Stream<BurnStatus> watchStatus() {
    final stream = _controller.stream;

    final currentStatus = _box.get(_statusKey);
    if (currentStatus != null) {
      return stream.where((status) => status != null).cast<BurnStatus>().newStreamWithInitialValue(currentStatus);
    }

    return stream.where((status) => status != null).cast<BurnStatus>();
  }

  /// Call this method to clean up resources when the repository is no longer needed.
  void dispose() {
    _controller.close();
  }
}

extension StreamExtensions<T> on Stream<T> {
  Stream<T> newStreamWithInitialValue(T initialValue) {
    return Stream.multi((controller) {
      controller.add(initialValue);
      listen(
        (value) {
          controller.add(value);
        },
        onDone: () {
          controller.close();
        },
        onError: (error, stackTrace) {
          controller.addError(error, stackTrace);
        },
      );
    });
  }
}
