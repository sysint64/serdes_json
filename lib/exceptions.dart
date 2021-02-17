part of serdes_json;

class SchemeConsistencyException implements Exception {
  final String message;

  SchemeConsistencyException([this.message = 'Schemes consistency error']);

  @override
  String toString() {
    if (message == null) {
      return '$SchemeConsistencyException';
    }
    return '$SchemeConsistencyException: $message';
  }
}
