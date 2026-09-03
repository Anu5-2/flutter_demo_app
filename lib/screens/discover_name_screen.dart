import 'package:flutter/material.dart';
import '../constants.dart';
import 'login_screen.dart';

class DiscoverNameScreen extends StatelessWidget {
  const DiscoverNameScreen({super.key});

  static const _features = [
    _Feature(
      icon: Icons.shield_outlined,
      letter: 'P',
      title: 'Protect',
      description: 'Always know where your pet is, in real time.',
    ),
    _Feature(
      icon: Icons.favorite_border,
      letter: 'E',
      title: 'Embrace',
      description: 'Safety wrapped in love, not restrictions.',
    ),
    _Feature(
      icon: Icons.show_chart,
      letter: 'T',
      title: 'Track',
      description: 'Live location updates inside a zone you define.',
    ),
    _Feature(
      icon: Icons.location_on_outlined,
      letter: 'Z',
      title: 'Zone',
      description: 'A custom geofence that moves with your peace of mind.',
    ),
    _Feature(
      icon: Icons.show_chart,
      letter: 'O',
      title: 'Observe',
      description: 'Instant alerts the moment boundaries are crossed.',
    ),
    _Feature(
      icon: Icons.shield_outlined,
      letter: 'N',
      title: 'Notify',
      description: 'Your phone becomes the guardian of their freedom.',
    ),
    _Feature(
      icon: Icons.favorite_border,
      letter: 'E',
      title: 'Ease',
      description: 'One tap to check in. One less thing to worry about.',
    ),
  ];

  void _goToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              const Text(
                'What PET ZONE means',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Every letter stands for a promise we make to you and your pet.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey, fontSize: 14.5),
              ),
              const SizedBox(height: 28),

              // Feature grid
              LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 12.0;
                  final columns = constraints.maxWidth > 600 ? 3 : 2;
                  final cardWidth =
                      (constraints.maxWidth - spacing * (columns - 1)) /
                          columns;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      for (final feature in _features)
                        SizedBox(
                          width: cardWidth,
                          child: _FeatureCard(feature: feature),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 36),

              // CTA card
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                decoration: BoxDecoration(
                  color: AppColors.ctaNavy,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Your pet's safe zone is one login away.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Track boundaries, receive instant alerts, and give '
                      'your best friend the freedom they deserve.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFC5CCD6),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => _goToLogin(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Log in to ${AppStrings.appName}',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Center(
                child: Text(
                  '© ${DateTime.now().year} ${AppStrings.appName}. '
                  'Keeping tails wagging safely.',
                  style:
                      const TextStyle(color: AppColors.textGrey, fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String letter;
  final String title;
  final String description;

  const _Feature({
    required this.icon,
    required this.letter,
    required this.title,
    required this.description,
  });
}

class _FeatureCard extends StatelessWidget {
  final _Feature feature;
  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentOrangeBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(feature.icon, color: AppColors.accentOrange, size: 18),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.textDark,
              ),
              children: [
                TextSpan(
                  text: feature.letter,
                  style: const TextStyle(color: AppColors.accentOrange),
                ),
                TextSpan(text: feature.title.substring(1)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            feature.description,
            style: const TextStyle(
                color: AppColors.textGrey, fontSize: 12.5, height: 1.3),
          ),
        ],
      ),
    );
  }
}
