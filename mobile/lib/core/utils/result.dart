// lib/core/utils/result.dart

import '../errors/failures.dart';

sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}

extension ResultWhenExtension<T> on Result<T> {
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) error,
  }) {
    if (this is Success<T>) {
      return success((this as Success<T>).data);
    }
    if (this is Error<T>) {
      return error((this as Error<T>).failure);
    }
    throw StateError('Unhandled Result type');
  }
}