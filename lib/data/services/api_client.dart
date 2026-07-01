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

  // Debug Log Helper for Requests
  void _logRequest(String method, Uri url, Map<String, String> headers, {dynamic body, Map<String, String>? fields, List<String>? filePaths, String? fileFieldName}) {
    if (!kDebugMode) return;
    print('╔═══════════════════════════════════════════════════════════════════════════');
    print('║ 🚀 [API REQUEST] -> ${method.toUpperCase()}');
    print('╠═══════════════════════════════════════════════════════════════════════════');
    print('║ 🔗 URL: $url');
    print('║ 📂 Headers:');
    headers.forEach((key, value) => print('║    • $key: $value'));
    if (body != null) {
      print('║ 📝 Body:');
      try {
        final parsed = body is String ? jsonDecode(body) : body;
        final prettyString = const JsonEncoder.withIndent('  ').convert(parsed);
        for (var line in prettyString.split('\n')) {
          print('║    $line');
        }
      } catch (_) {
        print('║    $body');
      }
    }
    if (fields != null && fields.isNotEmpty) {
      print('║ 📋 Fields:');
      fields.forEach((key, value) => print('║    • $key: $value'));
    }
    if (filePaths != null && filePaths.isNotEmpty) {
      print('║ 📁 Files (Field: $fileFieldName):');
      for (var path in filePaths) {
        print('║    • $path');
      }
    }
    print('╚═══════════════════════════════════════════════════════════════════════════');
  }

  // Debug Log Helper for Responses
  void _logResponse(String method, Uri url, http.Response response, DateTime startTime) {
    if (!kDebugMode) return;
    final duration = DateTime.now().difference(startTime).inMilliseconds;
    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
    final statusColor = isSuccess ? '✅' : '❌';
    print('╔═══════════════════════════════════════════════════════════════════════════');
    print('║ $statusColor [API RESPONSE] -> ${method.toUpperCase()} | Status: ${response.statusCode} | Time: ${duration}ms');
    print('╠═══════════════════════════════════════════════════════════════════════════');
    print('║ 🔗 URL: $url');
    print('║ 💬 Response Body:');
    try {
      final parsed = jsonDecode(response.body);
      final prettyString = const JsonEncoder.withIndent('  ').convert(parsed);
      for (var line in prettyString.split('\n')) {
        print('║    $line');
      }
    } catch (_) {
      for (var line in response.body.split('\n')) {
        print('║    $line');
      }
    }
    print('╚═══════════════════════════════════════════════════════════════════════════');
  }

  // Debug Log Helper for Errors
  void _logError(String method, Uri url, dynamic error, DateTime startTime) {
    if (!kDebugMode) return;
    final duration = DateTime.now().difference(startTime).inMilliseconds;
    print('╔═══════════════════════════════════════════════════════════════════════════');
    print('║ 💥 [API ERROR] -> ${method.toUpperCase()} | Time: ${duration}ms');
    print('╠═══════════════════════════════════════════════════════════════════════════');
    print('║ 🔗 URL: $url');
    print('║ ⚠️ Error details: $error');
    print('╚═══════════════════════════════════════════════════════════════════════════');
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

    _logRequest('POST', url, requestHeaders, body: body);

    final startTime = DateTime.now();
    try {
      final response = await http.post(
        url,
        headers: requestHeaders,
        body: requestBody,
      );

      _logResponse('POST', url, response, startTime);
      return response;
    } catch (e) {
      _logError('POST', url, e, startTime);
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

    _logRequest(
      'POST (Multipart)',
      url,
      requestHeaders,
      fields: fields,
      filePaths: filePaths,
      fileFieldName: fieldName,
    );

    final startTime = DateTime.now();
    try {
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(requestHeaders);

      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      if (filePaths != null) {
        for (String path in filePaths) {
          final mimeType = path.endsWith('.png') ? 'png' : 'jpeg';
          request.files.add(
            await http.MultipartFile.fromPath(
              fieldName,
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

      _logResponse('POST (Multipart)', url, response, startTime);
      return response;
    } catch (e) {
      _logError('POST (Multipart)', url, e, startTime);
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

    _logRequest('PATCH', url, requestHeaders, body: body);

    final startTime = DateTime.now();
    try {
      final response = await http.patch(
        url,
        headers: requestHeaders,
        body: requestBody,
      );

      _logResponse('PATCH', url, response, startTime);
      return response;
    } catch (e) {
      _logError('PATCH', url, e, startTime);
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
    requestHeaders.remove('Content-Type');

    _logRequest(
      'PATCH (Multipart)',
      url,
      requestHeaders,
      fields: fields,
      filePaths: filePath != null ? [filePath] : null,
      fileFieldName: fieldName,
    );

    final startTime = DateTime.now();
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

      _logResponse('PATCH (Multipart)', url, response, startTime);
      return response;
    } catch (e) {
      _logError('PATCH (Multipart)', url, e, startTime);
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

    _logRequest('GET', url, requestHeaders);

    final startTime = DateTime.now();
    try {
      final response = await http.get(url, headers: requestHeaders);

      _logResponse('GET', url, response, startTime);
      return response;
    } catch (e) {
      _logError('GET', url, e, startTime);
      rethrow;
    }
  }
}
