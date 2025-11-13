class ApiConfig {
  // Thay đổi URL này theo môi trường
  // Android Emulator: 10.0.2.2
  // iOS Simulator: localhost
  // Physical Device: IP của máy (VD: 192.168.1.100)

  // static const String baseUrl = 'http://10.0.2.2:5015/api'; // Android Emulator
  static const String baseUrl =
      'http://192.168.0.158:5015/api'; // Physical Device - HTTP port 5015
  // static const String baseUrl = 'http://127.0.0.1:5015/api'; // iOS Simulator / Desktop

  static const Duration timeout = Duration(seconds: 30);

  // Endpoints
  static const String auth = '/Auth';
  static const String decks = '/decks';
  static const String flashcards = '/flashcards';
  static const String study = '/study';
  static const String statistics = '/statistics';
}
