import 'package:flutter/material.dart';
import 'forgot_password_screen.dart';
import 'home_page.dart';
import 'services/api_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  static const Color deepGreen = Color(0xFF2D5016);
  static const Color midGreen = Color(0xFF366000);
  static const Color lightGreen = Color(0xFF8BC34A);
  static const Color cardCream = Color(0xFFFFFBF2);
  static const Color gold = Color(0xFFC0B87A);

  bool isLogin = true;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;
  bool _forgotHover = false;
  bool _switchHover = false;
  String? _errorMessage;
  String? _successMessage;
  String? _selectedUserType;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _switchMode() {
    _animController.reset();
    setState(() {
      isLogin = !isLogin;
      _errorMessage = null;
      _successMessage = null;
      _selectedUserType = null;
      _formKey.currentState?.reset();
    });
    _animController.forward();
  }

  Future<void> _skipLogin() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; _successMessage = null; });

    final result = await _api.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => _errorMessage = result['message']);
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; _successMessage = null; });

    final result = await _api.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      age: int.tryParse(_ageController.text),
      usertype: _selectedUserType ?? 'Farmer',
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      setState(() { _successMessage = result['message']; _errorMessage = null; });
      await Future.delayed(const Duration(seconds: 2));
      _switchMode();
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
                    const SizedBox(height: 20),
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildCard(),
                    const SizedBox(height: 20),
                    _buildSwitchMode(),
                  ],
                ),
              ),

              Positioned(
                top: 12, right: 16,
                child: TextButton(
                  onPressed: _isLoading ? null : _skipLogin,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                        color: deepGreen.withOpacity(0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
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

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: deepGreen.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Image.asset('assets/yucca1.png', height: 52),
        ),
        const SizedBox(height: 16),
        Text(
          'Yucca Agro',
          style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: deepGreen,
              letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        Text(
          'Smart Agricultural Solutions',
          style: TextStyle(
              fontSize: 13,
              color: deepGreen.withOpacity(0.6),
              letterSpacing: 0.3),
        ),
      ],
    );
  }

  Widget _buildCard() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          decoration: BoxDecoration(
            color: cardCream,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                  color: deepGreen.withOpacity(0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8))
            ],
            border: Border.all(color: gold.withOpacity(0.3), width: 1),
          ),
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isLogin ? 'Welcome Back ' : 'Create Account ',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: deepGreen),
                ),
                const SizedBox(height: 24),

                if (_errorMessage != null) _buildErrorBanner(),
                if (_successMessage != null) _buildSuccessBanner(),

                if (!isLogin) ...[
                  _buildField(
                    controller: _nameController,
                    hint: 'Full Name',
                    validator: (v) => v!.isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    controller: _ageController,
                    hint: 'Age',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v!.isEmpty) return 'Please enter your age';
                      if (int.tryParse(v) == null) return 'Invalid age';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildUserTypeDropdown(),
                  const SizedBox(height: 14),
                ],

                _buildField(
                  controller: _emailController,
                  hint: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v!.isEmpty) return 'Please enter your email';
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(v))
                      return 'Invalid email address';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                _buildPasswordField(
                  controller: _passwordController,
                  hint: 'Password',
                  isVisible: _showPassword,
                  onToggle: () => setState(() => _showPassword = !_showPassword),
                  validator: (v) {
                    if (v!.isEmpty) return 'Please enter your password';
                    if (!isLogin && v.length < 6)
                      return 'Password must be at least 6 characters';
                    return null;
                  },
                ),

                if (!isLogin) ...[
                  const SizedBox(height: 14),
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    hint: 'Confirm Password',
                    isVisible: _showConfirmPassword,
                    onToggle: () => setState(
                        () => _showConfirmPassword = !_showConfirmPassword),
                    validator: (v) {
                      if (v != _passwordController.text)
                        return 'Passwords do not match';
                      return null;
                    },
                  ),
                ],

                // ── Forgot Password ──
                if (isLogin) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _forgotHover = true),
                      onExit: (_) => setState(() => _forgotHover = false),
                      child: GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const ForgotPasswordScreen()),
                                ),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            color: _forgotHover
                                ? const Color.fromARGB(255, 250, 229, 146)
                                : midGreen,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                          ),
                          child: const Text('Forgot Password?'),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : isLogin ? _handleLogin : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: deepGreen,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: deepGreen.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(
                            isLogin ? 'Sign In' : 'Create Account',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── User Type Dropdown — empty by default, Farmer only option ──
  Widget _buildUserTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF7E6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: lightGreen.withOpacity(0.3), width: 1),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedUserType,
        dropdownColor: Colors.white,
        icon: Icon(Icons.arrow_drop_down, color: deepGreen.withOpacity(0.5)),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
        style: TextStyle(color: deepGreen, fontSize: 15),
        hint: Text(
          'User Type',
          style: TextStyle(color: deepGreen.withOpacity(0.4), fontSize: 14),
        ),
        items: const [
          DropdownMenuItem(value: 'Farmer', child: Text('Farmer')),
        ],
        onChanged: _isLoading ? null : (v) => setState(() => _selectedUserType = v),
        validator: (v) => v == null ? 'Please select user type' : null,
      ),
    );
  }

  // ── Switch mode — no underline, light yellow on hover ──
  Widget _buildSwitchMode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isLogin ? "Don't have an account? " : "Already have an account? ",
          style: TextStyle(color: deepGreen.withOpacity(0.6), fontSize: 14),
        ),
        MouseRegion(
          onEnter: (_) => setState(() => _switchHover = true),
          onExit: (_) => setState(() => _switchHover = false),
          child: GestureDetector(
            onTap: _isLoading ? null : _switchMode,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: _switchHover
                    ? const Color.fromARGB(255, 250, 229, 146)
                    : deepGreen,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
              child: Text(isLogin ? 'Sign Up' : 'Sign In'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Text(_errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Text(_successMessage!,
                  style: const TextStyle(color: Colors.green, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: lightGreen.withOpacity(0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF366000), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red[300]!, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red[300]!, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isVisible,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
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
          icon: Icon(
              isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: deepGreen.withOpacity(0.5),
              size: 20),
          onPressed: _isLoading ? null : onToggle,
        ),
        filled: true,
        fillColor: const Color(0xFFEFF7E6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: lightGreen.withOpacity(0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF366000), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red[300]!, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red[300]!, width: 1.5),
        ),
      ),
      validator: validator ?? (v) => v!.isEmpty ? 'Please enter your password' : null,
    );
  }
}