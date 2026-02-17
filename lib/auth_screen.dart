
// import 'package:flutter/material.dart';
// import 'forgot_password_screen.dart';

// class AuthScreen extends StatefulWidget {
//   @override
//   _AuthScreenState createState() => _AuthScreenState();
// }

// class _AuthScreenState extends State<AuthScreen> {
//   bool isLogin = true;
//   bool showPassword = false;
//   bool showConfirmPassword = false;

//   final _formKey = GlobalKey<FormState>();

//   // Controllers
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPasswordController =
//       TextEditingController();
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController ageController = TextEditingController();

//   String? selectedUserType;

//   final Color logoGreen = const Color(0xFF366000);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: logoGreen,
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(30),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 const SizedBox(height: 20),

//                 Text(
//                   isLogin ? "Sign In" : "Sign Up",
//                   style: const TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // NAME
//                 if (!isLogin)
//                   TextFormField(
//                     controller: nameController,
//                     decoration: _inputDecoration("Full Name"),
//                     validator: (value) {
//                       if (!isLogin && (value == null || value.isEmpty)) {
//                         return "Please enter your full name";
//                       }
//                       return null;
//                     },
//                   ),
//                 if (!isLogin) const SizedBox(height: 15),

//                 // AGE
//                 if (!isLogin)
//                   TextFormField(
//                     controller: ageController,
//                     keyboardType: TextInputType.number,
//                     decoration: _inputDecoration("Age"),
//                     validator: (value) {
//                       if (!isLogin && (value == null || value.isEmpty)) {
//                         return "Please enter your age";
//                       }
//                       return null;
//                     },
//                   ),
//                 if (!isLogin) const SizedBox(height: 15),

//                 // USER TYPE
//                 if (!isLogin)
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     child: DropdownButtonFormField<String>(
//                       value: selectedUserType,
//                       decoration: const InputDecoration(
//                           border: InputBorder.none, hintText: "User Type"),
//                       items: ["Farmer", "Customer"]
//                           .map((type) => DropdownMenuItem(
//                                 value: type,
//                                 child: Text(type),
//                               ))
//                           .toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           selectedUserType = value;
//                         });
//                       },
//                       validator: (value) {
//                         if (!isLogin && value == null) {
//                           return "Please select a user type";
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                 if (!isLogin) const SizedBox(height: 15),

//                 // EMAIL
//                 TextFormField(
//                   controller: emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: _inputDecoration("Email"),
//                   validator: (value) =>
//                       value!.isEmpty ? "Please enter your email" : null,
//                 ),

//                 const SizedBox(height: 15),

//                 // PASSWORD
//                 TextFormField(
//                   controller: passwordController,
//                   obscureText: !showPassword,
//                   decoration: _passwordDecoration(
//                     "Password",
//                     showPassword,
//                     () {
//                       setState(() {
//                         showPassword = !showPassword;
//                       });
//                     },
//                   ),
//                   validator: (value) =>
//                       value!.isEmpty ? "Please enter your password" : null,
//                 ),

//                 const SizedBox(height: 15),

//                 // CONFIRM PASSWORD
//                 if (!isLogin)
//                   TextFormField(
//                     controller: confirmPasswordController,
//                     obscureText: !showConfirmPassword,
//                     decoration: _passwordDecoration(
//                       "Confirm Password",
//                       showConfirmPassword,
//                       () {
//                         setState(() {
//                           showConfirmPassword = !showConfirmPassword;
//                         });
//                       },
//                     ),
//                     validator: (value) {
//                       if (!isLogin && value != passwordController.text) {
//                         return "Passwords do not match";
//                       }
//                       return null;
//                     },
//                   ),

//                 const SizedBox(height: 10),

//                 // FORGOT PASSWORD
//                 if (isLogin)
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => ForgotPasswordScreen()),
//                         );
//                       },
//                       child: const Text(
//                         "Forgot Password?",
//                         style: TextStyle(color: Colors.white70),
//                       ),
//                     ),
//                   ),

//                 const SizedBox(height: 20),

//                 // SUBMIT BUTTON
//                 ElevatedButton(
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {}
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 80, vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                   ),
//                   child: Text(
//                     isLogin ? "Sign In" : "Sign Up",
//                     style: TextStyle(
//                         color: logoGreen,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ),

//                 const SizedBox(height: 15),

//                 // SWITCH
//                 TextButton(
//                   onPressed: () {
//                     setState(() {
//                       isLogin = !isLogin;
//                     });
//                   },
//                   child: Text(
//                     isLogin
//                         ? "Don't have an account? Sign Up"
//                         : "Already have an account? Sign In",
//                     style: const TextStyle(color: Colors.white70),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Normal inputs
//   InputDecoration _inputDecoration(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       filled: true,
//       fillColor: Colors.white,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(30),
//         borderSide: BorderSide.none,
//       ),
//       contentPadding:
//           const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//     );
//   }

//   // Password input with eye icon update
//   InputDecoration _passwordDecoration(
//       String hint, bool isVisible, VoidCallback onPressed) {
//     return InputDecoration(
//       hintText: hint,
//       filled: true,
//       fillColor: Colors.white,
//       suffixIcon: IconButton(
//         icon: Icon(
//           isVisible ? Icons.visibility : Icons.visibility_off,
//           color: Colors.grey[700],
//         ),
//         onPressed: onPressed,
//       ),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(30),
//         borderSide: BorderSide.none,
//       ),
//       contentPadding:
//           const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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

  final Color primaryGreen = const Color.fromARGB(255, 130, 167, 123);

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
      backgroundColor: primaryGreen,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),

                // --- Header
                Text(
                  isLogin ? "Sign In" : "Sign Up",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // --- Sign Up Fields
                if (!isLogin) ...[
                  _buildTextField(nameController, "Full Name",
                      validator: (v) =>
                          v!.isEmpty ? "Please enter your full name" : null),
                  const SizedBox(height: 15),
                  _buildTextField(ageController, "Age",
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v!.isEmpty ? "Please enter your age" : null),
                  const SizedBox(height: 15),
                  _buildDropdown(),
                  const SizedBox(height: 15),
                ],

                // --- Email
                _buildTextField(emailController, "Email",
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        v!.isEmpty ? "Please enter your email" : null),
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
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Color.fromARGB(179, 7, 7, 7)),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // --- Submit Button
                ElevatedButton(
                  onPressed: handleAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    isLogin ? "Sign In" : "Sign Up",
                    style: TextStyle(
                        color: primaryGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 10),

                // --- Skip Button
                TextButton(
                  onPressed: skipLogin,
                  child: const Text("Skip", style: TextStyle(color: Colors.white70)),
                ),

                const SizedBox(height: 10),

                // --- Switch Login/Sign Up
                TextButton(
                  onPressed: () {
                    setState(() => isLogin = !isLogin);
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

  // --- Helpers

  Widget _buildTextField(TextEditingController controller, String hint,
      {TextInputType keyboardType = TextInputType.text,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hint,
      bool isVisible, VoidCallback toggleVisibility,
      {String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey[700]),
          onPressed: toggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      validator: validator ?? (v) => v!.isEmpty ? "Please enter your password" : null,
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
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
