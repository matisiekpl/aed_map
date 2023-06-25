import 'package:aed_map/bloc/edit/edit_state.dart';
import 'package:aed_map/bloc/location/location_cubit.dart';
import 'package:aed_map/bloc/location/location_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';

import '../../bloc/edit/edit_cubit.dart';
import '../../bloc/panel/panel_cubit.dart';

class MarkerSelectionFooter extends StatelessWidget {
  const MarkerSelectionFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditCubit, EditState>(builder: (context, state) {
      if (!state.enabled) return Container();
      return SafeArea(
        child: AnimatedOpacity(
          opacity: state.enabled ? 1 : 0,
          duration: const Duration(milliseconds: 150),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(AppLocalizations.of(context)!.chooseLocation,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: CupertinoButton(
                              onPressed: () {
                                context.read<EditCubit>().exit();
                                context.read<PanelCubit>().show();
                              },
                              color: Colors.white,
                              child: Text(AppLocalizations.of(context)!.cancel,
                                  style: const TextStyle(color: Colors.black))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CupertinoButton(
                              onPressed: () async {
                                var state = context.read<LocationCubit>().state;
                                if (state is LocationDetermined) {
                                  context.read<PanelCubit>().show();
                                  context.read<EditCubit>().add();
                                }
                              },
                              color: Colors.green,
                              child: Text(AppLocalizations.of(context)!.next)),
                        )
                      ],
                    )
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.translate(
                            offset: const Offset(0, -36),
                            child:
                                SvgPicture.asset('assets/pin.svg', height: 36))
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
