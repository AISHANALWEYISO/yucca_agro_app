
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'forgot_password_screen.dart';
import 'home_page.dart';
import 'services/api_service.dart'; // ✅ Correct path: inside services folder

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool showPassword = false;
  bool showConfirmPassword = false;
  bool _isLoading = false;
  String? _errorMessage;

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final ageController = TextEditingController();

  String? selectedUserType;

  final Color primaryGreen = const Color(0xFF366000);
  
  // API Service Instance
  final ApiService _api = ApiService();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  /// Skip login and go to HomePage as guest
  Future<void> skipLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  /// Handle Login with Flask Backend
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _api.login(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => _errorMessage = result['message']);
    }
  }

  /// Handle Register with Flask Backend
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    int? age;
    if (ageController.text.isNotEmpty) {
      age = int.tryParse(ageController.text);
    }

    final result = await _api.register(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
      confirmPassword: confirmPasswordController.text,
      age: age,
      usertype: selectedUserType,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      setState(() {
        isLogin = true;
        _errorMessage = result['message'];
        _formKey.currentState?.reset();
      });
    } else {
      setState(() => _errorMessage = result['message']);
    }
  }

  /// Main Auth Handler
  Future<void> handleAuth() async {
    if (isLogin) {
      await _handleLogin();
    } else {
      await _handleRegister();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Header
                  Text(
                    isLogin ? "Sign In" : "Sign Up",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Error Message Display
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Sign Up Fields
                  if (!isLogin) ...[
                    _buildTextField(nameController, "Full Name"),
                    const SizedBox(height: 15),
                    _buildTextField(ageController, "Age", keyboardType: TextInputType.number),
                    const SizedBox(height: 15),
                    _buildDropdown(), // ✅ Fixed dropdown logic below
                    const SizedBox(height: 15),
                  ],

                  // Email
                  _buildTextField(emailController, "Email", keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 15),

                  // Password
                  _buildPasswordField(passwordController, "Password", showPassword, () {
                    setState(() => showPassword = !showPassword);
                  }),
                  const SizedBox(height: 15),

                  // Confirm Password (Sign Up)
                  if (!isLogin) ...[
                    _buildPasswordField(
                      confirmPasswordController, 
                      "Confirm Password",
                      showConfirmPassword, 
                      () {
                        setState(() => showConfirmPassword = !showConfirmPassword);
                      }, 
                      validator: (v) {
                        if (v != passwordController.text) return "Passwords do not match";
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                  ],

                  // Forgot Password
                  if (isLogin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading ? null : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                          );
                        },
                        child: Text("Forgot Password?", style: TextStyle(color: primaryGreen)),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : handleAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            isLogin ? "Sign In" : "Sign Up",
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),

                  const SizedBox(height: 20),

                  // Switch Login/Sign Up
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              isLogin = !isLogin;
                              _errorMessage = null;
                              _formKey.currentState?.reset();
                            });
                          },
                    child: Text(
                      isLogin ? "Don't have an account? Sign Up" : "Already have an account? Sign In",
                      style: TextStyle(color: primaryGreen),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Skip Button
          Positioned(
            top: 40,
            right: 20,
            child: TextButton(
              onPressed: _isLoading ? null : skipLogin,
              child: Text("Skip", style: TextStyle(color: primaryGreen)),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildTextField(TextEditingController controller, String hint,
      {TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF5EA),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF366000), width: 1),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: !_isLoading,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        style: const TextStyle(color: Colors.black),
        validator: (v) => v!.isEmpty ? "Please enter $hint" : null,
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hint,
      bool isVisible, VoidCallback toggleVisibility,
      {String? Function(String?)? validator}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF5EA),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF366000), width: 1),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        enabled: !_isLoading,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF366000)),
            onPressed: _isLoading ? null : toggleVisibility,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        style: const TextStyle(color: Colors.black),
        validator: validator ?? (v) => v!.isEmpty ? "Please enter $hint" : null,
      ),
    );
  }

  // ✅ FIXED: Dropdown with IgnorePointer instead of 'enabled' parameter
  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF5EA),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF366000), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: IgnorePointer(
        ignoring: _isLoading, // Disables interaction when loading
        child: DropdownButtonFormField<String>(
          value: selectedUserType,
          decoration: const InputDecoration(
            border: InputBorder.none, 
            hintText: "User Type"
          ),
          items: ["Farmer", "Customer"]
              .map((type) => DropdownMenuItem(value: type, child: Text(type)))
              .toList(),
          onChanged: _isLoading ? null : (v) => setState(() => selectedUserType = v),
          validator: (v) => v == null ? "Please select a user type" : null,
          dropdownColor: Colors.white,
          icon: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.arrow_drop_down),
        ),
      ),
    );
  }
}