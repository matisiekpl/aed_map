import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

import '../../tool/screenshots/scenario.dart';

class BrandColors {
  static const green = Color(0xFF029140);
  static const deepGreen = Color(0xFF014D23);
  static const bezel = Color(0xFF111111);
}

class StoreScreenshot extends StatelessWidget {
  const StoreScreenshot({
    super.key,
    required this.caption,
    required this.screen,
    required this.device,
    required this.dark,
  });

  final String caption;
  final Uint8List screen;
  final ScreenshotDevice device;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final height = constraints.maxHeight;
      final tablet = device == ScreenshotDevice.ipad || device == ScreenshotDevice.tablet;
      final captionHeight = height * (tablet ? 0.17 : 0.2);
      final available = height - captionHeight - height * 0.05;
      final aspect = device.width / device.height;
      final frameWidth = (available * aspect).clamp(0.0, width * (tablet ? 0.86 : 0.84));
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [BrandColors.green, BrandColors.deepGreen],
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: captionHeight,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                  child: Text(
                    caption,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w800,
                      fontSize: width * (tablet ? 0.052 : 0.074),
                      height: 1.15,
                      letterSpacing: -0.5,
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
            ),
            DeviceFrame(width: frameWidth, device: device, screen: screen, dark: dark),
          ],
        ),
      );
    });
  }
}

class DeviceFrame extends StatelessWidget {
  const DeviceFrame({
    super.key,
    required this.width,
    required this.device,
    required this.screen,
    required this.dark,
  });

  final double width;
  final ScreenshotDevice device;
  final Uint8List screen;
  final bool dark;

  static const metal = [Color(0xFF5C5C60), Color(0xFF2B2B2E), Color(0xFF1B1B1D), Color(0xFF2B2B2E), Color(0xFF5C5C60)];

  bool get phone => device == ScreenshotDevice.iphone || device == ScreenshotDevice.android;

  double get rim => width * (phone ? 0.012 : 0.008);

  double get bezel => width * (phone ? 0.03 : 0.022);

  double get screenWidth => width - (rim + bezel) * 2;

  double get screenHeight => screenWidth * device.height / device.width;

  double get height => screenHeight + (rim + bezel) * 2;

  double get scale => screenWidth / (device.width / device.pixelRatio);

  double get screenRadius => switch (device) {
        ScreenshotDevice.iphone => 55 * scale,
        ScreenshotDevice.ipad => 18 * scale,
        ScreenshotDevice.android => 34 * scale,
        ScreenshotDevice.tablet => 20 * scale,
      };

  List<(bool, double, double)> get buttons => switch (device) {
        ScreenshotDevice.iphone => [(true, 0.155, 0.04), (true, 0.235, 0.075), (true, 0.33, 0.075), (false, 0.25, 0.115)],
        ScreenshotDevice.android => [(false, 0.2, 0.12), (false, 0.36, 0.07)],
        ScreenshotDevice.ipad => [(false, 0.05, 0.06), (false, 0.13, 0.06)],
        ScreenshotDevice.tablet => [(false, 0.12, 0.06), (false, 0.21, 0.09)],
      };

  @override
  Widget build(BuildContext context) {
    final buttonDepth = width * (phone ? 0.009 : 0.005);
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final (left, top, length) in buttons)
            Positioned(
              left: left ? -buttonDepth : null,
              right: left ? null : -buttonDepth,
              top: height * top,
              child: Container(
                width: buttonDepth * 2,
                height: height * length,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(buttonDepth),
                  gradient: const LinearGradient(colors: metal),
                ),
              ),
            ),
          Container(
            width: width,
            height: height,
            padding: EdgeInsets.all(rim),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenRadius + bezel + rim),
              gradient: const LinearGradient(colors: metal, stops: [0, 0.06, 0.5, 0.94, 1]),
              boxShadow: [
                BoxShadow(color: const Color(0x55000000), blurRadius: width * 0.06, offset: Offset(0, width * 0.02)),
              ],
            ),
            child: Container(
              padding: EdgeInsets.all(bezel),
              decoration: BoxDecoration(
                color: const Color(0xFF000000),
                borderRadius: BorderRadius.circular(screenRadius + bezel),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(screenRadius),
                child: Stack(
                  children: [
                    Positioned.fill(child: Image.memory(screen, fit: BoxFit.cover)),
                    StatusBar(device: device, scale: scale, dark: dark),
                    const Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0x14FFFFFF), Color(0x00FFFFFF)],
                            stops: [0, 0.45],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatusBar extends StatelessWidget {
  const StatusBar({super.key, required this.device, required this.scale, required this.dark});

  final ScreenshotDevice device;
  final double scale;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final color = dark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    final iphone = device == ScreenshotDevice.iphone;
    final android = device == ScreenshotDevice.android || device == ScreenshotDevice.tablet;
    final barHeight = (iphone ? 54 : device.topPadding) * scale;
    final fontSize = (iphone ? 17 : android ? 14 : 15) * scale;
    final horizontal = (iphone ? 38 : android ? 20 : 22) * scale;
    final icons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(CupertinoIcons.wifi, size: fontSize * 1.1, color: color),
        SizedBox(width: fontSize * 0.35),
        Icon(CupertinoIcons.battery_full, size: fontSize * 1.5, color: color),
      ],
    );
    return SizedBox(
      height: barHeight,
      child: Stack(
        children: [
          Positioned(
            left: horizontal,
            top: 0,
            bottom: 0,
            child: Center(
              child: Text(
                '9:41',
                style: TextStyle(
                  fontFamily: android ? 'Roboto' : 'CupertinoSystemText',
                  fontSize: fontSize,
                  fontWeight: android ? FontWeight.w500 : FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ),
          Positioned(right: horizontal, top: 0, bottom: 0, child: Center(child: icons)),
          if (iphone)
            Positioned(
              top: 11 * scale,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 126 * scale,
                  height: 37 * scale,
                  decoration: BoxDecoration(
                    color: const Color(0xFF000000),
                    borderRadius: BorderRadius.circular(20 * scale),
                  ),
                ),
              ),
            ),
          if (device == ScreenshotDevice.android)
            Positioned(
              top: 10 * scale,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 12 * scale,
                  height: 12 * scale,
                  decoration: const BoxDecoration(color: Color(0xFF000000), shape: BoxShape.circle),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FeatureGraphic extends StatelessWidget {
  const FeatureGraphic({
    super.key,
    required this.appName,
    required this.sentence,
    required this.icon,
    required this.screen,
  });

  final String appName;
  final String sentence;
  final Uint8List icon;
  final Uint8List screen;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [BrandColors.green, BrandColors.deepGreen],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: 70,
            top: 48,
            child: DeviceFrame(width: 290, device: ScreenshotDevice.android, screen: screen, dark: false),
          ),
          Positioned(
            left: 64,
            top: 0,
            bottom: 0,
            width: 560,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 24, offset: Offset(0, 8))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.memory(icon, width: 96, height: 96),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  appName,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w800,
                    fontSize: 64,
                    height: 1.05,
                    letterSpacing: -1,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  sentence,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    fontSize: 28,
                    height: 1.25,
                    color: Color(0xE6FFFFFF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
