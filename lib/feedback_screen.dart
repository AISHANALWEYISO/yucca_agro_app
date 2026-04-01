import 'package:flutter/material.dart';
import 'services/api_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;
  final ApiService _api = ApiService();

  static const Color colorLogoGreen = Color(0xFF366000);
  static const Color colorBtnGreen = Color(0xFF427A43);

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // TODO: Replace with actual API call
      // final response = await http.post(
      //   Uri.parse('${_api.baseUrl}/feedback'),
      //   headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${_api.token}'},
      //   body: jsonEncode({'subject': _subjectController.text, 'message': _messageController.text}),
      // );

      await Future.delayed(const Duration(seconds: 1)); // Mock API

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you! Your feedback has been sent.')),
        );
        _subjectController.clear();
        _messageController.clear();
        _formKey.currentState!.reset();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colorLogoGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'We value your input!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorLogoGreen),
              ),
              const SizedBox(height: 8),
              Text(
                'Help us improve Yucca Consult by sharing your thoughts, suggestions, or issues.',
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 24),

              // Subject Field
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  hintText: 'e.g., Feature request, Bug report, General feedback',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) => v!.trim().isEmpty ? 'Please enter a subject' : null,
              ),
              const SizedBox(height: 16),

              // Message Field
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  hintText: 'Tell us more...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.edit_note),
                ),
                maxLines: 5,
                validator: (v) => v!.trim().length < 10 ? 'Please enter at least 10 characters' : null,
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorBtnGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Send Feedback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),

              // Contact Info
              Row(
                children: [
                  Icon(Icons.email, size: 18, color: colorLogoGreen),
                  const SizedBox(width: 8),
                  Text('support@yuccaconsult.com', style: TextStyle(color: colorLogoGreen)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone, size: 18, color: colorLogoGreen),
                  const SizedBox(width: 8),
                  Text('+256 XXX XXX XXX', style: TextStyle(color: colorLogoGreen)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}