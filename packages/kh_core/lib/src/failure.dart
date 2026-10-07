/// Sealed failure union mapped from the backend error envelope
/// (Architecture-Frontend §6.3). `message` is the server-localised string where
/// one exists; the client supplies copy only for transport failures.
sealed class Failure {
  const Failure({
    this.code,
    this.message,
    this.fieldErrors = const {},
    this.details = const {},
  });

  final String? code;
  final String? message;
  final Map<String, String> fieldErrors;
  final Map<String, String> details;
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No connection. Check your network and try again.'});
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message = 'That took too long. Try again.'});
}

class UnauthorisedFailure extends Failure {
  const UnauthorisedFailure({super.code, super.message, super.details});
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure({super.code, super.message, super.details});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({super.code, super.message, super.details});
}

class ConflictFailure extends Failure {
  const ConflictFailure({super.code, super.message, super.details});
}

class ValidationFailure extends Failure {
  const ValidationFailure({super.code, super.message, super.fieldErrors});
}

class RateLimitedFailure extends Failure {
  const RateLimitedFailure({super.code, super.message});
}

class ServerFailure extends Failure {
  const ServerFailure({super.code, super.message, super.details});
}

class MaintenanceFailure extends Failure {
  const MaintenanceFailure({super.message});
}
