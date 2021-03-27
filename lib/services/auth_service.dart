import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<String> get onAuthStateChanged => _firebaseAuth.authStateChanges().map(
        (User user) => user?.uid,
      );

  // Email & Password Sign Up
  Future<String> createUserWithEmailAndPassword(
      String email, String password, String name) async {
   User currentUser =
        (await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    )).user ;

    // Update the username
    //var userUpdateInfo = UserUpdateInfo();
    //userUpdateInfo.displayName = name;
    await currentUser
        .updateProfile(displayName: name)
        .then((name) => print(currentUser.displayName));
    await currentUser.reload();
    return currentUser.uid;
  }

  // Email & Password Sign In
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    User currentUser = (await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password)).user
        ;

    var name = currentUser.displayName;
    await currentUser.updateProfile(displayName: name);
    await currentUser.reload();
    return name;
  }

  // Sign Out
  signOut() {
    return _firebaseAuth.signOut();
  }
}
