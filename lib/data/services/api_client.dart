import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'api_url.dart';

import '../helpers/shared_prefe.dart';

class ApiClient {
  final String baseUrl = ApiUrl.baseUrl;

  // Base Headers
  Map<String, String> getHeader() {
    final token = SharePrefsHelper.getString(SharePrefsHelper.accessTokenKey);
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // POST Request
  Future<http.Response> postData(
    String uri,
    dynamic body, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$baseUrl$uri');
    final Map<String, String> requestHeaders = headers ?? getHeader();
    final String requestBody = body is Map || body is List
        ? jsonEncode(body)
        : body.toString();

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

  // POST Multipart Request
  Future<http.Response> postMultipart(
    String uri,
    Map<String, String> fields, {
    List<String>? filePaths,
    String fieldName = 'images',
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$baseUrl$uri');
    final Map<String, String> requestHeaders = headers ?? getHeader();
    requestHeaders.remove('Content-Type');

    if (kDebugMode) {
      print('=== API POST Multipart Request ===');
      print('URL: $url');
      print('Headers: $requestHeaders');
      print('Fields: $fields');
      if (filePaths != null) print('Files: $filePaths (field: $fieldName)');
    }

    try {
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(requestHeaders);

      // Separate 'data' from fields if you want to use the combined pattern
      // But let's try the direct fields first as requested by standard multipart
      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      if (filePaths != null) {
        for (String path in filePaths) {
          final mimeType = path.endsWith('.png') ? 'png' : 'jpeg';
          request.files.add(
            await http.MultipartFile.fromPath(
              fieldName, // This must match the backend's expected field name
              path,
              contentType: MediaType('image', mimeType),
            ),
          );
        }
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(
        streamedResponse,
      ).timeout(const Duration(seconds: 30));

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

  // PATCH Request
  Future<http.Response> patchData(
    String uri,
    dynamic body, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$baseUrl$uri');
    final Map<String, String> requestHeaders = headers ?? getHeader();
    final String requestBody = body is Map || body is List
        ? jsonEncode(body)
        : body.toString();

    if (kDebugMode) {
      print('=== API PATCH Request ===');
      print('URL: $url');
      print('Headers: $requestHeaders');
      print('Body: $requestBody');
    }

    try {
      final response = await http.patch(
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

  // PATCH Multipart Request
  Future<http.Response> patchMultipart(
    String uri,
    Map<String, String> fields, {
    String? filePath,
    String fieldName = 'profile',
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$baseUrl$uri');
    final Map<String, String> requestHeaders = headers ?? getHeader();
    requestHeaders.remove(
      'Content-Type',
    ); // Multipart handles its own Content-Type

    if (kDebugMode) {
      print('=== API PATCH Multipart Request ===');
      print('URL: $url');
      print('Headers: $requestHeaders');
      print('Fields: $fields');
      if (filePath != null) print('File: $filePath (field: $fieldName)');
    }

    try {
      final request = http.MultipartRequest('PATCH', url);
      request.headers.addAll(requestHeaders);
      request.fields.addAll(fields);

      if (filePath != null) {
        final mimeType = filePath.endsWith('.png') ? 'png' : 'jpeg';
        request.files.add(
          await http.MultipartFile.fromPath(
            fieldName,
            filePath,
            contentType: MediaType('image', mimeType),
          ),
        );
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(
        streamedResponse,
      ).timeout(const Duration(seconds: 30));

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
  Future<http.Response> getData(
    String uri, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$baseUrl$uri');
    final Map<String, String> requestHeaders = headers ?? getHeader();

    if (kDebugMode) {
      print('=== API GET Request ===');
      print('URL: $url');
      print('Headers: $requestHeaders');
    }

    try {
      final response = await http.get(url, headers: requestHeaders);

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
