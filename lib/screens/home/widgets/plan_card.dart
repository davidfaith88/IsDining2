import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/dining_plan.dart';

class PlanCard extends StatelessWidget {
  final DiningPlan plan;

  const PlanCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Someone is going to", style: Theme.of(context).textTheme.bodySmall),
                      Text(plan.restaurantName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text("📅 ${plan.plannedTime.toString().substring(0, 16)}"),
            if (plan.note != null && plan.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(plan.note!, style: const TextStyle(fontStyle: FontStyle.italic)),
            ],
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                plan.visibility.toUpperCase(),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("You're in! 🎉")),
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("I'm In"),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final url = Uri.parse("https://www.opentable.com");
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.table_restaurant),
                  label: const Text("Reserve Table"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}