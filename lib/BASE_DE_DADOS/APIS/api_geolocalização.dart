import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';
class Localizacao {
  Future<Position> determinaposicao() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica se os serviços de localização estão habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Serviços de localização indisponíveis.');
    }

    // Verifica o status das permissões de localização
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Permissões de localização permanentemente negadas.');
    }

    // Obtém a posição atual do dispositivo
    return await Geolocator.getCurrentPosition();
  }
}

class LocalizacaoOSM {
  // Método para obter endereço a partir de coordenadas
  Future<String> getEnderecoFromCoordinates(double latitude, double longitude) async {
    String url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude';

    try {
      var response = await http.get(Uri.parse(url), headers: {
        'User-Agent': 'SoftShares', 
      });
if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        // Extrai 'neighbourhood' e 'city' do objeto 'address'
        String neighbourhood = data['address']['neighbourhood'] ?? '';
        String city = data['address']['city'] ?? '';

        // Combina os dois campos com uma vírgula e espaço, se ambos estiverem presentes
        String address = (neighbourhood.isNotEmpty && city.isNotEmpty) ? '$neighbourhood, $city' : 
                         neighbourhood.isNotEmpty ? neighbourhood : 
                         city.isNotEmpty ? city : 
                         'Localização não disponível';
        return address;
      } else {
        return 'Endereço não encontrado.';
      }
    } catch (e) {
      print('Erro ao obter endereço: $e');
      return 'Erro ao conectar no serviço !! ';
    }
  }
Future<Map<String, String>> getDetailedAddressFromCoordinates(double latitude, double longitude) async {
  String url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude';

  try {
    var response = await http.get(Uri.parse(url), headers: {
      'User-Agent': 'SoftShares',  // Nome do seu aplicativo
    });

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      // Criar um mapa para armazenar os valores desejados
      Map<String, String> addressDetails = {
        'name': data['address']['name'] ?? '',
        'house_number': data['address']['house_number'] ?? '',
        'road': data['address']['road'] ?? '',
        'neighbourhood': data['address']['neighbourhood'] ?? '',
        'village': data['address']['village'] ?? '',
        'city': data['address']['city'] ?? '',
        'county': data['address']['county'] ?? '',
      };

      return addressDetails;
    } else {
      print('Falha na resposta da API: Status ${response.statusCode}');
      // Retorna o endereço padrão em caso de falha
      return {
        'name': 'Localização incorreta',
        'house_number':'Volte atras para corrigir',
        
      };
    }
  } catch (e) {
    print('Erro ao obter endereço: $e');
    // Retorna o endereço padrão em caso de erro
    return {
      
      'name': 'Localização incorreta',
        'house_number':'Volte atras para corrigir',
      
    };
  }
}

  
Future<void> _openGoogleMaps(double latitude, double longitude) async {
    String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

   // Método para obter coordenadas a partir do nome do local
  Future<Map<String, double>> getCoordinatesFromName(String placeName) async {
    String url = 'https://nominatim.openstreetmap.org/search?format=json&q=$placeName';

    try {
      var response = await http.get(Uri.parse(url), headers: {
        'User-Agent': 'AULA11',
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          double latitude = double.parse(data[0]['lat']);
          double longitude = double.parse(data[0]['lon']);
          return {'latitude': latitude, 'longitude': longitude};
        } else {
          return {'latitude': 0.0, 'longitude': 0.0};
        }
      } else {
        return {'latitude': 0.0, 'longitude': 0.0};
      }
    } catch (e) {
      print('Erro ao obter coordenadas: $e');
      return {'latitude': 0.0, 'longitude': 0.0};
    }
  }
}