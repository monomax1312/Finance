import 'package:flutter_test/flutter_test.dart';

import 'package:finance_tracker/app.dart';
import 'package:finance_tracker/data/api/mock_finance_api.dart';
import 'package:finance_tracker/data/local/transactions_storage.dart';
import 'package:finance_tracker/data/repositories/transactions_repository_impl.dart';
import 'package:finance_tracker/data/local/notification_service.dart';
import 'package:finance_tracker/presentation/providers/settings_scope.dart';
import 'package:finance_tracker/presentation/settings/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App launches dashboard', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final notificationService = NotificationService(
      prefs: prefs,
      enablePlatform: false,
    );
    final storage = TransactionsStorage(prefs);
    final api = MockFinanceApi(storage: storage);
    final repository = TransactionsRepositoryImpl(api: api);
    final settingsController = SettingsController(prefs, notificationService);
    await settingsController.load();

    await tester.pumpWidget(
      SettingsScope(
        controller: settingsController,
        child: App(
          repository: repository,
          notificationService: notificationService,
          settingsController: settingsController,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Баланс'), findsWidgets);
  });
}
