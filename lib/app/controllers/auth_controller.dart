import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sso_poc_one_app/app/routing/app_routes.dart';

class AuthController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);

  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await auth.signInWithCredential(credential);

      Get.offAllNamed(AppRoutes.user);

      return userCred.user;
    } catch (e) {
      debugPrint("Google Sign-In error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
    await googleSignIn.signOut();

    Get.offAllNamed(AppRoutes.login);
  }
}
