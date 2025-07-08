import 'package:hive_flutter/hive_flutter.dart';

import '../burn_status_repository.dart';
import '../models/burn_status.dart';
import '../storage/burn_status_adapter.dart';
import '../storage/burn_status_hive_repository.dart';
import 'web_scraper_service.dart';

/// This class is responsible for handling the execution of background tasks.
/// It is completely decoupled from the UI.
class BackgroundTaskHandler {
  /// Fetches the current burn status and saves it to the repository.
  /// This method is designed to be called from a background isolate.
  static Future<bool> fetchAndSaveStatus() async {
    print('Background Task: Initializing Hive...');
    // Must initialize Hive and register adapters within the background isolate.
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(BurnStatusAdapter().typeId)) {
      Hive.registerAdapter(BurnStatusAdapter());
    }

    print('Background Task: Opening Box...');
    final box = await Hive.openBox<BurnStatus>('burnStatusBox');
    final BurnStatusRepository repository = BurnStatusHiveRepository(box);

    try {
      print('Background Task: Fetching status from web...'); // TODO: remove prints
      final status = await WebScraperService.fetchBurnStatus();
      print('Background Task: Saving status to repository...');
      await repository.saveStatus(status);
      print('Background Task: Successfully fetched and saved status.');
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
