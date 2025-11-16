import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sso_poc_one_app/app/models/user_model.dart';
import 'package:sso_poc_one_app/app/utils/app_constants.dart';

class AuthController extends GetxController {
  final storage = const FlutterSecureStorage();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);

  // -------------------------
  // CHECK IF USER IS LOGGED IN
  // -------------------------
  Future<bool> isLoggedIn() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return true;
    }

    return false;
  }

  // -------------------------
  // EMAIL REGISTER
  // -------------------------
  Future<User?> register(String email, String password) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        await registerToBackend(user, password: password);
        await loginToBackend(user);
        return user;
      } else {
        return null;
      }
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
      final user = userCredential.user;
      if (user != null) {
        await loginToBackend(user);
        return user;
      } else {
        return null;
      }
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
        final user = userCred.user;

        if (user != null) {
          await registerToBackend(user);
          await loginToBackend(user);
          return user;
        } else {
          return null;
        }
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

    await storage.delete(key: AppConstants.ssoAppAccessTokenKey);
    await storage.delete(key: AppConstants.ssoAppFirebaseUId);
  }

  // -------------------------
  // LOGIN TO BACKEND
  // -------------------------
  Future<void> loginToBackend(User firebaseUser) async {
    try {
      final response = await http.post(
        Uri.parse("${AppConstants.backendBaseUrl}/api/v1/auth/login"),
        headers: {
          "Content-Type": "application/json",
          "X-FIREBASE-UID": firebaseUser.uid,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'];
        final firebaseUid = data['user']['firebase_uid'];
        final userData = data['user'];

        final appUser = AppUser.fromJson({
          ...userData,
        });

        // Store in secure storage
        await storage.write(
            key: AppConstants.ssoAppAccessTokenKey, value: accessToken);
        await storage.write(
            key: AppConstants.ssoAppFirebaseUId, value: firebaseUid);
        await storage.write(
            key: AppConstants.userData, value: jsonEncode(appUser));

        debugPrint("User logged in backend successfully");
      } else {
        debugPrint(
            "Backend login failed: ${response.statusCode} - ${response.body}");
        throw Exception(
            "Backend login failed with status code ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Backend login error: $e");
      rethrow;
    }
  }

  // -------------------------
  // REGISTER TO BACKEND
  // -------------------------
  Future<void> registerToBackend(User firebaseUser, {String? password}) async {
    final user = AppUser(
      firebaseUid: firebaseUser.uid,
      email: firebaseUser.email!,
      name: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      password: password,
      provider: password != null ? "password" : "google",
      role: "user",
    );

    final response = await http.post(
      Uri.parse("${AppConstants.backendBaseUrl}/api/v1/auth/register"),
      headers: {
        "Content-Type": "application/json",
        "X-FIREBASE-UID": firebaseUser.uid,
      },
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 201) {
      debugPrint("User registered to backend successfully");
    } else {
      debugPrint("Backend registration failed: ${response.body}");
    }
  }

  // -------------------------
  // FETCH USER FROM BACKEND
  // -------------------------
  // Future<void> fetchUserFromBackend() async {
  //   final uid = getFirebaseUid();
  //   final token = getAccessToken();

  //   final response = await http.get(
  //     Uri.parse("${AppConstants.backendBaseUrl}/api/v1/auth/user/$uid"),
  //     headers: {
  //       "Authorization": "Bearer $token",
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     // update your app state with user info
  //   }
  // }

  // -------------------------
  // GET STORED TOKEN/UID
  // -------------------------
  Future<String?> getAccessToken() async {
    return await storage.read(key: AppConstants.ssoAppAccessTokenKey);
  }

  Future<String?> getFirebaseUid() async {
    return await storage.read(key: AppConstants.ssoAppFirebaseUId);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final jsonStr = await storage.read(key: AppConstants.userData);
    if (jsonStr == null) return null;

    debugPrint("-----------------------------------");
    debugPrint("User Data JSON: $jsonStr");
    debugPrint("-----------------------------------");

    return jsonDecode(jsonStr);
  }
}
