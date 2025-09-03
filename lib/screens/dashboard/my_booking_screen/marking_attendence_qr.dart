import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool scanned = false;

  Future<void> _handleScan(String bookingId) async {
    try {
      await FirebaseFirestore.instance
          .collection("bookings")
          .doc(bookingId)
          .update({"status": "attended"});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Attendance marked!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR Code")),
      body: MobileScanner(
        onDetect: (capture) {
          if (scanned) return;
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            final bookingId = barcode.rawValue;
            if (bookingId != null && !scanned) {
              scanned = true;
              _handleScan(bookingId);
            }
          }
        },
      ),
    );
  }
}
