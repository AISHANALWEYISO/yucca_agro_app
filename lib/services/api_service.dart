// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class ApiService {
//   String get baseUrl {
//     if (kIsWeb) return 'http://localhost:5001/api';
//     try {
//       if (Platform.isAndroid) return 'http://192.168.1.241:5001/api';
//     } catch (_) {}
//     return 'http://localhost:5001/api';
//   }

//   Future<Map<String, String>> _getHeaders() async {
//     final token = await getToken();
//     return {
//       'Content-Type': 'application/json',
//       if (token != null) 'Authorization': 'Bearer $token',
//     };
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   //  AUTH
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<Map<String, dynamic>> login({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/login'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'email': email, 'password': password}),
//       );

//       if (response.statusCode == 200) {
//         final data  = jsonDecode(response.body);
//         final prefs = await SharedPreferences.getInstance();

//         // ✅ FIXED: backend returns access_token directly at top level
//         await prefs.setString('access_token',  data['access_token']);
//         await prefs.setString('refresh_token', data['refresh_token'] ?? '');
//         await prefs.setString('user',          jsonEncode(data['user']));
//         await prefs.setBool('isLoggedIn',      true);

//         return {'success': true, 'data': data};
//       } else {
//         final error = jsonDecode(response.body);
//         return {'success': false, 'message': error['message'] ?? 'Login failed'};
//       }
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> register({
//     required String name,
//     required String email,
//     required String password,
//     required String confirmPassword,
//     int? age,
//     String? usertype,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/register'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'name':             name,
//           'email':            email,
//           'password':         password,
//           'confirm_password': confirmPassword,
//           'age':              age,
//           'usertype':         usertype ?? 'farmer',
//         }),
//       );

//       if (response.statusCode == 201) {
//         return {'success': true, 'message': 'Account created successfully! Please sign in.'};
//       } else {
//         final error = jsonDecode(response.body);
//         return {'success': false, 'message': error['message'] ?? 'Registration failed'};
//       }
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> sendOtp({required String email}) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/forgot-password/send-otp'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'email': email}),
//       ).timeout(const Duration(seconds: 15));

//       final data = jsonDecode(response.body);
//       if (response.statusCode == 200) {
//         return {'success': true, 'message': data['message']};
//       } else {
//         return {'success': false, 'message': data['message'] ?? 'Failed to send OTP'};
//       }
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> verifyOtp({
//     required String email,
//     required String otp,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/forgot-password/verify-otp'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'email': email, 'otp': otp}),
//       ).timeout(const Duration(seconds: 15));

//       final data = jsonDecode(response.body);
//       if (response.statusCode == 200 && data['success'] == true) {
//         return {'success': true, 'message': data['message']};
//       } else {
//         return {'success': false, 'message': data['message'] ?? 'Invalid OTP'};
//       }
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> resetPassword({
//     required String email,
//     required String newPassword,
//     required String confirmPassword,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/forgot-password/reset'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'email':            email,
//           'new_password':     newPassword,
//           'confirm_password': confirmPassword,
//         }),
//       ).timeout(const Duration(seconds: 15));

//       final data = jsonDecode(response.body);
//       if (response.statusCode == 200) {
//         return {'success': true, 'message': data['message']};
//       } else {
//         return {'success': false, 'message': data['message'] ?? 'Password reset failed'};
//       }
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   //  SESSION
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('access_token');
//     await prefs.remove('refresh_token');
//     await prefs.remove('user');
//     await prefs.setBool('isLoggedIn', false);
//   }

//   Future<bool> isLoggedIn() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool('isLoggedIn') ?? false;
//   }

//   Future<Map<String, dynamic>?> getUser() async {
//     final prefs   = await SharedPreferences.getInstance();
//     final userJson = prefs.getString('user');
//     if (userJson != null) return jsonDecode(userJson);
//     return null;
//   }

//   Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('access_token');
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   //  PROFILE
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<String?> uploadProfileImage(File imageFile) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('access_token');

//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/user/upload-profile-image'),
//       );
//       if (token != null) request.headers['Authorization'] = 'Bearer $token';
//       request.files.add(
//         await http.MultipartFile.fromPath('profile_image', imageFile.path),
//       );

//       final streamedResponse = await request.send();
//       final response         = await http.Response.fromStream(streamedResponse);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final user = await getUser();
//         if (user != null && data['image_url'] != null) {
//           user['profile_image'] = data['image_url'];
//           await prefs.setString('user', jsonEncode(user));
//         }
//         return data['image_url'] as String?;
//       } else {
//         throw Exception('Failed to upload: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Upload error: $e');
//       rethrow;
//     }
//   }

//   Future<Map<String, dynamic>> updateUserProfile({
//     String? name,
//     String? email,
//     String? phone,
//     String? profileImage,
//   }) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('access_token');

//       final response = await http.patch(
//         Uri.parse('$baseUrl/user/profile'),
//         headers: {
//           'Content-Type': 'application/json',
//           if (token != null) 'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           if (name != null)         'name':          name,
//           if (email != null)        'email':         email,
//           if (phone != null)        'phone':         phone,
//           if (profileImage != null) 'profile_image': profileImage,
//         }),
//       );

//       final data = jsonDecode(response.body);
//       if (response.statusCode == 200) {
//         final user = await getUser();
//         if (user != null) {
//           if (name != null)         user['name']          = name;
//           if (email != null)        user['email']         = email;
//           if (phone != null)        user['phone']         = phone;
//           if (profileImage != null) user['profile_image'] = profileImage;
//           await prefs.setString('user', jsonEncode(user));
//         }
//         return {'success': true, 'message': data['message'] ?? 'Profile updated'};
//       } else {
//         return {'success': false, 'message': data['message'] ?? 'Update failed'};
//       }
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   //  SOIL SCANNER
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<Map<String, dynamic>> checkSoilScannerCredits() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/user/soil-scanner-access'),
//         headers: await _getHeaders(),
//       ).timeout(const Duration(seconds: 10));
//       return jsonDecode(response.body);
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> getSoilScanHistory() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/soil/history'),
//         headers: await _getHeaders(),
//       ).timeout(const Duration(seconds: 10));
//       return jsonDecode(response.body);
//     } catch (e) {
//       return {'success': false, 'scans': [], 'message': 'Connection error: $e'};
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   //  PAYMENT
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<Map<String, dynamic>> getPaymentInfo() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/payment/info'),
//         headers: await _getHeaders(),
//       ).timeout(const Duration(seconds: 10));
//       return jsonDecode(response.body);
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> initiatePayment({
//     required String package,
//     required String paymentMethod,
//     required String phoneNumber,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/payment/initiate'),
//         headers: await _getHeaders(),
//         body: jsonEncode({
//           'package':        package,
//           'payment_method': paymentMethod,
//           'phone_number':   phoneNumber,
//         }),
//       ).timeout(const Duration(seconds: 15));
//       return jsonDecode(response.body);
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> submitTransactionId({
//     required String orderRef,
//     required String transactionId,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/payment/submit-transaction'),
//         headers: await _getHeaders(),
//         body: jsonEncode({
//           'order_ref':      orderRef,
//           'transaction_id': transactionId,
//         }),
//       ).timeout(const Duration(seconds: 15));
//       return jsonDecode(response.body);
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> getPaymentHistory() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/payment/my-orders'),
//         headers: await _getHeaders(),
//       ).timeout(const Duration(seconds: 10));
//       return jsonDecode(response.body);
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   //  TIPS
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<Map<String, dynamic>> getAllTips({String? category}) async {
//     try {
//       String url = '$baseUrl/';
//       if (category != null && category != 'All') url += '?category=$category';
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//       ).timeout(const Duration(seconds: 15));
//       if (response.statusCode == 200) return jsonDecode(response.body);
//       return {'success': false, 'message': 'Failed to fetch tips'};
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> getTipById(int tipId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/$tipId'),
//         headers: {'Content-Type': 'application/json'},
//       ).timeout(const Duration(seconds: 15));
//       if (response.statusCode == 200) return jsonDecode(response.body);
//       return {'success': false, 'message': 'Tip not found'};
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   //  DISEASES
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<Map<String, dynamic>> getDiseases({String? search}) async {
//     try {
//       String url = '$baseUrl/diseases/';
//       if (search != null && search.isNotEmpty) url += '?search=$search';
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//       ).timeout(const Duration(seconds: 15));
//       if (response.statusCode == 200) return jsonDecode(response.body);
//       return {'success': false, 'message': 'Failed to fetch diseases'};
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> getDiseaseById(int diseaseId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/diseases/$diseaseId'),
//         headers: {'Content-Type': 'application/json'},
//       ).timeout(const Duration(seconds: 15));
//       if (response.statusCode == 200) return jsonDecode(response.body);
//       return {'success': false, 'message': 'Disease not found'};
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> createDisease({
//     required String name,
//     String? description,
//     String? signs,
//     String? prevention,
//     String? treatment,
//     String? imageUrl,
//     File? imageFile,
//   }) async {
//     try {
//       final headers = await _getHeaders();
//       if (imageFile != null) {
//         var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/diseases/'));
//         request.headers.addAll(headers);
//         request.fields['name'] = name;
//         if (description != null) request.fields['description'] = description;
//         if (signs != null)       request.fields['signs']       = signs;
//         if (prevention != null)  request.fields['prevention']  = prevention;
//         if (treatment != null)   request.fields['treatment']   = treatment;
//         request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
//         final sr = await request.send();
//         return jsonDecode((await http.Response.fromStream(sr)).body);
//       } else {
//         final response = await http.post(
//           Uri.parse('$baseUrl/diseases/'),
//           headers: headers,
//           body: jsonEncode({
//             'name': name,
//             if (description != null) 'description': description,
//             if (signs != null)       'signs':       signs,
//             if (prevention != null)  'prevention':  prevention,
//             if (treatment != null)   'treatment':   treatment,
//             if (imageUrl != null)    'image_url':   imageUrl,
//           }),
//         ).timeout(const Duration(seconds: 15));
//         return jsonDecode(response.body);
//       }
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> updateDisease({
//     required int diseaseId,
//     String? name,
//     String? description,
//     String? signs,
//     String? prevention,
//     String? treatment,
//     String? imageUrl,
//     File? imageFile,
//   }) async {
//     try {
//       final headers = await _getHeaders();
//       if (imageFile != null) {
//         var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/diseases/$diseaseId'));
//         request.headers.addAll(headers);
//         if (name != null)        request.fields['name']        = name;
//         if (description != null) request.fields['description'] = description;
//         if (signs != null)       request.fields['signs']       = signs;
//         if (prevention != null)  request.fields['prevention']  = prevention;
//         if (treatment != null)   request.fields['treatment']   = treatment;
//         request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
//         final sr = await request.send();
//         return jsonDecode((await http.Response.fromStream(sr)).body);
//       } else {
//         final response = await http.put(
//           Uri.parse('$baseUrl/diseases/$diseaseId'),
//           headers: headers,
//           body: jsonEncode({
//             if (name != null)        'name':        name,
//             if (description != null) 'description': description,
//             if (signs != null)       'signs':       signs,
//             if (prevention != null)  'prevention':  prevention,
//             if (treatment != null)   'treatment':   treatment,
//             if (imageUrl != null)    'image_url':   imageUrl,
//           }),
//         ).timeout(const Duration(seconds: 15));
//         return jsonDecode(response.body);
//       }
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> deleteDisease(int diseaseId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/diseases/$diseaseId'),
//         headers: await _getHeaders(),
//       ).timeout(const Duration(seconds: 15));
//       return jsonDecode(response.body);
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   //  MARKET
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<Map<String, dynamic>> getMarketItems({
//     String? category,
//     String? search,
//     double? minPrice,
//     double? maxPrice,
//   }) async {
//     try {
//       String url          = '$baseUrl/market/';
//       final params        = <String, String>{};
//       if (category != null && category != 'All') params['category']  = category;
//       if (search != null && search.isNotEmpty)   params['search']    = search;
//       if (minPrice != null) params['min_price'] = minPrice.toString();
//       if (maxPrice != null) params['max_price'] = maxPrice.toString();
//       if (params.isNotEmpty) {
//         url += '?' + params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
//       }
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//       ).timeout(const Duration(seconds: 15));
//       return response.statusCode == 200
//           ? jsonDecode(response.body)
//           : {'success': false, 'message': 'Failed to fetch items'};
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> getMarketItemById(int itemId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/market/$itemId'),
//         headers: {'Content-Type': 'application/json'},
//       ).timeout(const Duration(seconds: 15));
//       return response.statusCode == 200
//           ? jsonDecode(response.body)
//           : {'success': false, 'message': 'Item not found'};
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> createMarketItem({
//     required String name,
//     required String category,
//     required double price,
//     String? description,
//     String unit = 'kg',
//     int quantityAvailable = 0,
//     String? sellerName,
//     String? sellerPhone,
//     String? sellerLocation,
//     String? imageUrl,
//     File? imageFile,
//   }) async {
//     try {
//       final headers = await _getHeaders();
//       if (imageFile != null) {
//         var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/market/'));
//         request.headers.addAll(headers);
//         request.fields['name']               = name;
//         request.fields['category']           = category;
//         request.fields['price']              = price.toString();
//         request.fields['unit']               = unit;
//         request.fields['quantity_available'] = quantityAvailable.toString();
//         if (description != null)    request.fields['description']    = description;
//         if (sellerName != null)     request.fields['seller_name']    = sellerName;
//         if (sellerPhone != null)    request.fields['seller_phone']   = sellerPhone;
//         if (sellerLocation != null) request.fields['seller_location']= sellerLocation;
//         request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
//         final sr = await request.send();
//         return jsonDecode((await http.Response.fromStream(sr)).body);
//       } else {
//         final response = await http.post(
//           Uri.parse('$baseUrl/market/'),
//           headers: headers,
//           body: jsonEncode({
//             'name':               name,
//             'category':           category,
//             'price':              price,
//             'unit':               unit,
//             'quantity_available': quantityAvailable,
//             if (description != null)    'description':    description,
//             if (sellerName != null)     'seller_name':    sellerName,
//             if (sellerPhone != null)    'seller_phone':   sellerPhone,
//             if (sellerLocation != null) 'seller_location':sellerLocation,
//             if (imageUrl != null)       'image_url':      imageUrl,
//           }),
//         ).timeout(const Duration(seconds: 15));
//         return jsonDecode(response.body);
//       }
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> updateMarketItem({
//     required int itemId,
//     String? name,
//     String? category,
//     double? price,
//     String? description,
//     String? unit,
//     int? quantityAvailable,
//     String? sellerName,
//     String? sellerPhone,
//     String? sellerLocation,
//     String? imageUrl,
//     File? imageFile,
//   }) async {
//     try {
//       final headers = await _getHeaders();
//       if (imageFile != null) {
//         var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/market/$itemId'));
//         request.headers.addAll(headers);
//         if (name != null)               request.fields['name']               = name;
//         if (category != null)           request.fields['category']           = category;
//         if (price != null)              request.fields['price']              = price.toString();
//         if (description != null)        request.fields['description']        = description;
//         if (unit != null)               request.fields['unit']               = unit;
//         if (quantityAvailable != null)  request.fields['quantity_available'] = quantityAvailable.toString();
//         if (sellerName != null)         request.fields['seller_name']        = sellerName;
//         if (sellerPhone != null)        request.fields['seller_phone']       = sellerPhone;
//         if (sellerLocation != null)     request.fields['seller_location']    = sellerLocation;
//         request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
//         final sr = await request.send();
//         return jsonDecode((await http.Response.fromStream(sr)).body);
//       } else {
//         final response = await http.put(
//           Uri.parse('$baseUrl/market/$itemId'),
//           headers: headers,
//           body: jsonEncode({
//             if (name != null)               'name':               name,
//             if (category != null)           'category':           category,
//             if (price != null)              'price':              price,
//             if (description != null)        'description':        description,
//             if (unit != null)               'unit':               unit,
//             if (quantityAvailable != null)  'quantity_available': quantityAvailable,
//             if (sellerName != null)         'seller_name':        sellerName,
//             if (sellerPhone != null)        'seller_phone':       sellerPhone,
//             if (sellerLocation != null)     'seller_location':    sellerLocation,
//             if (imageUrl != null)           'image_url':          imageUrl,
//           }),
//         ).timeout(const Duration(seconds: 15));
//         return jsonDecode(response.body);
//       }
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> deleteMarketItem(int itemId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/market/$itemId'),
//         headers: await _getHeaders(),
//       ).timeout(const Duration(seconds: 15));
//       return jsonDecode(response.body);
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   //  HELPER
//   // ─────────────────────────────────────────────────────────────────────────

//   String getFullImageUrl(String? relativeUrl) {
//     if (relativeUrl == null || relativeUrl.isEmpty) return '';
//     if (relativeUrl.startsWith('http')) return relativeUrl;
//     final root = baseUrl.replaceFirst('/api', '');
//     return '$root$relativeUrl';
//   }
// }
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class ApiService {
//   // 🔧 Dynamic IP: Use environment variable for flexibility
//   // Run with: flutter run --dart-define=DEV_IP=192.168.1.112
//   String get _devIp => const String.fromEnvironment('DEV_IP', defaultValue: '192.168.1.112');
//   bool get _isEmulator => const bool.fromEnvironment('IS_EMULATOR', defaultValue: false);

//   String get baseUrl {
//     if (kIsWeb) return 'http://localhost:5001/api';
//     try {
//       if (Platform.isAndroid) {
//         // Emulator uses special localhost alias
//         if (_isEmulator) return 'http://10.0.2.2:5001/api';
//         // Physical device: use configured IP
//         return 'http://$_devIp:5001/api';
//       }
//     } catch (_) {}
//     return 'http://localhost:5001/api';
//   }

//   // ── Shared Headers Helper ─────────────────────────────────────────────────
//   Future<Map<String, String>> _getHeaders() async {
//     final token = await getToken();
//     return {
//       'Content-Type': 'application/json',
//       if (token != null) 'Authorization': 'Bearer $token',
//     };
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   //  AUTH
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<Map<String, dynamic>> login({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/login'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'email': email, 'password': password}),
//       ).timeout(const Duration(seconds: 15));

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('access_token', data['access_token'] ?? '');
//         await prefs.setString('refresh_token', data['refresh_token'] ?? '');
//         await prefs.setString('user', jsonEncode(data['user'] ?? {}));
//         await prefs.setBool('isLoggedIn', true);
//         return {'success': true, 'data': data};
//       } else {
//         final error = jsonDecode(response.body);
//         return {'success': false, 'message': error['message'] ?? 'Login failed'};
//       }
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> register({
//     required String name,
//     required String email,
//     required String password,
//     required String confirmPassword,
//     int? age,
//     String? usertype,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/register'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'name': name,
//           'email': email,
//           'password': password,
//           'confirm_password': confirmPassword,
//           'age': age,
//           'usertype': usertype ?? 'farmer',
//         }),
//       ).timeout(const Duration(seconds: 15));

//       if (response.statusCode == 201) {
//         return {'success': true, 'message': 'Account created successfully! Please sign in.'};
//       } else {
//         final error = jsonDecode(response.body);
//         return {'success': false, 'message': error['message'] ?? 'Registration failed'};
//       }
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> sendOtp({required String email}) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/forgot-password/send-otp'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'email': email}),
//       ).timeout(const Duration(seconds: 15));

//       final data = jsonDecode(response.body);
//       if (response.statusCode == 200) {
//         return {'success': true, 'message': data['message']};
//       } else {
//         return {'success': false, 'message': data['message'] ?? 'Failed to send OTP'};
//       }
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> verifyOtp({
//     required String email,
//     required String otp,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/forgot-password/verify-otp'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'email': email, 'otp': otp}),
//       ).timeout(const Duration(seconds: 15));

//       final data = jsonDecode(response.body);
//       if (response.statusCode == 200 && data['success'] == true) {
//         return {'success': true, 'message': data['message']};
//       } else {
//         return {'success': false, 'message': data['message'] ?? 'Invalid OTP'};
//       }
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> resetPassword({
//     required String email,
//     required String newPassword,
//     required String confirmPassword,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/auth/forgot-password/reset'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'email': email,
//           'new_password': newPassword,
//           'confirm_password': confirmPassword,
//         }),
//       ).timeout(const Duration(seconds: 15));

//       final data = jsonDecode(response.body);
//       if (response.statusCode == 200) {
//         return {'success': true, 'message': data['message']};
//       } else {
//         return {'success': false, 'message': data['message'] ?? 'Password reset failed'};
//       }
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   //  SESSION
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('access_token');
//     await prefs.remove('refresh_token');
//     await prefs.remove('user');
//     await prefs.setBool('isLoggedIn', false);
//   }

//   Future<bool> isLoggedIn() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool('isLoggedIn') ?? false;
//   }

//   Future<Map<String, dynamic>?> getUser() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userJson = prefs.getString('user');
//     if (userJson != null) return jsonDecode(userJson);
//     return null;
//   }

//   Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('access_token');
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   //  PROFILE
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<String?> uploadProfileImage(File imageFile) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('access_token');

//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/user/upload-profile-image'),
//       );
//       if (token != null) request.headers['Authorization'] = 'Bearer $token';
//       request.files.add(
//         await http.MultipartFile.fromPath('profile_image', imageFile.path),
//       );

//       final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
//       final response = await http.Response.fromStream(streamedResponse);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final user = await getUser();
//         if (user != null && data['image_url'] != null) {
//           user['profile_image'] = data['image_url'];
//           await prefs.setString('user', jsonEncode(user));
//         }
//         return data['image_url'] as String?;
//       } else {
//         throw Exception('Failed to upload: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Upload error: $e');
//       rethrow;
//     }
//   }

//   Future<Map<String, dynamic>> updateUserProfile({
//     String? name,
//     String? email,
//     String? phone,
//     String? profileImage,
//   }) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('access_token');

//       final response = await http.patch(
//         Uri.parse('$baseUrl/user/profile'),
//         headers: {
//           'Content-Type': 'application/json',
//           if (token != null) 'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           if (name != null) 'name': name,
//           if (email != null) 'email': email,
//           if (phone != null) 'phone': phone,
//           if (profileImage != null) 'profile_image': profileImage,
//         }),
//       ).timeout(const Duration(seconds: 15));

//       final data = jsonDecode(response.body);
//       if (response.statusCode == 200) {
//         final user = await getUser();
//         if (user != null) {
//           if (name != null) user['name'] = name;
//           if (email != null) user['email'] = email;
//           if (phone != null) user['phone'] = phone;
//           if (profileImage != null) user['profile_image'] = profileImage;
//           await prefs.setString('user', jsonEncode(user));
//         }
//         return {'success': true, 'message': data['message'] ?? 'Profile updated'};
//       } else {
//         return {'success': false, 'message': data['message'] ?? 'Update failed'};
//       }
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   //  SOIL SCANNER
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<Map<String, dynamic>> checkSoilScannerCredits() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/user/soil-scanner-access'),
//         headers: await _getHeaders(),
//       ).timeout(const Duration(seconds: 10));
//       return jsonDecode(response.body);
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> getSoilScanHistory() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/soil/history'),
//         headers: await _getHeaders(),
//       ).timeout(const Duration(seconds: 10));
//       return jsonDecode(response.body);
//     } catch (e) {
//       return {'success': false, 'scans': [], 'message': 'Connection error: $e'};
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   //  PAYMENT
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<Map<String, dynamic>> getPaymentInfo() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/payment/info'),
//         headers: await _getHeaders(),
//       ).timeout(const Duration(seconds: 10));
//       return jsonDecode(response.body);
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> initiatePayment({
//     required String package,
//     required String paymentMethod,
//     required String phoneNumber,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/payment/initiate'),
//         headers: await _getHeaders(),
//         body: jsonEncode({
//           'package': package,
//           'payment_method': paymentMethod,
//           'phone_number': phoneNumber,
//         }),
//       ).timeout(const Duration(seconds: 15));
//       return jsonDecode(response.body);
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> submitTransactionId({
//     required String orderRef,
//     required String transactionId,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/payment/submit-transaction'),
//         headers: await _getHeaders(),
//         body: jsonEncode({
//           'order_ref': orderRef,
//           'transaction_id': transactionId,
//         }),
//       ).timeout(const Duration(seconds: 15));
//       return jsonDecode(response.body);
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> getPaymentHistory() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/payment/my-orders'),
//         headers: await _getHeaders(),
//       ).timeout(const Duration(seconds: 10));
//       return jsonDecode(response.body);
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   //  TIPS
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<Map<String, dynamic>> getAllTips({String? category}) async {
//     try {
//       String url = '$baseUrl/';
//       if (category != null && category != 'All') url += '?category=$category';
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//       ).timeout(const Duration(seconds: 15));
//       if (response.statusCode == 200) return jsonDecode(response.body);
//       return {'success': false, 'message': 'Failed to fetch tips'};
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> getTipById(int tipId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/$tipId'),
//         headers: {'Content-Type': 'application/json'},
//       ).timeout(const Duration(seconds: 15));
//       if (response.statusCode == 200) return jsonDecode(response.body);
//       return {'success': false, 'message': 'Tip not found'};
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   //  DISEASES
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<Map<String, dynamic>> getDiseases({String? search}) async {
//     try {
//       String url = '$baseUrl/diseases/';
//       if (search != null && search.isNotEmpty) url += '?search=$search';
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//       ).timeout(const Duration(seconds: 15));
//       if (response.statusCode == 200) return jsonDecode(response.body);
//       return {'success': false, 'message': 'Failed to fetch diseases'};
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> getDiseaseById(int diseaseId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/diseases/$diseaseId'),
//         headers: {'Content-Type': 'application/json'},
//       ).timeout(const Duration(seconds: 15));
//       if (response.statusCode == 200) return jsonDecode(response.body);
//       return {'success': false, 'message': 'Disease not found'};
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> createDisease({
//     required String name,
//     String? description,
//     String? signs,
//     String? prevention,
//     String? treatment,
//     String? imageUrl,
//     File? imageFile,
//   }) async {
//     try {
//       final headers = await _getHeaders();
//       if (imageFile != null) {
//         var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/diseases/'));
//         request.headers.addAll(headers);
//         request.fields['name'] = name;
//         if (description != null) request.fields['description'] = description;
//         if (signs != null) request.fields['signs'] = signs;
//         if (prevention != null) request.fields['prevention'] = prevention;
//         if (treatment != null) request.fields['treatment'] = treatment;
//         request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
//         final sr = await request.send().timeout(const Duration(seconds: 30));
//         return jsonDecode((await http.Response.fromStream(sr)).body);
//       } else {
//         final response = await http.post(
//           Uri.parse('$baseUrl/diseases/'),
//           headers: headers,
//           body: jsonEncode({
//             'name': name,
//             if (description != null) 'description': description,
//             if (signs != null) 'signs': signs,
//             if (prevention != null) 'prevention': prevention,
//             if (treatment != null) 'treatment': treatment,
//             if (imageUrl != null) 'image_url': imageUrl,
//           }),
//         ).timeout(const Duration(seconds: 15));
//         return jsonDecode(response.body);
//       }
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> updateDisease({
//     required int diseaseId,
//     String? name,
//     String? description,
//     String? signs,
//     String? prevention,
//     String? treatment,
//     String? imageUrl,
//     File? imageFile,
//   }) async {
//     try {
//       final headers = await _getHeaders();
//       if (imageFile != null) {
//         var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/diseases/$diseaseId'));
//         request.headers.addAll(headers);
//         if (name != null) request.fields['name'] = name;
//         if (description != null) request.fields['description'] = description;
//         if (signs != null) request.fields['signs'] = signs;
//         if (prevention != null) request.fields['prevention'] = prevention;
//         if (treatment != null) request.fields['treatment'] = treatment;
//         request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
//         final sr = await request.send().timeout(const Duration(seconds: 30));
//         return jsonDecode((await http.Response.fromStream(sr)).body);
//       } else {
//         final response = await http.put(
//           Uri.parse('$baseUrl/diseases/$diseaseId'),
//           headers: headers,
//           body: jsonEncode({
//             if (name != null) 'name': name,
//             if (description != null) 'description': description,
//             if (signs != null) 'signs': signs,
//             if (prevention != null) 'prevention': prevention,
//             if (treatment != null) 'treatment': treatment,
//             if (imageUrl != null) 'image_url': imageUrl,
//           }),
//         ).timeout(const Duration(seconds: 15));
//         return jsonDecode(response.body);
//       }
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> deleteDisease(int diseaseId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/diseases/$diseaseId'),
//         headers: await _getHeaders(),
//       ).timeout(const Duration(seconds: 15));
//       return jsonDecode(response.body);
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   //  MARKET
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<Map<String, dynamic>> getMarketItems({
//     String? category,
//     String? search,
//     double? minPrice,
//     double? maxPrice,
//   }) async {
//     try {
//       String url = '$baseUrl/market/';
//       final params = <String, String>{};
//       if (category != null && category != 'All') params['category'] = category;
//       if (search != null && search.isNotEmpty) params['search'] = search;
//       if (minPrice != null) params['min_price'] = minPrice.toString();
//       if (maxPrice != null) params['max_price'] = maxPrice.toString();
//       if (params.isNotEmpty) {
//         url += '?' + params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
//       }
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {'Content-Type': 'application/json'},
//       ).timeout(const Duration(seconds: 15));
//       return response.statusCode == 200
//           ? jsonDecode(response.body)
//           : {'success': false, 'message': 'Failed to fetch items'};
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> getMarketItemById(int itemId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/market/$itemId'),
//         headers: {'Content-Type': 'application/json'},
//       ).timeout(const Duration(seconds: 15));
//       return response.statusCode == 200
//           ? jsonDecode(response.body)
//           : {'success': false, 'message': 'Item not found'};
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> createMarketItem({
//     required String name,
//     required String category,
//     required double price,
//     String? description,
//     String unit = 'kg',
//     int quantityAvailable = 0,
//     String? sellerName,
//     String? sellerPhone,
//     String? sellerLocation,
//     String? imageUrl,
//     File? imageFile,
//   }) async {
//     try {
//       final headers = await _getHeaders();
//       if (imageFile != null) {
//         var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/market/'));
//         request.headers.addAll(headers);
//         request.fields['name'] = name;
//         request.fields['category'] = category;
//         request.fields['price'] = price.toString();
//         request.fields['unit'] = unit;
//         request.fields['quantity_available'] = quantityAvailable.toString();
//         if (description != null) request.fields['description'] = description;
//         if (sellerName != null) request.fields['seller_name'] = sellerName;
//         if (sellerPhone != null) request.fields['seller_phone'] = sellerPhone;
//         if (sellerLocation != null) request.fields['seller_location'] = sellerLocation;
//         request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
//         final sr = await request.send().timeout(const Duration(seconds: 30));
//         return jsonDecode((await http.Response.fromStream(sr)).body);
//       } else {
//         final response = await http.post(
//           Uri.parse('$baseUrl/market/'),
//           headers: headers,
//           body: jsonEncode({
//             'name': name,
//             'category': category,
//             'price': price,
//             'unit': unit,
//             'quantity_available': quantityAvailable,
//             if (description != null) 'description': description,
//             if (sellerName != null) 'seller_name': sellerName,
//             if (sellerPhone != null) 'seller_phone': sellerPhone,
//             if (sellerLocation != null) 'seller_location': sellerLocation,
//             if (imageUrl != null) 'image_url': imageUrl,
//           }),
//         ).timeout(const Duration(seconds: 15));
//         return jsonDecode(response.body);
//       }
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> updateMarketItem({
//     required int itemId,
//     String? name,
//     String? category,
//     double? price,
//     String? description,
//     String? unit,
//     int? quantityAvailable,
//     String? sellerName,
//     String? sellerPhone,
//     String? sellerLocation,
//     String? imageUrl,
//     File? imageFile,
//   }) async {
//     try {
//       final headers = await _getHeaders();
//       if (imageFile != null) {
//         var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/market/$itemId'));
//         request.headers.addAll(headers);
//         if (name != null) request.fields['name'] = name;
//         if (category != null) request.fields['category'] = category;
//         if (price != null) request.fields['price'] = price.toString();
//         if (description != null) request.fields['description'] = description;
//         if (unit != null) request.fields['unit'] = unit;
//         if (quantityAvailable != null) request.fields['quantity_available'] = quantityAvailable.toString();
//         if (sellerName != null) request.fields['seller_name'] = sellerName;
//         if (sellerPhone != null) request.fields['seller_phone'] = sellerPhone;
//         if (sellerLocation != null) request.fields['seller_location'] = sellerLocation;
//         request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
//         final sr = await request.send().timeout(const Duration(seconds: 30));
//         return jsonDecode((await http.Response.fromStream(sr)).body);
//       } else {
//         final response = await http.put(
//           Uri.parse('$baseUrl/market/$itemId'),
//           headers: headers,
//           body: jsonEncode({
//             if (name != null) 'name': name,
//             if (category != null) 'category': category,
//             if (price != null) 'price': price,
//             if (description != null) 'description': description,
//             if (unit != null) 'unit': unit,
//             if (quantityAvailable != null) 'quantity_available': quantityAvailable,
//             if (sellerName != null) 'seller_name': sellerName,
//             if (sellerPhone != null) 'seller_phone': sellerPhone,
//             if (sellerLocation != null) 'seller_location': sellerLocation,
//             if (imageUrl != null) 'image_url': imageUrl,
//           }),
//         ).timeout(const Duration(seconds: 15));
//         return jsonDecode(response.body);
//       }
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   Future<Map<String, dynamic>> deleteMarketItem(int itemId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/market/$itemId'),
//         headers: await _getHeaders(),
//       ).timeout(const Duration(seconds: 15));
//       return jsonDecode(response.body);
//     } catch (e) {
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   //  HELPER: Convert backend relative image URL to full URL
//   // ─────────────────────────────────────────────────────────────────────────

//   String getFullImageUrl(String? relativeUrl) {
//     if (relativeUrl == null || relativeUrl.isEmpty) return '';
//     if (relativeUrl.startsWith('http')) return relativeUrl;
//     // Remove /api from baseUrl to get root: http://192.168.1.112:5001
//     final root = baseUrl.replaceFirst('/api', '');
//     return '$root$relativeUrl';
//   }
// }

// services/api_service.dart

// services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  String get _devIp => const String.fromEnvironment('DEV_IP', defaultValue: '192.168.1.112');
  bool get _isEmulator => const bool.fromEnvironment('IS_EMULATOR', defaultValue: false);

  String get baseUrl {
    if (kIsWeb) return 'http://localhost:5001/api';
    try {
      if (Platform.isAndroid) {
        if (_isEmulator) return 'http://10.0.2.2:5001/api';
        return 'http://$_devIp:5001/api';
      }
    } catch (_) {}
    return 'http://localhost:5001/api';
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
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
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['access_token'] ?? '');
        await prefs.setString('refresh_token', data['refresh_token'] ?? '');
        await prefs.setString('user', jsonEncode(data['user'] ?? {}));
        await prefs.setBool('isLoggedIn', true);
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
          'name': name,
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
          'age': age,
          'usertype': usertype ?? 'farmer',
        }),
      ).timeout(const Duration(seconds: 15));

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
          'email': email,
          'new_password': newPassword,
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
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.files.add(
        await http.MultipartFile.fromPath('profile_image', imageFile.path),
      );

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

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
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (name != null) 'name': name,
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
          if (profileImage != null) 'profile_image': profileImage,
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final user = await getUser();
        if (user != null) {
          if (name != null) user['name'] = name;
          if (email != null) user['email'] = email;
          if (phone != null) user['phone'] = phone;
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
  //  SOIL SCANNER
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

  Future<Map<String, dynamic>> getSoilScanHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/soil/history'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'scans': [], 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> analyzeSoilImage({
    required File imageFile,
    required String region,
    required String season,
  }) async {
    try {
      final headers = await _getHeaders();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/soil/analyze'),
      );
      request.headers.addAll(headers);
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
      request.fields['region'] = region;
      request.fields['season'] = season;

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['error'] ?? error['message'] ?? 'Analysis failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  PAYMENT
  // ─────────────────────────────────────────────────────────────────────────

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
          'package': package,
          'payment_method': paymentMethod,
          'phone_number': phoneNumber,
        }),
      ).timeout(const Duration(seconds: 15));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> submitTransactionId({
    required String orderRef,
    required String transactionId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payment/submit-transaction'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'order_ref': orderRef,
          'transaction_id': transactionId,
        }),
      ).timeout(const Duration(seconds: 15));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

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

  Future<Map<String, dynamic>> demoPaymentSuccess({
    required int credits,
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payment/demo/success'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'credits': credits,
          'email': email,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Demo payment failed'};
      }
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
      if (category != null && category != 'All') url += '?category=$category';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {'success': false, 'message': 'Failed to fetch tips'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> getTipById(int tipId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tips/$tipId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {'success': false, 'message': 'Tip not found'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  DISEASES ✅ INCLUDING MISSING METHODS
  // ─────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDiseases({String? search}) async {
    try {
      String url = '$baseUrl/diseases/';
      if (search != null && search.isNotEmpty) url += '?search=$search';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {'success': false, 'message': 'Failed to fetch diseases'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> getDiseaseById(int diseaseId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/diseases/$diseaseId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {'success': false, 'message': 'Disease not found'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> createDisease({
    required String name,
    String? description,
    String? signs,
    String? prevention,
    String? treatment,
    String? imageUrl,
    File? imageFile,
  }) async {
    try {
      final headers = await _getHeaders();
      if (imageFile != null) {
        var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/diseases/'));
        request.headers.addAll(headers);
        request.fields['name'] = name;
        if (description != null) request.fields['description'] = description;
        if (signs != null) request.fields['signs'] = signs;
        if (prevention != null) request.fields['prevention'] = prevention;
        if (treatment != null) request.fields['treatment'] = treatment;
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
        final sr = await request.send().timeout(const Duration(seconds: 30));
        return jsonDecode((await http.Response.fromStream(sr)).body);
      } else {
        final response = await http.post(
          Uri.parse('$baseUrl/diseases/'),
          headers: headers,
          body: jsonEncode({
            'name': name,
            if (description != null) 'description': description,
            if (signs != null) 'signs': signs,
            if (prevention != null) 'prevention': prevention,
            if (treatment != null) 'treatment': treatment,
            if (imageUrl != null) 'image_url': imageUrl,
          }),
        ).timeout(const Duration(seconds: 15));
        return jsonDecode(response.body);
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateDisease({
    required int diseaseId,
    String? name,
    String? description,
    String? signs,
    String? prevention,
    String? treatment,
    String? imageUrl,
    File? imageFile,
  }) async {
    try {
      final headers = await _getHeaders();
      if (imageFile != null) {
        var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/diseases/$diseaseId'));
        request.headers.addAll(headers);
        if (name != null) request.fields['name'] = name;
        if (description != null) request.fields['description'] = description;
        if (signs != null) request.fields['signs'] = signs;
        if (prevention != null) request.fields['prevention'] = prevention;
        if (treatment != null) request.fields['treatment'] = treatment;
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
        final sr = await request.send().timeout(const Duration(seconds: 30));
        return jsonDecode((await http.Response.fromStream(sr)).body);
      } else {
        final response = await http.put(
          Uri.parse('$baseUrl/diseases/$diseaseId'),
          headers: headers,
          body: jsonEncode({
            if (name != null) 'name': name,
            if (description != null) 'description': description,
            if (signs != null) 'signs': signs,
            if (prevention != null) 'prevention': prevention,
            if (treatment != null) 'treatment': treatment,
            if (imageUrl != null) 'image_url': imageUrl,
          }),
        ).timeout(const Duration(seconds: 15));
        return jsonDecode(response.body);
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteDisease(int diseaseId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/diseases/$diseaseId'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 15));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  MARKET ✅ INCLUDING MISSING METHODS
  // ─────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getMarketItems({
    String? category,
    String? search,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      String url = '$baseUrl/market/';
      final params = <String, String>{};
      if (category != null && category != 'All') params['category'] = category;
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (minPrice != null) params['min_price'] = minPrice.toString();
      if (maxPrice != null) params['max_price'] = maxPrice.toString();
      if (params.isNotEmpty) {
        url += '?' + params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
      }
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));
      return response.statusCode == 200
          ? jsonDecode(response.body)
          : {'success': false, 'message': 'Failed to fetch items'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> getMarketItemById(int itemId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/market/$itemId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));
      return response.statusCode == 200
          ? jsonDecode(response.body)
          : {'success': false, 'message': 'Item not found'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> createMarketItem({
    required String name,
    required String category,
    required double price,
    String? description,
    String unit = 'kg',
    int quantityAvailable = 0,
    String? sellerName,
    String? sellerPhone,
    String? sellerLocation,
    String? imageUrl,
    File? imageFile,
  }) async {
    try {
      final headers = await _getHeaders();
      if (imageFile != null) {
        var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/market/'));
        request.headers.addAll(headers);
        request.fields['name'] = name;
        request.fields['category'] = category;
        request.fields['price'] = price.toString();
        request.fields['unit'] = unit;
        request.fields['quantity_available'] = quantityAvailable.toString();
        if (description != null) request.fields['description'] = description;
        if (sellerName != null) request.fields['seller_name'] = sellerName;
        if (sellerPhone != null) request.fields['seller_phone'] = sellerPhone;
        if (sellerLocation != null) request.fields['seller_location'] = sellerLocation;
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
        final sr = await request.send().timeout(const Duration(seconds: 30));
        return jsonDecode((await http.Response.fromStream(sr)).body);
      } else {
        final response = await http.post(
          Uri.parse('$baseUrl/market/'),
          headers: headers,
          body: jsonEncode({
            'name': name,
            'category': category,
            'price': price,
            'unit': unit,
            'quantity_available': quantityAvailable,
            if (description != null) 'description': description,
            if (sellerName != null) 'seller_name': sellerName,
            if (sellerPhone != null) 'seller_phone': sellerPhone,
            if (sellerLocation != null) 'seller_location': sellerLocation,
            if (imageUrl != null) 'image_url': imageUrl,
          }),
        ).timeout(const Duration(seconds: 15));
        return jsonDecode(response.body);
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateMarketItem({
    required int itemId,
    String? name,
    String? category,
    double? price,
    String? description,
    String? unit,
    int? quantityAvailable,
    String? sellerName,
    String? sellerPhone,
    String? sellerLocation,
    String? imageUrl,
    File? imageFile,
  }) async {
    try {
      final headers = await _getHeaders();
      if (imageFile != null) {
        var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/market/$itemId'));
        request.headers.addAll(headers);
        if (name != null) request.fields['name'] = name;
        if (category != null) request.fields['category'] = category;
        if (price != null) request.fields['price'] = price.toString();
        if (description != null) request.fields['description'] = description;
        if (unit != null) request.fields['unit'] = unit;
        if (quantityAvailable != null) request.fields['quantity_available'] = quantityAvailable.toString();
        if (sellerName != null) request.fields['seller_name'] = sellerName;
        if (sellerPhone != null) request.fields['seller_phone'] = sellerPhone;
        if (sellerLocation != null) request.fields['seller_location'] = sellerLocation;
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
        final sr = await request.send().timeout(const Duration(seconds: 30));
        return jsonDecode((await http.Response.fromStream(sr)).body);
      } else {
        final response = await http.put(
          Uri.parse('$baseUrl/market/$itemId'),
          headers: headers,
          body: jsonEncode({
            if (name != null) 'name': name,
            if (category != null) 'category': category,
            if (price != null) 'price': price,
            if (description != null) 'description': description,
            if (unit != null) 'unit': unit,
            if (quantityAvailable != null) 'quantity_available': quantityAvailable,
            if (sellerName != null) 'seller_name': sellerName,
            if (sellerPhone != null) 'seller_phone': sellerPhone,
            if (sellerLocation != null) 'seller_location': sellerLocation,
            if (imageUrl != null) 'image_url': imageUrl,
          }),
        ).timeout(const Duration(seconds: 15));
        return jsonDecode(response.body);
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteMarketItem(int itemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/market/$itemId'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 15));
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  HELPER
  // ─────────────────────────────────────────────────────────────────────────

  String getFullImageUrl(String? relativeUrl) {
    if (relativeUrl == null || relativeUrl.isEmpty) return '';
    if (relativeUrl.startsWith('http')) return relativeUrl;
    final root = baseUrl.replaceFirst('/api', '');
    return '$root$relativeUrl';
  }
}