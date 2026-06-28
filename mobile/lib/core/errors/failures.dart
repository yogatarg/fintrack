// lib/core/errors/failures.dart

class Failure {
  final String message;
  final int? statusCode;

  Failure({required this.message, this.statusCode});

  @override
  String toString() => message;
}

class NetworkFailure extends Failure {
  NetworkFailure() : super(message: 'Tidak dapat terhubung ke server. Periksa koneksi Anda.');
}

class UnauthorizedFailure extends Failure {
  UnauthorizedFailure() : super(message: 'Sesi Anda telah berakhir. Silakan login kembali.', statusCode: 401);
}

class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;

  ValidationFailure({required String message, this.errors})
      : super(message: message, statusCode: 422);
}

class ServerFailure extends Failure {
  ServerFailure({required String message, int? statusCode})
      : super(message: message, statusCode: statusCode);
}