class SendOTPModel {
  int? _statusCode;
  String? _message;

  SendOTPModel({int? statusCode, String? message}) {
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

  SendOTPModel.fromJson(Map<String, dynamic> json) {
    _statusCode = json['status_code'];
    _message = json['message'];
  }
}
