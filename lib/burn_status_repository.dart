// The contract (Interface)
import 'package:burnsafe/models/burn_status.dart';

abstract class BurnStatusRepository {
  Future<void> saveStatus(BurnStatus status);
  Future<BurnStatus?> getStatus();
  Stream<BurnStatus> watchStatus(); // GoF Observer Pattern
}
