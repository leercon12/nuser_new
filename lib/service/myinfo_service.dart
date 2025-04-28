import 'package:firebase_auth/firebase_auth.dart';

final _auth = FirebaseAuth.instance;

Future<bool> reauthenticate(String pw) async {
  try {
    final user = _auth.currentUser;
    if (user == null) return false;

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: pw,
    );

    await user.reauthenticateWithCredential(credential);
    return true;
  } catch (e) {
    return false;
  }
}
