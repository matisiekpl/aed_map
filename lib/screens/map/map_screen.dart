import 'package:aed_map/bloc/points/points_cubit.dart';
import 'package:aed_map/bloc/points/points_state.dart';
import 'package:aed_map/screens/loading_widget.dart';
import 'package:aed_map/screens/map/bottom_panel.dart';
import 'package:aed_map/screens/map/floating_panel.dart';
import 'package:aed_map/screens/map/map_header.dart';
import 'package:aed_map/screens/map/vector_map.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../bloc/panel/panel_cubit.dart';
import '../../bloc/panel/panel_state.dart' as panelState;
import '../../main.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {

  final PanelController panel = PanelController();
  final double _floatingPanelPosition = 0;

  @override
  void initState() {
    super.initState();
    analytics.event();
  }


  @override
  Widget build(BuildContext context) {
    BorderRadius radius = const BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );
    return CupertinoPageScaffold(
        child: BlocListener<PanelCubit, panelState.PanelState>(
      listener: (BuildContext context, state) {
        if (state.open && panel.isPanelClosed) panel.open();
        if (!state.open && panel.isPanelOpen) panel.close();
        if (state.visible && !panel.isPanelShown) panel.show();
        if (!state.visible && panel.isPanelShown) panel.hide();
      },
      child: BlocBuilder<PointsCubit, PointsState>(builder: (context, state) {
        if (state is PointsStateLoading) {
          return const LoadingWidget();
        }
        if (state is PointsStateLoaded) {
          return Stack(
            children: [
              SlidingUpPanel(
                  controller: panel,
                  maxHeight: 500,
                  borderRadius: radius,
                  parallaxEnabled: true,
                  parallaxOffset: 0.5,
                  panelBuilder: (ScrollController sc) => AnimatedContainer(
                      decoration: BoxDecoration(
                        borderRadius: radius,
                        color: MediaQuery.of(context).platformBrightness ==
                                Brightness.dark
                            ? Colors.black
                            : Colors.white,
                      ),
                      duration: const Duration(milliseconds: 300),
                      child: BottomPanel(scrollController: sc)),
                  body: VectorMap()),
              MapHeader(),
              FloatingPanel(floatingPanelPosition: _floatingPanelPosition),
              _editMode
                  ? SafeArea(child: _buildMarkerSelectionFooter())
                  : Container()
            ],
          );
        }
        return Container();
      }),
    ));
  }

  Widget _buildMarkerSelectionFooter() {
    return AnimatedOpacity(
      opacity: _editMode ? 1 : 0,
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
                            setState(() {
                              _editMode = false;
                            });
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
                            // AED aed = AED(
                            //     LatLng(mapController.center.latitude,
                            //         mapController.center.longitude),
                            //     0,
                            //     '',
                            //     false,
                            //     '',
                            //     '',
                            //     '',
                            //     'yes');
                            // AED newAed = await Navigator.of(context).push(
                            //     CupertinoPageRoute(
                            //         builder: (context) =>
                            //             EditForm(aed: aed, isEditing: false)));
                            // aeds.add(newAed);
                            setState(() {
                              _editMode = false;
                            });
                            // markersController.replaceAll(_getMarkers());
                            context.read<PanelCubit>().show();
                            // _selectAED(newAed);
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
                        child: SvgPicture.asset('assets/pin.svg', height: 36))
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  bool _editMode = false;

  _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationIcon:
          const Image(image: AssetImage('assets/icon.png'), width: 64),
      applicationName: AppLocalizations.of(context)!.heading,
      applicationVersion: 'v1.0.2',
      applicationLegalese: 'By Mateusz Woźniak',
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Text(AppLocalizations.of(context)!.about)),
      ],
    );
  }
}
