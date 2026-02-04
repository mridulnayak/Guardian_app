import 'package:flutter/material.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RESIDENT INFO"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.indigo,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          _infoTile("Head of House", "Mridul Nayak", Icons.account_box),
          _infoTile("Plot Number", "B10/17", Icons.home),
          const Divider(),
          const Text("Family Members", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
          _infoTile("Member 1", "Tejashvi Nayak", Icons.people),
          _infoTile("Member 2", "Somdatt Nayak", Icons.people),
          const Divider(),
          const Text("Registered Vehicles", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
          _infoTile("Car", "i10 (CG07SDXXXX)", Icons.directions_car),
          _infoTile("Bike", "CB Shine (CG07XDXXXX)", Icons.motorcycle),
        ],
      ),
    );
  }

  // A reusable helper function to keep your code clean
  Widget _infoTile(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}