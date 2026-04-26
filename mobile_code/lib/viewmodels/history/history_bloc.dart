import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/history_repository.dart';
import '../../models/history_model.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HistoryRepository historyRepository;

  HistoryBloc({required this.historyRepository}) : super(HistoryInitial()) {
    on<LoadHistory>(_onLoadHistory);
    on<AddHistory>(_onAddHistory);
    on<DeleteHistory>(_onDeleteHistory);
    on<UpdateHistoryTitle>(_onUpdateHistoryTitle);
  }

  Future<void> _onLoadHistory(LoadHistory event, Emitter<HistoryState> emit) async {
    emit(HistoryLoading());
    await emit.forEach<List<HistoryModel>>(
      historyRepository.getHistories(event.userId, isGuest: event.isGuest),
      onData: (histories) => HistoryLoaded(histories),
      onError: (error, stackTrace) => HistoryError(error.toString()),
    );
  }

  Future<void> _onAddHistory(AddHistory event, Emitter<HistoryState> emit) async {
    try {
      await historyRepository.addHistory(event.history, isGuest: event.isGuest);
    } catch (e) {
      // Ignore or log error
    }
  }

  Future<void> _onDeleteHistory(DeleteHistory event, Emitter<HistoryState> emit) async {
    try {
      await historyRepository.deleteHistory(event.id, event.userId, isGuest: event.isGuest);
    } catch (e) {
      // Ignore or log error
    }
  }

  Future<void> _onUpdateHistoryTitle(UpdateHistoryTitle event, Emitter<HistoryState> emit) async {
    try {
      await historyRepository.updateHistoryTitle(event.id, event.userId, event.newTitle, isGuest: event.isGuest);
    } catch (e) {
      // Ignore or log error
    }
  }
}
