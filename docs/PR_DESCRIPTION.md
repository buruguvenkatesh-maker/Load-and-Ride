# Add Load and Ride Android transport and carpool prototype

Creates an English Flutter app with explicit sample-data notices, goods/carpool
search, forward ordered-stop matching, owner/customer registration, vehicle
information, local trip posting and simulated booking lifecycle. Seeds
Hyderabad–Thorrur and accepts any Indian location text.

Adds separate Firebase phone OTP and private Firestore profile integration,
default-deny rules, a future Maps adapter boundary and console setup instructions.
The demo does not initialize Firebase or present sample requests as live bookings.

GitHub Actions supports manual dispatch and PR builds on Flutter stable, Java 17
and Android SDK, runs analysis/tests, builds a debug APK and uploads Rideload-APK.
README includes installation instructions usable from an Android phone.

Validation: static structure checks only in the authoring workspace. Flutter/Dart
were absent and network proxy unreachable, so dependency resolution, analyzer,
Flutter tests and APK build remain unverified until Actions runs. No live backend,
release signing or Play Store publishing is included.
