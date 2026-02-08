import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Note: Ensure this file exists in lib/models/ folder
import '../models/visitor_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Visitor ke exit ko mark karne ke liye
  Future<void> markExit(String docId) async {
    try {
      await _db.collection('requests').doc(docId).update({
        'isExited': true,
        'exitTime': FieldValue.serverTimestamp(), // Analysis ke liye exact exit time
      });
    } catch (e) {
      debugPrint("Exit Error: $e");
    }
  }
  /// 1. Resident Verification
  /// Checks if a plate exists in the 'residents' collection.
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

  /// 2. Logging Entries (For Logs/History)
  Future<void> logVisitor(VisitorModel visitor) async {
    try {
      await _db.collection('visitors').add(visitor.toJson());
    } catch (e) {
      debugPrint("Error logging visitor entry: $e");
    }
  }

  /// 3. Creating Requests (Guard Side) - FIXED ALIGNMENT
  /// Note: Named parameters used to match your Screen's call.
  /// 3. Creating Requests (Guard Side) - UPGRADED FOR ANALYTICS
  Future<void> addRequest({
    required String name,
    required String plot,
    required String plate
  }) async {
    try {
      // Unique ID generate kar rahe hain analysis ke liye
      String requestId = "REQ_${DateTime.now().millisecondsSinceEpoch}";

      await _db.collection('requests').add({
        'requestId': requestId,          // Tracking ke liye
        'visitorName': name,
        'plotToVisit': plot,
        'vehicleNo': plate.toUpperCase().trim(),
        'status': 'pending',             // Default status
        'entryTime': FieldValue.serverTimestamp(), // Analysis: Kis waqt bheed hoti hai?
        'dayOfWeek': DateTime.now().weekday,       // Analysis: Kaunse din jyada visitors aate hain?
        'residentID': "RES_$plot",       // Analysis: Kaunsa resident sabse jyada active hai?
        'isExited': false,               // Future feature: Exit tracking
      });
    } catch (e) {
      debugPrint("Firestore Error: $e");
      rethrow;
    }
  }
  /// 4. Real-time Request Stream (Resident/Guard Side)
  /// Used in 'Check Status' and 'Resident View'
  Stream<QuerySnapshot> getPendingRequests() {
    return _db
        .collection('requests')
        .where('status', isEqualTo: 'pending')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// 5. Status Updates (Resident Simulation)
  /// Approves or rejects a specific request.
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