import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  // Check current connectivity status
  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      // Log error or handle it as needed
      return false;
    }
  }

  // Stream of connectivity changes
  Stream<bool> get onConnectivityChanged => 
    _connectivity.onConnectivityChanged
      .map((result) => result != ConnectivityResult.none);
}