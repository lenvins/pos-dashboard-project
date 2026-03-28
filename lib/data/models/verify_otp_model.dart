class VerifyOTPModel {
  int? _statusCode;
  String? _message;
  String? _userId;
  String? _firstName;
  String? _lastName;

  VerifyOTPModel(
      {int? statusCode,
      String? message,
      String? userId,
      String? firstName,
      String? lastName}) {
    if (statusCode != null) {
      _statusCode = statusCode;
    }
    if (message != null) {
      _message = message;
    }
    if (userId != null) {
      _userId = userId;
    }
    if (firstName != null) {
      _firstName = firstName;
    }
    if (lastName != null) {
      _lastName = lastName;
    }
  }

  int? get statusCode => _statusCode;
  set statusCode(int? statusCode) => _statusCode = statusCode;
  String? get message => _message;
  set message(String? message) => _message = message;
  String? get userId => _userId;
  set userId(String? userId) => _userId = userId;
  String? get firstName => _firstName;
  set firstName(String? firstName) => _firstName = firstName;
  String? get lastName => _lastName;
  set lastName(String? lastName) => _lastName = lastName;

  VerifyOTPModel.fromJson(Map<String, dynamic> json) {
    // Try multiple possible response key formats
    _statusCode = json['status_code'] ?? 
                  json['statusCode'] ?? 
                  json['code'] ?? 
                  (json['success'] == true ? 200 : 400);
    
    _message = json['message'] ?? 
               json['Message'] ?? 
               json['msg'] ?? 
               '';
    
    _userId = json['UserId'] ?? 
              json['user_id'] ?? 
              json['userId'] ?? 
              json['id'] ?? 
              '';
    
    _firstName = json['FirstName'] ?? 
                 json['first_name'] ?? 
                 json['firstName'] ?? 
                 '';
    
    _lastName = json['LastName'] ?? 
                json['last_name'] ?? 
                json['lastName'] ?? 
                '';
  }
}
