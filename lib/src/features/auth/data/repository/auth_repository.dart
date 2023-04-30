import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationRepository {
  final FirebaseAuth _firebaseAuth;
  final _googleSignIn = GoogleSignIn();

  AuthenticationRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Stream<User?> get user {
    return FirebaseAuth.instance.authStateChanges();
  }

  Future<User?> authenticateUser({
    required String email,
    required String password,
  }) async {
    try {
      final User? user = await signUpWithEmailAndPassword(email, password);
      return user;
    } catch (e) {
      final User? user = await logInWithEmailAndPassword(email, password);
      return user;
    }
  }

  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }

  Future<User?> logInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (authException) {
      throw Exception(authException.message);
    }
  }

  Future<User?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (authException) {
      throw Exception(authException.message);
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Obtain the auth details from the request
      GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      // Create a new credential
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase Authentication with the Google credential
      UserCredential cred =
          await _firebaseAuth.signInWithCredential(credential);

      User? _user = cred.user;

      assert(!_user!.isAnonymous);

      assert(await _user?.getIdToken() != null);

      User? currentUser = await _firebaseAuth.currentUser;

      assert(_user?.uid == currentUser?.uid);

      return cred;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
