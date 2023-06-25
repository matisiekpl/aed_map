import 'package:equatable/equatable.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../models/aed.dart';

class PointsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PointsLoadInProgress extends PointsState {}

class PointsLoadSuccess extends PointsState {
  final List<AED> aeds;
  final AED selected;
  final List<Marker> markers;
  final String hash;

  @override
  List<Object?> get props => [aeds, selected, markers, hash];

  PointsLoadSuccess({
    required this.aeds,
    required this.selected,
    required this.markers,
    required this.hash,
  });

  PointsLoadSuccess copyWith({
    List<AED>? aeds,
    AED? selected,
    List<Marker>? markers,
    String? hash,
  }) {
    return PointsLoadSuccess(
      aeds: aeds ?? this.aeds,
      selected: selected ?? this.selected,
      markers: markers ?? this.markers,
      hash: hash ?? this.hash,
    );
  }
}
