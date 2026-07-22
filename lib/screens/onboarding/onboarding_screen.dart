import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterCarousel(
        options: CarouselOptions(
          height: double.infinity,
          viewportFraction: 1.0,
          enableInfiniteScroll: false,
          showIndicator: true,
        ),
        items: [
          _buildOnboardingPage(
            icon: Icons.restaurant,
            title: "Welcome to IsDining",
            description: "See what your friends are eating and join them.",
            color: Colors.orange,
          ),
          _buildOnboardingPage(
            icon: Icons.group,
            title: "Create Groups",
            description: "Organize your friends and send targeted plans.",
            color: Colors.deepOrange,
          ),
          _buildOnboardingPage(
            icon: Icons.card_giftcard,
            title: "For Restaurant Owners",
            description: "Get notified of plans and send incentives to guests.",
            color: Colors.green,
            buttonText: "Get Started",
            onButtonPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return Container(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 120, color: color),
            const SizedBox(height: 40),
            Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
            if (buttonText != null) ...[
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: onButtonPressed,
                child: Text(buttonText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}