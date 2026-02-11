import 'dart:math' as math;
import 'package:dartcarwings/dartcarwings.dart';
import 'package:dartnissanconnect/dartnissanconnect.dart' as nissanconnect;
import 'package:dartnissanconnectna/dartnissanconnectna.dart'
    as nissanconnectna;

enum API_TYPE { CARWINGS, NISSANCONNECTNA, NISSANCONNECT }

/// This class holds a session for the old Carwings API (still used in Europe)
/// a session for the newer North American NissanConnect API
/// and finally a session for the new NissanConnect API.
/// For now this class only wraps a subset of calls.
class Session {
  CarwingsSession carwings = CarwingsSession();
  nissanconnectna.NissanConnectSession nissanConnectNa =
      nissanconnectna.NissanConnectSession(debug: true);
  nissanconnect.NissanConnectSession nissanConnect =
      nissanconnect.NissanConnectSession(debug: true);

  CarwingsRegion region = CarwingsRegion.World;

  // Use a valid iOS User-Agent that matches the official NissanConnect app
  static const String _validUserAgent =
      'Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) '
      'AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148';

  API_TYPE getAPIType() => isWorld()
      ? API_TYPE.NISSANCONNECT
      : isNorthAmerica()
          ? API_TYPE.NISSANCONNECTNA
          : API_TYPE.CARWINGS;

  bool isCanada() => region == CarwingsRegion.Canada;

  bool isWorld() => region == CarwingsRegion.World;

  bool isNorthAmerica() =>
      region == CarwingsRegion.USA || region == CarwingsRegion.Canada;

  changeVehicle(String nickname) {
    switch (getAPIType()) {
      case API_TYPE.CARWINGS:
        carwings.vehicle =
            carwings.vehicles.firstWhere((v) => v.nickname == nickname);
        break;
      case API_TYPE.NISSANCONNECTNA:
        nissanConnectNa.vehicle =
            nissanConnectNa.vehicles.firstWhere((v) => v.nickname == nickname);
        break;
      case API_TYPE.NISSANCONNECT:
        nissanConnect.vehicle =
            nissanConnect.vehicles.firstWhere((v) => v.nickname == nickname);
        break;
    }
  }

  getVehicle() {
    switch (getAPIType()) {
      case API_TYPE.CARWINGS:
        return carwings.vehicle;
      case API_TYPE.NISSANCONNECTNA:
        return nissanConnectNa.vehicle;
      case API_TYPE.NISSANCONNECT:
        return nissanConnect.vehicle;
    }
  }

  getVehicles() {
    switch (getAPIType()) {
      case API_TYPE.CARWINGS:
        return carwings.vehicles;
      case API_TYPE.NISSANCONNECTNA:
        return nissanConnectNa.vehicles;
      case API_TYPE.NISSANCONNECT:
        return nissanConnect.vehicles;
    }
  }

  /// Retry a login operation with exponential backoff
  Future<T> _retryLogin<T>(Future<T> Function() loginFunction,
      {int maxRetries = 3}) async {
    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        return await loginFunction();
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          rethrow;
        }
        // Exponential backoff: 1s, 2s, 4s
        await Future.delayed(
            Duration(seconds: math.pow(2, attempt - 1).toInt()));
      }
    }
    throw Exception('Login failed after $maxRetries attempts');
  }

  Future<void> login(
      {required String username,
      required String password,
      CarwingsRegion region = CarwingsRegion.Europe}) async {
    this.region = region;

    try {
      switch (getAPIType()) {
        case API_TYPE.CARWINGS:
          await carwings.login(
            username: username,
            password: password,
            region: region,
          );
          break;
        case API_TYPE.NISSANCONNECTNA:
          if (isCanada()) {
            await _retryLogin(() => nissanConnectNa.login(
                  username: username,
                  password: password,
                  countryCode: 'CA',
                  userAgent: _validUserAgent,
                ));
          } else {
            await _retryLogin(() => nissanConnectNa.login(
                  username: username,
                  password: password,
                  userAgent: _validUserAgent,
                ));
          }
          break;
        case API_TYPE.NISSANCONNECT:
          await nissanConnect.login(username: username, password: password);
          break;
      }
    } catch (e) {
      // Log error for debugging purposes
      // ignore: avoid_print
      print('Login failed for ${getAPIType()} API: $e');
      // Add more specific error handling based on error type
      if (e.toString().contains('401')) {
        throw Exception(
            'Authentication failed. Please check your credentials.');
      } else if (e.toString().contains('timeout')) {
        throw Exception(
            'Connection timed out. Please check your internet connection.');
      } else if (e.toString().contains('JSON')) {
        throw Exception(
            'Invalid response from server. The API may be temporarily unavailable.');
      }
      rethrow;
    }
  }
}
