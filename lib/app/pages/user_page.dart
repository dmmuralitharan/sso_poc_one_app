import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sso_poc_one_app/app/controllers/auth_controller.dart';
import 'package:sso_poc_one_app/app/routing/app_routes.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final user = auth.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome ${user?.displayName ?? user?.email ?? ''}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
              Get.offAllNamed(AppRoutes.login);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile Image Section
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: (user?.photoURL != null)
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? const Icon(Icons.person, size: 50, color: Colors.grey)
                  : null,
            ),

            const SizedBox(height: 25),

            // Name
            Text(
              user?.displayName ?? "No Name",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // Email
            Text(
              user?.email ?? "No Email",
              style: const TextStyle(fontSize: 17),
            ),

            const SizedBox(height: 30),

            Text(
              "UID: ${user?.uid}",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
