import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../bloc/panel/panel_cubit.dart';
import '../../bloc/routing/routing_cubit.dart';
import '../../bloc/routing/routing_state.dart';
import '../../models/trip.dart';

class FloatingPanel extends StatelessWidget {
  const FloatingPanel({super.key, required this.floatingPanelPosition});

  final double floatingPanelPosition;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<RoutingCubit, RoutingState>(builder: (context, state) {
        if (state is RoutingStateShowing) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding:
                    EdgeInsets.only(bottom: floatingPanelPosition * 400 + 84),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        // _animatedMapMove(
                        //     await Store.instance.determinePosition(), 18);
                      },
                      child: Card(
                          color: MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? Colors.black
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(128),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 12),
                            child: Row(
                              children: [
                                Text(
                                    _translateTimeAndLength(
                                        context, state.trip),
                                    style: TextStyle(
                                        fontSize: 17,
                                        color: MediaQuery.of(context)
                                                    .platformBrightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black)),
                                const SizedBox(width: 8),
                                SizedBox(
                                  height: 32,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15.0),
                                    child: CupertinoButton(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 6),
                                        color: Colors.red,
                                        child: Text(
                                            AppLocalizations.of(context)!.stop,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white)),
                                        onPressed: () {
                                          context.read<RoutingCubit>().cancel();
                                          // mapController.rotate(0);
                                          // panel.open();
                                          context.read<PanelCubit>().open();
                                        }),
                                  ),
                                )
                              ],
                            ),
                          )),
                    ),
                  ],
                ),
              )
            ],
          );
        }
        return Container();
      }),
    );
  }

  String _translateTimeAndLength(BuildContext context, Trip trip) {
    return '${(trip.time > 60 ? ('${(trip.time / 60).floor()} ${AppLocalizations.of(context)!.minutes}') : ('${trip.time.floor()} ${AppLocalizations.of(context)!.seconds}'))} (${(trip.length * 1000).floor()} ${AppLocalizations.of(context)!.meters})';
  }
}
