import 'package:equatable/equatable.dart';

import '../../models/aed.dart';

class PointsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PointsStateLoading extends PointsState {}

class PointsStateLoaded extends PointsState {
  final List<AED> aeds;
  final AED selected;

  @override
  List<Object?> get props => [aeds, selected];

  PointsStateLoaded({
    required this.aeds,
    required this.selected,
  });

  PointsStateLoaded copyWith({
    List<AED>? aeds,
    AED? selected,
  }) {
    return PointsStateLoaded(
      aeds: aeds ?? this.aeds,
      selected: selected ?? this.selected,
    );
  }
}
