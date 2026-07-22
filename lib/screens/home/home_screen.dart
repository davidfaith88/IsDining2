import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../create_plan/create_dining_plan_screen.dart';
import '../owner/owner_dashboard.dart';
import '../owner/owner_verification_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/plan_card.dart';
import '../../models/dining_plan.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isOwnerMode = false;
  bool _isVerifiedOwner = false;

  @override
  void initState() {
    super.initState();
    _checkOwnerStatus();
  }

  Future<void> _checkOwnerStatus() async {
    final String userId = "current_user_id"; // TODO: Replace with real auth
    final snapshot = await FirebaseFirestore.instance
        .collection('verified_restaurants')
        .where('ownerId', isEqualTo: userId)
        .get();

    setState(() => _isVerifiedOwner = snapshot.docs.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("IsDining"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
          Switch(
            value: _isOwnerMode,
            onChanged: (value) => setState(() => _isOwnerMode = value),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Text("Owner Mode", style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
      floatingActionButton: _isOwnerMode 
          ? null 
          : FloatingActionButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateDiningPlanScreen())),
              child: const Icon(Icons.add),
            ),
      body: _isOwnerMode
          ? (_isVerifiedOwner ? const OwnerDashboard() : const OwnerVerificationScreen())
          : _buildDinerFeed(),
    );
  }

  Widget _buildDinerFeed() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('dining_plans')
          .orderBy('plannedTime')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final plans = snapshot.data?.docs
            .map((doc) => DiningPlan.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList() ?? [];

        if (plans.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No plans yet.\nBe the first to create one!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: plans.length,
          itemBuilder: (context, index) => PlanCard(plan: plans[index]),
        );
      },
    );
  }
}