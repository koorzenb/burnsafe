import 'package:hive_flutter/hive_flutter.dart';

import '../burn_status_repository.dart';
import '../models/burn_status.dart';
import '../storage/burn_status_adapter.dart';
import '../storage/burn_status_hive_repository.dart';
import '../storage/burn_status_type_adapter.dart';
import 'web_scraper_service.dart';

/// This class is responsible for handling the execution of background tasks.
/// It is completely decoupled from the UI.
class BackgroundTaskHandler {
  /// Fetches the current burn status and saves it to the repository.
  static Future<bool> fetchAndSaveStatus() async {
    Box<BurnStatus>? box;
    try {
      await Hive.initFlutter();

      // Register adapters if they aren't already.
      if (!Hive.isAdapterRegistered(BurnStatusAdapter().typeId)) {
        Hive.registerAdapter(BurnStatusAdapter());
      }
      if (!Hive.isAdapterRegistered(BurnStatusTypeAdapter().typeId)) {
        Hive.registerAdapter(BurnStatusTypeAdapter());
      }

      box = await Hive.openBox<BurnStatus>('burnStatusBox');
      final BurnStatusRepository repository = BurnStatusHiveRepository(box);

      print('Background Task: Fetching status from web...');
      final status = await WebScraperService.fetchBurnStatus();
      await repository.saveStatus(status);
      return true;
    } catch (e) {
      print('Background Task: Error during background fetch: $e');
      return false;
    } finally {
      // CRITICAL: Always close the box in the background task.
      // This releases the file lock, allowing the main UI to open it again.
      await box?.close();
    }
  }
}
