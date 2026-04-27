import 'package:equatable/equatable.dart';
import '../../models/history_model.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadHistory extends HistoryEvent {
  final String? userId;
  final bool isGuest;

  const LoadHistory({this.userId, required this.isGuest});

  @override
  List<Object?> get props => [userId, isGuest];
}

class AddHistory extends HistoryEvent {
  final HistoryModel history;
  final String? userId;
  final bool isGuest;

  const AddHistory(this.history, {this.userId, required this.isGuest});

  @override
  List<Object?> get props => [history, userId, isGuest];
}

class DeleteHistory extends HistoryEvent {
  final String id;
  final String? userId;
  final bool isGuest;

  const DeleteHistory(this.id, {this.userId, required this.isGuest});

  @override
  List<Object?> get props => [id, userId, isGuest];
}

class UpdateHistoryTitle extends HistoryEvent {
  final String id;
  final String newTitle;
  final String? userId;
  final bool isGuest;

  const UpdateHistoryTitle(this.id, this.newTitle, {this.userId, required this.isGuest});

  @override
  List<Object?> get props => [id, newTitle, userId, isGuest];
}

class ClearGuestHistory extends HistoryEvent {}
