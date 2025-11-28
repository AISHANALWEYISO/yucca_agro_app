
import 'package:flutter/material.dart';
import 'forgot_password_screen.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool showPassword = false;
  bool showConfirmPassword = false;

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  String? selectedUserType;

  final Color logoGreen = const Color(0xFF366000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: logoGreen,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),

                Text(
                  isLogin ? "Sign In" : "Sign Up",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                // NAME
                if (!isLogin)
                  TextFormField(
                    controller: nameController,
                    decoration: _inputDecoration("Full Name"),
                    validator: (value) {
                      if (!isLogin && (value == null || value.isEmpty)) {
                        return "Please enter your full name";
                      }
                      return null;
                    },
                  ),
                if (!isLogin) const SizedBox(height: 15),

                // AGE
                if (!isLogin)
                  TextFormField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration("Age"),
                    validator: (value) {
                      if (!isLogin && (value == null || value.isEmpty)) {
                        return "Please enter your age";
                      }
                      return null;
                    },
                  ),
                if (!isLogin) const SizedBox(height: 15),

                // USER TYPE
                if (!isLogin)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedUserType,
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: "User Type"),
                      items: ["Farmer", "Customer"]
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedUserType = value;
                        });
                      },
                      validator: (value) {
                        if (!isLogin && value == null) {
                          return "Please select a user type";
                        }
                        return null;
                      },
                    ),
                  ),
                if (!isLogin) const SizedBox(height: 15),

                // EMAIL
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration("Email"),
                  validator: (value) =>
                      value!.isEmpty ? "Please enter your email" : null,
                ),

                const SizedBox(height: 15),

                // PASSWORD
                TextFormField(
                  controller: passwordController,
                  obscureText: !showPassword,
                  decoration: _passwordDecoration(
                    "Password",
                    showPassword,
                    () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Please enter your password" : null,
                ),

                const SizedBox(height: 15),

                // CONFIRM PASSWORD
                if (!isLogin)
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: !showConfirmPassword,
                    decoration: _passwordDecoration(
                      "Confirm Password",
                      showConfirmPassword,
                      () {
                        setState(() {
                          showConfirmPassword = !showConfirmPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (!isLogin && value != passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),

                const SizedBox(height: 10),

                // FORGOT PASSWORD
                if (isLogin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen()),
                        );
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // SUBMIT BUTTON
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {}
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    isLogin ? "Sign In" : "Sign Up",
                    style: TextStyle(
                        color: logoGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 15),

                // SWITCH
                TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                  child: Text(
                    isLogin
                        ? "Don't have an account? Sign Up"
                        : "Already have an account? Sign In",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Normal inputs
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  // Password input with eye icon update
  InputDecoration _passwordDecoration(
      String hint, bool isVisible, VoidCallback onPressed) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      suffixIcon: IconButton(
        icon: Icon(
          isVisible ? Icons.visibility : Icons.visibility_off,
          color: Colors.grey[700],
        ),
        onPressed: onPressed,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
}
