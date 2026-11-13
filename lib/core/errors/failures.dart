/// Base Failure class for domain and data layer error handling.
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => '$runtimeType: $message (code: $code)';
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

class PairingFailure extends Failure {
  const PairingFailure(super.message, {super.code});
}
