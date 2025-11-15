import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sso_poc_one_app/app/controllers/auth_controller.dart';
import 'package:sso_poc_one_app/app/routing/app_pages.dart';
import 'package:sso_poc_one_app/app/routing/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final authController = Get.put(AuthController());
  final loggedIn = await authController.isLoggedIn();

  runApp(MyApp(loggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool loggedIn;
  const MyApp({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Google Login",
      debugShowCheckedModeBanner: false,
      initialRoute: loggedIn ? AppRoutes.user : AppRoutes.login,
      getPages: AppPages.pages,
    );
  }
}
