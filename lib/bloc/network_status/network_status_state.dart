import 'package:equatable/equatable.dart';

class NetworkStatusState extends Equatable {
  const NetworkStatusState({required this.connected});

  final bool connected;

  @override
  List<Object> get props => [connected];
}