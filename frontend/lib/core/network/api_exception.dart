/// A single exception type our whole app throws/catches for any API
/// failure, instead of leaking raw DioException or SocketException details
/// into UI code. UI layers only ever need to know: what message to show,
/// and optionally the HTTP status code for conditional handling (e.g. 401
/// meaning "token expired", 404 meaning "session expired").
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
