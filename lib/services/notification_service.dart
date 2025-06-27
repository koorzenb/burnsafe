import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/burn_status.dart';

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

    await _notifications.initialize(settings);
    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    await Permission.notification.request();
  }

  static Future<void> showBurnStatusNotification(BurnStatus status) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'burn_status_channel',
      'Burn Status Updates',
      channelDescription: 'Daily burn status notifications for Halifax County',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);

    const NotificationDetails details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(0, 'Halifax County Burn Status', 'Current status: ${status.status}', details);
  }
}
