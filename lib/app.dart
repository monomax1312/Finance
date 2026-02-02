import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'domain/repositories/transactions_repository.dart';
import 'presentation/bloc/transactions_bloc.dart';
import 'presentation/bloc/transactions_event.dart';
import 'presentation/providers/filters_scope.dart';
import 'presentation/providers/settings_scope.dart';
import 'presentation/routing/app_router.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/ui/widgets/neon_background.dart';
import 'data/local/notification_service.dart';
import 'presentation/settings/settings_controller.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    required this.repository,
    required this.notificationService,
    required this.settingsController,
  });

  final TransactionsRepository repository;
  final NotificationService notificationService;
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.createRouter();

    return FiltersScope(
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<TransactionsRepository>.value(value: repository),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) =>
                  TransactionsBloc(
                    repository: repository,
                    notificationService: notificationService,
                    settingsController: settingsController,
                  )
                    ..add(const TransactionsRequested()),
            ),
          ],
          child: MaterialApp.router(
            title: 'Finance Tracker',
            theme: AppTheme.dark(),
            locale: const Locale('ru'),
            supportedLocales: const [Locale('ru')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: router,
            builder: (context, child) {
              final settings = SettingsScope.of(context);
              return NeonBackground(
                enabled: settings.neonEnabled,
                child: child ?? const SizedBox.shrink(),
              );
            },
          ),
        ),
      ),
    );
  }
}
