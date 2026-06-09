import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_url.dart';

class ApiClient {
  final String baseUrl = ApiUrl.baseUrl;

  // Base Headers
  Map<String, String> getHeader() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // POST Request
  Future<http.Response> postData(String uri, dynamic body, {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$uri');
    final Map<String, String> requestHeaders = headers ?? getHeader();
    final String requestBody = body is Map || body is List ? jsonEncode(body) : body.toString();

    if (kDebugMode) {
      print('=== API POST Request ===');
      print('URL: $url');
      print('Headers: $requestHeaders');
      print('Body: $requestBody');
    }

    try {
      final response = await http.post(
        url,
        headers: requestHeaders,
        body: requestBody,
      );

      if (kDebugMode) {
        print('=== API Response (${response.statusCode}) ===');
        print('Response Body: ${response.body}');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('=== API Error ===');
        print('Error: $e');
      }
      rethrow;
    }
  }

  // GET Request
  Future<http.Response> getData(String uri, {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$uri');
    final Map<String, String> requestHeaders = headers ?? getHeader();

    if (kDebugMode) {
      print('=== API GET Request ===');
      print('URL: $url');
      print('Headers: $requestHeaders');
    }

    try {
      final response = await http.get(
        url,
        headers: requestHeaders,
      );

      if (kDebugMode) {
        print('=== API Response (${response.statusCode}) ===');
        print('Response Body: ${response.body}');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('=== API Error ===');
        print('Error: $e');
      }
      rethrow;
    }
  }
}
