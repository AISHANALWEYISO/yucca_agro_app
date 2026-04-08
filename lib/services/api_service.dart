import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ── Base URL ──────────────────────────────────────────────────────────────
  String get baseUrl {
    if (kIsWeb) return 'http://localhost:5001/api';
    try {
      if (Platform.isAndroid) return 'http://192.168.1.85:5001/api';
    } catch (_) {}
    return 'http://localhost:5001/api';
  }

  // ── Shared Headers Helper ─────────────────────────────────────────────────
  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  AUTH
  // ─────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token',  data['access_token']);
        await prefs.setString('refresh_token', data['refresh_token']);
        await prefs.setString('user',          jsonEncode(data['user']));
        await prefs.setBool('isLoggedIn',      true);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    int? age,
    String? usertype,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name':             name,
          'email':            email,
          'password':         password,
          'confirm_password': confirmPassword,
          'age':              age,
          'usertype':         'Farmer',
        }),
      );

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Account created successfully! Please sign in.'};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> sendOtp({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to send OTP'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Invalid OTP'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password/reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email':            email,
          'new_password':     newPassword,
          'confirm_password': confirmPassword,
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Password reset failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SESSION
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user');
    await prefs.setBool('isLoggedIn', false);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) return jsonDecode(userJson);
    return null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  PROFILE
  // ─────────────────────────────────────────────────────────────────────────

  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/user/upload-profile-image'),
      );

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(
        await http.MultipartFile.fromPath('profile_image', imageFile.path),
      );

      final streamedResponse = await request.send();
      final response        = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = await getUser();
        if (user != null && data['image_url'] != null) {
          user['profile_image'] = data['image_url'];
          await prefs.setString('user', jsonEncode(user));
        }
        return data['image_url'] as String?;
      } else {
        throw Exception('Failed to upload: ${response.statusCode}');
      }
    } catch (e) {
      print('Upload error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateUserProfile({
    String? name,
    String? email,
    String? phone,
    String? profileImage,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.patch(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (name != null)         'name':          name,
          if (email != null)        'email':         email,
          if (phone != null)        'phone':         phone,
          if (profileImage != null) 'profile_image': profileImage,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final user = await getUser();
        if (user != null) {
          if (name != null)         user['name']          = name;
          if (email != null)        user['email']         = email;
          if (phone != null)        user['phone']         = phone;
          if (profileImage != null) user['profile_image'] = profileImage;
          await prefs.setString('user', jsonEncode(user));
        }
        return {'success': true, 'message': data['message'] ?? 'Profile updated'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Update failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SOIL SCANNER CREDITS
  // ─────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> checkSoilScannerCredits() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/soil-scanner-access'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  PAYMENT
  // ─────────────────────────────────────────────────────────────────────────

  // Get your MTN/Airtel numbers + packages from backend
  Future<Map<String, dynamic>> getPaymentInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payment/info'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Step 1: Create order → farmer gets email with instructions
  Future<Map<String, dynamic>> initiatePayment({
    required String package,
    required String paymentMethod,
    required String phoneNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payment/initiate'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'package':        package,
          'payment_method': paymentMethod,
          'phone_number':   phoneNumber,
        }),
      ).timeout(const Duration(seconds: 15));

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Step 2: Farmer submits transaction ID from their MTN/Airtel SMS
  Future<Map<String, dynamic>> submitTransactionId({
    required String orderRef,
    required String transactionId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payment/submit-transaction'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'order_ref':      orderRef,
          'transaction_id': transactionId,
        }),
      ).timeout(const Duration(seconds: 15));

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Get farmer's payment history
  Future<Map<String, dynamic>> getPaymentHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payment/my-orders'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  TIPS
  // ─────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getAllTips({String? category}) async {
    try {
      String url = '$baseUrl/tips/';
      if (category != null) url += '?category=$category';

      final response = await http.get(
        Uri.parse(url),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Failed to fetch tips'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> getTipById(int tipId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tips/$tipId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Tip not found'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}