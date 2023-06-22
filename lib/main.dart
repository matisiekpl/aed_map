import 'package:aed_map/bloc/location/location_cubit.dart';
import 'package:aed_map/bloc/map_style/map_style_cubit.dart';
import 'package:aed_map/bloc/panel/panel_cubit.dart';
import 'package:aed_map/bloc/points/points_cubit.dart';
import 'package:aed_map/bloc/points/points_state.dart';
import 'package:aed_map/bloc/routing/routing_cubit.dart';
import 'package:aed_map/screens/map/map_screen.dart';
import 'package:aed_map/utils.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:plausible_analytics/navigator_observer.dart';
import 'package:plausible_analytics/plausible_analytics.dart';

import 'constants.dart';

final analytics = Plausible(plausible, 'aedmapa.app');

void main() async {
  enableFlutterDriverExtension();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RestartWidget(child: BetterFeedback(child: App())));
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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return CupertinoApp(
      navigatorObservers: [PlausibleNavigatorObserver(analytics)],
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiBlocProvider(providers: [
        BlocProvider<MapStyleCubit>(
          create: (BuildContext context) => MapStyleCubit()..load(),
        ),
        BlocProvider<PointsCubit>(
          create: (BuildContext context) => PointsCubit()..load(),
        ),
        BlocProvider<RoutingCubit>(
          create: (BuildContext context) => RoutingCubit(),
        ),
        BlocProvider<LocationCubit>(
          create: (BuildContext context) => LocationCubit()..locate(),
        ),
        BlocProvider<PanelCubit>(
          create: (BuildContext context) => PanelCubit(),
        ),
      ], child: const MapScreen()),
    );
  }
}
