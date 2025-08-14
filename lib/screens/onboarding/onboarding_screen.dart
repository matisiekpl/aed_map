import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_svg/svg.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/i18n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    var titleTextStyle = TextStyle(
      color: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? Colors.white
          : Colors.black,
      fontSize: 20,
      fontFamily: 'Manrope',
      fontWeight: FontWeight.w500,
    );
    var bodyTextStyle = TextStyle(
      color: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? Colors.white
          : Colors.black,
      fontSize: 18.0,
      fontWeight: FontWeight.normal,
    );
    return Container(
      color: MediaQuery.of(context).platformBrightness == Brightness.dark
          ? Colors.black
          : Colors.white,
      child: Theme(
        data: ThemeData(
          colorScheme: ColorScheme.light(primary: Colors.green.shade400),
        ),
        child: SafeArea(
          child: IntroductionScreen(
            globalBackgroundColor:
                MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? Colors.black
                    : Colors.white,
            dotsDecorator: DotsDecorator(
              activeColor: Colors.green.shade400,
            ),
            pages: [
              PageViewModel(
                  title: AppLocalizations.of(context)!.onboardingTitle0,
                  body: AppLocalizations.of(context)!.onboardingBody0,
                  image: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 128),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset("assets/icon.png"),
                      ),
                    ),
                  ),
                  decoration: PageDecoration(
                    bodyPadding: EdgeInsets.symmetric(horizontal: 24),
                    imageFlex: 2,
                    imagePadding: EdgeInsets.only(top: 24),
                    titleTextStyle: titleTextStyle,
                    bodyTextStyle: bodyTextStyle,
                  )),
              PageViewModel(
                  title: AppLocalizations.of(context)!.onboardingTitle1,
                  body: AppLocalizations.of(context)!.onboardingBody1,
                  image: SafeArea(
                      child: Image.asset("assets/onboarding/onboarding1.png")),
                  decoration: PageDecoration(
                    bodyPadding: EdgeInsets.symmetric(horizontal: 24),
                    imageFlex: 4,
                    imagePadding: EdgeInsets.only(top: 24),
                    titleTextStyle: titleTextStyle,
                    bodyTextStyle: bodyTextStyle,
                  )),
              PageViewModel(
                  title: AppLocalizations.of(context)!.onboardingTitle2,
                  body: AppLocalizations.of(context)!.onboardingBody2,
                  image: SafeArea(
                      child: Image.asset("assets/onboarding/onboarding2.png")),
                  decoration: PageDecoration(
                    bodyPadding: EdgeInsets.symmetric(horizontal: 24),
                    imageFlex: 4,
                    imagePadding: EdgeInsets.only(top: 24),
                    titleTextStyle: titleTextStyle,
                    bodyTextStyle: bodyTextStyle,
                  )),
              PageViewModel(
                  title: AppLocalizations.of(context)!.onboardingTitle3,
                  body: AppLocalizations.of(context)!.onboardingBody3,
                  image: SafeArea(
                      child: SvgPicture.asset("assets/onboarding/osm.svg")),
                  decoration: PageDecoration(
                    bodyPadding: EdgeInsets.symmetric(horizontal: 24),
                    imageFlex: 2,
                    imagePadding: EdgeInsets.only(top: 24),
                    titleTextStyle: titleTextStyle,
                    bodyTextStyle: bodyTextStyle,
                  ))
            ],
            done: Text(
              AppLocalizations.of(context)!.next,
              style: TextStyle(color: Colors.green.shade400),
            ),
            next: Text(
              AppLocalizations.of(context)!.next,
              style: TextStyle(color: Colors.green.shade400),
            ),
            onDone: () {
              SharedPreferences.getInstance().then((prefs) {
                prefs.setBool('onboarded', true);
              });
              Phoenix.rebirth(context);
            },
          ),
        ),
      ),
    );
  }
}
