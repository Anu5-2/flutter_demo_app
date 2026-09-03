import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants.dart';
import 'discover_name_screen.dart';
import 'login_screen.dart';

class HeroLandingScreen extends StatefulWidget {
  const HeroLandingScreen({super.key});

  @override
  State<HeroLandingScreen> createState() => _HeroLandingScreenState();
}

class _HeroLandingScreenState extends State<HeroLandingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweepController;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/petzone-hero-bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.15)),
          ),

          // Animated radar sweep overlay, positioned roughly where the
          // badge sits in the background art (center, upper-middle area).
          Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: const Alignment(0, -0.28),
                child: AnimatedBuilder(
                  animation: _sweepController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _sweepController.value * 2 * math.pi,
                      child: child,
                    );
                  },
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: CustomPaint(
                      painter: _RadarSweepPainter(
                        color: AppColors.accentOrange,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(Icons.location_on,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        AppStrings.appName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 8),
                        ),
                        child: const Text('Log in',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                          children: [
                            TextSpan(
                                text: 'PET ',
                                style: TextStyle(color: Colors.white)),
                            TextSpan(
                                text: 'ZONE',
                                style:
                                    TextStyle(color: AppColors.accentOrange)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'A safe digital boundary drawn around the pet you '
                        'love. Where protection meets freedom.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 22, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Enter your zone',
                                    style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700)),
                                SizedBox(width: 6),
                                Icon(Icons.arrow_forward, size: 16),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const DiscoverNameScreen()),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.4)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 22, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text('Discover the name',
                                style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints a thin rotating sweep line + faint trailing arc, like a radar scan.
class _RadarSweepPainter extends CustomPainter {
  final Color color;
  _RadarSweepPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Faint trailing arc (the "sweep tail")
    final tailPaint = Paint()
      ..shader = SweepGradient(
        colors: [color.withValues(alpha: 0.0), color.withValues(alpha: 0.35)],
        startAngle: 0,
        endAngle: math.pi / 2,
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    final tailPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        math.pi / 2,
        false,
      )
      ..close();
    canvas.drawPath(tailPath, tailPaint);

    // Bright leading sweep line
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - radius),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RadarSweepPainter oldDelegate) => false;
}
