/*
{
  "error": {
    "code": 400,
    "message": "INVALID_EMAIL",
    "errors": [
      {
        "message": "INVALID_EMAIL",
        "domain": "global",
        "reason": "invalid"
      }
    ]
  }
}

 */
class HebServiceError {
  int code;
  String message;

  HebServiceError(this.code, this.message);

  factory HebServiceError.fromJson(Map<String, dynamic> decodedJson) {
    return HebServiceError(decodedJson['code'], decodedJson['message']);
  }
}
