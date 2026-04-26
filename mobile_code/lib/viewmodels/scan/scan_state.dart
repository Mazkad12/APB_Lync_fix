import 'package:equatable/equatable.dart';

abstract class ScanState extends Equatable {
  const ScanState();

  @override
  List<Object?> get props => [];
}

class ScanInitial extends ScanState {}

class ScanInProgress extends ScanState {}

class ScanSuccess extends ScanState {
  final String scannedData;

  const ScanSuccess(this.scannedData);

  @override
  List<Object?> get props => [scannedData];
}

class ScanFailure extends ScanState {
  final String error;

  const ScanFailure(this.error);

  @override
  List<Object?> get props => [error];
}
