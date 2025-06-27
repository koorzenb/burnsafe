import 'package:flutter/material.dart';
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

  // Show persistent status in status bar
  static Future<void> showPersistentBurnStatus(BurnStatus status) async {
    Color statusColor = _getStatusColor(status.status);

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'burn_status_persistent',
      'Current Burn Status',
      channelDescription: 'Always shows current burn status',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      icon: '@drawable/burn_status_icon',
      color: statusColor,
    );

    await _notifications.show(
      1, // Different ID from alerts
      'Halifax County',
      status.status,
      NotificationDetails(android: androidDetails),
    );
  }

  // Show high-priority alerts for status changes
  static Future<void> showBurnStatusAlert(BurnStatus status, {bool isChange = false}) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'burn_status_alerts',
      'Burn Status Alerts',
      channelDescription: 'Important burn status updates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/alert_icon',
    );

    String title = isChange ? 'Burn Status Changed!' : 'Daily Burn Update';

    await _notifications.show(0, title, 'Halifax County: ${status.status}', const NotificationDetails(android: androidDetails));
  }

  static Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'no restrictions':
        return Colors.green;
      case 'restricted':
        return Colors.orange;
      case 'prohibited':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
