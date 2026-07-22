import 'package:flutter/material.dart';
import '../groups/groups_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 60),
          ),
          const SizedBox(height: 16),
          const Text(
            "Your Name", // TODO: Replace with real user name
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const Text(
            "@username", // TODO: Replace with real username
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          ListTile(
            leading: const Icon(Icons.group),
            title: const Text("My Groups"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupsScreen()));
            },
          ),

          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("My Past Plans"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Past plans coming soon")),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Logout
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Logged out")));
            },
            icon: const Icon(Icons.logout),
            label: const Text("Log Out"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}