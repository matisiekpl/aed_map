import 'package:flutter/cupertino.dart';

class OfflineScreen extends StatefulWidget {
  const OfflineScreen({Key? key}) : super(key: key);

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
      Icon(CupertinoIcons.wifi_exclamationmark, size: 128),
      SizedBox(height: 24),
      Text('Brak połączenia z siecią', style: TextStyle(fontSize: 20)),
      SizedBox(height: 24),
    ])));
  }
}
