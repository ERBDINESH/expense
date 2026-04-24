import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController mainController;
  late AnimationController particleController;

  late Animation<double> logoScale;
  late Animation<double> logoFade;
  late Animation<double> barAnim;
  late Animation<double> graphAnim;
  late Animation<double> textFade;

  @override
  void initState() {
    super.initState();

    mainController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));

    particleController =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();

    logoScale = Tween(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: mainController, curve: Curves.easeOutBack),
    );

    logoFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: mainController, curve: Curves.easeIn),
    );

    barAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: mainController, curve: const Interval(0.3, 0.7)),
    );

    graphAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: mainController, curve: const Interval(0.5, 1.0)),
    );

    textFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: mainController, curve: const Interval(0.6, 1.0)),
    );

    mainController.forward();

    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    mainController.dispose();
    particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([mainController, particleController]),
        builder: (context, _) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF061A12), Color(0xFF0B2F1F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // 🔹 PARTICLES
                CustomPaint(
                  size: Size.infinite,
                  painter: ParticlePainter(particleController.value),
                ),

                // 🔹 MAIN CONTENT
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeTransition(
                        opacity: logoFade,
                        child: ScaleTransition(
                          scale: logoScale,
                          child: CustomPaint(
                            size: const Size(120, 120),
                            painter: LogoPainter(barAnim.value),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Opacity(
                        opacity: textFade.value,
                        child: Column(
                          children: const [
                            Text(
                              "Moniqo",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 6),
                          ],
                        ),
                      ),

                      Opacity(
                        opacity: textFade.value,
                        child: RichText(
                          text: const TextSpan(
                            text: "Make ",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 16),
                            children: [
                              TextSpan(
                                text: "Smarter",
                                style: TextStyle(
                                  color: Color(0xFF64DD17),
                                ),
                              ),
                              TextSpan(text: " Money"),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // 🔹 GRAPH LINE
                      CustomPaint(
                        size: const Size(200, 80),
                        painter: GraphPainter(graphAnim.value),
                      ),

                      const SizedBox(height: 40),

                      // 🔹 LOADING BAR
                      SizedBox(
                        width: 200,
                        child: LinearProgressIndicator(
                          value: mainController.value,
                          minHeight: 6,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xFF64DD17),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

//
// 🔥 LOGO PAINTER (Bars Grow)
//
class LogoPainter extends CustomPainter {
  final double progress;
  LogoPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00C853), Color(0xFF64DD17)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final barWidth = size.width / 6;

    for (int i = 0; i < 3; i++) {
      double height = (i + 1) * size.height * 0.2 * progress;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(i * barWidth * 1.5 + 20,
              size.height - height, barWidth, height),
          const Radius.circular(6),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

//
// 🔥 GRAPH LINE
//
class GraphPainter extends CustomPainter {
  final double progress;
  GraphPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF64DD17)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();

    List<Offset> points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.3, size.height * 0.5),
      Offset(size.width * 0.6, size.height * 0.6),
      Offset(size.width, size.height * 0.2),
    ];

    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      double x = lerp(points[i - 1].dx, points[i].dx, progress);
      double y = lerp(points[i - 1].dy, points[i].dy, progress);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  double lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

//
// 🔥 PARTICLES
//
class ParticlePainter extends CustomPainter {
  final double progress;
  ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.greenAccent;

    for (int i = 0; i < 20; i++) {
      double x = (i * 37 % size.width);
      double y = (progress * size.height + i * 50) % size.height;

      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
