import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'payment_history_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final ApiService _api = ApiService();
  
  // Form controllers
  final _phoneController = TextEditingController(text: '+256');
  final _transactionIdController = TextEditingController();
  
  // Selected package
  String _selectedPackage = '5_scans';
  String _paymentMethod = 'MTN';
  
  // State
  bool _isSubmitting = false;
  int _credits = 0;
  bool _isLoadingCredits = true;
  
  // Colors (match your app theme)
  static const Color colorLogoGreen = Color(0xFF366000);
  static const Color colorCardGreen = Color(0xFFBCD9A2);
  static const Color colorBtnGreen = Color(0xFF427A43);
  
  // Package data
  final Map<String, Map<String, dynamic>> _packages = {
    '1_scan': {
      'name': 'Starter',
      'credits': 1,
      'price': 12000,
      'popular': false,
    },
    '5_scans': {
      'name': 'Popular',
      'credits': 5,
      'price': 50000,
      'popular': true,
    },
    '10_scans': {
      'name': 'Pro',
      'credits': 10,
      'price': 90000,
      'popular': false,
    },
    '20_scans': {
      'name': 'Agent',
      'credits': 20,
      'price': 160000,
      'popular': false,
    },
  };

  @override
  void initState() {
    super.initState();
    _loadCredits();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _transactionIdController.dispose();
    super.dispose();
  }

  Future<void> _loadCredits() async {
    setState(() => _isLoadingCredits = true);
    final result = await _api.checkSoilScannerCredits();
    if (mounted) {
      setState(() {
        _credits = result['credits_remaining'] ?? 0;
        _isLoadingCredits = false;
      });
    }
  }

  Future<void> _submitPayment() async {
    // Validate
    if (_transactionIdController.text.trim().isEmpty) {
      _showError('Please enter Transaction ID from SMS');
      return;
    }
    if (_phoneController.text.length < 12) {
      _showError('Please enter valid phone number');
      return;
    }

    setState(() => _isSubmitting = true);

    // Submit payment
    final result = await _api.initiatePayment(
      package: _selectedPackage,
      paymentMethod: _paymentMethod,
      phoneNumber: _phoneController.text,
      transactionId: _transactionIdController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      
      if (result['success'] == true) {
        _showSuccess(result);
      } else {
        _showError(result['message'] ?? 'Payment failed');
      }
    }
  }

  void _showSuccess(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Submitted! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            Text(
              'Order: ${result['order_ref']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('${result['credits_amount']} credits will be added after approval.'),
            const SizedBox(height: 16),
            const Text(
              'Please allow 1-24 hours for verification.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to soil scanner
            },
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentHistoryScreen()),
              );
            },
            child: const Text('View History'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
      ),
    );
  }

  // ✅ HELPER: Format price with commas (e.g., 50000 → 50,000)
  String _formatPrice(num? price) {
    if (price == null) return '0';
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final package = _packages[_selectedPackage]!;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5E9CF),
      appBar: AppBar(
        title: const Text('Buy Credits'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colorLogoGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentHistoryScreen()),
              );
            },
            tooltip: 'Payment History',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Credits Card
            _buildCreditsCard(),
            const SizedBox(height: 24),
            
            // Payment Instructions
            _buildInstructionsCard(),
            const SizedBox(height: 24),
            
            // Package Selection
            _buildPackageSelector(),
            const SizedBox(height: 24),
            
            // Payment Method
            _buildPaymentMethod(),
            const SizedBox(height: 16),
            
            // Phone Number
            _buildPhoneNumberField(),
            const SizedBox(height: 16),
            
            // Transaction ID
            _buildTransactionIdField(),
            const SizedBox(height: 24),
            
            // Submit Button
            _buildSubmitButton(package['price']),
            const SizedBox(height: 16),
            
            // Help Text
            _buildHelpText(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D5016), Color(0xFF4A7C2F)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Credits',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                _isLoadingCredits
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : Text(
                        '$_credits Scans',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorCardGreen.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: colorLogoGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'How to Pay',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorLogoGreen,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStep('1', 'Select your package below'),
          _buildStep('2', 'Send exact amount via MTN/Airtel Mobile Money'),
          _buildStep('3', 'Enter the Transaction ID from your SMS'),
          _buildStep('4', 'Wait for approval (1-24 hours)'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorCardGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Send Payment To:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: colorLogoGreen),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.yellow[600],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('MTN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Text('+256 7XX XXX XXX', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red[600],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Airtel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Text('+256 7XX XXX XXX', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Name: Yucca Consulting Ltd', style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: colorLogoGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(num, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildPackageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Package',
          style: TextStyle(fontWeight: FontWeight.bold, color: colorLogoGreen, fontSize: 16),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemCount: _packages.length,
          itemBuilder: (context, index) {
            final key = _packages.keys.elementAt(index);
            final pkg = _packages[key]!;
            final isSelected = _selectedPackage == key;
            
            return GestureDetector(
              onTap: () => setState(() => _selectedPackage = key),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? colorLogoGreen : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? colorLogoGreen : colorCardGreen,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            pkg['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : colorLogoGreen,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${pkg['credits']} Scans',
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white70 : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // ✅ FIXED: Use helper method for price formatting
                          Text(
                            'UGX ${_formatPrice(pkg['price'])}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : colorBtnGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (pkg['popular'])
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'POPULAR',
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    if (isSelected)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: colorLogoGreen, size: 14),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: TextStyle(fontWeight: FontWeight.bold, color: colorLogoGreen, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPaymentOption('MTN', Colors.yellow[600]!),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPaymentOption('Airtel', Colors.red[600]!),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentOption(String method, Color color) {
    final isSelected = _paymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = method),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : Colors.grey[300]!, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio<String>(
              value: method,
              groupValue: _paymentMethod,
              onChanged: (v) => setState(() => _paymentMethod = v!),
              activeColor: color,
            ),
            Text(method, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: TextStyle(fontWeight: FontWeight.bold, color: colorLogoGreen),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: '+256 XX XXX XXXX',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.phone),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionIdField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction ID *',
          style: TextStyle(fontWeight: FontWeight.bold, color: colorLogoGreen),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _transactionIdController,
          decoration: InputDecoration(
            hintText: 'Enter ID from SMS (e.g., MOB123456789)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.receipt),
            filled: true,
            fillColor: Colors.white,
            helperText: 'Check your Mobile Money SMS after sending payment',
            helperStyle: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(num price) {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _submitPayment,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorBtnGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
      child: _isSubmitting
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : Text(
              // ✅ FIXED: Use helper method for price formatting
              'Submit Payment - UGX ${_formatPrice(price)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }

  Widget _buildHelpText() {
    return Text(
      'Need help? Contact us: support@yuccaconsult.com | +256 XXX XXX XXX',
      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
      textAlign: TextAlign.center,
    );
  }
}