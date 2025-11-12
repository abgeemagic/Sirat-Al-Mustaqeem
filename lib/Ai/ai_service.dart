import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AIService {
  // Use Firebase Functions URL - replace with your actual project ID
  static const String _baseUrl =
      'https://molvi-qn66afdif-abgees-projects.vercel.app';
  static const String _fallbackUrl =
      'http://192.168.73.183:3000'; // Keep as fallback for local development
  static Process? _serverProcess;
  static bool _isServerRunning = false;
  static bool _useCloudFunction =
      true; // Flag to switch between cloud and local
  static Future<bool> isServerRunning() async {
    try {
      final url = _useCloudFunction ? _baseUrl : _fallbackUrl;
      final response = await http
          .get(Uri.parse('$url/health'))
          .timeout(const Duration(seconds: 5));
      _isServerRunning = response.statusCode == 200;
      return _isServerRunning;
    } catch (e) {
      // If cloud function fails, try fallback URL
      if (_useCloudFunction) {
        try {
          final response = await http
              .get(Uri.parse('$_fallbackUrl/health'))
              .timeout(const Duration(seconds: 5));
          _isServerRunning = response.statusCode == 200;
          return _isServerRunning;
        } catch (fallbackError) {
          _isServerRunning = false;
          return false;
        }
      }
      _isServerRunning = false;
      return false;
    }
  }

  static Future<bool> startServer() async {
    if (_isServerRunning) return true;
    try {
      final serverPath =
          'e:\\FlutterProjects\\molvipromaxnew\\lib\\ChatBot\\Server';
      _serverProcess = await Process.start(
        'node',
        ['index.js'],
        workingDirectory: serverPath,
        mode: ProcessStartMode.detached,
      );
      await Future.delayed(const Duration(seconds: 3));
      bool running = await isServerRunning();
      _isServerRunning = running;
      return running;
    } catch (e) {
      print('Error starting server: $e');
      return false;
    }
  }

  static Future<bool> stopServer() async {
    try {
      if (_serverProcess != null) {
        _serverProcess!.kill();
        _serverProcess = null;
      }
      _isServerRunning = false;
      return true;
    } catch (e) {
      print('Error stopping server: $e');
      return false;
    }
  }

  static bool get serverStatus => _isServerRunning;
  static Future<String> sendMessage(String message,
      {String? userContext}) async {
    final url = _useCloudFunction ? _baseUrl : _fallbackUrl;
    print('🔄 Attempting to send message to: $url/chat');

    try {
      final response = await http
          .post(
            Uri.parse('$url/chat'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'message': message,
              'userContext': userContext ?? "general Islamic guidance",
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['text'] ?? 'Sorry, I could not generate a response.';
      } else {
        print('❌ API Error: ${response.statusCode} - ${response.body}');
        // Try fallback if cloud function fails
        if (_useCloudFunction) {
          return await _tryFallbackRequest(message, userContext);
        }
        return 'Sorry, I encountered an error while processing your request. Please try again.';
      }
    } catch (e) {
      print('Network Error: $e');
      // Try fallback if cloud function fails
      if (_useCloudFunction) {
        return await _tryFallbackRequest(message, userContext);
      }
      return _getFallbackResponse(message);
    }
  }

  static Future<String> _tryFallbackRequest(
      String message, String? userContext) async {
    try {
      print('🔄 Trying fallback URL: $_fallbackUrl/chat');
      final response = await http
          .post(
            Uri.parse('$_fallbackUrl/chat'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'message': message,
              'userContext': userContext ?? "general Islamic guidance",
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['text'] ?? 'Sorry, I could not generate a response.';
      }
    } catch (e) {
      print('Fallback request also failed: $e');
    }
    return _getFallbackResponse(message);
  }

  // Method to toggle between cloud and local server
  static void setUseCloudFunction(bool useCloud) {
    _useCloudFunction = useCloud;
  }

  static bool get isUsingCloudFunction => _useCloudFunction;

  static String _getFallbackResponse(String message) {
    final query = message.toLowerCase();
    if (query.contains('salah') ||
        query.contains('prayer') ||
        query.contains('namaz')) {
      return "Salah (Prayer) is one of the Five Pillars of Islam. Muslims are required to perform five daily prayers: Fajr (dawn), Dhuhr (midday), Asr (afternoon), Maghrib (sunset), and Isha (night). Each prayer has specific times and consists of a sequence of physical postures and recitations from the Quran.\n\n[Note: AI service temporarily unavailable - showing offline response]";
    } else if (query.contains('quran') || query.contains('quraan')) {
      return "The Quran is the holy book of Islam, believed by Muslims to be the direct word of Allah revealed to Prophet Muhammad (PBUH) through the angel Gabriel (Jibril). It consists of 114 chapters (Surahs) and is written in Arabic. The Quran provides guidance for all aspects of life.\n\n[Note: AI service temporarily unavailable - showing offline response]";
    } else if (query.contains('hadith') || query.contains('sunnah')) {
      return "Hadith are the recorded sayings, actions, and approvals of Prophet Muhammad (PBUH). Along with the Quran, Hadith form the basis of Islamic jurisprudence and provide practical examples of how to implement Quranic teachings in daily life.\n\n[Note: AI service temporarily unavailable - showing offline response]";
    } else {
      return "I'm sorry, I'm currently unable to connect to the AI service. Please check your internet connection and try again. You can ask about Islamic teachings, Quran, Hadith, prayers, and other Islamic topics.\n\n[Note: AI service temporarily unavailable]";
    }
  }
}
