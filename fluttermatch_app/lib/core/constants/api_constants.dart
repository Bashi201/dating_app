class ApiConstants {
  // Change this to your Laravel URL
  // Note: 10.0.2.2 is how Android emulator reaches your localhost
  static const String baseHost = 'http://10.0.2.2:8000';
  static const String baseUrl = '$baseHost/api';

  // Auth
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String forgotPass = '/forgot-password';
  static const String resetPass = '/reset-password';

  // Profile
  static const String profile = '/profile';
  static const String updateProfile = '/profile/update';
  static const String uploadPhoto = '/profile/photos';

  // Discovery
  static const String discover = '/discover';
  static const String like = '/like';
  static const String dislike = '/dislike';

  // Matches
  static const String matches = '/matches';

  // Chat
  static const String messages = '/messages';
  static const String sendMessage = '/messages/send';

  // Reverb WebSocket
  static const String reverbHost =
      '10.0.2.2'; // Android emulator → host localhost
  static const String reverbPort = '8080';
  static const String reverbKey =
      '3n3nvkv6wvrtm9l30wba'; // from your .env REVERB_APP_KEY
  static const String reverbScheme = 'ws'; // ws for local, wss for production
}
