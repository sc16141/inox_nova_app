import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../login_screen/bloc/auth_bloc.dart';
import '../login_screen/bloc/auth_state.dart';

class SessionBookingScreen extends StatelessWidget {
  const SessionBookingScreen({super.key});

  Future<void> _bookSession(BuildContext context, String sessionType, String userId) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(width: 16),
              Text("Booking $sessionType session..."),
            ],
          ),
          duration: const Duration(days: 365), // Show indefinitely
          backgroundColor: Colors.blue[700],
        ),
      );

      await FirebaseFirestore.instance.collection("bookings").add({
        "userId": userId,
        "sessionType": sessionType,
        "bookingDate": DateTime.now().toIso8601String(),
        "status": "booked",
      });

      // Hide loading indicator and show success message
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$sessionType session booked successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to book: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Book a Session", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state.userId == null) {
            return const Center(child: Text("Please login first"));
          }

          final uid = state.userId!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSessionCard(
                  context: context,
                  title: "Yoga & Meditation",
                  subtitle: "Find your balance and calm.",
                  imagePath: "assets/images/yoga.jpg", // Replace with your image asset
                  onPressed: () => _bookSession(context, "Yoga", uid),
                ),
                const SizedBox(height: 20),
                _buildSessionCard(
                  context: context,
                  title: "Gym Workout",
                  subtitle: "Build strength and endurance.",
                  imagePath: "assets/images/gym.jpg", // Replace with your image asset
                  onPressed: () => _bookSession(context, "Gym", uid),
                ),
                const SizedBox(height: 20),
                _buildSessionCard(
                  context: context,
                  title: "Zumba Class",
                  subtitle: "Dance your way to fitness.",
                  imagePath: "assets/images/zumba.jpg", // Replace with your image asset
                  onPressed: () => _bookSession(context, "Zumba", uid),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSessionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String imagePath,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.asset(
                imagePath,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: const Text('Image not found', style: TextStyle(color: Colors.grey)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text("Book Now"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}