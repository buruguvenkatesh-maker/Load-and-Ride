# Load and Ride

English-only Flutter Android prototype for goods transport and carpool journeys.
The default app runs entirely with local sample data. No Firebase credentials,
location permission, Maps key, SMS, payment, or real vehicle is required.

## Build and install from an Android phone

1. Put this project's contents at the root of your GitHub repository. The workflow
   must be at `.github/workflows/build-apk.yml`. If uploading from a ZIP, enable
   hidden files so `.github` is included.
2. In GitHub on your phone, open **Actions → Build Rideload APK → Run workflow**.
   If the button is hidden, use your browser's desktop-site option. GitHub requires
   the workflow on the default branch for manual dispatch. Pull requests also build.
3. Open the successful run, then under **Artifacts** download **Rideload-APK**.
4. Extract the ZIP and install `app-debug.apk`. Android may ask you to permit
   installation from your browser or file manager. This is a debug-signed APK for
   personal testing, not a Play Store release. Artifacts expire after 14 days.
5. If a run fails, open its failed step and give the log to Codex for repair.

GitHub Actions installs Java 17, Android SDK tools and Flutter stable, restores
Flutter's standard Gradle launcher, resolves packages, analyzes, tests, builds and
uploads the APK. No laptop is necessary. GitHub-hosted runner availability and
account Actions quotas still apply. Debug keys can change between runners; a later
APK may require uninstalling the earlier app before installation.

## Try the prototype

- Search Hyderabad → Thorrur in Goods Transport or Carpool.
- Try Hayathnagar → Thorrur to see forward intermediate-stop matching.
- Reverse routes do not match. Unknown routes show an honest empty state.
- Open vehicle details, request a demo booking, then use the booking menu to
  simulate accepted, declined or cancelled states. No owner is contacted.
- Register as Customer or Vehicle Owner through Register. Phone validation is
  local only; there is no OTP in the prototype.
- As a Vehicle Owner, post a one-way trip with pickup/drop, optional ordered stops,
  vehicle details, capacity, fare and future departure. Any Indian location text
  can be entered. Search the posted route afterward.
- Changes reset after process restart. Profiles, vehicles and capacity are
  unverified. Simulated acceptance does not reserve capacity.

Matching currently uses normalized exact location names and ordered stops. It does
not calculate geographic proximity, road overlap, detours or available inventories.
Prices are illustrative for the entire trip (goods) or per seat (carpool); no
partial-route pricing is calculated. The app does not dispatch vehicles or accept
money. All navigation and statuses are in English.

## Codex Cloud development

Use a cloud environment with Flutter stable, Java 17, Android SDK and network
access to GitHub, pub.dev, Flutter/Google storage, Google Maven and Maven Central.
Then run:

```sh
bash tool/bootstrap_android.sh
flutter analyze
flutter test
flutter build apk --debug
```

Gradle launcher scripts and the wrapper binary are restored from the installed
Flutter template rather than including a binary in this source bundle. Native
Android configuration is checked in; the bootstrap does not overwrite it.
`flutter pub get` generates `pubspec.lock`; commit that lockfile after the first
successful dependency resolution to pin transitive packages. Flutter stable tracks
the stable channel; pin its version after the first verified build if reproducible
SDK builds are required.

## Firebase and Maps

See [Firebase setup](docs/FIREBASE.md). The independent
`lib/firebase_backend.dart` adapter implements actual Firebase phone verification,
OTP credential sign-in, and private Firestore profile access. It is deliberately
not imported by the demo UI. Wiring a live UI and backend-controlled trips/bookings
is additional development; credentials alone do not turn the demo into a live
marketplace.

## Validation status for this source bundle

The authoring workspace had no Flutter or Dart SDK, and its configured network
proxy was unreachable. Flutter installation, dependency resolution, analysis,
Flutter tests and APK compilation could not run here. No APK or successful CI run
is claimed. XML, JSON, workflow shape, shell syntax and source structure were
checked locally. The workflow is the next executable build verification.
