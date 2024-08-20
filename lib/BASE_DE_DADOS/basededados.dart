
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_comentarios_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_imagens_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_listaparticipantes_evento.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_topicosfavoritos_user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_publicacoes.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_partilhasfotos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_areas.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_usuarios.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_tipodeevento.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_topicos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_areafavoritas_douser.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_user_menbro_grupos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_grupos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_foruns.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_mensagens_do_forum.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_topicos_imgens.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_imagens_de_publicacoes.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_horario_publicacao.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_comentarios_de_publicacoes.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_likes_partilhas.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_comentarios_partilhasfotos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_mesnagens_grupos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_centros.dart';

class DatabaseHelper {

  static const String nomebd = "bdpdm.db";
  static const int versao = 1;
  static Database? _basededados;

  static Future<Database> get basededados async {
    if (_basededados != null) return _basededados!;

    _basededados = await _initDatabase();
    return _basededados!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), nomebd);

    return await openDatabase(
      path,
      version: versao,
      onCreate: _onCreate,
    );
  }
//AO CRIAR A BASE DE DADOS
  static Future<void> _onCreate(Database db, int version) async {

  await Funcoes_Centros.createCentrosTable(db);//CENTROS // TA A BUSCAR NA API

  await Funcoes_Usuarios.createUsuariosTable(db);//users //TA A BUSCAR NA API
  

  await Funcoes_Areas.createAreasTable(db);//areas ta a buscar a api
  //await Funcoes_Areas.insertAreas(db);

  await Funcoes_Topicos.createTopicosTable(db);// topicos das areas //TA A BUSCAR NA API
  

  await Funcoes_Topicos_imagens.createTopicosImagensTable(db);//IMAGENS DOS TOPICOS
  await Funcoes_Topicos_imagens.insertTopicosImagens(db);

///////////////////////////////
  await Funcoes_TipodeEvento.create_TipodeEVENTO_Table(db);//tipo de evento ->TA A BUSCAR DA API
  
  
  await Funcoes_Eventos.createEventoTable(db);//eventos->TA A BUSCAR DA API
  

  await Funcoes_Participantes_Evento.createParticipantesEventoTable(db);//lista de participantes evento->TA A BUSCAR DA API
  

  await Funcoes_Comentarios_Eventos.criarTabela_Eventos_Comentarios(db);//comentarios eventos->TA A BUSCAR DA API
  

  await Funcoes_Eventos_Imagens.criarTabela_Eventos_imagens(db);//galeria do evento->TA A BUSCAR DA API
  

//////////////////////////////////////////////////



  await Funcoes_Publicacoes.criarTabela_Publicacoes(db);//publicaçoes de locais
  await Funcoes_Publicacoes.insertPublicacoes(db);

  await Funcoes_Comentarios_Publicacoes.criarTabela_Publicacoes_comentarios(db);//comentarios dos locais
  await Funcoes_Comentarios_Publicacoes.insertComentarios(db);

  await Funcoes_Publicacoes_Imagens.criarTabela_Publicacoes_imagens(db);//imagens das publicacoes de locais
  await Funcoes_Publicacoes_Imagens.insertPublicacoes_imagens(db);

  await Funcoes_Publicacoes_Horario.criarTabela_Publicacoes_horario(db);//tabela do horario publicacao
  await Funcoes_Publicacoes_Horario.insertPublicacoes_horario(db);


 await Funcoes_AreasFavoritas.createAreasFavoritas_douserTable(db);//TA A BUSCAR NA API
  

await Funcoes_TopicosFavoritos.createTopicosFavoritosUserTable(db);// TA A BUSCAR NA API



  await Funcoes_Partilhas.createPartilhasTable(db);//partilhas TA A BUSCAR DA API
 // await Funcoes_Partilhas.insertPartilhas(db);

  await Funcoes_Likes_das_Partilhas.createPartilhasLikesTable(db);//likes das partilhas fotos
  //await Funcoes_Likes_das_Partilhas.insertLikesPartilhas(db);

  await Funcoes_Comentarios_das_Partilhas.createPartilhasComentariosTable(db);//conentarios das partilhas fotos TA A BUSCAR A API
  //await Funcoes_Comentarios_das_Partilhas.insertComentairiosPartilhas(db);

  await Funcoes_Grupos.createGrupoTable(db);// grupos
  await Funcoes_Grupos.insertGrupos(db);

  await Funcoes_User_menbro_grupos.createUsuariomenbrodegruposTable(db);//user_menbro_de_grupos
  await Funcoes_User_menbro_grupos.insertUsuariomenbrodegrupos(db);

  await Funcoes_Mensagens_Grupos.createMensagemGrupoTable(db);//mensagens dos grupos
  await Funcoes_Mensagens_Grupos.insertMensagemGrupo(db);

  await Funcoes_Foruns.createForumTable(db);//foruns
  await Funcoes_Foruns.insertForum(db);

  await Funcoes_Mensagens_foruns.createMensagemForumTable(db);//mensagens dos foruns
  await Funcoes_Mensagens_foruns.insertMensagemForum(db);

  }

}
