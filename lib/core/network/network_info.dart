import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Abstract interface for network connectivity checking.
/// This abstraction allows for easy mocking in tests.
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<InternetStatus> get onStatusChange;
}

/// Implementation using internet_connection_checker_plus.
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnection _connectionChecker;

  NetworkInfoImpl(this._connectionChecker);

  @override
  Future<bool> get isConnected => _connectionChecker.hasInternetAccess;

  @override
  Stream<InternetStatus> get onStatusChange =>
      _connectionChecker.onStatusChange;
}
