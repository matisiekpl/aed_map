import 'package:equatable/equatable.dart';

class PanelState extends Equatable {
  final bool open;
  final bool visible;
  final String hash;

  const PanelState(
      {required this.open, required this.visible, required this.hash});

  PanelState copyWith({
    bool? open,
    bool? visible,
    String? hash,
  }) {
    return PanelState(
      open: open ?? this.open,
      visible: visible ?? this.visible,
      hash: hash ?? this.hash,
    );
  }

  @override
  List<Object?> get props => [hash];
}
