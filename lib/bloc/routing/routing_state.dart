import 'package:equatable/equatable.dart';

import '../../models/trip.dart';

class RoutingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RoutingStateNotShowing extends RoutingState {}

class RoutingStateCalculating extends RoutingState {}

class RoutingStateShowing extends RoutingState {
  final Trip trip;

  RoutingStateShowing({
    required this.trip,
  });
}
