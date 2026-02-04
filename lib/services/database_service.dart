import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Note: If 'visitor_model.dart' still shows red, ensure the filename is exactly
// visitor_model.dart and it is inside the lib/models/ folder.
import '../models/visitor_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 1. Resident Verification
  /// Checks if a plate exists as a Document ID in the 'residents' collection.
  Future<bool> isResident(String plateNumber) async {
    try {
      final doc = await _db
          .collection('residents')
          .doc(plateNumber.toUpperCase().trim())
          .get();
      return doc.exists;
    } catch (e) {
      debugPrint("Error checking resident status: $e");
      return false;
    }
  }

  /// 2. Logging Entries
  /// Saves a record of the entry to the 'visitors' history.
  Future<void> logVisitor(VisitorModel visitor) async {
    try {
      // Ensure your VisitorModel has a toJson() method.
      await _db.collection('visitors').add(visitor.toJson());
    } catch (e) {
      debugPrint("Error logging visitor entry: $e");
    }
  }

  /// 3. Creating Requests (Guard Side)
  /// Adds a new entry to the 'requests' collection with a 'pending' status.
  Future<void> raiseVisitorRequest({
    required String plate,
    required String name,
    required String plot,
  }) async {
    try {
      await _db.collection('requests').add({
        'plateNumber': plate.toUpperCase().trim(),
        'visitorName': name.trim(),
        'plotNo': plot.trim(),
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error raising visitor request: $e");
    }
  }

  /// 4. Real-time Request Stream (Resident Side)
  /// Listens for new pending requests.
  ///
  Stream<QuerySnapshot> getPendingRequests() {
    return _db
        .collection('requests')
        .where('status', isEqualTo: 'pending')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// 5. Status Updates (Resident Side)
  /// Approves or rejects a specific request via its Document ID.
  Future<void> updateRequestStatus(String docId, String newStatus) async {
    try {
      await _db.collection('requests').doc(docId).update({
        'status': newStatus,
      });
    } catch (e) {
      debugPrint("Error updating request status: $e");
    }
  }
}