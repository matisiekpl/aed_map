#!/bin/bash

echo "Generating translations 🌐"
flutter gen-l10n &>/dev/null

echo "Generating icons 🎨"
flutter pub get &>/dev/null
flutter pub run flutter_launcher_icons &>/dev/null

echo "Downloading fresh defibrillators database 📦"
cd assets || exit
[ -f aed_poland.geojson ] && rm aed_poland.geojson
wget https://aed.openstreetmap.org.pl/aed_poland.geojson &>/dev/null
cd ..
COUNT=$(jq '.features | length' assets/aed_poland.geojson)
echo "Found $COUNT AEDs in Poland 🫀"