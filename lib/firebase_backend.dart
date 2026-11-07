// Optional integration: never initialized by the sample-data application.
// Configure a separate entry point before connecting production UI to this API.
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseBackend {
  FirebaseBackend._(this.auth, this.database);
  final FirebaseAuth auth;
  final FirebaseFirestore database;

  static Future<FirebaseBackend> initialize(FirebaseOptions options) async {
    await Firebase.initializeApp(options: options);
    return FirebaseBackend._(FirebaseAuth.instance, FirebaseFirestore.instance);
  }

  Future<void> sendOtp({
    required String indianPhoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(FirebaseAuthException error) onFailure,
    required void Function(PhoneAuthCredential credential) onAutoVerified,
    required void Function(String verificationId) onTimeout,
  }) async {
    if (!RegExp(r'^\+91[6-9][0-9]{9}$').hasMatch(indianPhoneNumber)) {
      throw ArgumentError('Use a valid Indian mobile number in +91 format.');
    }
    await auth.verifyPhoneNumber(
      phoneNumber: indianPhoneNumber,
      verificationCompleted: onAutoVerified,
      verificationFailed: onFailure,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onTimeout,
    );
  }

  Future<UserCredential> confirmOtp(String verificationId, String smsCode) =>
      auth.signInWithCredential(PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode));

  Future<void> saveProfile(String name, String role) async {
    final user = auth.currentUser;
    if (user == null) throw StateError('Phone sign-in is required.');
    if (!['Customer', 'Vehicle Owner'].contains(role) || name.trim().length < 2) {
      throw ArgumentError('Enter a valid name and role.');
    }
    await database.collection('profiles').doc(user.uid).set({
      'name': name.trim(), 'role': role,
      'phone': user.phoneNumber, 'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Firestore access is deliberately limited to the authenticated user's own
  // profile. Trips/bookings require a trusted server and production rules first.
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchOwnProfile() {
    final user = auth.currentUser;
    if (user == null) throw StateError('Phone sign-in is required.');
    return database.collection('profiles').doc(user.uid).snapshots();
  }
}

// Future Maps adapter boundary; no API key, geocoding, or GPS is needed for demo.
class IndianLocation {
  const IndianLocation(this.name, {this.placeId, this.latitude, this.longitude});
  final String name;
  final String? placeId;
  final double? latitude, longitude;
}

abstract interface class LocationSearch {
  Future<List<IndianLocation>> search(String query);
}
