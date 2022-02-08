class HebServiceException implements Exception {
  final String message;

  HebServiceException(this.message);

  @override
  String toString() {
    return message;
  }
}