#!/bin/bash
cd ios
fastlane release
cd ..
cd android
fastlane release
cd ..

echo '🚀 Deployed to iOS and Android!'