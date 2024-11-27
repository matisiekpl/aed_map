import 'package:aed_map/models/trip.dart';
import 'package:equatable/equatable.dart';

class RoutingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RoutingReady extends RoutingState {}

class RoutingCalculatingInProgress extends RoutingState {}

class RoutingSuccess extends RoutingState {
  final Trip trip;

  RoutingSuccess({
    required this.trip,
  });
}
