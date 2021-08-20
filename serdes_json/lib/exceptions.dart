part of serdes_json;

class SchemeConsistencyException implements Exception {
  final String message;

  SchemeConsistencyException([this.message = 'Schemes consistency error']);

  @override
  String toString() {
    return '$SchemeConsistencyException: $message';
  }
}

// ignore: avoid_positional_boolean_parameters
void require(bool invariant, Exception Function() exceptionFactory) {
  if (!invariant) {
    throw exceptionFactory();
  }
}
