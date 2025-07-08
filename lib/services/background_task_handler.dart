import 'package:hive_flutter/hive_flutter.dart';

import '../burn_status_repository.dart';
import '../models/burn_status.dart';
import '../storage/burn_status_adapter.dart';
import '../storage/burn_status_hive_repository.dart';
import '../storage/burn_status_type_adapter.dart';
import 'notification_service.dart';
import 'status_bar_service.dart';
import 'web_scraper_service.dart';

/// This class is responsible for handling the execution of background tasks.
/// It is completely decoupled from the UI.
class BackgroundTaskHandler {
  /// This method is designed to be called from a background isolate.
  static Future<bool> fetchAndSaveStatus() async {
    await Hive.initFlutter();
    await NotificationService.initialize();

    if (!Hive.isAdapterRegistered(BurnStatusAdapter().typeId)) {
      Hive.registerAdapter(BurnStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(BurnStatusTypeAdapter().typeId)) {
      Hive.registerAdapter(BurnStatusTypeAdapter());
    }

    final box = await Hive.openBox<BurnStatus>('burnStatusBox');
    final BurnStatusRepository repository = BurnStatusHiveRepository(box);

    BurnStatus? previousStatus;
    try {
      previousStatus = await repository.getStatus();
      print('Background Task: Fetching status from web...');
      final newStatus = await WebScraperService.fetchBurnStatus();
      await repository.saveStatus(newStatus);
      print('Background Task: Updating status bar notification...');
      await StatusBarService.updateStatusBar(newStatus, previousStatus);
      return true;
    } catch (e) {
      print('Background Task: Error fetching status: $e');
      return false;
    } finally {
      await box.close();
      print('Background Task: Box closed.');
    }
  }
}
