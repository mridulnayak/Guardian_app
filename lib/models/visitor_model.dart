class VisitorModel {
  String? id;
  String name;
  String phone;
  String purpose;
  DateTime entryTime;
  String status; // e.g., "Checked In", "Checked Out"

  VisitorModel({
    this.id,
    required this.name,
    required this.phone,
    required this.purpose,
    required this.entryTime,
    this.status = "Checked In",
  });

  // Convert to Map to send to Firebase
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "phone": phone,
      "purpose": purpose,
      "entryTime": entryTime.toIso8601String(),
      "status": status,
    };
  }
}