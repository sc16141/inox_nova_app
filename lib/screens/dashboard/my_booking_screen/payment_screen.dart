import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../login_screen/bloc/auth_bloc.dart';
import '../../login_screen/bloc/auth_state.dart';



class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void openCheckout(String userId) async {
    var options = {
      'key': 'rzp_test_xxxxxxxx', // 🔑 Razorpay test key
      'amount': 49900, // 499 INR in paise
      'name': 'Inox Nova Fitness',
      'description': 'Monthly Membership',
      'prefill': {
        'contact': '8382896199',
        'email': 'sheelusingh7905@gmail.com',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final uid = context.read<AuthBloc>().state.userId;
    if (uid != null) {
      await FirebaseFirestore.instance.collection("users").doc(uid).update({
        "membership_active": true,
        "payment_id": response.paymentId,
        "plan": "Monthly",
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Successful! Membership Activated")),
      );
      Navigator.pop(context);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet: ${response.walletName}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state.userId == null) {
            return const Center(child: Text("Please login first"));
          }
          return Center(
            child: ElevatedButton(
              onPressed: () => openCheckout(state.userId!),
              child: const Text("Pay ₹499 for Membership"),
            ),
          );
        },
      ),
    );
  }
}
