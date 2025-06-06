import 'package:flutter/material.dart';
import 'package:i/service/user_provider.dart';
import 'package:i/view/calender_page.dart';
import 'package:i/view/home_page.dart';
import 'package:i/view/login_page.dart';
import 'package:i/view/regiser_page.dart';
import 'package:i/view/speak_page.dart';
import 'package:i/view_model/home/home_view_model.dart';
import 'package:i/view_model/tasks/task_view_model.dart';
import 'package:i/view_model/theme_view_model.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final userProvider = UserProvider();
  final taskViewModel = TaskViewModel();
  final themeApp = ThemeApp();
  await userProvider.loadUser();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => userProvider),
        ChangeNotifierProvider(create: (context) => taskViewModel),
        ChangeNotifierProvider(create: (context) => HomeViewModel()),
        ChangeNotifierProvider(create: (context) => themeApp)
      ],
      child: MyApp(themeApp: themeApp),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.themeApp});
  final ThemeApp themeApp;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Criteria',
      locale: const Locale("fr", "CH"),
      theme: themeApp.currentTheme,
      initialRoute: '/login',
      routes: {
        '/login': (c) => LoginPage(),
        '/register': (c) => RegisterPage(),
        '/home_page': (c) => HomePage(),
        '/calender_page': (c) => CalenderPage(),
        '/speak_page': (c) => SpeakPage(),
      },
    );
  }
}
