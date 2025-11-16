import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sso_poc_one_app/app/controllers/auth_controller.dart';
import 'package:sso_poc_one_app/app/routing/app_routes.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    // Load user data on UI build (safe because storage read is fast)
    auth.loadBackendUser();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final user = auth.backendUser.value;
          final name = user?['name'] ?? user?['email'] ?? '';

          return Text("Welcome $name");
        }),
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
        child: Obx(() {
          final user = auth.backendUser.value;

          if (user == null) {
            return const CircularProgressIndicator();
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Profile Image
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: (user['photo_url'] != null)
                    ? NetworkImage(user['photo_url'])
                    : null,
                child: user['photo_url'] == null
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),

              const SizedBox(height: 25),

              Text(
                user['name'] ?? "No Name",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Text(
                user['email'] ?? "No Email",
                style: const TextStyle(fontSize: 17),
              ),

              const SizedBox(height: 30),

              Text(
                "Backend UID: ${user['id']}",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          );
        }),
      ),
    );
  }
}
