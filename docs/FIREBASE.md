# Separate Firebase integration

The sample app always starts at `lib/main.dart`. It never initializes Firebase
and cannot make live bookings. Do not relabel it as live after adding keys.

## Your Firebase console configuration

1. Create a Firebase project. Add Android app **in.rideload.app**.
2. Enable Authentication → Phone. Configure allowed SMS regions for India,
   billing/quotas as required by Firebase, and test phone numbers first.
3. Register SHA-1 and SHA-256 fingerprints for the certificate signing the APK.
   For CI debug APKs obtain them from `cd android && ./gradlew signingReport` on
   the build runner after bootstrap. Ephemeral runner debug keys can change.
   For consistent OTP testing, configure a persistent testing signing keystore
   through GitHub Actions secrets in a later signing change; never commit its
   password or private key.
4. Create Firestore in a suitable Indian region. Deploy the supplied restrictive
   rules using Firebase CLI: `firebase deploy --only firestore:rules --project YOUR_ID`.
   These allow only each signed-in user's own validated profile. All trip and
   booking access is denied until production rules/server logic are designed.
5. In a Flutter-enabled Codex Cloud environment install Firebase CLI and
   FlutterFire CLI and run `flutterfire configure --platforms=android
   --android-package-name=in.rideload.app --project=YOUR_ID`. Use the generated
   `FirebaseOptions` from `lib/firebase_options.dart` with
   `FirebaseBackend.initialize(DefaultFirebaseOptions.currentPlatform)` in a
   **separate live entry point**. Keep demo startup independent.
6. If using native `google-services.json` instead of explicit Dart options, obtain
   the file from the Firebase console, add it privately to
   `android/app/google-services.json`, and configure the Google Services Gradle
   plugin. The default project uses explicit options and does not apply that
   plugin. No service-account key belongs in an Android APK.

Firebase client configuration identifies the project; Firestore rules and backend
validation provide authorization. Avoid publishing real phone numbers in logs.

## Integration work still required

Build the live login screen with OTP entry, resend cooldown, loading/error states,
expired-code handling, and signed-in routing. Wire `sendOtp`'s auto-verification
callback to credential sign-in; call `confirmOtp` for manually entered codes.
Use test numbers or the Authentication emulator before real SMS. Add emulator
integration tests for profile isolation and validation before deploying rules.
Phone verification proves control of a number, not driver or vehicle identity.

Introduce repository implementations for live trips and booking requests, with
server-side ownership checks, capacity transactions, cancellation rules and
idempotency. Persist immutable request/vehicle snapshots, restrict profile contact
access and add abuse prevention. Do not reuse the demo's client-editable booking
statuses or its unverified role for authorization. No production trips/bookings
repository is supplied; profile CRUD is the prepared Firestore integration.

## Future Google Maps support

`LocationSearch` and `IndianLocation` in `lib/firebase_backend.dart` define a
location-provider boundary. Add a Places/Maps adapter later, preserve place IDs
and coordinates, and migrate matching to geographic routes on a trusted backend.
Enable the required Google Maps/Places APIs, billing and quotas. Restrict Android
API keys to package `in.rideload.app` and your signing SHA-1; restrict server keys
to server APIs and addresses. Store CI configuration using repository secrets,
and request location permission only for features that need current location.
No Maps key or GPS permission is needed for typed locations in this prototype.
