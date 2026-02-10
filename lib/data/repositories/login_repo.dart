import 'package:dio/dio.dart';
import 'package:pos_dashboard/core/utils/app_constants.dart';

class LoginRepository {
  final Dio dio;

  LoginRepository({required this.dio});

  Future<Response> login(String username, String password) async {
    try {
      Response response = await dio.post(
        AppConstants.TOKEN_URL,
        data: {
          "grant_type": "password",
          "username": username,
          "password": password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      return response;
    } on DioException catch (e) {
      return Future.error(e);
    } catch (e) {
      return Future.error(e);
    }
  }
}