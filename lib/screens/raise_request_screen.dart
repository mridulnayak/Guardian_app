import 'package:flutter/material.dart';
// 1. Updated Import: Pointing to your new service file
import '../services/database_service.dart';

class RaiseRequestScreen extends StatefulWidget {
  final String plate;
  const RaiseRequestScreen({super.key, required this.plate});

  @override
  State<RaiseRequestScreen> createState() => _RaiseRequestScreenState();
}

class _RaiseRequestScreenState extends State<RaiseRequestScreen> {
  final _nameController = TextEditingController();
  final _plotController = TextEditingController();

  // 2. Initialize the Service
  final DatabaseService _dbService = DatabaseService();
  bool _isSending = false;

  void _submitRequest() async {
    if (_nameController.text.isEmpty || _plotController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all details")),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      // 3. Use the Service instead of direct Firestore calls
      await _dbService.raiseVisitorRequest(
        plate: widget.plate,
        name: _nameController.text.trim(),
        plot: _plotController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.green,
              content: Text("Request Sent to Resident!")
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gate Entry Request"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Vehicle Detected", style: TextStyle(color: Colors.grey)),
                Text(widget.plate, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
                const Divider(height: 30),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Visitor Name", prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _plotController,
                  decoration: const InputDecoration(labelText: "Plot/Flat Number", prefixIcon: Icon(Icons.home)),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    onPressed: _isSending ? null : _submitRequest,
                    child: _isSending
                        ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                        : const Text("NOTIFY RESIDENT", style: TextStyle(fontSize: 16)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}