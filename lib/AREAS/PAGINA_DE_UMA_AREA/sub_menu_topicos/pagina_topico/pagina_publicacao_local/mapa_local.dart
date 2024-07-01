import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_publicacoes.dart';

class MapaLocal extends StatefulWidget {
  final int idPublicacao; // Adicionar o campo idPublicacao

  const MapaLocal(
      {super.key, required this.idPublicacao}); // Modificar o construtor

  @override
  State<MapaLocal> createState() => _MapaLocalState();
}

class _MapaLocalState extends State<MapaLocal> {
  double _latitude = 0;
  double _longitude = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  void _getLocation() async {
    try {
      Map<String, double>? coordenadas =
          await Funcoes_Publicacoes.obter_cordenadada_pub(widget.idPublicacao);

      if (coordenadas != null) {
        setState(() {
          _latitude = coordenadas['latitude']!;
          _longitude = coordenadas['longitude']!;
        });
      } else {}
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(_longitude);
    print(_latitude);

    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14),
      child: Container(
        width: MediaQuery.of(context).size.width - 10,
        height: MediaQuery.of(context).size.height / 4,
        decoration: BoxDecoration(
          //color: const Color.fromARGB(255, 65, 112, 11),
          borderRadius: BorderRadius.circular(20),
        ),
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : _latitude != 0 && _longitude != 0
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_latitude, _longitude),
                      zoom: 14.0,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('location_marker'),
                        position: LatLng(_latitude, _longitude),
                      ),
                    },
                  )
                : Center(child: Text("Falha ao obter coordenadas")),
      ),
    );
  }
}
