# Finance Tracker

Мини-банковский финансовый трекер с аналитикой по месяцам и категориям. Flutter (Android, iOS), чистая архитектура.

## Стек

- **Flutter** 3.x, Dart 3
- **Состояние:** flutter_bloc
- **Навигация:** go_router
- **Локальное хранение:** shared_preferences
- **Уведомления:** flutter_local_notifications, Firebase Cloud Messaging
- **Логирование:** собственный AppLogger (core/logger)

## Структура проекта

```
lib/
├── main.dart              # Точка входа, инициализация сервисов
├── app.dart               # Корневой виджет, провайдеры, роутинг
├── core/
│   └── logger/            # AppLogger — структурированное логирование
├── data/
│   ├── api/               # Контракт API и mock-реализация
│   ├── local/             # Хранилище транзакций, сервис уведомлений
│   ├── models/            # DTO (category_dto, transaction_dto)
│   └── repositories/      # Реализации репозиториев
├── domain/
│   ├── entities/          # Сущности (Transaction, Category, MonthSummary)
│   ├── repositories/      # Контракты репозиториев
│   └── usecases/          # Сценарии (get_transactions, save_transaction и т.д.)
└── presentation/
    ├── bloc/              # TransactionsBloc (события, состояние)
    ├── providers/         # FiltersScope, SettingsScope
    ├── routing/           # GoRouter
    ├── settings/          # SettingsController
    ├── theme/             # AppTheme
    ├── ui/
    │   ├── screens/       # Экраны (dashboard, transactions, stats, settings…)
    │   └── widgets/       # Переиспользуемые виджеты
    └── utils/             # Форматтеры, диалоги
```

## Запуск

```bash
flutter pub get
flutter run
```

## Сборка

- **Android:** `flutter build apk` или `flutter build appbundle`
- **iOS:** `flutter build ios --no-codesign` (подпись в Xcode)

## CI

GitHub Actions: при push в `main`/`develop` выполняется **Flutter iOS Build** (macOS, `flutter build ios --debug --no-codesign`).  
Вкладка: **Actions** в репозитории.

## Тесты

```bash
flutter test
```

Сейчас: виджет-тест запуска приложения (dashboard, SharedPreferences mock).

## Основные функции

- Список операций (доходы/расходы), фильтр по месяцу и датам
- Баланс, доход и расход за период
- Статистика по категориям, диаграммы
- Локальные уведомления (лимит расходов, крупный расход, отрицательный баланс)
- Опционально: push по топику (FCM)
- Настройки: валюта, неон-тема, лимиты уведомлений

## Окружение

- Firebase (FCM) опционален: при ошибке инициализации приложение стартует без push.
- Для iOS push нужны: Push Notifications и Remote Notifications в Xcode, APNs key в Firebase Console.
