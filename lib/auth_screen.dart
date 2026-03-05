

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'forgot_password_screen.dart';
// import 'home_page.dart';

// class AuthScreen extends StatefulWidget {
//   const AuthScreen({super.key});

//   @override
//   State<AuthScreen> createState() => _AuthScreenState();
// }

// class _AuthScreenState extends State<AuthScreen> {
//   bool isLogin = true;
//   bool showPassword = false;
//   bool showConfirmPassword = false;

//   final _formKey = GlobalKey<FormState>();

//   // Controllers
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final confirmPasswordController = TextEditingController();
//   final nameController = TextEditingController();
//   final ageController = TextEditingController();

//   String? selectedUserType;

//   final Color primaryGreen = const Color(0xFF366000); // Updated to your green

//   /// Skip login and go to HomePage as guest
//   Future<void> skipLogin() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isLoggedIn', false); // mark as guest
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const HomePage()),
//     );
//   }

//   /// Handle login/signup action
//   Future<void> handleAuth() async {
//     if (!_formKey.currentState!.validate()) return;

//     // TODO: implement real auth logic
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isLoggedIn', true); // mark as logged in

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const HomePage()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white, // White background
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   const SizedBox(height: 20),

//                   // --- Header
//                   Text(
//                     isLogin ? "Sign In" : "Sign Up",
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                       color: primaryGreen,
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // --- Sign Up Fields
//                   if (!isLogin) ...[
//                     _buildTextField(nameController, "Full Name"),
//                     const SizedBox(height: 15),
//                     _buildTextField(ageController, "Age",
//                         keyboardType: TextInputType.number),
//                     const SizedBox(height: 15),
//                     _buildDropdown(),
//                     const SizedBox(height: 15),
//                   ],

//                   // --- Email
//                   _buildTextField(emailController, "Email",
//                       keyboardType: TextInputType.emailAddress),
//                   const SizedBox(height: 15),

//                   // --- Password
//                   _buildPasswordField(passwordController, "Password",
//                       showPassword, () {
//                     setState(() => showPassword = !showPassword);
//                   }),
//                   const SizedBox(height: 15),

//                   // --- Confirm Password (Sign Up)
//                   if (!isLogin) ...[
//                     _buildPasswordField(
//                         confirmPasswordController, "Confirm Password",
//                         showConfirmPassword, () {
//                       setState(() => showConfirmPassword = !showConfirmPassword);
//                     }, validator: (v) {
//                       if (v != passwordController.text) return "Passwords do not match";
//                       return null;
//                     }),
//                     const SizedBox(height: 15),
//                   ],

//                   // --- Forgot Password (Sign In only)
//                   if (isLogin)
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: TextButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (_) => const ForgotPasswordScreen()),
//                           );
//                         },
//                         child: Text(
//                           "Forgot Password?",
//                           style: TextStyle(color: primaryGreen),
//                         ),
//                       ),
//                     ),

//                   const SizedBox(height: 20),

//                   // --- Submit Button
//                   ElevatedButton(
//                     onPressed: handleAuth,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: primaryGreen, // Green box
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 80, vertical: 16),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30)),
//                     ),
//                     child: Text(
//                       isLogin ? "Sign In" : "Sign Up",
//                       style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold),
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // --- Switch Login/Sign Up
//                   TextButton(
//                     onPressed: () {
//                       setState(() => isLogin = !isLogin);
//                     },
//                     child: Text(
//                       isLogin
//                           ? "Don't have an account? Sign Up"
//                           : "Already have an account? Sign In",
//                       style: TextStyle(color: primaryGreen),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // --- Skip Button Top Right
//           Positioned(
//             top: 40,
//             right: 20,
//             child: TextButton(
//               onPressed: skipLogin,
//               child: Text("Skip", style: TextStyle(color: primaryGreen)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // --- Helpers

//   Widget _buildTextField(TextEditingController controller, String hint,
//       {TextInputType keyboardType = TextInputType.text}) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       decoration: InputDecoration(
//         hintText: hint,
//         filled: true,
//         fillColor: const Color(0xFFEFF5EA), // Light green box (#EFF5EA)
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(30),
//           borderSide: BorderSide.none,
//         ),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       ),
//       validator: (v) => v!.isEmpty ? "Please enter $hint" : null,
//     );
//   }

//   Widget _buildPasswordField(TextEditingController controller, String hint,
//       bool isVisible, VoidCallback toggleVisibility,
//       {String? Function(String?)? validator}) {
//     return TextFormField(
//       controller: controller,
//       obscureText: !isVisible,
//       decoration: InputDecoration(
//         hintText: hint,
//         filled: true,
//         fillColor: const Color(0xFFEFF5EA), // Light green box
//         suffixIcon: IconButton(
//           icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off,
//               color: Colors.grey[700]),
//           onPressed: toggleVisibility,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(30),
//           borderSide: BorderSide.none,
//         ),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       ),
//       validator: validator ?? (v) => v!.isEmpty ? "Please enter $hint" : null,
//     );
//   }

//   Widget _buildDropdown() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       decoration: BoxDecoration(
//         color: const Color(0xFFEFF5EA), // Light green box
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: DropdownButtonFormField<String>(
//         value: selectedUserType,
//         decoration:
//             const InputDecoration(border: InputBorder.none, hintText: "User Type"),
//         items: ["Farmer", "Customer"]
//             .map((type) => DropdownMenuItem(value: type, child: Text(type)))
//             .toList(),
//         onChanged: (v) => setState(() => selectedUserType = v),
//         validator: (v) => v == null ? "Please select a user type" : null,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'forgot_password_screen.dart';
import 'home_page.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool showPassword = false;
  bool showConfirmPassword = false;

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final ageController = TextEditingController();

  String? selectedUserType;

  final Color primaryGreen = const Color(0xFF366000); // Dark green

  /// Skip login and go to HomePage as guest
  Future<void> skipLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false); // mark as guest
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  /// Handle login/signup action
  Future<void> handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    // TODO: implement real auth logic
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true); // mark as logged in

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // --- Header
                  Text(
                    isLogin ? "Sign In" : "Sign Up",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Sign Up Fields
                  if (!isLogin) ...[
                    _buildTextField(nameController, "Full Name"),
                    const SizedBox(height: 15),
                    _buildTextField(ageController, "Age",
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 15),
                    _buildDropdown(),
                    const SizedBox(height: 15),
                  ],

                  // --- Email
                  _buildTextField(emailController, "Email",
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 15),

                  // --- Password
                  _buildPasswordField(passwordController, "Password",
                      showPassword, () {
                    setState(() => showPassword = !showPassword);
                  }),
                  const SizedBox(height: 15),

                  // --- Confirm Password (Sign Up)
                  if (!isLogin) ...[
                    _buildPasswordField(
                        confirmPasswordController, "Confirm Password",
                        showConfirmPassword, () {
                      setState(() => showConfirmPassword = !showConfirmPassword);
                    }, validator: (v) {
                      if (v != passwordController.text) return "Passwords do not match";
                      return null;
                    }),
                    const SizedBox(height: 15),
                  ],

                  // --- Forgot Password (Sign In only)
                  if (isLogin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen()),
                          );
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(color: primaryGreen),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // --- Submit Button
                  ElevatedButton(
                    onPressed: handleAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen, // Green button
                      padding: const EdgeInsets.symmetric(
                          horizontal: 80, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text(
                      "Sign In / Sign Up",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- Switch Login/Sign Up
                  TextButton(
                    onPressed: () {
                      setState(() => isLogin = !isLogin);
                    },
                    child: Text(
                      isLogin
                          ? "Don't have an account? Sign Up"
                          : "Already have an account? Sign In",
                      style: TextStyle(color: primaryGreen),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- Skip Button Top Right
          Positioned(
            top: 40,
            right: 20,
            child: TextButton(
              onPressed: skipLogin,
              child: Text("Skip", style: TextStyle(color: primaryGreen)),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers

  Widget _buildTextField(TextEditingController controller, String hint,
      {TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF5EA), // Light green background
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF366000), width: 1), // optional border
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none, // remove default border
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        color: const Color(0xFFEFF5EA), // Light green background
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF366000), width: 1), // optional border
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFF366000)),
            onPressed: toggleVisibility,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        style: const TextStyle(color: Colors.black),
        validator: validator ?? (v) => v!.isEmpty ? "Please enter $hint" : null,
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFF5EA), // Light green box
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF366000), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DropdownButtonFormField<String>(
        value: selectedUserType,
        decoration:
            const InputDecoration(border: InputBorder.none, hintText: "User Type"),
        items: ["Farmer", "Customer"]
            .map((type) => DropdownMenuItem(value: type, child: Text(type)))
            .toList(),
        onChanged: (v) => setState(() => selectedUserType = v),
        validator: (v) => v == null ? "Please select a user type" : null,
      ),
    );
  }
}
