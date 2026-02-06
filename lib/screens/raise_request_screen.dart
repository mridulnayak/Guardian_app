import 'package:flutter/material.dart';
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

  final DatabaseService _dbService = DatabaseService();
  bool _isSending = false;

  void _submitRequest() async {
    if (_nameController.text.trim().isEmpty || _plotController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all details")),
      );
      return;
    }

    setState(() => _isSending = true); // Spinner start

    try {
      // 1. Data bhej rahe hain
      await _dbService.addRequest(
        name: _nameController.text.trim(),
        plot: _plotController.text.trim(),
        plate: widget.plate,
      );

      // 2. Agar yahan tak pahunch gaye, matlab success!
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.green, content: Text("Request Sent!")),
        );
        Navigator.pop(context); // Dashboard pe wapas
      }
    } catch (e) {
      // 3. Error handling: Terminal mein dekho kya likha aa raha hai
      debugPrint("FINAL ERROR CHECK: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      // 4. Sabse zaruri: Spinner ko band karna hi hai
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gate Entry Request"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
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
                const SizedBox(height: 5),
                Text(
                  widget.plate,
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue
                  ),
                ),
                const Divider(height: 30),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Visitor Name",
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _plotController,
                  decoration: const InputDecoration(
                    labelText: "Plot/Flat Number",
                    prefixIcon: Icon(Icons.home),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                      ),
                    ),
                    onPressed: _isSending ? null : _submitRequest,
                    child: _isSending
                        ? const SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2
                      ),
                    )
                        : const Text(
                        "NOTIFY RESIDENT",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _plotController.dispose();
    super.dispose();
  }
}