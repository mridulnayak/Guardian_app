import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// 1. Corrected paths: Only one '../' is needed to go from lib/screens to lib/
import '../services/database_service.dart';
import '../models/visitor_model.dart';

// 2. Local screen imports
import 'details_screen.dart';
import 'raise_request_screen.dart'; // UNCOMMENT THIS - This fixes the 'RaiseRequestScreen' error
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  final TextRecognizer _textRecognizer = TextRecognizer();
  final DatabaseService _dbService = DatabaseService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _controller!.initialize();
        if (!mounted) return;
        setState(() {});
      }
    } catch (e) {
      debugPrint("Camera error: $e");
    }
  }

  // BUSINESS LOGIC: Resident Check & Branching
  Future<void> _processAndSave(String scannedText) async {
    if (scannedText.trim().isEmpty) return;

    // Clean the scanned text (Remove special characters/spaces)
    String cleanPlate = scannedText.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();

    setState(() => _isProcessing = true);

    try {
      // 1. Check if vehicle belongs to a resident
      bool isResident = await _dbService.isResident(cleanPlate);

      if (isResident) {
        // --- GREEN SIGNAL PATH ---
        _showResultDialog(
          title: "RESIDENT DETECTED",
          message: "Vehicle $cleanPlate is registered.\nGate Opening...",
          icon: Icons.check_circle,
          color: Colors.green,
        );

        // Auto-log the entry as a Resident
        await _dbService.logVisitor(VisitorModel(
          name: "Resident",
          phone: cleanPlate,
          purpose: "Resident Entry",
          entryTime: DateTime.now(),
          status: "Verified",
        ));
      } else {
        // --- ORANGE SIGNAL PATH (GUEST) ---
        _showResultDialog(
          title: "UNKNOWN VEHICLE",
          message: "Plate $cleanPlate not found.\nRedirecting to Request Form...",
          icon: Icons.warning,
          color: Colors.orange,
        );

        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          Navigator.pop(context); // Close the dialog first
          // Pass the scanned plate to the RaiseRequestScreen
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => RaiseRequestScreen(plate: cleanPlate)
          ));
        }
      }
    } catch (e) {
      debugPrint("Database Error: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // UI Helper for the Green/Orange Pop-up
  void _showResultDialog({required String title, required String message, required IconData icon, required Color color}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 60),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _scanText() async {
    if (_controller == null || _isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final XFile image = await _controller!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      if (mounted) {
        await _processAndSave(recognizedText.text);
      }
    } catch (e) {
      debugPrint("OCR Error: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Vehicle Scanner"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Positioned.fill(child: CameraPreview(_controller!)),

          // The Overlay Mask
          ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.srcOut),
            child: Stack(
              children: [
                Container(decoration: const BoxDecoration(color: Colors.black, backgroundBlendMode: BlendMode.dstOut)),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 320,
                    height: 150,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),

          // Viewfinder Frame
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 320,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.indigoAccent, width: 3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          if (_isProcessing)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanText,
        backgroundColor: Colors.indigo,
        label: const Text("SCAN PLATE", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}