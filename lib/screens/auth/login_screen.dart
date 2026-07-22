import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.restaurant, size: 100, color: Colors.orange),
              const SizedBox(height: 40),
              const Text(
                "IsDining",
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const Text("Dine together.", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 60),

              ElevatedButton.icon(
                onPressed: () async {
                  final user = await authService.signInWithFacebook();
                  if (user != null && context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  }
                },
                icon: const Icon(Icons.facebook, size: 28),
                label: const Text("Continue with Facebook", style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "We only use Facebook to find your friends.\nNo spam. Ever.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}