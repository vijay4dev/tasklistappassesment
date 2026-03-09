import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tasklistapp/app/app_theme.dart';
import 'package:tasklistapp/auth/auth_services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'auth/login_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'dashboard/task_provider.dart';


Future<void> main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // Wakelock initialize karo — screen off pe app chalta rahega
  await WakelockPlus.enable();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Supabase initialize karo — iske baad SupabaseService use kar sakte hain
  await Supabase.initialize(
    url: dotenv.env['project_url'] ?? '',
    anonKey: dotenv.env['anon_key'] ?? '',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const TaskHubApp(),
    ),
  );
}


class TaskHubApp extends StatelessWidget {
  const TaskHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Mini TaskHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: switch (auth.status) {
        AuthStatus.authenticated => const DashboardScreen(),
        AuthStatus.unauthenticated => const LoginScreen(),
        AuthStatus.unknown => const _SplashScreen(),
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primaryColor,
              child: Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 44,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'TaskHub',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }
}
