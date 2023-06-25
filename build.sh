#!/bin/bash

start=$(date +%s)
./setup.sh
echo "Building archives 🏗️"
flutter build ipa
flutter build appbundle
end=$(date +%s)
echo "Done! 🚀 ($(($end-$start)) s)"