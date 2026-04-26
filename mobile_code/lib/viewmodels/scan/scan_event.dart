import 'package:equatable/equatable.dart';

abstract class ScanEvent extends Equatable {
  const ScanEvent();

  @override
  List<Object?> get props => [];
}

class StartScan extends ScanEvent {}

class ProcessScannedData extends ScanEvent {
  final String data;

  const ProcessScannedData(this.data);

  @override
  List<Object?> get props => [data];
}

class ResetScan extends ScanEvent {}
