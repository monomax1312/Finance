import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/api/mock_finance_api.dart';
import 'data/local/notification_service.dart';
import 'data/local/transactions_storage.dart';
import 'data/repositories/transactions_repository_impl.dart';
import 'presentation/providers/settings_scope.dart';
import 'presentation/settings/settings_controller.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru');

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  final prefs = await SharedPreferences.getInstance();
  final notificationService = NotificationService(prefs: prefs);
  await notificationService.init();
  final storage = TransactionsStorage(prefs);
  final api = MockFinanceApi(storage: storage);
  final repository = TransactionsRepositoryImpl(api: api);
  FirebaseMessaging.onMessage.listen(notificationService.showRemoteMessage);
  final settingsController = SettingsController(prefs, notificationService);
  await settingsController.load();

  runApp(
    SettingsScope(
      controller: settingsController,
      child: App(
        repository: repository,
        notificationService: notificationService,
        settingsController: settingsController,
      ),
    ),
  );
}
