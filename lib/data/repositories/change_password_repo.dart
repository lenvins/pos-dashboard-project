import 'package:get/get.dart';
import 'package:pos_dashboard/core/api/api_client.dart';
import 'package:dio/dio.dart' as dio;
import 'package:pos_dashboard/presentation/controllers/login_controller.dart';

class ChangePasswordRepo {
  final ApiClient apiClient;

  ChangePasswordRepo({required this.apiClient});

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final loginController = Get.find<LoginController>();
      const String endpoint = 'api/Account/ChangePassword';

      final response = await apiClient.postData(
        endpoint,
        {
          'OldPassword': currentPassword,
          'NewPassword': newPassword,
          'ConfirmPassword': confirmPassword,
        },
        authToken: loginController.accessToken,
      );

      final int? statusCode = response.statusCode;
      final bool success = statusCode != null && statusCode >= 200 && statusCode < 300;
      final String responseMessage = _extractMessageFromResponse(response.data);

      final String message = success
          ? (responseMessage.isNotEmpty ? responseMessage : 'Password changed successfully')
          : _buildErrorMessage(responseMessage, statusCode);

      return {
        'success': success,
        'statusCode': statusCode,
        'data': response.data,
        'message': message,
      };
    } on dio.DioException catch (e) {
      final int? statusCode = e.response?.statusCode;
      final String responseMessage = _extractMessageFromResponse(e.response?.data);
      final String message = _buildErrorMessage(responseMessage, statusCode, dioException: e);

      return {
        'success': false,
        'data': e.response?.data,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'data': null,
        'message': 'An unexpected error occurred - please try again',
      };
    }
  }

  String _extractMessageFromResponse(dynamic data) {
    if (data == null) return '';

    if (data is String) {
      return data.trim();
    }

    if (data is Map) {
      for (final key in [
        'message',
        'Message',
        'error',
        'Error',
        'detail',
        'Detail',
        'description',
        'Description',
        'title',
        'Title'
      ]) {
        final value = data[key];
        if (value is String && value.isNotEmpty) {
          return value.trim();
        }
      }

      for (final value in data.values) {
        final extracted = _extractMessageFromResponse(value);
        if (extracted.isNotEmpty) {
          return extracted;
        }
      }
    }

    if (data is List) {
      for (final element in data) {
        final extracted = _extractMessageFromResponse(element);
        if (extracted.isNotEmpty) {
          return extracted;
        }
      }
    }

    return '';
  }

  String _buildErrorMessage(String responseMessage, int? statusCode, {dio.DioException? dioException}) {
    final String lowerMessage = responseMessage.toLowerCase();

    if (statusCode == 400 || statusCode == 422) {
      if (lowerMessage.contains('old password') ||
          lowerMessage.contains('current password') ||
          lowerMessage.contains('password incorrect') ||
          lowerMessage.contains('invalid password') ||
          (lowerMessage.contains('password') &&
              (lowerMessage.contains('wrong') ||
                  lowerMessage.contains('incorrect') ||
                  lowerMessage.contains('invalid') ||
                  lowerMessage.contains('not match')))) {
        return 'Invalid Current Password';
      }

      if (lowerMessage.contains('new password') &&
          (lowerMessage.contains('weak') ||
              lowerMessage.contains('strength') ||
              lowerMessage.contains('complexity'))) {
        return 'New password is too weak';
      }

      if (lowerMessage.contains('confirm') && lowerMessage.contains('match')) {
        return 'Password confirmation does not match';
      }

        if (responseMessage.toLowerCase().contains('request')) {
          return 'The Current Password is Incorrect';
        }
        if (responseMessage.isNotEmpty) {
          return responseMessage;
        }

        return 'Invalid Current Password';
    }

    switch (statusCode) {
      case 401:
        return 'Authentication failed - please login again';
      case 403:
        return 'Access denied - insufficient permissions';
      case 404:
        return 'Password change service not available';
      case 409:
        return 'New password must be different from current password';
      case 429:
        return 'Too many attempts - please try again later';
      case 500:
      case 502:
      case 503:
      case 504:
        return 'Server temporarily unavailable - please try again later';
      default:
        if (statusCode != null && statusCode >= 400 && statusCode < 500) {
          return responseMessage.isNotEmpty
              ? responseMessage
              : 'Request error ($statusCode) - please check your input';
        }
        if (statusCode != null && statusCode >= 500) {
          return 'Server error - please try again later';
        }
        final String? dioMessage = dioException?.message;
        if (dioMessage != null && dioMessage.isNotEmpty) {
          return dioMessage;
        }
        return 'Network error occurred';
    }
  }
}
