import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';

class OwnerVerificationScreen extends StatefulWidget {
  const OwnerVerificationScreen({super.key});

  @override
  State<OwnerVerificationScreen> createState() => _OwnerVerificationScreenState();
}

class _OwnerVerificationScreenState extends State<OwnerVerificationScreen> {
  final _restaurantNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _emailVerified = false;
  bool _phoneVerified = false;

  Future<void> _submitVerification() async {
    if (_restaurantNameController.text.isEmpty || !_emailVerified || !_phoneVerified) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please complete all fields")));
      return;
    }

    await FirebaseFirestore.instance.collection('verified_restaurants').add({
      'restaurantName': _restaurantNameController.text,
      'ownerId': AuthService().getCurrentUserId() ?? "current_user_id",
      'email': _emailController.text,
      'phone': _phoneController.text,
      'verifiedAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Verification submitted!")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Restaurant")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text("Verify Your Restaurant", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),

            TextFormField(controller: _restaurantNameController, decoration: const InputDecoration(labelText: "Restaurant Name")),
            const SizedBox(height: 16),

            TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: "Business Email")),
            ElevatedButton(
              onPressed: () => setState(() => _emailVerified = true),
              child: Text(_emailVerified ? "✓ Email Verified" : "Verify Email"),
            ),

            const SizedBox(height: 16),

            TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: "Business Phone")),
            ElevatedButton(
              onPressed: () => setState(() => _phoneVerified = true),
              child: Text(_phoneVerified ? "✓ Phone Verified" : "Verify Phone"),
            ),

            const SizedBox(height: 40),
            ElevatedButton(onPressed: _submitVerification, child: const Text("Complete Verification")),
          ],
        ),
      ),
    );
  }
}