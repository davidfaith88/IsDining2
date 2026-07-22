import 'package:cloud_firestore/cloud_firestore.dart';

class DiningPlan {
  final String id;
  final String creatorId;
  final String restaurantPlaceId;
  final String restaurantName;
  final DateTime plannedTime;
  final String? note;
  final String visibility;
  final List<String> targetGroupIds;
  final List<String> invitedUserIds;
  final List<String> committedUserIds;
  final List<String> invitedNonUsers; // New: for deep link invites

  DiningPlan({
    required this.id,
    required this.creatorId,
    required this.restaurantPlaceId,
    required this.restaurantName,
    required this.plannedTime,
    this.note,
    required this.visibility,
    this.targetGroupIds = const [],
    this.invitedUserIds = const [],
    this.committedUserIds = const [],
    this.invitedNonUsers = const [],
  });

  // ... fromMap and toMap methods (add invitedNonUsers)
  factory DiningPlan.fromMap(Map<String, dynamic> map, String id) {
    return DiningPlan(
      id: id,
      creatorId: map['creatorId'],
      restaurantPlaceId: map['restaurantPlaceId'],
      restaurantName: map['restaurantName'],
      plannedTime: (map['plannedTime'] as Timestamp).toDate(),
      note: map['note'],
      visibility: map['visibility'],
      targetGroupIds: List<String>.from(map['targetGroupIds'] ?? []),
      invitedUserIds: List<String>.from(map['invitedUserIds'] ?? []),
      committedUserIds: List<String>.from(map['committedUserIds'] ?? []),
      invitedNonUsers: List<String>.from(map['invitedNonUsers'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'creatorId': creatorId,
      'restaurantPlaceId': restaurantPlaceId,
      'restaurantName': restaurantName,
      'plannedTime': Timestamp.fromDate(plannedTime),
      'note': note,
      'visibility': visibility,
      'targetGroupIds': targetGroupIds,
      'invitedUserIds': invitedUserIds,
      'committedUserIds': committedUserIds,
      'invitedNonUsers': invitedNonUsers,
    };
  }
}