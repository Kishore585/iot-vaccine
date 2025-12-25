#!/bin/bash

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure

# Clean and get dependencies
flutter clean
flutter pub get

echo "Firebase setup completed!" 