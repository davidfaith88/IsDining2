import 'package:cloud_firestore/cloud_firestore.dart';

class ContactGroup {
  final String id;
  final String ownerId;
  final String name;
  final List<String> memberIds;
  final DateTime createdAt;

  ContactGroup({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.memberIds,
    required this.createdAt,
  });

  factory ContactGroup.fromMap(Map<String, dynamic> map, String id) {
    return ContactGroup(
      id: id,
      ownerId: map['ownerId'],
      name: map['name'],
      memberIds: List<String>.from(map['memberIds'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'memberIds': memberIds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}