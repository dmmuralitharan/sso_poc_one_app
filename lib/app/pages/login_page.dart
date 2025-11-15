import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Google Login")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final user = await Get.find<AuthController>().signInWithGoogle();

            if (user != null) {
              Get.snackbar("Login Success", user.displayName ?? 'No Name');
            } else {
              Get.snackbar("Login Failed", "User returned null");
            }
          },
          child: Text("Sign in with Google"),
        ),
      ),
    );
  }
}
