import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../login_screen/bloc/auth_bloc.dart';
import '../../login_screen/bloc/auth_state.dart';

class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({super.key});

  Future<void> _handleDetection(
      BuildContext context, String bookingId, String uid) async {
    await FirebaseFirestore.instance
        .collection("bookings")
        .doc(bookingId)
        .update({
      "status": "Attended",
      "attendedBy": uid,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Attendance marked for $bookingId")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR for Attendance")),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state.userId == null) {
            return const Center(child: Text("Please login first"));
          }
          final uid = state.userId!;

          return MobileScanner(
            onDetect: (BarcodeCapture capture) {
              for (final barcode in capture.barcodes) {
                final bookingId = barcode.rawValue;
                if (bookingId != null) {
                  _handleDetection(context, bookingId, uid);
                }
              }
            },
          );
        },
      ),
    );
  }
}
