import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import 'status_bar_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(settings, onDidReceiveNotificationResponse: _onNotificationResponse);
    await _requestPermissions();
  }

  static Future<void> _onNotificationResponse(NotificationResponse response) async {
    if (response.actionId == 'dismiss_action' || response.notificationResponseType == NotificationResponseType.selectedNotification) {
      // Clear status bar when notification is dismissed
      await StatusBarService.clearStatusBar();
    }
  }

  static FlutterLocalNotificationsPlugin get notifications => _notifications;

  static Future<void> _requestPermissions() async {
    await Permission.notification.request();
  }

  /// Shows a notification specifically when burning becomes allowed.
  static Future<void> showBurningAllowedNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'burn_allowed_channel',
      'Burning Allowed Alerts',
      channelDescription: 'Notifications for when burn status changes to allowed.',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: 'burn_status_icon',
      sound: RawResourceAndroidNotificationSound('fire'),
      playSound: true,
      ongoing: false, // User can dismiss by swiping
      autoCancel: true, // Dismisses when tapped
    );

    await _notifications.show(
      0,
      'Burning Now Allowed',
      'The burn status for Halifax County has changed. You may now burn.',
      const NotificationDetails(android: androidDetails),
    );
  }
}
