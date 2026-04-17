// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'services/api_service.dart';
// import 'payment_history_screen.dart';

// class PaymentScreen extends StatefulWidget {
//   const PaymentScreen({super.key});

//   @override
//   State<PaymentScreen> createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen> {
//   final ApiService _api = ApiService();

//   final _phoneController         = TextEditingController(text: '+256');
//   final _transactionIdController = TextEditingController();

//   String _selectedPackage = '5_scans';
//   String _paymentMethod   = 'MTN';
//   bool   _isLoading       = false;
//   bool   _isLoadingCredits = true;
//   int    _credits         = 0;

//   int    _step          = 0;
//   String _orderRef      = '';
//   int    _orderAmount   = 0;
//   String _sendToNumber  = '';

//   String _mtnNumber    = '0766753527';
//   String _airtelNumber = '0750163604';

//   static const Color _green     = Color(0xFF366000);
//   static const Color _cardGreen = Color(0xFFBCD9A2);
//   static const Color _btnGreen  = Color(0xFF427A43);
//   static const Color _bgColor   = Color(0xFFF5E9CF);

//   final Map<String, Map<String, dynamic>> _packages = {
//     '1_scan':   {'name': 'Starter', 'credits': 1,  'price': 12000,  'popular': false},
//     '5_scans':  {'name': 'Popular', 'credits': 5,  'price': 50000,  'popular': true},
//     '10_scans': {'name': 'Pro',     'credits': 10, 'price': 90000,  'popular': false},
//     '20_scans': {'name': 'Agent',   'credits': 20, 'price': 160000, 'popular': false},
//   };

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     _transactionIdController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadData() async {
//     setState(() => _isLoadingCredits = true);
//     final credits = await _api.checkSoilScannerCredits();
//     try {
//       final info = await _api.getPaymentInfo();
//       if (info['success'] == true) {
//         setState(() {
//           _mtnNumber    = info['mtn_number']    ?? '0766753527';
//           _airtelNumber = info['airtel_number'] ?? '0750163604';
//         });
//       }
//     } catch (_) {}
//     if (mounted) {
//       setState(() {
//         _credits          = credits['credits_remaining'] ?? 0;
//         _isLoadingCredits = false;
//       });
//     }
//   }

//   Future<void> _initiateOrder() async {
//     if (_phoneController.text.length < 10) {
//       _showError('Please enter a valid phone number');
//       return;
//     }
//     setState(() => _isLoading = true);
//     final result = await _api.initiatePayment(
//       package:       _selectedPackage,
//       paymentMethod: _paymentMethod,
//       phoneNumber:   _phoneController.text.trim(),
//     );
//     setState(() => _isLoading = false);
//     if (!mounted) return;
//     if (result['success'] == true) {
//       setState(() {
//         _orderRef     = result['order_ref'] ?? '';
//         _orderAmount  = (result['amount']   ?? 0).toInt();
//         _sendToNumber = _paymentMethod == 'MTN' ? _mtnNumber : _airtelNumber;
//         _step         = 1;
//       });
//     } else {
//       _showError(result['message'] ?? 'Failed to create order');
//     }
//   }

//   Future<void> _submitTransactionId() async {
//     final txnId = _transactionIdController.text.trim();
//     if (txnId.isEmpty) {
//       _showError('Please enter the Transaction ID from your SMS');
//       return;
//     }
//     setState(() => _isLoading = true);
//     final result = await _api.submitTransactionId(
//       orderRef:      _orderRef,
//       transactionId: txnId,
//     );
//     setState(() => _isLoading = false);
//     if (!mounted) return;
//     if (result['success'] == true) {
//       _showSuccessDialog();
//     } else {
//       _showError(result['message'] ?? 'Submission failed');
//     }
//   }

//   void _showSuccessDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.mark_email_read_outlined, color: _green, size: 70),
//             const SizedBox(height: 16),
//             const Text('Payment Submitted!',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _green)),
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: _cardGreen.withOpacity(0.3),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Column(
//                 children: [
//                   Text('📧 Check your email!', style: TextStyle(fontWeight: FontWeight.bold)),
//                   SizedBox(height: 6),
//                   Text(
//                     'We have sent you a confirmation email.\n'
//                     'Credits will be added after we verify your payment.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontSize: 13),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text('Order: $_orderRef', style: const TextStyle(fontSize: 12, color: Colors.grey)),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () { Navigator.pop(context); Navigator.pop(context); },
//             child: const Text('OK', style: TextStyle(color: _green)),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentHistoryScreen()));
//             },
//             child: const Text('View History'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg), backgroundColor: Colors.red[400]),
//     );
//   }

//   String _formatPrice(num price) {
//     return price.toStringAsFixed(0).replaceAllMapped(
//       RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//       (m) => '${m[1]},',
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _bgColor,
//       appBar: AppBar(
//         title: const Text('Buy Credits'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         foregroundColor: _green,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.history),
//             tooltip: 'Payment History',
//             onPressed: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const PaymentHistoryScreen()),
//             ),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _buildCreditsCard(),
//             const SizedBox(height: 20),
//             _buildStepIndicator(),
//             const SizedBox(height: 20),

//             if (_step == 0) ...[
//               _buildPaymentNumbers(),
//               const SizedBox(height: 20),
//               _buildPackageSelector(),
//               const SizedBox(height: 20),
//               _buildPaymentMethodSelector(),
//               const SizedBox(height: 16),
//               _buildPhoneField(),
//               const SizedBox(height: 24),
//               _buildProceedButton(),
//             ],

//             if (_step == 1) ...[
//               _buildSendMoneyCard(),
//               const SizedBox(height: 20),
//               _buildTransactionIdField(),
//               const SizedBox(height: 24),
//               _buildSubmitButton(),
//               const SizedBox(height: 12),
//               TextButton(
//                 onPressed: () => setState(() => _step = 0),
//                 child: const Text('← Go Back', style: TextStyle(color: _green)),
//               ),
//             ],

//             const SizedBox(height: 16),
//             _buildHelpText(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCreditsCard() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(colors: [Color(0xFF2D5016), Color(0xFF4A7C2F)]),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.eco, color: Colors.white, size: 40),
//           const SizedBox(width: 16),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('Your Credits', style: TextStyle(color: Colors.white70, fontSize: 12)),
//               const SizedBox(height: 4),
//               _isLoadingCredits
//                   ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                   : Text(
//                       '$_credits Scan${_credits == 1 ? '' : 's'}',
//                       style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
//                     ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStepIndicator() {
//     return Row(
//       children: [
//         _stepDot(1, _step >= 0, 'Choose Package'),
//         Expanded(child: Divider(color: _step >= 1 ? _green : Colors.grey[300], thickness: 2)),
//         _stepDot(2, _step >= 1, 'Send & Confirm'),
//       ],
//     );
//   }

//   Widget _stepDot(int num, bool active, String label) {
//     return Column(
//       children: [
//         CircleAvatar(
//           radius: 16,
//           backgroundColor: active ? _green : Colors.grey[300],
//           child: Text('$num', style: TextStyle(color: active ? Colors.white : Colors.grey)),
//         ),
//         const SizedBox(height: 4),
//         Text(label, style: TextStyle(fontSize: 11, color: active ? _green : Colors.grey)),
//       ],
//     );
//   }

//   Widget _buildPaymentNumbers() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: _cardGreen),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(' Send Payment To:',
//               style: TextStyle(fontWeight: FontWeight.bold, color: _green, fontSize: 15)),
//           const SizedBox(height: 12),
//           _buildNumberRow('MTN',    _mtnNumber,    Colors.yellow[700]!),
//           const SizedBox(height: 8),
//           _buildNumberRow('Airtel', _airtelNumber, Colors.red[600]!),
//           const SizedBox(height: 8),
//           Text('Name: Yucca Consulting Ltd', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
//         ],
//       ),
//     );
//   }

//   Widget _buildNumberRow(String provider, String number, Color color) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
//           child: Text(provider,
//               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
//         ),
//         const SizedBox(width: 10),
//         Text(number, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
//         const Spacer(),
//         GestureDetector(
//           onTap: () {
//             Clipboard.setData(ClipboardData(text: number));
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('$provider number copied!'), duration: const Duration(seconds: 1)),
//             );
//           },
//           child: const Icon(Icons.copy, size: 18, color: _green),
//         ),
//       ],
//     );
//   }

//   Widget _buildPackageSelector() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Select Package',
//             style: TextStyle(fontWeight: FontWeight.bold, color: _green, fontSize: 16)),
//         const SizedBox(height: 12),
//         GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.3,
//           ),
//           itemCount: _packages.length,
//           itemBuilder: (_, index) {
//             final key      = _packages.keys.elementAt(index);
//             final pkg      = _packages[key]!;
//             final selected = _selectedPackage == key;
//             return GestureDetector(
//               onTap: () => setState(() => _selectedPackage = key),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: selected ? _green : Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: selected ? _green : _cardGreen, width: selected ? 2 : 1),
//                 ),
//                 child: Stack(
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(12),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(pkg['name'],
//                               style: TextStyle(fontWeight: FontWeight.bold,
//                                   color: selected ? Colors.white : _green)),
//                           const SizedBox(height: 4),
//                           Text('${pkg['credits']} Scan${pkg['credits'] > 1 ? 's' : ''}',
//                               style: TextStyle(fontSize: 12,
//                                   color: selected ? Colors.white70 : Colors.grey[600])),
//                           const SizedBox(height: 8),
//                           Text('UGX ${_formatPrice(pkg['price'])}',
//                               style: TextStyle(fontWeight: FontWeight.bold,
//                                   color: selected ? Colors.white : _btnGreen)),
//                         ],
//                       ),
//                     ),
//                     if (pkg['popular'])
//                       Positioned(
//                         top: 6, right: 6,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
//                           decoration: BoxDecoration(
//                               color: Colors.orange, borderRadius: BorderRadius.circular(10)),
//                           child: const Text('HOT',
//                               style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
//                         ),
//                       ),
//                     if (selected)
//                       Positioned(
//                         bottom: 8, right: 8,
//                         child: Container(
//                           padding: const EdgeInsets.all(3),
//                           decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
//                           child: const Icon(Icons.check, color: _green, size: 14),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildPaymentMethodSelector() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Payment Method',
//             style: TextStyle(fontWeight: FontWeight.bold, color: _green, fontSize: 16)),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(child: _buildMethodOption('MTN',    Colors.yellow[700]!)),
//             const SizedBox(width: 12),
//             Expanded(child: _buildMethodOption('AIRTEL', Colors.red[600]!)),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildMethodOption(String method, Color color) {
//     final selected = _paymentMethod == method;
//     return GestureDetector(
//       onTap: () => setState(() => _paymentMethod = method),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         decoration: BoxDecoration(
//           color: selected ? color.withOpacity(0.15) : Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: selected ? color : Colors.grey[300]!, width: 2),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Radio<String>(
//               value: method, groupValue: _paymentMethod,
//               onChanged: (v) => setState(() => _paymentMethod = v!),
//               activeColor: color,
//             ),
//             Text(method, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPhoneField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Your Phone Number',
//             style: TextStyle(fontWeight: FontWeight.bold, color: _green)),
//         const SizedBox(height: 8),
//         TextField(
//           controller: _phoneController,
//           keyboardType: TextInputType.phone,
//           decoration: InputDecoration(
//             hintText: '+256 7XX XXX XXX',
//             prefixIcon: const Icon(Icons.phone),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             filled: true, fillColor: Colors.white,
//             helperText: 'The number you will send money FROM',
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildProceedButton() {
//     final pkg = _packages[_selectedPackage]!;
//     return ElevatedButton(
//       onPressed: _isLoading ? null : _initiateOrder,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: _btnGreen, foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         elevation: 3,
//       ),
//       child: _isLoading
//           ? const SizedBox(width: 20, height: 20,
//               child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//           : Text('Proceed – UGX ${_formatPrice(pkg['price'])}',
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//     );
//   }

//   Widget _buildSendMoneyCard() {
//     final pkg = _packages[_selectedPackage]!;
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: _green, width: 2),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('Now Send Money',
//               style: TextStyle(fontWeight: FontWeight.bold, color: _green, fontSize: 16)),
//           const SizedBox(height: 12),
//           _infoRow('Send To',   _sendToNumber),
//           _infoRow('Amount',    'UGX ${_formatPrice(_orderAmount)}'),
//           _infoRow('Credits',   '${pkg['credits']} Scan${pkg['credits'] > 1 ? 's' : ''}'),
//           _infoRow('Method',    _paymentMethod),
//           _infoRow('Reference', _orderRef),
//           const Divider(height: 20),
//           const Text(
//             '✅ After sending, you will receive an SMS with a Transaction ID like:\n"TXN123456789"\n\nCopy it and paste below.',
//             style: TextStyle(fontSize: 13, color: Colors.black87),
//           ),
//           const SizedBox(height: 8),
//           OutlinedButton.icon(
//             onPressed: () {
//               Clipboard.setData(ClipboardData(text: _sendToNumber));
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                     content: Text('Number copied!'), duration: Duration(seconds: 1)),
//               );
//             },
//             icon: const Icon(Icons.copy, size: 16),
//             label: Text('Copy Number: $_sendToNumber'),
//             style: OutlinedButton.styleFrom(foregroundColor: _green),
//           ),
//           const SizedBox(height: 4),
//           const Text('Payment instructions also sent to your email.',
//               style: TextStyle(fontSize: 12, color: Colors.grey)),
//         ],
//       ),
//     );
//   }

//   Widget _infoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           SizedBox(width: 90,
//               child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13))),
//           Expanded(
//               child: Text(value,
//                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
//         ],
//       ),
//     );
//   }

//   Widget _buildTransactionIdField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Transaction ID *',
//             style: TextStyle(fontWeight: FontWeight.bold, color: _green, fontSize: 16)),
//         const SizedBox(height: 8),
//         TextField(
//           controller: _transactionIdController,
//           textCapitalization: TextCapitalization.characters,
//           decoration: InputDecoration(
//             hintText: 'e.g. TXN123456789 or MOB987654',
//             prefixIcon: const Icon(Icons.receipt_long),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             filled: true, fillColor: Colors.white,
//             helperText: 'Copy from the SMS you received after sending money',
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSubmitButton() {
//     return ElevatedButton.icon(
//       onPressed: _isLoading ? null : _submitTransactionId,
//       icon: const Icon(Icons.send),
//       label: _isLoading
//           ? const SizedBox(width: 20, height: 20,
//               child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//           : const Text('Submit Transaction ID',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: _green, foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         elevation: 3,
//       ),
//     );
//   }

//   // ✅ Company support email
//   Widget _buildHelpText() {
//     return Text(
//       'Need help? Email: yuccan.consult.ac@gmail.com',
//       style: TextStyle(fontSize: 11, color: Colors.grey[600]),
//       textAlign: TextAlign.center,
//     );
//   }
// }

// payment_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/api_service.dart';
import 'payment_history_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final ApiService _api = ApiService();

  // Controllers
  final _phoneController = TextEditingController(text: '+256');
  final _transactionIdController = TextEditingController();

  // State
  String _selectedPackage = '5_scans';
  String _paymentMethod = 'MTN';
  bool _isLoading = false;
  bool _isLoadingCredits = true;
  int _credits = 0;

  // Step: 0 = choose package, 1 = send money + enter TXN ID
  int _step = 0;
  String _orderRef = '';
  int _orderAmount = 0;
  String _sendToNumber = '';

  // Numbers from backend
  String _mtnNumber = '0766753527';
  String _airtelNumber = '0750163604';

  // ✅ DEMO MODE TOGGLE - Set to true for presentations
  bool _useDemoMode = true; // 👈 Toggle this for demo vs production

  // Theme
  static const Color _green = Color(0xFF366000);
  static const Color _cardGreen = Color(0xFFBCD9A2);
  static const Color _btnGreen = Color(0xFF427A43);
  static const Color _bgColor = Color(0xFFF5E9CF);

  // Packages
  final Map<String, Map<String, dynamic>> _packages = {
    '1_scan': {'name': 'Starter', 'credits': 1, 'price': 12000, 'popular': false},
    '5_scans': {'name': 'Popular', 'credits': 5, 'price': 50000, 'popular': true},
    '10_scans': {'name': 'Pro', 'credits': 10, 'price': 90000, 'popular': false},
    '20_scans': {'name': 'Agent', 'credits': 20, 'price': 160000, 'popular': false},
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _transactionIdController.dispose();
    super.dispose();
  }

  // ── Load credits + payment numbers from backend ───────────────────────────
  Future<void> _loadData() async {
    setState(() => _isLoadingCredits = true);

    // Load credits
    final credits = await _api.checkSoilScannerCredits();

    // Load payment info (numbers) from backend
    try {
      final info = await _api.getPaymentInfo();
      if (info['success'] == true) {
        setState(() {
          _mtnNumber = info['mtn_number'] ?? '0766753527';
          _airtelNumber = info['airtel_number'] ?? '0750163604';
        });
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _credits = credits['credits_remaining'] ?? 0;
        _isLoadingCredits = false;
      });
    }
  }

  // ── DEMO MODE: Simulate successful payment ─────────────────────────────────
  Future<void> _demoPayment() async {
    final pkg = _packages[_selectedPackage]!;
    
    setState(() => _isLoading = true);
    
    try {
      // Call demo endpoint (adds credits + sends email)
      final result = await _api.demoPaymentSuccess(
        credits: pkg['credits'],
        email: 'yuccan.consult.ac@gmail.com', // Replace with user's email in production
      );

      if (mounted && result['success'] == true) {
        // Update local credits
        setState(() {
          _credits = result['new_credits'] ?? _credits + pkg['credits'];
        });
        _showDemoSuccessDialog(pkg['credits']);
      } else {
        _showError(result['message'] ?? 'Demo payment failed');
      }
    } catch (e) {
      _showError('Demo error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Step 1: Initiate order → get order ref + send-to number ──────────────
  Future<void> _initiateOrder() async {
    // ✅ If demo mode, skip to success
    if (_useDemoMode) {
      await _demoPayment();
      return;
    }

    // Real flow continues...
    if (_phoneController.text.length < 10) {
      _showError('Please enter a valid phone number');
      return;
    }

    setState(() => _isLoading = true);

    final result = await _api.initiatePayment(
      package: _selectedPackage,
      paymentMethod: _paymentMethod,
      phoneNumber: _phoneController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _orderRef = result['order_ref'] ?? '';
        _orderAmount = (result['amount'] ?? 0).toInt();
        _sendToNumber = _paymentMethod == 'MTN' ? _mtnNumber : _airtelNumber;
        _step = 1; // Move to step 2
      });
    } else {
      _showError(result['message'] ?? 'Failed to create order');
    }
  }

  // ── Step 2: Submit transaction ID ─────────────────────────────────────────
  Future<void> _submitTransactionId() async {
    final txnId = _transactionIdController.text.trim();
    if (txnId.isEmpty) {
      _showError('Please enter the Transaction ID from your SMS');
      return;
    }

    setState(() => _isLoading = true);

    final result = await _api.submitTransactionId(
      orderRef: _orderRef,
      transactionId: txnId,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      _showSuccessDialog();
    } else {
      _showError(result['message'] ?? 'Submission failed');
    }
  }

  // ── Success Dialog (Real Flow) ────────────────────────────────────────────
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mark_email_read_outlined, color: _green, size: 70),
            const SizedBox(height: 16),
            const Text(
              'Payment Submitted!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _green),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _cardGreen.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    '📧 Check your email!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'We have sent you a confirmation email.\n'
                    'Credits will be added after we verify your payment.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Order: $_orderRef',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK', style: TextStyle(color: _green)),
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

  // ── Demo Success Dialog ───────────────────────────────────────────────────
  void _showDemoSuccessDialog(int creditsAdded) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.build, color: Colors.orange, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              '✅ Demo Mode Active',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _green),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _cardGreen.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '🎁 $creditsAdded credit${creditsAdded > 1 ? 's' : ''} added!',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'This is a demo simulation.\n'
                    'In production, credits are added after payment verification.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Balance: $_credits scans',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to previous screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Start Scanning'),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red[400]),
    );
  }

  String _formatPrice(num price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text('Buy Credits'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _green,
        actions: [
          // ✅ Demo mode indicator
          if (_useDemoMode)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'DEMO',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Payment History',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaymentHistoryScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCreditsCard(),
            const SizedBox(height: 20),

            // ✅ Demo mode toggle (hidden in production)
            if (_useDemoMode) _buildDemoToggle(),
            if (_useDemoMode) const SizedBox(height: 12),

            // Step indicator
            _buildStepIndicator(),
            const SizedBox(height: 20),

            // Step 0: Choose package + method + phone
            if (_step == 0) ...[
              _buildPaymentNumbers(),
              const SizedBox(height: 20),
              _buildPackageSelector(),
              const SizedBox(height: 20),
              _buildPaymentMethodSelector(),
              const SizedBox(height: 16),
              _buildPhoneField(),
              const SizedBox(height: 24),
              _buildProceedButton(),
            ],

            // Step 1: Send money + enter TXN ID (only in real mode)
            if (_step == 1 && !_useDemoMode) ...[
              _buildSendMoneyCard(),
              const SizedBox(height: 20),
              _buildTransactionIdField(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setState(() => _step = 0),
                child: const Text('← Go Back', style: TextStyle(color: _green)),
              ),
            ],

            const SizedBox(height: 16),
            _buildHelpText(),
          ],
        ),
      ),
    );
  }

  // ── Demo Mode Toggle Widget ───────────────────────────────────────────────
  Widget _buildDemoToggle() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.build, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Demo Mode: Credits added instantly without real payment',
              style: TextStyle(fontSize: 12, color: Colors.orange[800]),
            ),
          ),
          Switch(
            value: _useDemoMode,
            onChanged: (val) => setState(() => _useDemoMode = val),
            activeColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────────

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your Credits', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              _isLoadingCredits
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      '$_credits Scan${_credits == 1 ? '' : 's'}',
                      style: const TextStyle(
                        color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold,
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _stepDot(1, _step >= 0, 'Choose Package'),
        Expanded(child: Divider(color: _step >= 1 ? _green : Colors.grey[300], thickness: 2)),
        _stepDot(2, _step >= 1, 'Send & Confirm'),
      ],
    );
  }

  Widget _stepDot(int num, bool active, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: active ? _green : Colors.grey[300],
          child: Text('$num', style: TextStyle(color: active ? Colors.white : Colors.grey)),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: active ? _green : Colors.grey)),
      ],
    );
  }

  Widget _buildPaymentNumbers() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📱 Send Payment To:',
            style: TextStyle(fontWeight: FontWeight.bold, color: _green, fontSize: 15),
          ),
          const SizedBox(height: 12),
          _buildNumberRow('MTN', _mtnNumber, Colors.yellow[700]!),
          const SizedBox(height: 8),
          _buildNumberRow('Airtel', _airtelNumber, Colors.red[600]!),
          const SizedBox(height: 8),
          Text(
            'Name: Yucca Consulting Ltd',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberRow(String provider, String number, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          child: Text(provider, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        const SizedBox(width: 10),
        Text(number, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const Spacer(),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: number));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$provider number copied!'), duration: const Duration(seconds: 1)),
            );
          },
          child: const Icon(Icons.copy, size: 18, color: _green),
        ),
      ],
    );
  }

  Widget _buildPackageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Package', style: TextStyle(fontWeight: FontWeight.bold, color: _green, fontSize: 16)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.3,
          ),
          itemCount: _packages.length,
          itemBuilder: (_, index) {
            final key = _packages.keys.elementAt(index);
            final pkg = _packages[key]!;
            final selected = _selectedPackage == key;

            return GestureDetector(
              onTap: () => setState(() => _selectedPackage = key),
              child: Container(
                decoration: BoxDecoration(
                  color: selected ? _green : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: selected ? _green : _cardGreen, width: selected ? 2 : 1),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(pkg['name'], style: TextStyle(fontWeight: FontWeight.bold, color: selected ? Colors.white : _green)),
                          const SizedBox(height: 4),
                          Text('${pkg['credits']} Scan${pkg['credits'] > 1 ? 's' : ''}',
                              style: TextStyle(fontSize: 12, color: selected ? Colors.white70 : Colors.grey[600])),
                          const SizedBox(height: 8),
                          Text('UGX ${_formatPrice(pkg['price'])}',
                              style: TextStyle(fontWeight: FontWeight.bold, color: selected ? Colors.white : _btnGreen)),
                        ],
                      ),
                    ),
                    if (pkg['popular'])
                      Positioned(
                        top: 6, right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(10)),
                          child: const Text('HOT', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    if (selected)
                      Positioned(
                        bottom: 8, right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.check, color: _green, size: 14),
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

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold, color: _green, fontSize: 16)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMethodOption('MTN', Colors.yellow[700]!)),
            const SizedBox(width: 12),
            Expanded(child: _buildMethodOption('AIRTEL', Colors.red[600]!)),
          ],
        ),
      ],
    );
  }

  Widget _buildMethodOption(String method, Color color) {
    final selected = _paymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = method),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? color : Colors.grey[300]!, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio<String>(
              value: method, groupValue: _paymentMethod,
              onChanged: (v) => setState(() => _paymentMethod = v!),
              activeColor: color,
            ),
            Text(method, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Phone Number', style: TextStyle(fontWeight: FontWeight.bold, color: _green)),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: '+256 7XX XXX XXX',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true, fillColor: Colors.white,
            helperText: 'The number you will send money FROM',
          ),
        ),
      ],
    );
  }

  // ✅ FIXED: Proper string interpolation using pkg variable
  Widget _buildProceedButton() {
    final pkg = _packages[_selectedPackage]!;
    return ElevatedButton(
      onPressed: _isLoading ? null : _initiateOrder,
      style: ElevatedButton.styleFrom(
        backgroundColor: _btnGreen, 
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
      child: _isLoading
          ? const SizedBox(
              width: 20, 
              height: 20, 
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : Text(
              _useDemoMode 
                ? 'Demo: Add ${pkg['credits']} Credits'  // ✅ Fixed: use pkg instead of re-accessing map
                : 'Proceed – UGX ${_formatPrice(pkg['price'])}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }

  Widget _buildSendMoneyCard() {
    final pkg = _packages[_selectedPackage]!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _green, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Now Send Money', style: TextStyle(fontWeight: FontWeight.bold, color: _green, fontSize: 16)),
          const SizedBox(height: 12),
          _infoRow('Send To', _sendToNumber),
          _infoRow('Amount', 'UGX ${_formatPrice(_orderAmount)}'),
          _infoRow('Credits', '${pkg['credits']} Scan${pkg['credits'] > 1 ? 's' : ''}'),
          _infoRow('Method', _paymentMethod),
          _infoRow('Reference', _orderRef),
          const Divider(height: 20),
          const Text(
            'After sending, you will receive an SMS with a Transaction ID like:\n"TXN123456789"\n\nCopy it and paste below.',
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _sendToNumber));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Number copied!'), duration: Duration(seconds: 1)),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: Text('Copy Number: $_sendToNumber'),
            style: OutlinedButton.styleFrom(foregroundColor: _green),
          ),
          const SizedBox(height: 4),
          const Text(
            'Payment instructions also sent to your email.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionIdField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Transaction ID *', style: TextStyle(fontWeight: FontWeight.bold, color: _green, fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: _transactionIdController,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'e.g. TXN123456789 or MOB987654',
            prefixIcon: const Icon(Icons.receipt_long),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true, fillColor: Colors.white,
            helperText: 'Copy from the SMS you received after sending money',
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _submitTransactionId,
      icon: const Icon(Icons.send),
      label: _isLoading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Text('Submit Transaction ID', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: _green, foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
    );
  }

  Widget _buildHelpText() {
    return Text(
      'Need help? Email: yuccan.consult.ac@gmail.com',
      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
      textAlign: TextAlign.center,
    );
  }
}