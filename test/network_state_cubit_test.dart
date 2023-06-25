import 'package:aed_map/bloc/network_status/network_status_cubit.dart';
import 'package:aed_map/bloc/network_status/network_status_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('NetworkStateCubit', () {
    late NetworkStatusCubit networkStatusCubit;
    setUp(() {
      networkStatusCubit = NetworkStatusCubit();
    });

    test('initial state is NetworkStatusState(connected: true)', () {
      expect(
          networkStatusCubit.state, const NetworkStatusState(connected: true));
    });
  });
}
