import 'package:aed_map/bloc/points/points_cubit.dart';
import 'package:aed_map/bloc/points/points_state.dart';
import 'package:aed_map/screens/map/bottom_panel.dart';
import 'package:aed_map/screens/map/floating_panel.dart';
import 'package:aed_map/screens/map/map_header.dart';
import 'package:aed_map/screens/map/marker_selection_footer.dart';
import 'package:aed_map/screens/map/raster_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../bloc/panel/panel_cubit.dart';
import '../../bloc/panel/panel_state.dart' as panel_state;
import '../../main.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final PanelController panel = PanelController();
  double _floatingPanelPosition = 0;

  @override
  void initState() {
    super.initState();
    analytics.event();
    init();
    context.read<PointsCubit>().refresh();
  }

  init() async {
    await Future.delayed(const Duration(milliseconds: 400));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('firstEnter') == true) {
      return false;
    }
    prefs.setBool('firstEnter', true);
    showFirstEnterDialog();
  }

  showFirstEnterDialog() {
    var appLocalizations = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.red.shade400,
          title: Text(appLocalizations.dataSource),
          content: Text(appLocalizations.dataSourceDescription),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: Text(appLocalizations.understand),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    BorderRadius radius = const BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );
    return CupertinoPageScaffold(
        child: BlocListener<PanelCubit, panel_state.PanelState>(
      listener: (BuildContext context, state) {
        if (state.visible && !panel.isPanelShown) panel.show();
        if (!state.visible && panel.isPanelShown) panel.hide();
        if (state.visible) {
          if (state.open && panel.isPanelClosed) panel.open();
          if (!state.open && panel.isPanelOpen) panel.close();
        }
      },
      child: BlocBuilder<PointsCubit, PointsState>(builder: (context, state) {
        if (state is PointsLoadInProgress) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is PointsLoadSuccess) {
          return Stack(
            children: [
              SlidingUpPanel(
                  defaultPanelState: PanelState.OPEN,
                  controller: panel,
                  maxHeight: 450,
                  borderRadius: radius,
                  parallaxEnabled: true,
                  parallaxOffset: 0.5,
                  onPanelSlide: (value) {
                    setState(() {
                      _floatingPanelPosition = value;
                    });
                  },
                  panelBuilder: (ScrollController sc) => Container(
                      decoration: BoxDecoration(borderRadius: radius),
                      child: BottomPanel(scrollController: sc)),
                  body: const RasterMap()),
              const MapHeader(),
              FloatingPanel(floatingPanelPosition: _floatingPanelPosition),
              const MarkerSelectionFooter()
            ],
          );
        }
        return Container();
      }),
    ));
  }
}
