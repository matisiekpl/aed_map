import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({super.key});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 4), () {
      setState(() {
        _showNetworkInformation = true;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  late Timer _timer;
  bool _showNetworkInformation = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 100),
        const Center(child: CircularProgressIndicator()),
        SizedBox(
          height: 100,
          child: !_showNetworkInformation
              ? Container()
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Text(AppLocalizations.of(context)!.checkNetwork,
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                        onPressed: () {
                          RestartWidget.restartApp(context);
                        },
                        child: Text(AppLocalizations.of(context)!.retry,
                            style: const TextStyle(color: Colors.red)))
                  ],
                ),
        ),
      ],
    );
  }
}
