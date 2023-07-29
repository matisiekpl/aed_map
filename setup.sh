#!/bin/bash

echo "Setting up the aed_map project 🛠"
echo "Generating translations 🌐"
flutter gen-l10n

echo "Generating icons 🎨"
flutter pub get
dart run flutter_launcher_icons

echo "Downloading fresh defibrillators database 📦"
cd assets || exit
[ -f aed_poland.geojson ] && rm aed_poland.geojson
[ -f world.geojson ] && rm world.geojson
wget https://aed.openstreetmap.org.pl/aed_poland.geojson &>/dev/null
wget https://back.openaedmap.org/data/world.geojson &>/dev/null
cd ..
COUNT=$(jq '.features | length' assets/aed_poland.geojson)
COUNT_WORLD=$(jq '.features | length' assets/world.geojson)
echo "Found $COUNT AEDs in Poland 🫀"
echo "Found $COUNT_WORLD AEDs worldwide 🫀"