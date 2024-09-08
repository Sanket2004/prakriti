import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:prakriti/components/button.dart';
import 'package:prakriti/navigation/bottomNavigation.dart';
import 'package:prakriti/screens/login_screen.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/bg.mp4")
      ..initialize().then((_) {
        setState(() {}); // Refresh UI when video is initialized
        _controller.play();
        _controller.setLooping(true);
      }).catchError((error) {
        print("Video initialization error: $error");
      });

    // Schedule animation initialization after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {}); // Trigger animations after the initial build
    });
  }

  @override
  void dispose() {
    _controller
        .dispose(); // Dispose of the controller when the widget is removed
    super.dispose();
  }

  void _checkAuthStatus() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(
        const Duration(seconds: 1)); // Hold the button for 1 sec

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && user.emailVerified) {
      // User is authenticated and email is verified
      try {
        Navigator.pushReplacement(
          context,
          PageTransition(
            child: const BottomNavigationScreen(),
            type: PageTransitionType.rightToLeft,
          ),
        );
      } catch (e) {
        print(e);
      }
    } else {
      // User is not authenticated or email is not verified
      try {
        Navigator.pushReplacement(
          context,
          PageTransition(
            child: const LoginScreen(),
            type: PageTransitionType.rightToLeft,
          ),
        );
      } catch (e) {
        print(e);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand, // Ensure the video takes up the entire screen
        children: <Widget>[
          _controller.value.isInitialized
              ? SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(
                  color: Colors.green,
                )), // Show loading indicator if video is not initialized
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'প্রকৃtiii', // Centered title text
                  // style: TextStyle(
                  //   fontSize: 100,
                  //   color: Colors.white,
                  //   fontWeight: FontWeight.bold,
                  // ),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.alkatra(
                    fontSize: 100,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(duration: 1000.ms).slideX(
                      end: 0,
                      begin: 15,
                      curve: Curves.easeOutCubic,
                    ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sow',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn(duration: 1000.ms).slideX(
                        end: 0,
                        begin: 15,
                        curve: Curves.easeOutCubic,
                        delay: 200.ms),
                    const SizedBox(width: 10),
                    const Text(
                      'Reap',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn(duration: 1000.ms).slideX(
                        end: 0,
                        begin: 15,
                        curve: Curves.easeOutCubic,
                        delay: 400.ms),
                    const SizedBox(width: 10),
                    const Text(
                      'Harvest',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn(duration: 1000.ms).slideX(
                        end: 0,
                        begin: 15,
                        curve: Curves.easeOutCubic,
                        delay: 600.ms),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Button(
                  onPressed: _checkAuthStatus,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 6,
                              ),
                            )
                          : const Text(
                              "Let's Get Started",
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ).animate().fadeIn(duration: 1000.ms).slideX(
                    end: 0,
                    begin: 15,
                    curve: Curves.easeOutCubic,
                    delay: 700.ms),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
