import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);

  // -------------------------
  // EMAIL REGISTER
  // -------------------------
  Future<User?> register(String email, String password) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      debugPrint("Register Error: $e");
      return null;
    }
  }

  // -------------------------
  // EMAIL LOGIN
  // -------------------------
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      debugPrint("Login Error: $e");
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      try {
        final userCred = await auth.signInWithCredential(credential);
        return userCred.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          Get.snackbar(
            "Account Exists",
            "Please sign in with Email & Password for this account.",
          );
          return null;
        }
        rethrow;
      }
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      return null;
    }
  }

  // -------------------------
  // GOOGLE SIGN-OUT
  // -------------------------
  Future<void> signOut() async {
    await auth.signOut();
    await googleSignIn.signOut();
  }
}
