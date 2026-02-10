class LoginModel {
  String? accessToken;
  String? tokenType;
  int? expiresIn;
  String? userName;
  String? businessName;
  String? merchantId;
  String? userId;
  String? firstname;
  String? lastname;
  String? phoneNumber;
  String? phoneNumberConfirmed;
  String? issued;
  String? expires;

  LoginModel(
      {this.accessToken,
      this.tokenType,
      this.expiresIn,
      this.userName,
      this.businessName,
      this.merchantId,
      this.userId,
      this.firstname,
      this.lastname,
      this.phoneNumber,
      this.phoneNumberConfirmed,
      this.issued,
      this.expires});

  LoginModel.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    tokenType = json['token_type'];
    expiresIn = json['expires_in'];
    userName = json['userName'];
    businessName = json['BusinessName'];
    merchantId = json['MerchantId'];
    userId = json['UserId'];
    firstname = json['Firstname'];
    lastname = json['Lastname'];
    phoneNumber = json['PhoneNumber'];
    phoneNumberConfirmed = json['PhoneNumberConfirmed'];
    issued = json['.issued'];
    expires = json['.expires'];
  }

    Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['access_token'] = this.accessToken;
    data['token_type'] = this.tokenType;
    data['expires_in'] = this.expiresIn;
    data['userName'] = this.userName;
    data['BusinessName'] = this.businessName;
    data['MerchantId'] = this.merchantId;
    data['UserId'] = this.userId;
    data['Firstname'] = this.firstname;
    data['Lastname'] = this.lastname;
    data['PhoneNumber'] = this.phoneNumber;
    data['PhoneNumberConfirmed'] = this.phoneNumberConfirmed;
    data['.issued'] = this.issued;
    data['.expires'] = this.expires;
    return data;
  }
}

