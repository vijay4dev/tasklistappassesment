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


// ─── main() ──────────────────────────────────────────────────────────────
Future<void> main() async {
  // Flutter engine initialize karo — async main ke liye zaroori
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
    url:     dotenv.env['project_url'] ?? '',
    anonKey: dotenv.env['anon_key'] ?? '',
  );

  // App run karo — MultiProvider wrap karke
  runApp(
    MultiProvider(
      // MultiProvider = ek hi jagah multiple providers define karo
      // Ye sab providers poori app mein available honge
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const TaskHubApp(),
    ),
  );
}

// ─── Root App Widget ──────────────────────────────────────────────────────
class TaskHubApp extends StatelessWidget {
  const TaskHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ThemeProvider ko watch karo — theme toggle pe rebuild hoga
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Mini TaskHub',
      debugShowCheckedModeBanner: false,
      theme:     AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode, // Provider se current mode lo
      home: const _AuthGate(),
    );
  }
}

// ─── Auth Gate ────────────────────────────────────────────────────────────
// Ye decide karta hai: login screen dikhao ya dashboard
// AuthService ki status ke hisaab se
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return AnimatedSwitcher(
      // AnimatedSwitcher: jab auth.status badle toh smooth transition
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: switch (auth.status) {
        // Dart 3 switch expression — clean syntax
        AuthStatus.authenticated   => const DashboardScreen(),
        AuthStatus.unauthenticated => const LoginScreen(),
        AuthStatus.unknown         => const _SplashScreen(),
      },
    );
  }
}

// ─── Splash Screen ────────────────────────────────────────────────────────
// App start pe briefly dikhta hai jab tak auth status check ho raha hai
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
              child: Icon(Icons.check_circle_outline_rounded,
                  color: Colors.white, size: 44),
            ),
            SizedBox(height: 24),
            Text('TaskHub',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor)),
            SizedBox(height: 32),
            CircularProgressIndicator(color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }
}