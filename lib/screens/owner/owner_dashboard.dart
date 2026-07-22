import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/dining_plan.dart';
import 'premium_screen.dart';   // New import

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Owner Dashboard"),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()));
            },
            icon: const Icon(Icons.star, color: Colors.orange),
            label: const Text("Premium", style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('dining_plans')
            .orderBy('plannedTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final plans = snapshot.data!.docs
              .map((doc) => DiningPlan.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          if (plans.isEmpty) {
            return const Center(child: Text("No upcoming plans yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: plans.length,
            itemBuilder: (context, index) => _buildPlanTile(context, plans[index]),
          );
        },
      ),
    );
  }

  Widget _buildPlanTile(BuildContext context, DiningPlan plan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.restaurant, color: Colors.orange, size: 32),
        title: Text(plan.restaurantName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${plan.plannedTime.toString().substring(0, 16)}\n${plan.committedUserIds.length} interested"),
        trailing: ElevatedButton(
          onPressed: () => _showIncentiveDialog(context, plan),
          child: const Text("Send Offer"),
        ),
      ),
    );
  }

  void _showIncentiveDialog(BuildContext context, DiningPlan plan) {
    final messageController = TextEditingController(text: "Free dessert for your table tonight!");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create Incentive"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: "What are you offering?",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final incentiveCode = "INC-${DateTime.now().millisecondsSinceEpoch}";
              final qrData = "IsDining-${plan.id}-$incentiveCode";

              Navigator.pop(context);
              _showQRCodeDialog(context, qrData, messageController.text, incentiveCode);
            },
            child: const Text("Generate QR Code"),
          ),
        ],
      ),
    );
  }

  void _showQRCodeDialog(BuildContext context, String qrData, String offerText, String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Offer QR Code"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 220,
            ),
            const SizedBox(height: 16),
            Text(offerText, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("Code: $code", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            const Text("Guest shows this QR code at your restaurant", style: TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Offer marked as redeemed")),
              );
              Navigator.pop(context);
            },
            child: const Text("Mark as Redeemed"),
          ),
        ],
      ),
    );
  }
}