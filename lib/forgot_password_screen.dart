// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'services/api_service.dart';

// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});

//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
//     with SingleTickerProviderStateMixin {
//   // ── Colors ──
//   static const Color deepGreen = Color(0xFF2D5016);
//   static const Color lightGreen = Color(0xFF8BC34A);
//   static const Color cardCream = Color(0xFFFFFBF2);
//   static const Color gold = Color(0xFFC0B87A);

//   // ── Steps: 0=email, 1=otp, 2=new password ──
//   int _step = 0;
//   bool _isLoading = false;
//   String? _errorMessage;
//   String? _successMessage;
//   String _email = '';

//   final ApiService _api = ApiService();
//   int _countdown = 0;
//   Timer? _timer;

//   // ── Controllers ──
//   final _emailController = TextEditingController();
//   final _newPasswordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   bool _showNewPassword = false;
//   bool _showConfirmPassword = false;

//   // ── OTP boxes (6 digits) ──
//   final List<TextEditingController> _otpControllers =
//       List.generate(6, (_) => TextEditingController());
//   final List<FocusNode> _otpFocusNodes =
//       List.generate(6, (_) => FocusNode());

//   late AnimationController _animController;
//   late Animation<double> _fadeAnim;

//   @override
//   void initState() {
//     super.initState();
//     _animController = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 400));
//     _fadeAnim =
//         CurvedAnimation(parent: _animController, curve: Curves.easeOut);
//     _animController.forward();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _animController.dispose();
//     _emailController.dispose();
//     _newPasswordController.dispose();
//     _confirmPasswordController.dispose();
//     for (final c in _otpControllers) c.dispose();
//     for (final f in _otpFocusNodes) f.dispose();
//     super.dispose();
//   }

//   void _startCountdown() {
//     _countdown = 60;
//     _timer?.cancel();
//     _timer = Timer.periodic(const Duration(seconds: 1), (t) {
//       if (_countdown == 0) {
//         t.cancel();
//       } else {
//         setState(() => _countdown--);
//       }
//     });
//   }

//   void _nextStep() {
//     _animController.reset();
//     setState(() {
//       _step++;
//       _errorMessage = null;
//       _successMessage = null;
//     });
//     _animController.forward();
//   }

//   Future<void> _sendOtp() async {
//     final email = _emailController.text.trim();
//     if (email.isEmpty || !RegExp(r'\S+@\S+\.\S+').hasMatch(email)) {
//       setState(() => _errorMessage = 'Please enter a valid email address');
//       return;
//     }
//     setState(() { _isLoading = true; _errorMessage = null; });
//     final result = await _api.sendOtp(email: email);
//     if (!mounted) return;
//     setState(() => _isLoading = false);
//     if (result['success'] == true) {
//       _email = email;
//       _startCountdown();
//       _nextStep();
//     } else {
//       setState(() => _errorMessage = result['message']);
//     }
//   }

//   Future<void> _verifyOtp() async {
//     final otp = _otpControllers.map((c) => c.text).join();
//     if (otp.length < 6) {
//       setState(() => _errorMessage = 'Please enter the complete 6-digit OTP');
//       return;
//     }
//     setState(() { _isLoading = true; _errorMessage = null; });
//     final result = await _api.verifyOtp(email: _email, otp: otp);
//     if (!mounted) return;
//     setState(() => _isLoading = false);
//     if (result['success'] == true) {
//       _nextStep();
//     } else {
//       setState(() => _errorMessage = result['message']);
//     }
//   }

//   Future<void> _resetPassword() async {
//     final newPassword = _newPasswordController.text;
//     final confirmPassword = _confirmPasswordController.text;
//     if (newPassword.length < 6) {
//       setState(() => _errorMessage = 'Password must be at least 6 characters');
//       return;
//     }
//     if (newPassword != confirmPassword) {
//       setState(() => _errorMessage = 'Passwords do not match');
//       return;
//     }
//     setState(() { _isLoading = true; _errorMessage = null; });
//     final result = await _api.resetPassword(
//       email: _email,
//       newPassword: newPassword,
//       confirmPassword: confirmPassword,
//     );
//     if (!mounted) return;
//     setState(() => _isLoading = false);
//     if (result['success'] == true) {
//       setState(() => _successMessage = result['message']);
//       await Future.delayed(const Duration(seconds: 2));
//       if (mounted) Navigator.pop(context);
//     } else {
//       setState(() => _errorMessage = result['message']);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFFF5EDD6), Color(0xFFE8F5D6)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SafeArea(
//           child: Stack(
//             children: [
//               // ── Content ──
//               SingleChildScrollView(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 16),
//                     _buildTopBar(),
//                     const SizedBox(height: 32),
//                     _buildStepIndicator(),
//                     const SizedBox(height: 32),
//                     FadeTransition(
//                       opacity: _fadeAnim,
//                       child: _buildStepCard(),
//                     ),
//                   ],
//                 ),
//               ),

//               // ── Loading overlay ──
//               if (_isLoading)
//                 Container(
//                   color: Colors.black12,
//                   child: const Center(
//                     child: CircularProgressIndicator(color: Color(0xFF366000)),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Top bar ──
//   Widget _buildTopBar() {
//     return Row(
//       children: [
//         GestureDetector(
//           onTap: () {
//             if (_step > 0) {
//               _animController.reset();
//               setState(() { _step--; _errorMessage = null; });
//               _animController.forward();
//             } else {
//               Navigator.pop(context);
//             }
//           },
//           child: Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                     color: deepGreen.withOpacity(0.1),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2))
//               ],
//             ),
//             child: const Icon(Icons.arrow_back_ios_new, color: deepGreen, size: 18),
//           ),
//         ),
//         const SizedBox(width: 16),
//         Text(
//           'Reset Password',
//           style: TextStyle(
//               fontSize: 20, fontWeight: FontWeight.bold, color: deepGreen),
//         ),
//       ],
//     );
//   }

//   // ── Step indicator ──
//   Widget _buildStepIndicator() {
//     final steps = ['Email', 'OTP', 'Password'];
//     return Row(
//       children: steps.asMap().entries.map((e) {
//         final i = e.key;
//         final active = i == _step;
//         final done = i < _step;
//         return Expanded(
//           child: Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   children: [
//                     Container(
//                       width: 32, height: 32,
//                       decoration: BoxDecoration(
//                         color: done ? lightGreen : active ? deepGreen : Colors.white,
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                             color: done || active ? Colors.transparent : Colors.grey[300]!,
//                             width: 1.5),
//                         boxShadow: active
//                             ? [BoxShadow(color: deepGreen.withOpacity(0.3), blurRadius: 8)]
//                             : null,
//                       ),
//                       child: Center(
//                         child: done
//                             ? const Icon(Icons.check, color: Colors.white, size: 16)
//                             : Text(
//                                 '${i + 1}',
//                                 style: TextStyle(
//                                     color: active ? Colors.white : Colors.grey[400],
//                                     fontSize: 13,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       e.value,
//                       style: TextStyle(
//                           fontSize: 11,
//                           color: active || done ? deepGreen : Colors.grey[400],
//                           fontWeight: active ? FontWeight.bold : FontWeight.normal),
//                     ),
//                   ],
//                 ),
//               ),
//               if (i < steps.length - 1)
//                 Expanded(
//                   child: Container(
//                     height: 2,
//                     margin: const EdgeInsets.only(bottom: 20),
//                     color: i < _step ? lightGreen : Colors.grey[300],
//                   ),
//                 ),
//             ],
//           ),
//         );
//       }).toList(),
//     );
//   }

//   // ── Step card ──
//   Widget _buildStepCard() {
//     return Container(
//       decoration: BoxDecoration(
//         color: cardCream,
//         borderRadius: BorderRadius.circular(28),
//         boxShadow: [
//           BoxShadow(
//               color: deepGreen.withOpacity(0.12),
//               blurRadius: 24,
//               offset: const Offset(0, 8))
//         ],
//         border: Border.all(color: gold.withOpacity(0.3), width: 1),
//       ),
//       padding: const EdgeInsets.all(28),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           if (_errorMessage != null) ...[
//             _buildBanner(_errorMessage!, isError: true),
//             const SizedBox(height: 16),
//           ],
//           if (_successMessage != null) ...[
//             _buildBanner(_successMessage!, isError: false),
//             const SizedBox(height: 16),
//           ],
//           if (_step == 0) _buildEmailStep(),
//           if (_step == 1) _buildOtpStep(),
//           if (_step == 2) _buildNewPasswordStep(),
//         ],
//       ),
//     );
//   }

//   // ── Step 0: Email ──
//   Widget _buildEmailStep() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         Text('Enter your email',
//             style: TextStyle(
//                 fontSize: 20, fontWeight: FontWeight.bold, color: deepGreen)),
//         const SizedBox(height: 6),
//         Text("We'll send a 6-digit OTP to verify it's you",
//             style: TextStyle(fontSize: 13, color: deepGreen.withOpacity(0.55))),
//         const SizedBox(height: 24),
//         _buildInputField(
//           controller: _emailController,
//           hint: 'Email Address',
//           keyboardType: TextInputType.emailAddress,
//         ),
//         const SizedBox(height: 24),
//         _buildButton('Send OTP', _sendOtp),
//       ],
//     );
//   }

//   // ── Step 1: OTP ──
//   Widget _buildOtpStep() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         Text('Enter OTP',
//             style: TextStyle(
//                 fontSize: 20, fontWeight: FontWeight.bold, color: deepGreen)),
//         const SizedBox(height: 6),
//         Text('A 6-digit code was sent to $_email',
//             style: TextStyle(fontSize: 13, color: deepGreen.withOpacity(0.55))),
//         const SizedBox(height: 28),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: List.generate(6, (i) => _buildOtpBox(i)),
//         ),
//         const SizedBox(height: 24),
//         _buildButton('Verify OTP', _verifyOtp),
//         const SizedBox(height: 16),
//         Center(
//           child: _countdown > 0
//               ? Text(
//                   'Resend OTP in ${_countdown}s',
//                   style: TextStyle(color: deepGreen.withOpacity(0.5), fontSize: 13),
//                 )
//               : GestureDetector(
//                   onTap: _sendOtp,
//                   child: Text(
//                     'Resend OTP',
//                     style: TextStyle(
//                         color: deepGreen,
//                         fontSize: 13,
//                         fontWeight: FontWeight.bold,
//                         decoration: TextDecoration.underline),
//                   ),
//                 ),
//         ),
//       ],
//     );
//   }

//   Widget _buildOtpBox(int index) {
//     return SizedBox(
//       width: 44,
//       height: 54,
//       child: TextFormField(
//         controller: _otpControllers[index],
//         focusNode: _otpFocusNodes[index],
//         keyboardType: TextInputType.number,
//         textAlign: TextAlign.center,
//         maxLength: 1,
//         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//         style: TextStyle(
//             fontSize: 22, fontWeight: FontWeight.bold, color: deepGreen),
//         decoration: InputDecoration(
//           counterText: '',
//           filled: true,
//           fillColor: const Color(0xFFEFF7E6),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide.none,
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: deepGreen, width: 2),
//           ),
//         ),
//         onChanged: (value) {
//           if (value.isNotEmpty && index < 5) {
//             _otpFocusNodes[index + 1].requestFocus();
//           }
//           if (value.isEmpty && index > 0) {
//             _otpFocusNodes[index - 1].requestFocus();
//           }
//         },
//       ),
//     );
//   }

//   // ── Step 2: New Password ──
//   Widget _buildNewPasswordStep() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         Text('New Password',
//             style: TextStyle(
//                 fontSize: 20, fontWeight: FontWeight.bold, color: deepGreen)),
//         const SizedBox(height: 6),
//         Text('Create a strong new password',
//             style: TextStyle(fontSize: 13, color: deepGreen.withOpacity(0.55))),
//         const SizedBox(height: 24),
//         _buildPasswordInput(
//           controller: _newPasswordController,
//           hint: 'New Password',
//           isVisible: _showNewPassword,
//           onToggle: () => setState(() => _showNewPassword = !_showNewPassword),
//         ),
//         const SizedBox(height: 14),
//         _buildPasswordInput(
//           controller: _confirmPasswordController,
//           hint: 'Confirm Password',
//           isVisible: _showConfirmPassword,
//           onToggle: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
//         ),
//         const SizedBox(height: 24),
//         _buildButton('Reset Password', _resetPassword),
//       ],
//     );
//   }

//   // ── Text Field (no icon) ──
//   Widget _buildInputField({
//     required TextEditingController controller,
//     required String hint,
//     TextInputType keyboardType = TextInputType.text,
//   }) {
//     return TextField(
//       controller: controller,
//       keyboardType: keyboardType,
//       enabled: !_isLoading,
//       style: TextStyle(color: deepGreen, fontSize: 15),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: TextStyle(color: deepGreen.withOpacity(0.4), fontSize: 14),
//         filled: true,
//         fillColor: const Color(0xFFEFF7E6),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: BorderSide.none,
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(color: deepGreen, width: 1.5),
//         ),
//       ),
//     );
//   }

//   // ── Password Field (no icon) ──
//   Widget _buildPasswordInput({
//     required TextEditingController controller,
//     required String hint,
//     required bool isVisible,
//     required VoidCallback onToggle,
//   }) {
//     return TextField(
//       controller: controller,
//       obscureText: !isVisible,
//       enabled: !_isLoading,
//       style: TextStyle(color: deepGreen, fontSize: 15),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: TextStyle(color: deepGreen.withOpacity(0.4), fontSize: 14),
//         suffixIcon: IconButton(
//           icon: Icon(
//               isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
//               color: deepGreen.withOpacity(0.5),
//               size: 20),
//           onPressed: _isLoading ? null : onToggle,
//         ),
//         filled: true,
//         fillColor: const Color(0xFFEFF7E6),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: BorderSide.none,
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: const BorderSide(color: deepGreen, width: 1.5),
//         ),
//       ),
//     );
//   }

//   Widget _buildButton(String label, VoidCallback onTap) {
//     return SizedBox(
//       height: 52,
//       child: ElevatedButton(
//         onPressed: _isLoading ? null : onTap,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: deepGreen,
//           foregroundColor: Colors.white,
//           elevation: 3,
//           shadowColor: deepGreen.withOpacity(0.4),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         ),
//         child: _isLoading
//             ? const SizedBox(
//                 width: 22, height: 22,
//                 child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
//             : Text(label,
//                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//       ),
//     );
//   }

//   Widget _buildBanner(String message, {required bool isError}) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: isError ? Colors.red[50] : Colors.green[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: isError ? Colors.red[200]! : Colors.green[200]!),
//       ),
//       child: Row(
//         children: [
//           Icon(
//               isError ? Icons.error_outline : Icons.check_circle_outline,
//               color: isError ? Colors.red : Colors.green,
//               size: 18),
//           const SizedBox(width: 8),
//           Expanded(
//               child: Text(message,
//                   style: TextStyle(
//                       color: isError ? Colors.red : Colors.green,
//                       fontSize: 13))),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const Color deepGreen = Color(0xFF2D5016);
  static const Color midGreen = Color(0xFF366000);
  static const Color lightGreen = Color(0xFF8BC34A);
  static const Color cardCream = Color(0xFFFFFBF2);
  static const Color gold = Color(0xFFC0B87A);

  int _step = 0; // 0=email, 1=otp, 2=new password
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());

  // Resend OTP timer
  int _resendSeconds = 60;
  Timer? _resendTimer;

  final ApiService _api = ApiService();

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    for (final c in _otpControllers) c.dispose();
    for (final f in _otpFocusNodes) f.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds == 0) {
        t.cancel();
      } else {
        if (mounted) setState(() => _resendSeconds--);
      }
    });
  }

  // Step 0 — send OTP
  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !RegExp(r'\S+@\S+\.\S+').hasMatch(email)) {
      setState(() => _errorMessage = 'Please enter a valid email address');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; _successMessage = null; });

    final result = await _api.sendOtp(email: email);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      setState(() { _step = 1; _errorMessage = null; });
      _startResendTimer();
    } else {
      // Shows "Email does not exist" if not registered
      setState(() => _errorMessage = result['message']);
    }
  }

  // Step 1 — verify OTP
  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      setState(() => _errorMessage = 'Please enter the complete 6-digit OTP');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    final result = await _api.verifyOtp(
      email: _emailController.text.trim(),
      otp: otp,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      setState(() { _step = 2; _errorMessage = null; });
      _resendTimer?.cancel();
    } else {
      setState(() => _errorMessage = result['message']);
    }
  }

  // Step 2 — reset password
  Future<void> _resetPassword() async {
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (newPass.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters');
      return;
    }
    if (newPass != confirmPass) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    final result = await _api.resetPassword(
      email: _emailController.text.trim(),
      newPassword: newPass,
      confirmPassword: confirmPass,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      setState(() => _successMessage = 'Password reset successfully!');
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);
    } else {
      setState(() => _errorMessage = result['message']);
    }
  }

  Future<void> _resendOtp() async {
    if (_resendSeconds > 0) return;
    for (final c in _otpControllers) c.clear();
    setState(() { _errorMessage = null; _successMessage = null; });

    final result = await _api.sendOtp(email: _emailController.text.trim());
    if (!mounted) return;

    if (result['success'] == true) {
      _startResendTimer();
      setState(() => _successMessage = 'OTP resent to your email');
    } else {
      setState(() => _errorMessage = result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5EDD6), Color(0xFFE8F5D6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildTopBar(),
                    const SizedBox(height: 24),
                    _buildStepIndicator(),
                    const SizedBox(height: 32),
                    _buildStepCard(),
                  ],
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black12,
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF366000)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (_step > 0) {
              setState(() { _step--; _errorMessage = null; _successMessage = null; });
            } else {
              Navigator.pop(context);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: deepGreen.withOpacity(0.1), blurRadius: 8)],
            ),
            child: Icon(Icons.arrow_back, color: deepGreen, size: 20),
          ),
        ),
        const SizedBox(width: 16),
        Text('Reset Password',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: deepGreen)),
      ],
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Email', 'OTP', 'New Password'];
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Line between steps
          final stepIndex = i ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              color: _step > stepIndex ? midGreen : Colors.grey[300],
            ),
          );
        }
        final index = i ~/ 2;
        final done = _step > index;
        final active = _step == index;
        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: done ? midGreen : active ? midGreen : Colors.grey[200],
                shape: BoxShape.circle,
                border: Border.all(
                  color: active || done ? midGreen : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: Center(
                child: done
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : Text('${index + 1}',
                        style: TextStyle(
                            color: active ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
              ),
            ),
            const SizedBox(height: 4),
            Text(steps[index],
                style: TextStyle(
                    fontSize: 10,
                    color: active || done ? midGreen : Colors.grey,
                    fontWeight: active ? FontWeight.bold : FontWeight.normal)),
          ],
        );
      }),
    );
  }

  Widget _buildStepCard() {
    return Container(
      decoration: BoxDecoration(
        color: cardCream,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: deepGreen.withOpacity(0.12), blurRadius: 24, offset: const Offset(0, 8))
        ],
        border: Border.all(color: gold.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_errorMessage != null) _buildBanner(_errorMessage!, isError: true),
          if (_successMessage != null) _buildBanner(_successMessage!, isError: false),
          if (_step == 0) _buildEmailStep(),
          if (_step == 1) _buildOtpStep(),
          if (_step == 2) _buildNewPasswordStep(),
        ],
      ),
    );
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Enter Your Email',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: deepGreen)),
        const SizedBox(height: 8),
        Text('We will send a verification code to your registered email.',
            style: TextStyle(fontSize: 13, color: deepGreen.withOpacity(0.6), height: 1.5)),
        const SizedBox(height: 24),
        _buildField(
          controller: _emailController,
          hint: 'Email Address',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        _buildButton('Send OTP', _isLoading ? null : _sendOtp),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Enter OTP',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: deepGreen)),
        const SizedBox(height: 8),
        Text('A 6-digit code was sent to ${_emailController.text}',
            style: TextStyle(fontSize: 13, color: deepGreen.withOpacity(0.6), height: 1.5)),
        const SizedBox(height: 28),
        // OTP boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) => _buildOtpBox(i)),
        ),
        const SizedBox(height: 20),
        // Resend
        Center(
          child: GestureDetector(
            onTap: _resendSeconds == 0 ? _resendOtp : null,
            child: Text(
              _resendSeconds > 0
                  ? 'Resend OTP in ${_resendSeconds}s'
                  : 'Resend OTP',
              style: TextStyle(
                  fontSize: 13,
                  color: _resendSeconds > 0 ? Colors.grey : midGreen,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildButton('Verify OTP', _isLoading ? null : _verifyOtp),
      ],
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 44,
      height: 52,
      child: TextFormField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: deepGreen),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: const Color(0xFFEFF7E6),
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: lightGreen.withOpacity(0.4), width: 1.5)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF366000), width: 2)),
        ),
        onChanged: (val) {
          if (val.isNotEmpty && index < 5) {
            _otpFocusNodes[index + 1].requestFocus();
          } else if (val.isEmpty && index > 0) {
            _otpFocusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  Widget _buildNewPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('New Password',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: deepGreen)),
        const SizedBox(height: 8),
        Text('Create a strong password for your account.',
            style: TextStyle(fontSize: 13, color: deepGreen.withOpacity(0.6), height: 1.5)),
        const SizedBox(height: 24),
        _buildPasswordField(
          controller: _newPasswordController,
          hint: 'New Password',
          isVisible: _showNewPassword,
          onToggle: () => setState(() => _showNewPassword = !_showNewPassword),
        ),
        const SizedBox(height: 14),
        _buildPasswordField(
          controller: _confirmPasswordController,
          hint: 'Confirm Password',
          isVisible: _showConfirmPassword,
          onToggle: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
        ),
        const SizedBox(height: 24),
        _buildButton('Reset Password', _isLoading ? null : _resetPassword),
      ],
    );
  }

  Widget _buildButton(String label, VoidCallback? onTap) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: deepGreen,
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: !_isLoading,
      style: TextStyle(color: deepGreen, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: deepGreen.withOpacity(0.4), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFEFF7E6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: lightGreen.withOpacity(0.3), width: 1)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF366000), width: 1.5)),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      enabled: !_isLoading,
      style: TextStyle(color: deepGreen, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: deepGreen.withOpacity(0.4), fontSize: 14),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: deepGreen.withOpacity(0.5), size: 20),
          onPressed: _isLoading ? null : onToggle,
        ),
        filled: true,
        fillColor: const Color(0xFFEFF7E6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: lightGreen.withOpacity(0.3), width: 1)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF366000), width: 1.5)),
      ),
    );
  }

  Widget _buildBanner(String message, {required bool isError}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isError ? Colors.red[200]! : Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? Colors.red : Colors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Text(message,
                  style: TextStyle(
                      color: isError ? Colors.red : Colors.green, fontSize: 13))),
        ],
      ),
    );
  }
}