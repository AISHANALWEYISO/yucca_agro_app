

import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  final Color primaryGreen = const Color.fromARGB(255, 201, 231, 162); // consistent green

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryGreen.withOpacity(0.7),
      appBar: AppBar(
        backgroundColor: primaryGreen.withOpacity(0.7),
        elevation: 0,
        title: const Text("Forgot Password"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  "Enter your email to reset your password",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Email input
                _buildEmailField(),

                const SizedBox(height: 20),

                // Send reset link button
                _buildResetButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets

  Widget _buildEmailField() {
    return TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: "Email",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Please enter your email";
        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
          return "Please enter a valid email";
        }
        return null;
      },
    );
  }

  Widget _buildResetButton() {
    return ElevatedButton(
      onPressed: _sendResetLink,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        "Send Reset Link",
        style: TextStyle(
            color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  // --- Actions

  void _sendResetLink() {
    if (!_formKey.currentState!.validate()) return;

    // TODO: implement actual password reset logic

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reset Link Sent"),
        content: Text(
            "If an account exists for ${emailController.text}, a password reset link has been sent to your email."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back to auth page
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
