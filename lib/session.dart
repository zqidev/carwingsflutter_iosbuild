import 'dart:developer' as developer;
import 'package:dartcarwings/dartcarwings.dart';
import 'package:dartnissanconnect/dartnissanconnect.dart' as nissanconnect;
import 'package:dartnissanconnectna/dartnissanconnectna.dart'
    as nissanconnectna;

enum API_TYPE { CARWINGS, NISSANCONNECTNA, NISSANCONNECT }

/// The User-Agent string required by NissanConnect NA API.
/// This is not a typical browser user agent, but a specific identifier
/// required by the NissanConnect server-side API for authentication.
/// Without this exact string, authentication will fail with 401 errors.
const String nissanConnectUserAgent = '5AFC98CCD7E2AF32FD7C59916AABD';

/// This class holds a session for the old Carwings API (still used in Europe)
/// a session for the newer North American NissanConnect API
/// and finally a session for the new NissanConnect API.
/// For now this class only wraps a subset of calls.
class Session {
  CarwingsSession carwings = CarwingsSession();
  nissanconnectna.NissanConnectSession nissanConnectNa =
      nissanconnectna.NissanConnectSession();
  nissanconnect.NissanConnectSession nissanConnect =
      nissanconnect.NissanConnectSession();

  CarwingsRegion region = CarwingsRegion.World;

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

  Future<void> login(
      {required String username,
      required String password,
      CarwingsRegion region = CarwingsRegion.Europe}) async {
    this.region = region;

    switch (getAPIType()) {
      case API_TYPE.CARWINGS:
        await carwings.login(
          username: username,
          password: password,
          region: region,
        );
        break;
      case API_TYPE.NISSANCONNECTNA:
        // NissanConnect NA requires a specific User-Agent string for authentication.
        // Using the required User-Agent: 5AFC98CCD7E2AF32FD7C59916AABD
        developer.log('Authenticating with User-Agent: $nissanConnectUserAgent',
            name: 'NissanConnect NA');
        if (isCanada()) {
          await nissanConnectNa.login(
            username: username,
            password: password,
            countryCode: 'CA',
            userAgent: nissanConnectUserAgent,
          );
        } else {
          await nissanConnectNa.login(
            username: username,
            password: password,
            userAgent: nissanConnectUserAgent,
          );
        }
        developer.log('Authentication successful', name: 'NissanConnect NA');
        break;
      case API_TYPE.NISSANCONNECT:
        // NissanConnect World API does not require User-Agent parameter
        developer.log('Authenticating', name: 'NissanConnect World');
        await nissanConnect.login(username: username, password: password);
        developer.log('Authentication successful', name: 'NissanConnect World');
        break;
    }
  }
}
