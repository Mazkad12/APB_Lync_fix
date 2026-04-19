import 'package:flutter/material.dart';
import 'views/welcome_screen.dart';
import 'views/login_screen.dart';
import 'views/register_screen.dart';
import 'views/shorten_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lync App',
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/shorten') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ShortenScreen(
              isGuest: args['isGuest'],
              userEmail: args['userEmail'],
            ),
          );
        }
        return null;
      },
    );
  }
}