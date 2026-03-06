// lib/utils/constants.dart
class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/token/refresh';
  static const String forgotPassword = '/auth/forgot_password';
  
  // Weather
  static const String weatherForecast = '/weather/forecast';
  
  // Tips
  static const String tips = '/tips/';
  static String tipById(int id) => '/tips/$id';
  
  // Diseases
  static const String diseases = '/diseases/';
}

class AppConstants {
  static const String appName = 'Yucca Agro';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserData = 'user_data';
  
  // Form Validation
  static const int minPasswordLength = 6;
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
}