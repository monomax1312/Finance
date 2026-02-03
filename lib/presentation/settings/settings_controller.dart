import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/logger/app_logger.dart';
import '../../data/local/notification_service.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs, this._notifications);

  final SharedPreferences _prefs;
  final NotificationService _notifications;

  static const _currencyKey = 'settings_currency';
  static const _neonKey = 'settings_neon';
  static const _notificationsKey = 'settings_notifications';
  static const _dailyLimitKey = 'settings_daily_limit';
  static const _bigExpenseKey = 'settings_big_expense';
  static const _notifyDailyKey = 'settings_notify_daily';
  static const _notifyBigKey = 'settings_notify_big';
  static const _notifyNegativeKey = 'settings_notify_negative';
  static const _topicKey = 'settings_push_topic';

  String _currencySymbol = '₽';
  bool _neonEnabled = true;
  bool _notificationsEnabled = true;
  double _dailyLimit = 10000;
  double _bigExpenseLimit = 5000;
  bool _notifyDailyLimit = true;
  bool _notifyBigExpense = true;
  bool _notifyNegativeBalance = true;
  bool _pushTopicEnabled = false;

  String _draftCurrencySymbol = '₽';
  bool _draftNeonEnabled = true;
  bool _draftNotificationsEnabled = true;
  double _draftDailyLimit = 10000;
  double _draftBigExpenseLimit = 5000;
  bool _draftNotifyDailyLimit = true;
  bool _draftNotifyBigExpense = true;
  bool _draftNotifyNegativeBalance = true;
  bool _draftPushTopicEnabled = false;

  String get currencySymbol => _currencySymbol;
  bool get neonEnabled => _neonEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  double get dailyLimit => _dailyLimit;
  double get bigExpenseLimit => _bigExpenseLimit;
  bool get notifyDailyLimit => _notifyDailyLimit;
  bool get notifyBigExpense => _notifyBigExpense;
  bool get notifyNegativeBalance => _notifyNegativeBalance;
  bool get pushTopicEnabled => _pushTopicEnabled;

  String get draftCurrencySymbol => _draftCurrencySymbol;
  bool get draftNeonEnabled => _draftNeonEnabled;
  bool get draftNotificationsEnabled => _draftNotificationsEnabled;
  double get draftDailyLimit => _draftDailyLimit;
  double get draftBigExpenseLimit => _draftBigExpenseLimit;
  bool get draftNotifyDailyLimit => _draftNotifyDailyLimit;
  bool get draftNotifyBigExpense => _draftNotifyBigExpense;
  bool get draftNotifyNegativeBalance => _draftNotifyNegativeBalance;
  bool get draftPushTopicEnabled => _draftPushTopicEnabled;

  bool get hasChanges =>
      _currencySymbol != _draftCurrencySymbol ||
      _neonEnabled != _draftNeonEnabled ||
      _notificationsEnabled != _draftNotificationsEnabled ||
      _dailyLimit != _draftDailyLimit ||
      _bigExpenseLimit != _draftBigExpenseLimit ||
      _notifyDailyLimit != _draftNotifyDailyLimit ||
      _notifyBigExpense != _draftNotifyBigExpense ||
      _notifyNegativeBalance != _draftNotifyNegativeBalance ||
      _pushTopicEnabled != _draftPushTopicEnabled;

  Future<void> load() async {
    _currencySymbol = _prefs.getString(_currencyKey) ?? '₽';
    _neonEnabled = _prefs.getBool(_neonKey) ?? true;
    _notificationsEnabled = _prefs.getBool(_notificationsKey) ?? true;
    _dailyLimit = _prefs.getDouble(_dailyLimitKey) ?? 10000;
    _bigExpenseLimit = _prefs.getDouble(_bigExpenseKey) ?? 5000;
    _notifyDailyLimit = _prefs.getBool(_notifyDailyKey) ?? true;
    _notifyBigExpense = _prefs.getBool(_notifyBigKey) ?? true;
    _notifyNegativeBalance = _prefs.getBool(_notifyNegativeKey) ?? true;
    _pushTopicEnabled = _prefs.getBool(_topicKey) ?? false;
    _draftCurrencySymbol = _currencySymbol;
    _draftNeonEnabled = _neonEnabled;
    _draftNotificationsEnabled = _notificationsEnabled;
    _draftDailyLimit = _dailyLimit;
    _draftBigExpenseLimit = _bigExpenseLimit;
    _draftNotifyDailyLimit = _notifyDailyLimit;
    _draftNotifyBigExpense = _notifyBigExpense;
    _draftNotifyNegativeBalance = _notifyNegativeBalance;
    _draftPushTopicEnabled = _pushTopicEnabled;
    notifyListeners();
  }

  void setCurrency(String value) {
    _draftCurrencySymbol = value;
    notifyListeners();
  }

  void setNeonEnabled(bool value) {
    _draftNeonEnabled = value;
    notifyListeners();
  }

  void setNotificationsEnabled(bool value) {
    _draftNotificationsEnabled = value;
    notifyListeners();
  }

  void setDailyLimit(double value) {
    _draftDailyLimit = value;
    notifyListeners();
  }

  void setBigExpenseLimit(double value) {
    _draftBigExpenseLimit = value;
    notifyListeners();
  }

  void setNotifyDailyLimit(bool value) {
    _draftNotifyDailyLimit = value;
    notifyListeners();
  }

  void setNotifyBigExpense(bool value) {
    _draftNotifyBigExpense = value;
    notifyListeners();
  }

  void setNotifyNegativeBalance(bool value) {
    _draftNotifyNegativeBalance = value;
    notifyListeners();
  }

  void setPushTopicEnabled(bool value) {
    _draftPushTopicEnabled = value;
    notifyListeners();
  }

  Future<void> save() async {
    final prevNotifications = _notificationsEnabled;
    final prevTopic = _pushTopicEnabled;

    _currencySymbol = _draftCurrencySymbol;
    _neonEnabled = _draftNeonEnabled;
    _notificationsEnabled = _draftNotificationsEnabled;
    _dailyLimit = _draftDailyLimit;
    _bigExpenseLimit = _draftBigExpenseLimit;
    _notifyDailyLimit = _draftNotifyDailyLimit;
    _notifyBigExpense = _draftNotifyBigExpense;
    _notifyNegativeBalance = _draftNotifyNegativeBalance;
    _pushTopicEnabled = _draftPushTopicEnabled;

    await _prefs.setString(_currencyKey, _currencySymbol);
    await _prefs.setBool(_neonKey, _neonEnabled);
    await _prefs.setBool(_notificationsKey, _notificationsEnabled);
    await _prefs.setDouble(_dailyLimitKey, _dailyLimit);
    await _prefs.setDouble(_bigExpenseKey, _bigExpenseLimit);
    await _prefs.setBool(_notifyDailyKey, _notifyDailyLimit);
    await _prefs.setBool(_notifyBigKey, _notifyBigExpense);
    await _prefs.setBool(_notifyNegativeKey, _notifyNegativeBalance);
    await _prefs.setBool(_topicKey, _pushTopicEnabled);

    if (!prevNotifications && _notificationsEnabled) {
      try {
        await FirebaseMessaging.instance.requestPermission();
        await _notifications.requestPermissions();
        await _notifications.showTestNotification();
        AppLogger.info('Notifications enabled and permissions requested', tag: 'Settings');
      } catch (e, st) {
        AppLogger.warning(
          'Failed to enable notifications - Push/APNs may not be configured',
          tag: 'Settings',
          error: e,
          stackTrace: st,
        );
      }
    }

    if (prevTopic != _pushTopicEnabled) {
      try {
        if (_pushTopicEnabled) {
          await FirebaseMessaging.instance.subscribeToTopic('finance_alerts');
          AppLogger.info('Subscribed to push topic: finance_alerts', tag: 'Settings');
        } else {
          await FirebaseMessaging.instance.unsubscribeFromTopic('finance_alerts');
          AppLogger.info('Unsubscribed from push topic: finance_alerts', tag: 'Settings');
        }
      } catch (e, st) {
        AppLogger.warning(
          'Failed to manage push topic - FCM token may be unavailable',
          tag: 'Settings',
          error: e,
          stackTrace: st,
        );
      }
    }

    notifyListeners();
  }

  Future<void> sendTestNotification() async {
    try {
      await _notifications.requestPermissions();
      await _notifications.showTestNotification();
      AppLogger.debug('Test notification sent', tag: 'Settings');
    } catch (e, st) {
      AppLogger.error(
        'Failed to send test notification',
        tag: 'Settings',
        error: e,
        stackTrace: st,
      );
    }
  }
}
