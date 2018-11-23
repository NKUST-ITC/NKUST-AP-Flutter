class ErrorResponse {
  int status;
  String developerMessage;
  String userMessage;
  int errorCode;
  String moreInfo;

  ErrorResponse({
    this.status,
    this.developerMessage,
    this.userMessage,
    this.errorCode,
    this.moreInfo,
  });

  static ErrorResponse fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      status: json['status'],
      developerMessage: json['developer_message'],
      userMessage: json['user_message'],
      errorCode: json['error_code'],
      moreInfo: json['more_info'],
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'developer_message': developerMessage,
        'user_message': userMessage,
        'error_code': errorCode,
        'more_info': moreInfo,
      };
}
