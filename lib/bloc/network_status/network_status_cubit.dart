import 'dart:async';

import 'package:aed_map/bloc/network_status/ticker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'network_status_state.dart';

class NetworkStatusCubit extends Cubit<NetworkStatusState> {
  NetworkStatusCubit() : super(const NetworkStatusState(connected: true)) {
    _tickerSubscription = _ticker.tick(ticks: 5).listen((duration) async {
      ping();
    });
  }

  final Ticker _ticker = const Ticker();
  StreamSubscription<int>? _tickerSubscription;

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  Future ping() async => emit(NetworkStatusState(connected: await check()));

  Future<bool> check() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }
}
