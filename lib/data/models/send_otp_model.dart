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
    // Try multiple possible response key formats
    _statusCode = json['status_code'] ?? 
                  json['statusCode'] ?? 
                  json['code'] ?? 
                  (json['success'] == true ? 200 : 400);
    
    _message = json['message'] ?? 
               json['Message'] ?? 
               json['msg'] ?? 
               'OTP sent successfully';
  }
}
