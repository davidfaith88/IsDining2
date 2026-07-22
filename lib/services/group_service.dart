import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contact_group.dart';

class GroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<ContactGroup> createGroup(String ownerId, String name, List<String> memberIds) async {
    final docRef = _firestore.collection('groups').doc();
    final group = ContactGroup(
      id: docRef.id,
      ownerId: ownerId,
      name: name,
      memberIds: memberIds,
      createdAt: DateTime.now(),
    );

    await docRef.set(group.toMap());
    return group;
  }

  Stream<List<ContactGroup>> getUserGroups(String userId) {
    return _firestore
        .collection('groups')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ContactGroup.fromMap(doc.data(), doc.id))
            .toList());
  }
}