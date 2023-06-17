#!/bin/bash

start=$(date +%s)
./setup.sh
#echo "Running integration tests 🧪"
#flutter drive \
#  --profile --cache-sksl --write-sksl-on-exit flutter_01.sksl.json \
#  --driver=test_driver/integration_test.dart \
#  --target=integration_test/app_test.dart &>/dev/null
echo "Building archives 🏗️"
flutter build ipa &>/dev/null
flutter build appbundle &>/dev/null
end=$(date +%s)
echo "Done! 🚀 ($(($end-$start)) s)"