import 'dart:async';

import 'package:aed_map/bloc/network_status/ticker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'network_status_state.dart';

class NetworkStatusCubit extends Cubit<NetworkStatusState> {
  NetworkStatusCubit() : super(const NetworkStatusState(connected: true)) {
    _tickerSubscription =
        const Ticker().tick(seconds: 1).listen((duration) async {
      ping();
    });
  }

  StreamSubscription<int>? _tickerSubscription;

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  Future ping() async => emit(NetworkStatusState(connected: await check()));

  Future<bool> check() async {
    try {
      await http.get(Uri.parse(
          'https://aed.openstreetmap.org.pl/aed_poland.geojson_test'));
      return true;
    } catch (_) {
      return false;
    }
  }
}
