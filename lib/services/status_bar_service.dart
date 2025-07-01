import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/burn_status.dart';
import '../storage/burn_status_storage.dart';
import 'notification_service.dart';

class StatusBarService {
  static const int _persistentNotificationId = 100;
  static const int _alertNotificationId = 200;
  static const String statusBarActiveKey = 'statusBarActive';

  static Future<void> updateStatusBar(BurnStatus status, BurnStatus? previousStatus) async {
    // Always update persistent status
    await _showPersistentStatus(status);

    // Show alert if status changed or it's the daily update
    if (previousStatus == null || previousStatus.statusType != status.statusType) {
      await _showStatusAlert(status, isChange: previousStatus != null);
    } else {
      // Daily update - show regular alert
      await _showStatusAlert(status, isChange: false);
    }
  }

  static Future<void> _showPersistentStatus(BurnStatus status) async {
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
      category: AndroidNotificationCategory.status,
    );

    await NotificationService.notifications.show(
      _persistentNotificationId,
      'Halifax County',
      'Burn Status: ${status.status}',
      NotificationDetails(android: androidDetails),
    );

    // Mark status bar as active
    BurnStatusStorage.box.statusBarActive = true;
  }

  static Future<void> _showStatusAlert(BurnStatus status, {required bool isChange}) async {
    Color statusColor = _getStatusColor(status.statusType);
    String title = isChange ? 'Burn Status Changed!' : 'Daily Burn Update';
    String body = 'Halifax County: ${status.status}';

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'burn_status_alerts',
      'Burn Status Alerts',
      channelDescription: 'Important burn status updates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@drawable/alert_icon',
      color: statusColor,
      autoCancel: true,
      showWhen: true,
      when: DateTime.now().millisecondsSinceEpoch,
      category: AndroidNotificationCategory.alarm,
      // actions: [AndroidNotificationAction('dismiss_action', 'Dismiss', cancelNotification: true)],
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'burn_status_category',
    );

    await NotificationService.notifications.show(_alertNotificationId, title, body, NotificationDetails(android: androidDetails, iOS: iosDetails));
  }

  static Future<void> clearStatusBar() async {
    await NotificationService.notifications.cancel(_persistentNotificationId);
    await NotificationService.notifications.cancel(_alertNotificationId);

    BurnStatusStorage.box.statusBarActive = false;
  }

  static Future<void> clearAlertOnly() async {
    await NotificationService.notifications.cancel(_alertNotificationId);
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
