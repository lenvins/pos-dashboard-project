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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['access_token'] = accessToken;
    data['token_type'] = tokenType;
    data['expires_in'] = expiresIn;
    data['userName'] = userName;
    data['BusinessName'] = businessName;
    data['MerchantId'] = merchantId;
    data['UserId'] = userId;
    data['Firstname'] = firstname;
    data['Lastname'] = lastname;
    data['PhoneNumber'] = phoneNumber;
    data['PhoneNumberConfirmed'] = phoneNumberConfirmed;
    data['.issued'] = issued;
    data['.expires'] = expires;
    return data;
  }
}

