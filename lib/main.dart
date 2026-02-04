import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// Correct paths based on your new folders
import 'screens/raise_request_screen.dart';
import 'screens/resident_view.dart';
import 'services/database_service.dart';
import 'screens/details_screen.dart'; // No folder prefix because it's in root lib
import 'screens/scan_screen.dart';    // No folder prefix because it's in root lib

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ye line miss mat karna
  await Firebase.initializeApp();
  runApp(const MyApp());
}
class GuardianApp extends StatelessWidget {
  const GuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Society Guardian',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const GuardDashboard(),
    );
  }
}

class GuardDashboard extends StatelessWidget {
  const GuardDashboard({super.key});

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, Widget page) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Society Guardian"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Welcome back,", style: TextStyle(color: Colors.grey)),
              subtitle: Text("Main Gate Security", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              trailing: CircleAvatar(backgroundColor: Colors.indigo, child: Icon(Icons.security, color: Colors.white)),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildMenuCard(context, "Scan Vehicle", Icons.document_scanner, Colors.blue, const ScanScreen()),
                  _buildMenuCard(context, "Resident View", Icons.person_search, Colors.orange, const ResidentView()),
                  _buildMenuCard(context, "Check Status", Icons.rule, Colors.green, const PlaceholderScreen("Status Tracking")),
                  _buildMenuCard(context, "Logs / History", Icons.history, Colors.purple, const DetailsScreen()),
                ],
              ),
            ),
            // Quick Status Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.indigo),
                  SizedBox(width: 10),
                  Expanded(child: Text("Ensure license plates are clearly visible before scanning.")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String name;
  const PlaceholderScreen(this.name, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(name)), body: Center(child: Text("$name integration pending.")));
}