import 'package:dio/dio.dart';
import 'dart:convert';

class ApiClient {
  final Dio _dio;

  ApiClient({required String baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          validateStatus: (status) {
            return status! < 500;
          },
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

  void updateAuthToken(String? token) {
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  Future<Response> getData(
    String uri, {
    Map<String, dynamic>? queryParams,
    String? authToken,
  }) async {
    try {
      if (authToken != null) {
        updateAuthToken(authToken);
      }

      Response response = await _dio.get(uri, queryParameters: queryParams);
      return response;
    } on DioException catch (e) {
      print("GET request failed on api_client.dart: ${e.type} - ${e.message}");
      if (e.response != null) {
        return e.response!;
      } else {
        return Response(
          requestOptions: RequestOptions(path: uri),
          statusCode: 500,
          statusMessage: "Connection error: ${e.message}",
        );
      }
    } catch (e) {
      print("Unexpected error on api_client.dart: $e");
      return Response(
        requestOptions: RequestOptions(path: uri),
        statusCode: 500,
        statusMessage: "Unexpected error occurred",
      );
    }
  }

  Future<Response> postData(
    String uri,
    Map<String, dynamic> data, {
    String? authToken,
  }) async {
    try {
      print("Attempting POST form data to: $uri");
      print("With data: $data");
      print("And authToken: $authToken");

      if (authToken != null) {
        updateAuthToken(authToken);
      }

      _dio.options.contentType = Headers.jsonContentType;

      Response response = await _dio.post(uri, data: jsonEncode(data));

      print("Response received: ${response.statusCode}");
      if (response.data != null) {
        print("Response data: ${jsonEncode(response.data)}");
      }

      return response;
    } on DioException catch (e) {
      print("POST request failed on api_client.dart: ${e.type} - ${e.message}");
      print("Request data was: ${jsonEncode(data)}");
      if (e.response != null) {
        return e.response!;
      } else {
        return Response(
          requestOptions: RequestOptions(path: uri),
          statusCode: 500,
          statusMessage: "Connection error: ${e.message}",
        );
      }
    } catch (e) {
      print("Unexpected error: $e");
      return Response(
        requestOptions: RequestOptions(path: uri),
        statusCode: 500,
        statusMessage: "Unexpected error occurred",
      );
    }
  }
}
