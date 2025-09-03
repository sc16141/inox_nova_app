import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inox_nova/screens/dashboard/session_booking_screen.dart';

import '../login_screen/bloc/auth_bloc.dart';
import '../login_screen/bloc/auth_event.dart';
import '../login_screen/bloc/auth_state.dart';
import '../login_screen/login_screen.dart';
import 'my_booking_screen/marking_attendence_qr.dart';
import 'my_booking_screen/payment_screen.dart';


class DashboardScreen extends StatelessWidget {
  final String userId;
  const DashboardScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (!state.isLoading && state.userId == null) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => LoginScreen()),
                  (_) => false,
            );
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          if (state.userId == null) {
            return const Center(child: Text("Please login first"));
          }

          final uid = state.userId!;
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text("No profile data found"));
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;
              final name = data['name'] ?? 'User';
              final email = data['email'] ?? '';

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 180.0,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.only(left: 20.0, bottom: 20.0),
                      title: Text(
                        "Hi, $name",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[700]!, Colors.blue[900]!],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40.0, right: 16.0),
                            child: IconButton(
                              icon: const Icon(Icons.logout, color: Colors.white, size: 28),
                              onPressed: () {
                                context.read<AuthBloc>().add(AuthLogoutRequested());
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Your Progress'),
                              _buildProgressCard(0.7),
                              const SizedBox(height: 24),
                              _buildSectionTitle('Quick Actions'),
                              _buildActionButtons(context),
                              const SizedBox(height: 24),
                              _buildSectionTitle('Upcoming Sessions'),
                              _buildUpcomingSessionsList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildProgressCard(double value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Goal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: value,
              minHeight: 12,
              backgroundColor: Colors.grey[300],
              color: Colors.blue[700],
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 8),
            Text(
              '${(value * 100).toInt()}% completed today',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionButton(
              icon: Icons.calendar_today,
              label: 'Book Session',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SessionBookingScreen()),
                );
              },
            ),
            _buildActionButton(
              icon: Icons.qr_code_scanner,
              label: 'Scan QR',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QRScannerScreen() ),
                );
              },
            ),
            _buildActionButton(
              icon: Icons.shopping_cart,
              label: 'Buy Membership',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaymentScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: Colors.blue[700]),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSessionsList() {
    // This is a placeholder for your actual data-driven list.
    // Replace this with a StreamBuilder or FutureBuilder to fetch real data.
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.access_time, color: Colors.blue),
              title: Text('CrossFit Session', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Today, 6:00 PM - Trainer: Jane Doe'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.access_time, color: Colors.blue),
              title: Text('Yoga Class', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Tomorrow, 7:00 AM - Trainer: John Smith'),
            ),
          ],
        ),
      ),
    );
  }
}