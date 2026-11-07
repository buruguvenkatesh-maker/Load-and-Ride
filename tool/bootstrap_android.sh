#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
bootstrap_dir=$(mktemp -d)
trap 'rm -rf "$bootstrap_dir"' EXIT
flutter create --platforms=android --project-name=rideload_bootstrap "$bootstrap_dir/bootstrap"
cp "$bootstrap_dir/bootstrap/android/gradlew" android/gradlew
cp "$bootstrap_dir/bootstrap/android/gradle/wrapper/gradle-wrapper.jar" android/gradle/wrapper/gradle-wrapper.jar
chmod +x android/gradlew
flutter pub get
