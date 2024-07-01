import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_centro.dart';
import 'package:ficha3/centro_provider.dart';
import 'package:provider/provider.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_centros.dart';

class Pag_mudar_centro extends StatefulWidget {
  final int idCentro;

  const Pag_mudar_centro({Key? key, required this.idCentro}) : super(key: key);

  @override
  _Pag_mudar_centroState createState() => _Pag_mudar_centroState();
}

class _Pag_mudar_centroState extends State<Pag_mudar_centro> {
  @override
  void initState() {
    super.initState();
    selecionarCentroPorId(widget.idCentro);
  }

  void selecionarCentroPorId(int idCentro) async {
    print('ID do Centro: $idCentro');
    List<Map<String, dynamic>> centrosCarregados =
        await Funcoes_Centros.consultaCentros();
    var centroAssociado = centrosCarregados
        .firstWhere((centro) => centro['id'] == widget.idCentro);

    if (centroAssociado != null) {
      Provider.of<Centro_Provider>(context, listen: false).selecionarCentro(
        Centro(
          id: centroAssociado['id'],
          nome: centroAssociado['nome'],
          morada: centroAssociado['morada'],
          imagem: centroAssociado['imagem_centro'],
        ),
      );
      await Future.delayed(Duration(seconds: 2));

      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final centroProvider = Provider.of<Centro_Provider>(context);
    final centroSelecionado = centroProvider.centroSelecionado;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 20,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              'A mudar para a Softinsa',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontFamily: 'ABeeZee',
                fontWeight: FontWeight.w400,
                letterSpacing: 0.50,
              ),
            ),
            Text(
              'de ...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontFamily: 'ABeeZee',
                fontWeight: FontWeight.w400,
                letterSpacing: 0.50,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 9),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  width: MediaQuery.of(context).size.height / 3.70,
                  height: MediaQuery.of(context).size.height / 5,
                  color: Colors.grey,
                  child: centroSelecionado != null &&
                          centroSelecionado.imagem.isNotEmpty
                      ? Image.file(
                          File(centroSelecionado.imagem),
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          "assets/images/sem_imagem.png",
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            SizedBox(height: 5),
            Text(
              centroSelecionado != null
                  ? centroSelecionado.nome
                  : "Nome do Centro",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF15659F),
                fontSize: 28,
                fontFamily: 'ABeeZee',
                fontWeight: FontWeight.w400,
                letterSpacing: 0.50,
              ),
            ),
            Spacer(),
            customCircularProgress(),
            SizedBox(height: 35),
            Text(
              'carregando...  ',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF7E868D),
                fontSize: 16,
                fontFamily: 'ABeeZee',
                fontWeight: FontWeight.w400,
                height: 0.09,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Dica: Quando muda de polo pode na mesma interagir com eventos e locais desse polo',
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF7E868D),
                  fontSize: 16,
                  fontFamily: 'ABeeZee',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(
              height: 15,
            )
          ],
        ),
      ),
    );
  }
}

Widget customCircularProgress() {
  return Stack(
    alignment: Alignment.center,
    children: [
      SizedBox(
        width: 60,
        height: 60,
        child: CircularProgressIndicator(
          strokeWidth: 5,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF15659F)),
        ),
      ),
      Image.asset(
        'assets/images/circulo_progresso.png',
        width: 35,
        height: 35,
        fit: BoxFit.cover,
      ),
    ],
  );
}
