class VerifyPINModel {
  int? _statusCode;
  String? _message;

  VerifyPINModel({int? statusCode, String? message}) {
    if (statusCode != null) {
      _statusCode = statusCode;
    }
    if (message != null) {
      _message = message;
    }
  }

  int? get statusCode => _statusCode;
  set statusCode(int? statusCode) => _statusCode = statusCode;
  String? get message => _message;
  set message(String? message) => _message = message;

  VerifyPINModel.fromJson(Map<String, dynamic> json) {
    _statusCode = json['status_code'];
    _message = json['message'];
  }
}
