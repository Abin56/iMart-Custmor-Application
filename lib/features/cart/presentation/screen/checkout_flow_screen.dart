import 'package:flutter/material.dart';

import 'address_session_screen.dart';
import 'cart_screen.dart';
import 'payment_session_screen.dart';

/// Checkout Flow Screen
/// Manages navigation between Cart → Address → Payment sessions
class CheckoutFlowScreen extends StatefulWidget {
  const CheckoutFlowScreen({super.key, this.onBackToHome});
  final VoidCallback? onBackToHome;

  @override
  State<CheckoutFlowScreen> createState() => _CheckoutFlowScreenState();
}

class _CheckoutFlowScreenState extends State<CheckoutFlowScreen> {
  int _currentStep = 0;

  void _goToNextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      // If on first step, go back to home
      widget.onBackToHome?.call();
    }
  }

  void _handleOrderPlaced() {
    // Navigate back to home after order is placed
    widget.onBackToHome?.call();
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _currentStep,
      children: [
        // Step 0: Cart Session
        CartScreen(
          onBackPressed: _goToPreviousStep,
          onProceedToAddress: _goToNextStep,
        ),

        // Step 1: Address Session
        AddressSessionScreen(
          onBackPressed: _goToPreviousStep,
          onProceedToPayment: _goToNextStep,
        ),

        // Step 2: Payment Session
        PaymentSessionScreen(
          onBackPressed: _goToPreviousStep,
          onOrderPlaced: _handleOrderPlaced,
        ),
      ],
    );
  }
}
