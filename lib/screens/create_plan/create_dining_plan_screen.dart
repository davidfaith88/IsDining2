import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/dining_plan.dart';
import '../../models/contact_group.dart';
import '../../services/group_service.dart';

class CreateDiningPlanScreen extends StatefulWidget {
  const CreateDiningPlanScreen({super.key});

  @override
  State<CreateDiningPlanScreen> createState() => _CreateDiningPlanScreenState();
}

class _CreateDiningPlanScreenState extends State<CreateDiningPlanScreen> {
  final _restaurantController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedTime = DateTime.now().add(const Duration(hours: 2));
  String _visibility = "public";
  List<String> _selectedGroupIds = [];
  List<ContactGroup> _myGroups = [];
  final GroupService _groupService = GroupService();

  final String currentUserId = "current_user_id";

  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  void _loadGroups() {
    _groupService.getUserGroups(currentUserId).listen((groups) {
      if (mounted) setState(() => _myGroups = groups);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Dining Plan"),
        actions: [
          TextButton(
            onPressed: _isPosting ? null : _createPlan,
            child: _isPosting 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text("Post", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GooglePlaceAutoCompleteTextField(
            textEditingController: _restaurantController,
            googleAPIKey: "YOUR_GOOGLE_PLACES_API_KEY_HERE",
            inputDecoration: const InputDecoration(
              labelText: "Where are you eating?",
              hintText: "Search restaurants near you...",
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            debounceTime: 800,
            countries: const ["us"],
          ),

          const SizedBox(height: 20),

          ListTile(
            title: const Text("When are you going?"),
            subtitle: Text(_selectedTime.toString().substring(0, 16)),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDateTime,
          ),

          const SizedBox(height: 20),

          TextFormField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: "Optional note", border: OutlineInputBorder()),
            maxLines: 2,
          ),

          const SizedBox(height: 30),

          const Text("Who should see this?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: "public", label: Text("Public")),
              ButtonSegment(value: "group", label: Text("Groups")),
              ButtonSegment(value: "private", label: Text("Invite Friends")),
            ],
            selected: {_visibility},
            onSelectionChanged: (value) => setState(() => _visibility = value.first),
          ),

          const SizedBox(height: 20),

          if (_visibility == "group" && _myGroups.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Select Groups:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _myGroups.map((group) {
                    final isSelected = _selectedGroupIds.contains(group.id);
                    return FilterChip(
                      label: Text("${group.name} (${group.memberIds.length})"),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) _selectedGroupIds.add(group.id);
                          else _selectedGroupIds.remove(group.id);
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),

          if (_visibility == "private")
            ElevatedButton.icon(
              onPressed: _shareInviteLink,
              icon: const Icon(Icons.share),
              label: const Text("Invite Friends via Link"),
            ),
        ],
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime),
    );
    if (time == null) return;

    setState(() {
      _selectedTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _shareInviteLink() async {
    final String deepLink = "https://isdining.app/invite";
    await Share.share("Join me for dinner on IsDining!\n$deepLink");
  }

  Future<void> _createPlan() async {
    if (_restaurantController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a restaurant"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      final plan = DiningPlan(
        id: const Uuid().v4(),
        creatorId: currentUserId,
        restaurantPlaceId: "temp_place_id",
        restaurantName: _restaurantController.text,
        plannedTime: _selectedTime,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        visibility: _visibility,
        targetGroupIds: _selectedGroupIds,
      );

      await FirebaseFirestore.instance.collection('dining_plans').doc(plan.id).set(plan.toMap());

      // Check if we should notify the owner
      await _checkAndNotifyOwner(plan.restaurantPlaceId, plan.restaurantName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Plan posted successfully! 🎉"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to post plan. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  Future<void> _checkAndNotifyOwner(String placeId, String restaurantName) async {
    // Check if restaurant is already verified
    final verifiedSnapshot = await FirebaseFirestore.instance
        .collection('verified_restaurants')
        .where('placeId', isEqualTo: placeId)
        .get();

    if (verifiedSnapshot.docs.isNotEmpty) return; // Already verified

    // Check if we notified today
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final notifySnapshot = await FirebaseFirestore.instance
        .collection('owner_notifications')
        .where('placeId', isEqualTo: placeId)
        .where('date', isEqualTo: today)
        .get();

    if (notifySnapshot.docs.isNotEmpty) return; // Already notified today

    // Log the intent to notify
    await FirebaseFirestore.instance.collection('owner_notifications').add({
      'placeId': placeId,
      'restaurantName': restaurantName,
      'date': today,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    });

    print("Notification intent logged for $restaurantName");
  }
}