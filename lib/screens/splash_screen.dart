import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController logoController;
  late AnimationController textController;

  late Animation<double> scaleAnim;
  late Animation<double> glowAnim;
  late Animation<double> textFade;

  @override
  void initState() {
    super.initState();

    // 🔥 LOGO ANIMATION
    logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    scaleAnim = Tween(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: logoController, curve: Curves.easeInOutBack),
    );

    glowAnim = Tween(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: logoController, curve: Curves.easeIn),
    );

    // 🔥 TAGLINE ANIMATION
    textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    textFade = Tween(begin: 0.0, end: 1.0).animate(textController);

    // Remove native splash and start animations
    _removeNativeSplashAndStart();
  }

  void _removeNativeSplashAndStart() async {
    // Wait for the first frame to ensure our Flutter UI is underneath
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
      startFlow();
    });
  }

  Future<void> startFlow() async {
    // 1. Logo animation (Scale + Glow)
    await logoController.forward();

    // 2. Show tagline
    await textController.forward();

    // 3. Hold 1 second
    await Future.delayed(const Duration(seconds: 1));

    // 4. Navigate
    if (!mounted) return;
    
    final user = FirebaseAuth.instance.currentUser;
    final bool isLoggedIn = user != null;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            isLoggedIn ? const MainNavigationScreen() : const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    logoController.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061A12), // Match native splash exactly
      body: SizedBox.expand(
        child: AnimatedBuilder(
          animation: Listenable.merge([logoController, textController]),
          builder: (context, _) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔥 LOGO (Sized to match native splash appearance)
                ScaleTransition(
                  scale: scaleAnim,
                  child: Container(
                    height: 160, // Slightly larger for prominence
                    width: 160,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B2F1F),
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: const Color(0xFF64DD17).withOpacity(glowAnim.value),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(36),
                      child: Image.asset(
                        "assets/logo.png",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.trending_up, color: Colors.white, size: 80),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // 🔥 APP NAME (Bolder and larger)
                const Text(
                  "Moniqo",
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),

                const SizedBox(height: 12),

                // 🔥 TAGLINE (Fade in animation)
                Opacity(
                  opacity: textFade.value,
                  child: RichText(
                    text: const TextSpan(
                      text: "Make ",
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                      children: [
                        TextSpan(
                          text: "Smarter",
                          style: TextStyle(color: Color(0xFF64DD17), fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: " Money"),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
