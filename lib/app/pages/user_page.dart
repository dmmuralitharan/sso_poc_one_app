import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Get.find<AuthController>().auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome ${user?.displayName ?? ''}"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Get.find<AuthController>().signOut(),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage:
                  user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
            ),
            SizedBox(height: 20),
            Text("Name: ${user?.displayName ?? ''}",
                style: TextStyle(fontSize: 18)),
            Text("Email: ${user?.email ?? ''}", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
