import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_code/repositories/auth_repository.dart';
import 'package:mobile_code/repositories/history_repository.dart';
import 'package:mobile_code/viewmodels/auth/auth_bloc.dart';
import 'package:mobile_code/viewmodels/auth/auth_event.dart';
import 'package:mobile_code/viewmodels/history/history_bloc.dart';
import 'package:mobile_code/viewmodels/scan/scan_bloc.dart';

import 'views/welcome_screen.dart';
import 'views/login_screen.dart';
import 'views/register_screen.dart';
import 'views/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Try to initialize Firebase, but catch errors if configuration files are missing.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization failed. Make sure google-services.json / GoogleService-Info.plist are present. Error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Repositories and BLoCs
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => HistoryRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            )..add(AppStarted()),
          ),
          BlocProvider(
            create: (context) => HistoryBloc(
              historyRepository: context.read<HistoryRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => ScanBloc(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Lync App',
          theme: ThemeData(
            primaryColor: const Color(0xFF006D66),
            scaffoldBackgroundColor: const Color(0xFFF8FAFB),
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => WelcomeScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/main') {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => MainScreen(
                  isGuest: args['isGuest'],
                  userEmail: args['userEmail'],
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }
}