
import 'package:aed_map/screens/home_screen.dart';
import 'package:aed_map/screens/offline_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const App());
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
    _checkNetwork();
  }

  _checkNetwork() async {
    // try {
    //   final result = await InternetAddress.lookup('example.com');
    //   if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
    //     setState(() {
    //       current = HomeScreen();
    //     });
    //   }
    // } on SocketException catch (_) {
    //   setState(() {
    //     current = OfflineScreen();
    //   });
    // }
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        current = const HomeScreen();
      });
    } else {
      setState(() {
        current = const OfflineScreen();
      });
    }
  }

  Widget current = const CupertinoApp(home: Center(child: CircularProgressIndicator()));

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      home: current,
    );
  }
}
