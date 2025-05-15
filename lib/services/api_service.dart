// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io' if (dart.library.html) 'dart:html' show File; // Conditional import for File
import 'dart:typed_data'; // Used by both web and mobile

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // For MediaType
import 'package:path/path.dart' as path_lib; // Aliased to avoid conflict with http.path

/// A service class for handling API requests to the backend.
class ApiService {
  // Use 10.0.2.2 for Android emulator to connect to host's localhost.
  // For iOS simulator or physical devices, use your machine's local network IP.
  // static const _baseUrl = 'http://127.0.0.1:8000'; // For testing with local server directly
  static const _baseUrl = 'http://10.0.2.2:8000';

  /// Generic helper function for making POST requests with JSON body.
  static Future<Map<String, dynamic>> _post(String endpointPath, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl$endpointPath');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Decode with utf8 to handle various characters properly
        return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        _handleErrorResponse(response, endpointPath);
      }
    } catch (e) {
      throw Exception('Failed to connect to API at $endpointPath: $e');
    }
  }

  /// Generic helper function for making GET requests.
  static Future<Map<String, dynamic>> _get(String endpointPath) async {
    final uri = Uri.parse('$_baseUrl$endpointPath');
    try {
      final response = await http.get(uri);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } else {
        _handleErrorResponse(response, endpointPath);
      }
    } catch (e) {
      throw Exception('Failed to connect to API at $endpointPath: $e');
    }
  }

  /// Helper to consistently throw exceptions for error responses.
  static Never _handleErrorResponse(http.Response response, String endpointPath) {
    String errorMessage;
    try {
      // Try to parse error message from response body
      final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
      errorMessage = decodedBody['detail'] ?? decodedBody['message'] ?? utf8.decode(response.bodyBytes);
    } catch (_) {
      errorMessage = utf8.decode(response.bodyBytes);
    }
    throw Exception(
        'API Error on $endpointPath: ${response.statusCode} - $errorMessage');
  }

  /// 1) Translates the given [text] using the backend API.
  static Future<String> translate(String text) async {
    final data = await _post('/translate', {'text': text});
    return data['message'] as String;
  }

  /// 2) Fetches a list of [count] recommended topics from the API.
  static Future<List<String>> fetchTopics(int count) async {
    final data = await _get('/topics?count=$count');
    return List<String>.from(data['topics'] as List);
  }

  /// 3) Sends a message for role-playing conversation.
  ///
  /// [text] is the user's message.
  /// [language] is the target language for the conversation. // *** language 파라미터 추가 ***
  /// [history] is an optional list of previous messages for context.
  static Future<Map<String, dynamic>> roleplay({
    required String text,
    required String language,
    List<String>? history,
  }) async {
    final body = {
      'text': text,
      'language': language, // API 요청 바디에 language 포함
      if (history != null && history.isNotEmpty) 'history': history,
    };
    final data = await _post('/roleplay', body);
    return {
      'message': data['message'] as String,
      'history': List<String>.from(data['history'] as List),
    };
  }

  /// 4) Fetches an AI-generated comment for a given [eventId] and [userId].
  static Future<String> fetchComment({
    required String eventId,
    required String userId,
  }) async {
    final data = await _post('/comments', {
      'event_id': eventId,
      'user_id': userId,
    });
    return data['comment'] as String;
  }

  /// 5) Sends a message for free-form conversation.
  ///
  /// [text] is the user's message.
  /// [language] is the target language for the conversation. // *** language 파라미터 추가 ***
  /// [history] is an optional list of previous messages for context.
  static Future<Map<String, dynamic>> freeTalk({
    required String text,
    required String language,
    List<String>? history,
  }) async {
    final body = {
      'text': text,
      'language': language, // API 요청 바디에 language 포함
      if (history != null && history.isNotEmpty) 'history': history,
    };
    // Ensure the endpoint '/free-talk' matches your backend route
    final data = await _post('/free-talk', body);
    return {
      'message': data['message'] as String,
      'history': List<String>.from(data['history'] as List),
    };
  }

  /// 6) Uploads a photo to identify its location and get recommendations.
  ///
  /// For mobile: [filePath] is required.
  /// For web: [fileBytes], [fileName] are required. [mimeType] is optional but recommended.
  /// Returns a map with 'location_only' and 'full_text'. // *** 반환 타입 Map으로 변경 ***
  static Future<Map<String, String>> locatePhoto({
    String? filePath, // Required for mobile
    Uint8List? fileBytes, // Required for web
    String? fileName, // Required for web
    String? mimeType, // Optional for web, helps determine content type
  }) async {
    final uri = Uri.parse('$_baseUrl/locate');
    final request = http.MultipartRequest('POST', uri);
    http.MultipartFile multipartFile;

    if (kIsWeb) {
      // --- Web platform ---
      if (fileBytes == null || fileName == null) {
        throw ArgumentError('For web, fileBytes and fileName are required.');
      }

      MediaType? parsedMediaType;
      if (mimeType != null) {
        try {
          parsedMediaType = MediaType.parse(mimeType);
        } catch (e) {
          print('Warning: Could not parse provided MIME type: $mimeType. Defaulting...');
          // Fallback to octet-stream or try to guess from fileName
        }
      }

      if (parsedMediaType == null && fileName.contains('.')) {
        final extension = fileName.split('.').last.toLowerCase();
        if (extension == 'jpg' || extension == 'jpeg') {
          parsedMediaType = MediaType('image', 'jpeg');
        } else if (extension == 'png') {
          parsedMediaType = MediaType('image', 'png');
        }
        // Add more common types if needed
      }
      // Default if still null
      parsedMediaType ??= MediaType('application', 'octet-stream');

      multipartFile = http.MultipartFile.fromBytes(
        'file', // Field name expected by the server
        fileBytes,
        filename: fileName,
        contentType: parsedMediaType,
      );
    } else {
      // --- Mobile (iOS/Android) platform ---
      if (filePath == null || filePath.isEmpty) {
        throw ArgumentError('For mobile, filePath is required.');
      }
      final imageFile = File(filePath); // dart:io File
      if (!await imageFile.exists()) {
        throw Exception('Image file not found at path: $filePath');
      }

      String fileExtension = path_lib.extension(imageFile.path).replaceFirst('.', '').toLowerCase();
      if (fileExtension.isEmpty) fileExtension = 'jpg'; // Default extension

      multipartFile = await http.MultipartFile.fromPath(
        'file', // Field name
        imageFile.path,
        contentType: MediaType('image', fileExtension),
      );
    }

    request.files.add(multipartFile);

    try {
      final streamedResponse = await request.send();
      final responseString = await streamedResponse.stream.bytesToString(); // Read response once

      if (streamedResponse.statusCode >= 200 && streamedResponse.statusCode < 300) {
        final data = jsonDecode(responseString) as Map<String, dynamic>;

        // Null-safe access to response data
        final String locationOnly = data['location'] as String? ?? '';
        final String fullText = data['recommendation'] as String? ?? 'No additional information available.';

        return {'location_only': locationOnly, 'full_text': fullText};
      } else {
        throw Exception(
            'Photo location API failed: ${streamedResponse.statusCode} - $responseString');
      }
    } catch (e) {
      throw Exception('Error during photo location request: $e');
    }
  }

  /// 7) Fetches cultural differences information between [homeCountry] and [destinationCountry].
  ///    Uses a GET request like /culture?home=...&dest=...
  static Future<String> fetchCulturalDifferences({
    required String homeCountry,
    required String destinationCountry,
  }) async {
    final queryParameters = {
      'home': homeCountry,
      'dest': destinationCountry,
    };
    // Uri.encodeQueryComponent is implicitly handled by Uri constructor with queryParameters
    final endpointPath = '/culture?${Uri(queryParameters: queryParameters).query}';
    final data = await _get(endpointPath);
    return data['description'] as String;
  }

  /// 8) Fetches scenario-specific travel phrases based on [userRequest].
  ///    Example [userRequest]: "Expressions for checking in baggage at the airport in Korean"
  static Future<String> fetchScenarioPhrases({
    required String userRequest,
  }) async {
    final data = await _post('/phrases', {'request': userRequest});
    // Assumes server returns 'phrases' key with the string value.
    return data['phrases'] as String;
  }
}