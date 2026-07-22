import 'package:flutter/material.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Go Premium")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            const Text(
              "Unlock Premium Features",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              "Only \$2/month",   // Escaped $
              style: TextStyle(fontSize: 24, color: Colors.green, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            const Text(
              "• Advanced analytics\n"
              "• Priority notifications\n"
              "• Custom branding\n"
              "• No developer tip prompts\n"
              "• Monthly reports",
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Premium subscription coming soon! (\$2/month)"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text("Subscribe for \$2/month"),  // Escaped $
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Maybe later"),
            ),
          ],
        ),
      ),
    );
  }
}