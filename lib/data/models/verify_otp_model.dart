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
      this._statusCode = statusCode;
    }
    if (message != null) {
      this._message = message;
    }
    if (userId != null) {
      this._userId = userId;
    }
    if (firstName != null) {
      this._firstName = firstName;
    }
    if (lastName != null) {
      this._lastName = lastName;
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
    _statusCode = json['status_code'];
    _message = json['message'];
    _userId = json['UserId'];
    _firstName = json['FirstName'];
    _lastName = json['LastName'];
  }
}
