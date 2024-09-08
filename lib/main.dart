import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prakriti/constants/const.dart';
import 'package:prakriti/navigation/bottomNavigation.dart';
import 'package:prakriti/screens/splash_Screen.dart';

void main() async {
  Gemini.init(apiKey: GEMINI_API_KEY);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Transparent status bar color
    statusBarIconBrightness: Brightness.dark, // Dark status bar icons
    statusBarBrightness:
        Brightness.light, // Light status bar for dark backgrounds
  ));
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: "AIzaSyDbaVc557NcmzH9uN8CZJ-at7Qkc__VlKE",
    appId: "1:876452193313:android:871bea0d84793d9559af60",
    messagingSenderId: "876452193313",
    projectId: "prakriti-e9c9e",
    storageBucket: "prakriti-e9c9e.appspot.com",
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prakriti',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff399918)),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.overpassTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } else if (snapshot.hasData) {
          User? user = snapshot.data;
          if (user != null && !user.emailVerified) {
            return const SplashScreen();
          } else {
            return const BottomNavigationScreen();
          }
        } else {
          return const SplashScreen();
        }
      },
    );
  }
}
