import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sso_poc_one_app/app/controllers/auth_controller.dart';
import 'package:sso_poc_one_app/app/routing/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                final password = passwordController.text.trim();

                if (email.isEmpty || password.isEmpty) {
                  Get.snackbar("Error", "Email & Password required");
                  return;
                }

                final user = await auth.login(email, password);

                if (user != null) {
                  Get.snackbar("Login Success", user.email ?? "No Email");

                  /// Navigate to user page
                  Get.offAllNamed(AppRoutes.user);
                } else {
                  Get.snackbar("Login Failed", "Invalid credentials");
                }
              },
              child: const Text("Login"),
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.register),
              child: const Text("Create Account"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final user = await auth.signInWithGoogle();

                if (user != null) {
                  Get.snackbar("Login Success", user.displayName ?? "No Name");
                  Get.offAllNamed(AppRoutes.user);
                } else {
                  Get.snackbar("Login Failed", "Google sign-in error");
                }
              },
              child: const Text("Sign in with Google"),
            ),
          ],
        ),
      ),
    );
  }
}
