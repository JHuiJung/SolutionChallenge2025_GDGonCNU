// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io'; // dart:io를 직접 import
import 'dart:typed_data'; // Uint8List는 양쪽에서 사용
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path_lib; // path와 http.path 충돌 방지 위해 별칭 사용

class ApiService {
  static const _baseUrl = 'http://127.0.0.1:8000';

  // 공통적으로 JSON POST
  static Future<Map<String, dynamic>> _post(
      String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl$path');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('API Error ${resp.statusCode}: ${resp.body}');
  }

  // 공통적으로 GET
  static Future<Map<String, dynamic>> _get(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    final resp = await http.get(uri);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('API Error ${resp.statusCode}: ${resp.body}');
  }

  /// 1) 번역
  static Future<String> translate(String text) async {
    final data = await _post('/translate', {'text': text});
    return data['message'] as String;
  }

  /// 2) 토픽 추천
  static Future<List<String>> fetchTopics(int count) async {
    final data = await _get('/topics?count=$count');
    return List<String>.from(data['topics'] as List);
  }

  // /// 3) 구문 추천
  // static Future<List<String>> fetchPhrases() async {
  //   final data = await _post('/phrases', {});
  //   return List<String>.from(data['phrases'] as List);
  // }

  /// 4) 롤플레잉
  ///    history는 대화 컨텍스트 유지용 리스트
  static Future<Map<String, dynamic>> roleplay({
    required String text,
    List<String>? history,
  }) async {
    final body = {'text': text, if (history != null) 'history': history};
    final data = await _post('/roleplay', body);
    return {
      'message': data['message'] as String,
      'history': List<String>.from(data['history'] as List)
    };
  }

  /// 5) AI 코멘트
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

  // /// 6) 언어 학습 회화문
  // static Future<List<String>> fetchLessons({
  //   required String country,
  //   String? region,
  //   int count = 5,
  // }) async {
  //   // GET /learn?country=...&region=...&count=...
  //   final query = [
  //     'country=${Uri.encodeComponent(country)}',
  //     if (region != null) 'region=${Uri.encodeComponent(region)}',
  //     'count=$count'
  //   ].join('&');
  //   final data = await _get('/learn?$query');
  //   return List<String>.from(data['lessons'] as List);
  // }

  /// 7) 자유 대화
  static Future<Map<String, dynamic>> freeTalk({
    required String text,
    List<String>? history,
  }) async {
    final body = {'text': text, if (history != null) 'history': history};
    final data = await _post('/free-talk', body);
    return {
      'message': data['message'] as String,
      'history': List<String>.from(data['history'] as List)
    };
  }

  /// 8) 사진 위치 인식 (모바일 및 웹 호환)
  static Future<String> locatePhoto(
      {required String filePath, // 모바일용: 파일 경로
        Uint8List? fileBytes, // 웹용: 파일 바이트
        String? fileName, // 웹용: 파일 이름 (확장자 포함)
        String? mimeType // 웹용: MIME 타입
      }) async {
    final uri = Uri.parse('$_baseUrl/locate');
    final request = http.MultipartRequest('POST', uri);
    http.MultipartFile multipartFile;

    if (kIsWeb) {
      // --- 웹 환경 처리 ---
      if (fileBytes == null || fileName == null) {
        throw Exception('File bytes and name are required for web upload.');
      }
      // MIME 타입 추론 또는 직접 설정
      String fileExtension = '';
      MediaType? mediaType;

      if (mimeType != null) {
        mediaType = MediaType.parse(mimeType); // 'image/jpeg', 'image/png' 등
        fileExtension = mediaType.subtype;
      } else if (fileName.contains('.')) {
        fileExtension = fileName.split('.').last.toLowerCase();
        if (fileExtension == 'jpg' || fileExtension == 'jpeg') {
          mediaType = MediaType('image', 'jpeg');
        } else if (fileExtension == 'png') {
          mediaType = MediaType('image', 'png');
        } else {
          // 지원하지 않는 확장자 또는 알 수 없는 경우 기본값 또는 오류 처리
          mediaType = MediaType('application', 'octet-stream'); // 기본 바이너리 스트림
          print("Warning: Unknown image MIME type for web, defaulting to octet-stream for file: $fileName");
        }
      } else {
        mediaType = MediaType('application', 'octet-stream');
        print("Warning: Could not determine MIME type for web file: $fileName, defaulting to octet-stream.");
      }

      multipartFile = http.MultipartFile.fromBytes(
        'file', // 서버에서 받을 필드 이름
        fileBytes,
        filename: fileName, // 서버에서 파일명을 알 수 있도록
        contentType: mediaType,
      );
    } else {
      // 모바일 환경 처리 (File 클래스 사용)
      if (filePath.isEmpty) {
        throw Exception('File path is required for mobile upload.');
      }
      final imageFile = File(filePath); // dart:io의 File 사용
      if (!await imageFile.exists()) {
        throw Exception('Image file not found at path: $filePath');
      }
      String fileExtension = path_lib.extension(imageFile.path).replaceFirst('.', '').toLowerCase();
      if (fileExtension.isEmpty) {
        fileExtension = 'jpg';
        print("Warning: Image file extension is empty on mobile, defaulting to 'jpg'.");
      }
      multipartFile = await http.MultipartFile.fromPath(
        'file', imageFile.path, contentType: MediaType('image', fileExtension),
      );
    }

    request.files.add(multipartFile);

    final streamedResponse = await request.send();

    if (streamedResponse.statusCode >= 200 && streamedResponse.statusCode < 300) {
      final responseString = await streamedResponse.stream.bytesToString();
      final data = jsonDecode(responseString) as Map<String, dynamic>;
      return data['location'] as String; // 서버 응답에 'location' 키가 있다고 가정
    } else {
      final responseString = await streamedResponse.stream.bytesToString();
      throw Exception('사진 위치 인식 API 실패 ${streamedResponse.statusCode}: $responseString');
    }
  }
}