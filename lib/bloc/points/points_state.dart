import 'package:aed_map/models/aed.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_map/flutter_map.dart';

class PointsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PointsLoadInProgress extends PointsState {}

class PointsLoadSuccess extends PointsState {
  final List<Defibrillator> defibrillators;
  final int defibrillatorsCount;
  final Defibrillator selected;
  final List<Marker> markers;
  final String hash;
  final DateTime lastUpdateTime;
  final bool refreshing;
  final Set<int> pendingIds;

  @override
  List<Object?> get props => [
        defibrillators,
        defibrillatorsCount,
        selected,
        markers,
        hash,
        lastUpdateTime,
        refreshing,
        pendingIds
      ];

  PointsLoadSuccess({
    required this.defibrillators,
    required this.defibrillatorsCount,
    required this.selected,
    required this.markers,
    required this.hash,
    required this.lastUpdateTime,
    required this.refreshing,
    this.pendingIds = const {},
  });

  PointsLoadSuccess copyWith({
    List<Defibrillator>? defibrillators,
    int? defibrillatorsCount,
    Defibrillator? selected,
    List<Marker>? markers,
    String? hash,
    DateTime? lastUpdateTime,
    bool? refreshing,
    Set<int>? pendingIds,
  }) {
    return PointsLoadSuccess(
      defibrillators: defibrillators ?? this.defibrillators,
      defibrillatorsCount: defibrillatorsCount ?? this.defibrillatorsCount,
      selected: selected ?? this.selected,
      markers: markers ?? this.markers,
      hash: hash ?? this.hash,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      refreshing: refreshing ?? this.refreshing,
      pendingIds: pendingIds ?? this.pendingIds,
    );
  }
}
