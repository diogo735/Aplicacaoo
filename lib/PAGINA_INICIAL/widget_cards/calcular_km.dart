//import 'package:geolocator/geolocator.dart';
//import 'package:geocoding/geocoding.dart';
import 'dart:math' as math;
/*
Future<void> calcularDistancia() async {
  try {
    // 1. Obter a localização atual do usuário
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    double userLat = position.latitude;
    double userLong = position.longitude;

    // 2. Obter as coordenadas do endereço de destino
    List<Location> locations = await locationFromAddress('Endereço de Destino');
    Location destinationLocation = locations.first;
    double destinationLat = destinationLocation.latitude;
    double destinationLong = destinationLocation.longitude;

    // 3. Calcular a distância
    double distance = calculateDistance(userLat, userLong, destinationLat, destinationLong);

    // 4. Exibir a distância
    print('A distância entre a localização atual e o destino é: $distance km');
  } catch (e) {
    print('Erro ao calcular a distância: $e');
  }
}

double calculateDistance(double startLat, double startLong, double endLat, double endLong) {
  const int earthRadius = 6371; // Raio da Terra em quilômetros
  double lat1Rad = math.pi * startLat / 180;
  double lat2Rad = math.pi * endLat / 180;
  double lon1Rad = math.pi * startLong / 180;
  double lon2Rad = math.pi * endLong / 180;

  double latDiff = lat2Rad - lat1Rad;
  double lonDiff = lon2Rad - lon1Rad;

  double a = math.pow(math.sin(latDiff / 2), 2) +
      math.cos(lat1Rad) * math.cos(lat2Rad) * math.pow(math.sin(lonDiff / 2), 2);
  double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

  return earthRadius * c;
}
*/