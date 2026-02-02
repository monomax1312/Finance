import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/transaction.dart';

class NotificationService {
  NotificationService({
    required SharedPreferences prefs,
    this.enablePlatform = true,
  }) : _prefs = prefs;

  final bool enablePlatform;
  final SharedPreferences _prefs;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static const channelId = 'finance_tracker';
  static const channelName = 'Finance Tracker';
  static const _lastDailyKey = 'notif_last_daily';
  static const _lastNegativeKey = 'notif_last_negative';

  Future<void> init() async {
    if (!enablePlatform) {
      return;
    }
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: android,
      iOS: darwin,
    );
    await _plugin.initialize(initSettings);
    await _createAndroidChannel();
  }

  Future<void> requestPermissions() async {
    if (!enablePlatform) {
      return;
    }
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await _requestAndroidPermission(android);
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      await ios.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<void> showTestNotification() async {
    if (!enablePlatform) {
      return;
    }
    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Уведомления о финансах',
      importance: Importance.high,
      priority: Priority.high,
    );
    const darwinDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );
    await _plugin.show(
      0,
      'Finance Tracker',
      'Тестовое уведомление — всё работает',
      details,
    );
  }

  Future<void> _requestAndroidPermission(
    AndroidFlutterLocalNotificationsPlugin android,
  ) async {
    try {
      await (android as dynamic).requestPermission();
    } catch (_) {
    }
  }

  Future<void> showRemoteMessage(RemoteMessage message) async {
    if (!enablePlatform) {
      return;
    }
    final title = message.notification?.title ?? 'Finance Tracker';
    final body = message.notification?.body ?? 'Новое уведомление';
    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Уведомления о финансах',
      importance: Importance.high,
      priority: Priority.high,
    );
    const darwinDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );
    await _plugin.show(message.hashCode, title, body, details);
  }

  Future<void> handleTransactionChange({
    required List<Transaction> transactions,
    required Transaction? changed,
    required bool notificationsEnabled,
    required String currencySymbol,
    required double dailyLimit,
    required double bigExpenseLimit,
    required bool notifyDailyLimit,
    required bool notifyBigExpense,
    required bool notifyNegativeBalance,
  }) async {
    if (!enablePlatform || !notificationsEnabled) {
      return;
    }

    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month}-${now.day}';

    if (notifyBigExpense &&
        changed != null &&
        changed.type == TransactionType.expense &&
        changed.amount >= bigExpenseLimit) {
      await _showLocal(
        title: 'Крупный расход',
        body:
            'Списание ${changed.amount.toStringAsFixed(0)} $currencySymbol',
      );
    }

    final dailyExpense = _sumByDate(
      transactions,
      now,
      TransactionType.expense,
    );
    final lastDaily = _prefs.getString(_lastDailyKey);
    if (notifyDailyLimit && dailyExpense >= dailyLimit && lastDaily != todayKey) {
      await _showLocal(
        title: 'Лимит расходов',
        body:
            'Сегодня уже ${dailyExpense.toStringAsFixed(0)} $currencySymbol',
      );
      await _prefs.setString(_lastDailyKey, todayKey);
    }

    final balance = _sumByType(transactions, TransactionType.income) -
        _sumByType(transactions, TransactionType.expense);
    final lastNegative = _prefs.getString(_lastNegativeKey);
    if (notifyNegativeBalance && balance < 0 && lastNegative != todayKey) {
      await _showLocal(
        title: 'Баланс ниже нуля',
        body: 'Текущий баланс ${balance.toStringAsFixed(0)} $currencySymbol',
      );
      await _prefs.setString(_lastNegativeKey, todayKey);
    }
  }

  Future<void> _createAndroidChannel() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelId,
        channelName,
        description: 'Уведомления о финансах',
        importance: Importance.high,
      ),
    );
  }

  Future<void> _showLocal({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Уведомления о финансах',
      importance: Importance.high,
      priority: Priority.high,
    );
    const darwinDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );
    await _plugin.show(DateTime.now().millisecond, title, body, details);
  }

  double _sumByType(List<Transaction> items, TransactionType type) {
    var total = 0.0;
    for (final item in items) {
      if (item.type == type) {
        total += item.amount;
      }
    }
    return total;
  }

  double _sumByDate(
    List<Transaction> items,
    DateTime date,
    TransactionType type,
  ) {
    var total = 0.0;
    for (final item in items) {
      final sameDay = item.date.year == date.year &&
          item.date.month == date.month &&
          item.date.day == date.day;
      if (sameDay && item.type == type) {
        total += item.amount;
      }
    }
    return total;
  }
}
