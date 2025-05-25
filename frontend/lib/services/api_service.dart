import 'dart:async';
import 'dart:convert';
import 'package:frontend/core/exceptions/api_exception.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Properties
  final String baseUrl;
  final Duration timeout;
  final String? token;

  // Constants
  static const String _contentType = 'application/json';
  static const int defaultTimeout = 30; // seconds

  // Constructor
  ApiService({
    required this.baseUrl,
    this.timeout = const Duration(seconds: defaultTimeout),
    this.token,
  });

  // HTTP Methods
  Future<dynamic> get(
    String endpoint, {
    Duration? timeout,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/api/$endpoint',
      ).replace(queryParameters: queryParams);

      final response = await http
          .get(uri, headers: _buildHeaders())
          .timeout(timeout ?? this.timeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException('Request timed out', statusCode: 408);
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}', statusCode: 503);
    } catch (e) {
      throw ApiException('Request failed: ${e.toString()}');
    }
  }

  Future<dynamic> post(
    String endpoint,
    dynamic body, {
    Duration? timeout,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/$endpoint');
      final response = await http
          .post(uri, headers: _buildHeaders(), body: json.encode(body))
          .timeout(timeout ?? this.timeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException('Request timed out', statusCode: 408);
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}', statusCode: 503);
    } catch (e) {
      throw ApiException('Request failed: ${e.toString()}');
    }
  }

  // Helper Methods
  Map<String, String> _buildHeaders() {
    final headers = {
      'Content-Type': _contentType,
      'Accept': _contentType,
      'X-Requested-With':
          'XMLHttpRequest', // For Express to detect AJAX requests
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    if (statusCode >= 200 && statusCode < 300) {
      try {
        if (body.isEmpty) return null;
        return json.decode(body);
      } catch (e) {
        throw ApiException('Invalid JSON response', statusCode: statusCode);
      }
    }

    // Handle specific Express error responses
    switch (statusCode) {
      case 400:
        throw ApiException(
          'Bad Request: ${_parseErrorMessage(body)}',
          statusCode: statusCode,
        );
      case 401:
        throw ApiException('Unauthorized', statusCode: statusCode);
      case 403:
        throw ApiException('Forbidden', statusCode: statusCode);
      case 404:
        throw ApiException('Not Found', statusCode: statusCode);
      case 422:
        throw ApiException(
          'Validation Error: ${_parseErrorMessage(body)}',
          statusCode: statusCode,
        );
      case 429:
        throw ApiException('Too Many Requests', statusCode: statusCode);
      case 500:
        throw ApiException('Internal Server Error', statusCode: statusCode);
      default:
        throw ApiException(
          'Server error: $statusCode\n${_parseErrorMessage(body)}',
          statusCode: statusCode,
        );
    }
  }

  String _parseErrorMessage(String responseBody) {
    try {
      final Map<String, dynamic> body = json.decode(responseBody);
      return body['message'] ?? body['error'] ?? responseBody;
    } catch (_) {
      return responseBody;
    }
  }
}
