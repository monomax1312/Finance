import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/logger/app_logger.dart';
import '../../data/local/notification_service.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transactions_repository.dart';
import '../settings/settings_controller.dart';
import 'transactions_event.dart';
import 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  TransactionsBloc({
    required this.repository,
    required this.notificationService,
    required this.settingsController,
  }) : super(const TransactionsState()) {
    on<TransactionsRequested>(_onRequested);
    on<TransactionAdded>(_onAdded);
    on<TransactionUpdated>(_onUpdated);
    on<TransactionDeleted>(_onDeleted);
    on<TransactionsCleared>(_onCleared);
  }

  final TransactionsRepository repository;
  final NotificationService notificationService;
  final SettingsController settingsController;

  Future<void> _onRequested(
    TransactionsRequested event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final transactions = await repository.getTransactions();
      final categories = await repository.getCategories();
      emit(
        state.copyWith(
          isLoading: false,
          transactions: transactions,
          categories: categories,
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to load transactions',
        tag: 'TransactionsBloc',
        error: error,
        stackTrace: stackTrace,
      );
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Не удалось загрузить данные',
        ),
      );
    }
  }

  Future<void> _onAdded(
    TransactionAdded event,
    Emitter<TransactionsState> emit,
  ) async {
    try {
      final created = await repository.addTransaction(event.draft);
      final updatedList = [created, ...state.transactions];
      emit(
        state.copyWith(
          transactions: updatedList,
        ),
      );
      await _notifyIfNeeded(updatedList, created);
      AppLogger.info('Transaction added: ${created.id}', tag: 'TransactionsBloc');
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to add transaction',
        tag: 'TransactionsBloc',
        error: error,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(errorMessage: 'Не удалось добавить операцию'));
    }
  }

  Future<void> _onUpdated(
    TransactionUpdated event,
    Emitter<TransactionsState> emit,
  ) async {
    try {
      final updated = await repository.updateTransaction(event.transaction);
      final updatedList = state.transactions
          .map((item) => item.id == updated.id ? updated : item)
          .toList(growable: false);
      emit(state.copyWith(transactions: updatedList));
      await _notifyIfNeeded(updatedList, updated);
      AppLogger.info('Transaction updated: ${updated.id}', tag: 'TransactionsBloc');
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to update transaction',
        tag: 'TransactionsBloc',
        error: error,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(errorMessage: 'Не удалось обновить операцию'));
    }
  }

  Future<void> _onDeleted(
    TransactionDeleted event,
    Emitter<TransactionsState> emit,
  ) async {
    try {
      await repository.deleteTransaction(event.id);
      final updatedList = state.transactions
          .where((item) => item.id != event.id)
          .toList(growable: false);
      emit(state.copyWith(transactions: updatedList));
      await _notifyIfNeeded(updatedList, null);
      AppLogger.info('Transaction deleted: ${event.id}', tag: 'TransactionsBloc');
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to delete transaction',
        tag: 'TransactionsBloc',
        error: error,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(errorMessage: 'Не удалось удалить операцию'));
    }
  }

  Future<void> _onCleared(
    TransactionsCleared event,
    Emitter<TransactionsState> emit,
  ) async {
    try {
      await repository.clearTransactions();
      emit(state.copyWith(transactions: const []));
      AppLogger.info('All transactions cleared', tag: 'TransactionsBloc');
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to clear transactions',
        tag: 'TransactionsBloc',
        error: error,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(errorMessage: 'Не удалось очистить данные'));
    }
  }

  Future<void> _notifyIfNeeded(
    List<Transaction> transactions,
    Transaction? changed,
  ) async {
    await notificationService.handleTransactionChange(
      transactions: transactions,
      changed: changed,
      notificationsEnabled: settingsController.notificationsEnabled,
      currencySymbol: settingsController.currencySymbol,
      dailyLimit: settingsController.dailyLimit,
      bigExpenseLimit: settingsController.bigExpenseLimit,
      notifyDailyLimit: settingsController.notifyDailyLimit,
      notifyBigExpense: settingsController.notifyBigExpense,
      notifyNegativeBalance: settingsController.notifyNegativeBalance,
    );
  }
}
