import 'package:sqflite/sqflite.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';

class Funcoes_Publicacoes {
  static Future<void> criarTabela_Publicacoes(Database db) async {
    await db.execute('CREATE TABLE publicacao('
        'id INTEGER PRIMARY KEY,'
        ' nome TEXT,'
        'local TEXT,'
        'classificacao_media INTEGER,'
        'area_id INTEGER,'
        'caminho_imagem TEXT,'
        'descricao_local TEXT,'
        'topico_id INTEGER,'
        'pagina_web TEXT,'
        'data_publicacao TEXT,'
        'telemovel TEXT,'
        'email TEXT,'
        'latitude TEXT,'
        'longitude TEXT,'
        'centro_id INTEGRER,'
        'user_id INTEGER,'
        'FOREIGN KEY (user_id) REFERENCES usuario(id),'
        'FOREIGN KEY (centro_id) REFERENCES centros(id), '
        'FOREIGN KEY (topico_id) REFERENCES topicos(id),'
        'FOREIGN KEY (area_id) REFERENCES areas(id) )');
  }

  static Future<void> insertPublicacoes(Database db) async {
    await db.insert(
      'publicacao',
      {
        'nome': 'Estadio Municipal do Fontelo',
        'local': 'Av.José Relvas 6',
        'classificacao_media': '4.1',
        'caminho_imagem': 'assets/images/fontelo.jpg',
        'descricao_local':
            'O Estádio Municipal do Fontelo é um estádio de futebol municipal situado no "Parque Desportivo Municipal do Fontelo", na cidade de Viseu, em Portugal.',
        'pagina_web':'https://www.cm-viseu.pt/index.php/diretorio/desporto/instalcoes-esp-desp-municipais/parque-despotivo-fontelo/estadio-municipal-do-fontelo',
        'telemovel':'232 427 427',
        'email':'geral@cmviseu.pt',
        'data_publicacao':'31/06/2023',
        'area_id': 2,
        'user_id':3,
        'centro_id':5,
        'topico_id': 1,
        'latitude':'40.659533',
        'longitude':'-7.900403'
      },
    );
    await db.insert(
      'publicacao',
      {
        'nome': 'Campo de Futebol de Santo Estevão',
        'local': 'Praça do Comércio 45',
        'classificacao_media': '4.3',
        'caminho_imagem': 'assets/images/campodefutbol.jpg',
        'descricao_local': 'ainda nao desenvolvi',
        'area_id': 2,
        'pagina_web':null,
        'telemovel':null,
        'email':null,
        'data_publicacao':'02/03/2024',
        'user_id':5,
        'centro_id':4,
        'topico_id': 1,
        'latitude':'40.670266',
        'longitude':'-7.930095'
      },
    );
    /*
    await db.insert(
      'publicacao',
      {'nome': 'Hospital S. Teotónio', 
      'local': 'Av. Rei D.Duarte',
      'classificacao_media': '4.5',
      'caminho_imagem':'assets/images/hospital.png',
      'area_id':1,
      'topico_id':null,
      },
    );
    await db.insert(
      'publicacao',
      {'nome': 'Restaurante Feitoria', 
      'local': 'R.Montenegro 8',
      'classificacao_media': '4.2',
      'caminho_imagem':'assets/images/restaurante.jpg',
      'area_id':3,
      'topico_id':null,
      },
    );
   
   
    await db.insert(
      'publicacao',
      {'nome': 'Entredesafios- Formação Profissional', 
      'local': 'Quartel da Paz, Viseu',
      'classificacao_media': '4.9',
      'caminho_imagem':'assets/images/local_formacao.png',
      'area_id':4,
      'topico_id':6,
      },
    );
    await db.insert(
      'publicacao',
      {'nome': 'Hotel Bela Vista', 
      'local': 'R. Alexandre Herculano 510',
      'classificacao_media': '3.6',
      'caminho_imagem':'assets/images/local_alojamento.jpg',
      'area_id':5,
      'topico_id':null,
      },
    );
    await db.insert(
      'publicacao',
      {'nome': 'Estação Rodoviária de Viseu', 
      'local': 'Av. Dr. António José de Almeida 242',
      'classificacao_media': '3.7',
      'caminho_imagem':'assets/images/local_transportes.png',
      'area_id':6,
      'topico_id':null,
      },
    );
    await db.insert(
      'publicacao',
      {'nome': 'Parque do Fontelo', 
      'local': 'Av. José Relvas,Viseu',
      'classificacao_media': '4.9',
      'caminho_imagem':'assets/images/local_lazer.jpg',
      'area_id':7,
      'topico_id':null,
      },
    );*/
  }

  Future<List<Map<String, dynamic>>> consultaPublicacoes() async {
    Database db = await DatabaseHelper.basededados;
    return await db.rawQuery('SELECT * FROM publicacao');
  }

  Future<List<Map<String, dynamic>>> consultaPublicacoesPorCentroId(int centroId) async {
    Database db = await DatabaseHelper.basededados;
    return await db.query(
      'publicacao',
      where: 'centro_id = ?', 
      whereArgs: [centroId], 
    );
  }


  static Future<String> consultaNomeLocalPorId(int idLocal) async {
    Database db = await DatabaseHelper.basededados;

    List<Map<String, dynamic>> resultado = await db.query(
      'publicacao',
      columns: ['nome'],
      where: 'id = ?',
      whereArgs: [idLocal],
    );

    if (resultado.isNotEmpty) {
      return resultado.first['nome'];
    } else {
      return '';
    }
  }

  static Future<List<Map<String, dynamic>>> consultaDetalhesPublicacaoPorId(
      int idLocal) async {
    Database db = await DatabaseHelper.basededados;
    return await db.query(
      'publicacao',
      where: 'id = ?',
      whereArgs: [idLocal],
    );
  }

  static Future<Map<String, dynamic>?> detalhes_por_id(int idLocal) async {
    Database db = await DatabaseHelper.basededados;
    List<Map<String, dynamic>> results = await db.query(
      'publicacao',
      where: 'id = ?',
      whereArgs: [idLocal],
    );
    return results.isNotEmpty ? results.first : null;
  }

  static Future<List<Map<String, dynamic>>> consultarPublicacoesPorIdTopico(
      int idTopico) async {
    Database db = await DatabaseHelper.basededados;
    return await db.query(
      'publicacao',
      where: 'topico_id = ?',
      whereArgs: [idTopico],
    );
  }

  static Future<List<Map<String, dynamic>>> buscarPublicacoesPorNome(
      String nomePesquisa) async {
    Database db = await DatabaseHelper.basededados;
    return await db.query(
      'publicacao',
      where: 'nome LIKE ?',
      whereArgs: ['%$nomePesquisa%'],
    );
  }

  static Future<Map<String, double>?> obter_cordenadada_pub(int idLocal) async {
    Database db = await DatabaseHelper.basededados;
    List<Map<String, dynamic>> resultado = await db.query(
      'publicacao',
      columns: ['latitude', 'longitude'],
      where: 'id = ?',
      whereArgs: [idLocal],
    );

    if (resultado.isNotEmpty) {
      double? latitude = double.tryParse(resultado.first['latitude']);
      double? longitude = double.tryParse(resultado.first['longitude']);

      if (latitude != null && longitude != null) {
        return {'latitude': latitude, 'longitude': longitude};
      }
    }
    return null;
  }
}

