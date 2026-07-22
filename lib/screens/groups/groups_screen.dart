import 'package:flutter/material.dart';
import '../../services/group_service.dart';
import '../../models/contact_group.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final GroupService _groupService = GroupService();

  @override
  Widget build(BuildContext context) {
    final String userId = "current_user_id"; // TODO: Replace with real user ID

    return Scaffold(
      appBar: AppBar(title: const Text("My Groups")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateGroupDialog(context),
        child: const Icon(Icons.group_add),
      ),
      body: StreamBuilder<List<ContactGroup>>(
        stream: _groupService.getUserGroups(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final groups = snapshot.data!;

          if (groups.isEmpty) {
            return const Center(child: Text("No groups yet.\nTap + to create one."));
          }

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return ListTile(
                title: Text(group.name),
                subtitle: Text("${group.memberIds.length} members"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Open group detail later
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Group"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Group Name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await _groupService.createGroup("current_user_id", nameController.text, []);
                Navigator.pop(context);
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }
}