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
import 'package:aed_map/screens/onboarding/onboarding_screen.dart';
import 'package:feedback/feedback.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:plausible_analytics/plausible_analytics.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'firebase_options.dart';
import 'generated/i18n/app_localizations.dart';

final analytics = Plausible(plausible, 'aedmapa.app',
    userAgent: Platform.isIOS ? iosUserAgent : androidUserAgent);

late final Mixpanel mixpanel;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(hours: 1),
  ));
  await remoteConfig.setDefaults(const {
    "request_review": false,
    "livechat": false,
  });
  remoteConfig.fetchAndActivate();
  mixpanel = await Mixpanel.init(mixpanelToken, trackAutomaticEvents: true);
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://492fa94bb5e0bdf492c5a8b8a108d84e@o337011.ingest.sentry.io/4506661810274304';
      options.tracesSampleRate = 1.0;
      options.attachScreenshot = true;
      options.experimental.replay.sessionSampleRate = 1.0;
      options.experimental.replay.onErrorSampleRate = 1.0;
    },
    appRunner: () => runApp(
        SentryWidget(child: BetterFeedback(child: Phoenix(child: App())))),
  );
}

class App extends StatefulWidget {
  const App({super.key, this.skipOnboarding = false});

  final bool skipOnboarding;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        if (!prefs.containsKey('onboarded')) {
          home = OnboardingScreen();
        } else {
          home = Home();
        }
      });
    });
  }

  final GeolocationRepository geolocationRepository = GeolocationRepository();
  final PointsRepository pointsRepository = PointsRepository();
  final FeedbackRepository feedbackRepository = FeedbackRepository();
  final RoutingRepository routingRepository = RoutingRepository();

  Widget home = Scaffold(
      body: Center(
    child: CircularProgressIndicator(
      color: Colors.green.shade400,
    ),
  ));

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: List.from(AppLocalizations.supportedLocales)
        ..sort((a, b) =>
            const Locale('en').languageCode.compareTo(a.languageCode)),
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
              create: (BuildContext context) => EditCubit(
                  pointsRepository: pointsRepository,
                  geolocationRepository: geolocationRepository)),
          BlocProvider<NetworkStatusCubit>(
              create: (BuildContext context) => NetworkStatusCubit()),
          BlocProvider<FeedbackCubit>(
              create: (BuildContext context) =>
                  FeedbackCubit(feedbackRepository: feedbackRepository)),
        ],
        child: widget.skipOnboarding ? Home() : home,
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
