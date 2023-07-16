import 'dart:io';

import 'package:aed_map/bloc/edit/edit_cubit.dart';
import 'package:aed_map/bloc/edit/edit_state.dart';
import 'package:aed_map/bloc/feedback/feedback_cubit.dart';
import 'package:aed_map/bloc/location/location_cubit.dart';
import 'package:aed_map/bloc/network_status/network_status_cubit.dart';
import 'package:aed_map/bloc/panel/panel_cubit.dart';
import 'package:aed_map/bloc/points/points_cubit.dart';
import 'package:aed_map/bloc/routing/routing_cubit.dart';
import 'package:aed_map/repositories/feedback_repository.dart';
import 'package:aed_map/repositories/geolocation_repository.dart';
import 'package:aed_map/repositories/points_repository.dart';
import 'package:aed_map/repositories/routing_repository.dart';
import 'package:aed_map/screens/edit/edit_form.dart';
import 'package:aed_map/screens/map/map_screen.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:plausible_analytics/plausible_analytics.dart';

import 'constants.dart';

final analytics = Plausible(plausible, 'aedmapa.app',
    userAgent: Platform.isIOS ? iosUserAgent : androidUserAgent);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BetterFeedback(child: App()));
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
  }

  final GeolocationRepository geolocationRepository = GeolocationRepository();
  final PointsRepository pointsRepository = PointsRepository();
  final FeedbackRepository feedbackRepository = FeedbackRepository();
  final RoutingRepository routingRepository = RoutingRepository();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<PointsCubit>(
            create: (BuildContext context) => PointsCubit(
                pointsRepository: pointsRepository,
                geolocationRepository: geolocationRepository)
              ..load(),
          ),
          BlocProvider<RoutingCubit>(
            create: (BuildContext context) => RoutingCubit(
                geolocationRepository: geolocationRepository,
                routingRepository: routingRepository),
          ),
          BlocProvider<LocationCubit>(
            create: (BuildContext context) =>
                LocationCubit(geolocationRepository: geolocationRepository)
                  ..locate(),
          ),
          BlocProvider<PanelCubit>(
            create: (BuildContext context) => PanelCubit(),
          ),
          BlocProvider<EditCubit>(
              create: (BuildContext context) =>
                  EditCubit(pointsRepository: pointsRepository)),
          BlocProvider<NetworkStatusCubit>(
              create: (BuildContext context) => NetworkStatusCubit()),
          BlocProvider<FeedbackCubit>(
              create: (BuildContext context) =>
                  FeedbackCubit(feedbackRepository: feedbackRepository)),
        ],
        child: const Home(),
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditCubit, EditState>(
        listenWhen: (previous, current) =>
            previous is EditReady && current is EditInProgress,
        listener: (BuildContext context, state) async {
          if (state is EditInProgress) {
            var editCubit = context.read<EditCubit>();
            var pointsCubit = context.read<PointsCubit>();
            await Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => MultiBlocProvider(providers: [
                  BlocProvider<EditCubit>.value(value: editCubit),
                  BlocProvider<PointsCubit>.value(value: pointsCubit),
                ], child: const EditForm()),
              ),
            );
            editCubit.cancel();
          }
        },
        child: const MapScreen());
  }
}
