#!/bin/bash

flutter pub get
flutter pub run flutter_launcher_icons

cd assets || exit
[ -f aed_poland.geojson ] && rm aed_poland.geojson
wget https://aed.openstreetmap.org.pl/aed_poland.geojson
cd ..