import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/burn_status.dart';
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

  // Show persistent status in status bar
  static Future<void> showPersistentBurnStatus(BurnStatus status) async {
    Color statusColor = _getStatusColor(status.statusType);

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

  /// Shows a notification specifically when burning becomes allowed.
  static Future<void> showBurningAllowedNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'burn_allowed_channel',
      'Burning Allowed Alerts',
      channelDescription: 'Notifications for when burn status changes to allowed.',
      importance: Importance.low,
      priority: Priority.low,
      icon: 'burn_status_icon',
    );

    );

    await _notifications.show(
      0, // Use a different ID to avoid conflicts
      'Burning Now Allowed',
      'The burn status for Halifax County has changed. You may now burn.',
      const NotificationDetails(android: androidDetails),
    );
  }

  static Color _getStatusColor(BurnStatusType statusType) {
    switch (statusType) {
      case BurnStatusType.burn:
        return Colors.green;
      case BurnStatusType.restricted:
        return Colors.orange;
      case BurnStatusType.noBurn:
        return Colors.red;
      case BurnStatusType.unknown:
        return Colors.grey;
    }
  }
}
