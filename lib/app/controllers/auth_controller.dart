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
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        Get.snackbar(
          "Account Exists",
          "This email is already registered. Try logging in instead.",
        );
        return null;
      }

      if (e.code == 'invalid-email') {
        Get.snackbar("Invalid Email", "Please enter a valid email address.");
        return null;
      }

      if (e.code == 'weak-password') {
        Get.snackbar(
            "Weak Password", "Password should be at least 6 characters.");
        return null;
      }

      Get.snackbar("Registration Failed", e.message ?? "Unknown error");
      return null;
    } catch (e) {
      Get.snackbar("Error", e.toString());
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

  // -------------------------
  // SIGN-IN WITH GOOGLE
  // -------------------------
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
