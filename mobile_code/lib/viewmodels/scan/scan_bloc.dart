import 'package:flutter_bloc/flutter_bloc.dart';
import 'scan_event.dart';
import 'scan_state.dart';

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  ScanBloc() : super(ScanInitial()) {
    on<StartScan>((event, emit) => emit(ScanInProgress()));
    on<ProcessScannedData>((event, emit) {
      if (event.data.isNotEmpty) {
        emit(ScanSuccess(event.data));
      } else {
        emit(const ScanFailure("Invalid QR Data"));
      }
    });
    on<ResetScan>((event, emit) => emit(ScanInitial()));
  }
}
