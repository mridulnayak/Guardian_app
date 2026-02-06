import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';

class ResidentView extends StatelessWidget {
  const ResidentView({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService dbService = DatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Incoming Approvals"),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: dbService.getPendingRequests(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text("No pending requests", style: TextStyle(color: Colors.grey))
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orangeAccent,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  // FIXED: plotNo hata kar plotToVisit use kiya
                  title: Text(
                    "${data['visitorName']} (Plot ${data['plotToVisit']})",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // FIXED: plateNumber hata kar vehicleNo use kiya
                  subtitle: Text("Vehicle: ${data['vehicleNo']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Approve Button
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green, size: 30),
                        onPressed: () async {
                          await dbService.updateRequestStatus(doc.id, 'approved');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Entry Approved"))
                            );
                          }
                        },
                      ),
                      // Decline Button
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
                        onPressed: () async {
                          await dbService.updateRequestStatus(doc.id, 'declined');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Entry Declined"))
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}