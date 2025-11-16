import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sso_poc_one_app/app/controllers/auth_controller.dart';
import 'package:sso_poc_one_app/app/routing/app_routes.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                final password = passwordController.text.trim();

                if (email.isEmpty || password.isEmpty) {
                  Get.snackbar("Error", "Email and Password cannot be empty");
                  return;
                }

                final user = await auth.register(email, password);

                if (user != null) {
                  Get.snackbar("Success", "Registered as ${user.email}");

                  await Future.delayed(const Duration(milliseconds: 800));

                  // Get.offAllNamed(AppRoutes.login);
                  Get.offAllNamed(AppRoutes.user);
                } else {
                  Get.snackbar("Failed", "Registration failed");
                }
              },
              child: const Text("Register"),
            )
          ],
        ),
      ),
    );
  }
}
