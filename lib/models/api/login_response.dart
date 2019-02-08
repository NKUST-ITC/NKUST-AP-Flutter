class LoginResponse {
  String authToken;
  int duration;
  IsLogin isLogin;
  String tokenType;

  LoginResponse({this.authToken, this.duration, this.isLogin, this.tokenType});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    authToken = json['auth_token'];
    duration = json['duration'];
    isLogin = json['is_login'] != null
        ? new IsLogin.fromJson(json['is_login'])
        : null;
    tokenType = json['token_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['auth_token'] = this.authToken;
    data['duration'] = this.duration;
    if (this.isLogin != null) {
      data['is_login'] = this.isLogin.toJson();
    }
    data['token_type'] = this.tokenType;
    return data;
  }
}

class IsLogin {
  bool ap;
  bool bus;
  bool leave;

  IsLogin({this.ap, this.bus, this.leave});

  IsLogin.fromJson(Map<String, dynamic> json) {
    ap = json['ap'];
    bus = json['bus'];
    leave = json['leave'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ap'] = this.ap;
    data['bus'] = this.bus;
    data['leave'] = this.leave;
    return data;
  }
}
