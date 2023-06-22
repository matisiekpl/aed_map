import 'package:equatable/equatable.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

class MapStyleState extends Equatable {
  final Style? style;

  MapStyleState({this.style});

  MapStyleState copyWith({
    Style? style,
  }) {
    return MapStyleState(
      style: style ?? this.style,
    );
  }

  @override
  List<Object?> get props => [style];
}
