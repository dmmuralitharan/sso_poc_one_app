import 'package:get/get.dart';
import 'package:sso_poc_one_app/app/pages/login_page.dart';
import 'package:sso_poc_one_app/app/pages/register_page.dart';
import 'package:sso_poc_one_app/app/pages/user_page.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
    ),
    GetPage(name: AppRoutes.register, page: () => const RegisterPage()),
    GetPage(
      name: AppRoutes.user,
      page: () => const UserPage(),
    ),
  ];
}
