class LoginResponse {
  String authToken;
  int duration;
  String tokenType;

  LoginResponse({
    this.authToken,
    this.duration,
    this.tokenType,
  });

  static LoginResponse fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      authToken: json['auth_token'],
      duration: json['duration'],
      tokenType: json['token_type'],
    );
  }

  Map<String, dynamic> toJson() => {
        'auth_token': authToken,
        'duration': duration,
        'token_type': tokenType,
      };
}
