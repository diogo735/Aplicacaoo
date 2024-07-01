import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<void> mostrarEstruturaEdadosBancoDados() async {
  // Abre o banco de dados
  final database = await openDatabase(
    join(await getDatabasesPath(), 'bdpdm.db'),
  );

  // Obtém o nome do banco de dados
  final dbName = await database.path;
  print('Nome do banco de dados: $dbName');

  // Consulta para obter informações sobre as tabelas do banco de dados
  final tables = await database.rawQuery("SELECT name FROM sqlite_master WHERE type='table';");

  // Obtém o número de tabelas
  final numTables = tables.length;
  print('Número de tabelas: $numTables');

  // Itera sobre as tabelas e mostra a estrutura e os dados de cada uma
  for (final table in tables) {
    final tableName = table['name'];
    print('\n////////////////////////////////////////////////\nTabela: $tableName');

    // Consulta para obter a estrutura da tabela atual
    final columns = await database.rawQuery("PRAGMA table_info($tableName);");

    // Imprime a estrutura da tabela
    print('  Estrutura:');
    for (final column in columns) {
      print('    ${column['name']} - ${column['type']}');
    }

    // Consulta para obter os dados da tabela atual
    final rows = await database.rawQuery("SELECT * FROM $tableName;");

    // Imprime os dados da tabela
    print('  Dados:');
    for (final row in rows) {
      print('    $row');
    }
  }

  // Fecha o banco de dados
  //await database.close();
}
