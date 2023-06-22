import 'package:feedback/feedback.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../bloc/panel/panel_cubit.dart';
import '../../bloc/points/points_cubit.dart';
import '../../bloc/points/points_state.dart';
import '../../store.dart';

class MapHeader extends StatelessWidget {
  const MapHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.heading,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 32)),
                  BlocBuilder<PointsCubit, PointsState>(builder: (context, state) {
                    if (state is PointsStateLoaded) {
                      return Text(
                          AppLocalizations.of(context)!
                              .subheading(state.aeds.length),
                          style: const TextStyle(fontSize: 14));
                    } else {
                      return Text(AppLocalizations.of(context)!.subheading(0),
                          style: const TextStyle(fontSize: 14));
                    }
                  }),
                ],
              ),
              Column(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      // _showAboutDialog();
                    },
                    child: Card(
                      color: MediaQuery.of(context).platformBrightness ==
                          Brightness.dark
                          ? Colors.black
                          : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(CupertinoIcons.gear,
                            color: MediaQuery.of(context).platformBrightness ==
                                Brightness.dark
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () async {
                      // if (!await Store.instance.authenticate()) return;
                      context.read<PanelCubit>().hide();
                      // setState(() {
                      //   _editMode = true;
                      // });
                    },
                    child: Card(
                      color: MediaQuery.of(context).platformBrightness ==
                          Brightness.dark
                          ? Colors.black
                          : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(CupertinoIcons.wand_rays,
                            color: MediaQuery.of(context).platformBrightness ==
                                Brightness.dark
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      BetterFeedback.of(context).show((UserFeedback feedback) {
                        Store.instance.sendFeedback(feedback);
                      });
                    },
                    child: Card(
                      color: MediaQuery.of(context).platformBrightness ==
                          Brightness.dark
                          ? Colors.black
                          : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(CupertinoIcons.text_bubble,
                            color: MediaQuery.of(context).platformBrightness ==
                                Brightness.dark
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
