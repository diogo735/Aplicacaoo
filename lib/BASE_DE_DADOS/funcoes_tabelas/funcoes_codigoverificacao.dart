import 'package:ficha3/BASE_DE_DADOS/basededados.dart';
import 'package:sqflite/sqflite.dart';

class FuncoesCodigoverificacao {
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE password_reset_codes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        code TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  static Future<void> saveCodeForUser(String email, String code) async {
    Database db = await DatabaseHelper.basededados;
    await db.insert(
      'password_reset_codes',
      {
        'email': email,
        'code': code,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm
          .replace, // Substitui o código existente para o mesmo email
    );
  }

  static Future<bool> verifyCode(String email, String code) async {
    Database db = await DatabaseHelper.basededados;
    final List<Map<String, dynamic>> result = await db.query(
      'password_reset_codes',
      where: 'email = ? AND code = ?',
      whereArgs: [email, code],
    );

    return result.isNotEmpty;
  }

  static Future<void> deleteUsedOrExpiredCodes() async {
    Database db = await DatabaseHelper.basededados;
    await db.delete(
      'password_reset_codes',
      where: 'created_at < ?',
      whereArgs: [
        DateTime.now().subtract(Duration(hours: 1)).toIso8601String()
      ],
    );
  }
}
