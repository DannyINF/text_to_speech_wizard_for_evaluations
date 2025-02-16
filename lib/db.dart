import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'audio_files.db');
    return await openDatabase(
      path,
      version: 14,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE generated_audio_files (
            id TEXT PRIMARY KEY,
            content BLOB,
            input TEXT,
            gender TEXT,
            provider TEXT,
            model TEXT,
            voice TEXT,
            language_code TEXT
          );
        ''');
          await db.execute('''
          CREATE TABLE settings (
            id INTEGER PRIMARY KEY,
            model TEXT,
            language_code TEXT,
            gender TEXT,
            voice TEXT,
            custom_input INTEGER
          );
        ''');
          await db.execute('''
          CREATE TABLE buttons (
            id INTEGER,
            view TEXT,
            cellsX INTEGER,
            cellsY INTEGER,
            icon BLOB,
            title TEXT,
            message TEXT,
            PRIMARY KEY (id, view)
          );
        ''');
      },
      // onUpgrade: (db, oldVersion, newVersion) async {
      //   if (oldVersion < 14) {
      //     await db.execute('''
      //     CREATE TABLE buttons (
      //       id INTEGER,
      //       view TEXT,
      //       cellsX INTEGER,
      //       cellsY INTEGER,
      //       icon BLOB,
      //       title TEXT,
      //       message TEXT,
      //       PRIMARY KEY (id, view)
      //     )
      //   ''');
      //   }
      // }
    );
  }

  Future<int> insertAudioFile(String input, String gender, String provider, String model, String languageCode, String voice, Uint8List content) async {
    final db = await database;
    final id = '$input-$gender-$provider-$model-$languageCode-$voice';
    return await db.insert(
      'generated_audio_files',
      {
        'id': id,
        'content': content,
        'input': input,
        'gender': gender,
        'provider': provider,
        'model': model,
        'language_code': languageCode,
        'voice': voice,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getAudioFile(
      String input, String gender, String provider, String model, String languageCode, String voice) async {
    final db = await database;
    final id = '$input-$gender-$provider-$model-$languageCode-$voice';
    final result = await db.query(
      'generated_audio_files',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllAudioFiles() async {
    final db = await database;
    return await db.query('generated_audio_files');
  }

  Future<int> deleteAudioFile(
      String input, String gender, String provider, String model, String languageCode, String voice) async {
    final db = await database;
    final id = '$input-$gender-$provider-$model-$languageCode-$voice';
    return await db.delete(
      'generated_audio_files',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllAudioFiles() async {
    final db = await database;
    return await db.delete('generated_audio_files');
  }

  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }

  Future<int> insertSettings(
      String model, String languageCode, String gender, String voice, bool customInput) async {
    final db = await database;
    return await db.insert(
      'settings',
      {
        'model': model,
        'language_code': languageCode,
        'gender': gender,
        'voice': voice,
        'custom_input': customInput ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, Object?>?> getSettings() async {
    final db = await database;
    final result = await db.query('settings');
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateSettings(
      String model, String languageCode, String gender, String voice, bool customInput) async {
    final db = await database;
    return await db.update(
        'settings',
        {
          'model': model,
          'language_code': languageCode,
          'gender': gender,
          'voice': voice,
          'custom_input': customInput ? 1 : 0,
        }
    );
  }

  Future<bool> doesSettingsExist() async {
    final db = await database;
    final result = await db.rawQuery('SELECT name FROM sqlite_master WHERE type=\'table\' AND name=\'settings\'');
    if (result.isNotEmpty) {
      final result = await db.query('settings');
      return result.isNotEmpty;
    }
    return result.isNotEmpty;
  }

  // function for saving a button, consisting of "view": TEXT, "cellsX": INTEGER, "cellsY": INTEGER, "icon": serializedIcon(IconData), "title": TEXT,  "message": text
  Future<int> insertButton(int id, String view, int cellsX, int cellsY, String icon, String title, String message) async {
    final db = await database;
    return await db.insert(
      'buttons',
      {
        'id': id,
        'view': view,
        'cellsX': cellsX,
        'cellsY': cellsY,
        'icon': icon,
        'title': title,
        'message': message
      }
    );
  }

  // update button
  Future<int> updateButton(int id, String view, int cellsX, int cellsY, String icon, String title, String message) async {
    final db = await database;
    return await db.update(
      'buttons',
      {
        'cellsX': cellsX,
        'cellsY': cellsY,
        'icon': icon,
        'title': title,
        'message': message
      },
      where: 'id = ? AND view = ?',
      whereArgs: [id, view],
    );
  }

  // get button by view
  Future<List<Map<String, dynamic>>> getButtonsByView(String view) async {
    final db = await database;
    return await db.query(
      'buttons',
      where: 'view = ?',
      whereArgs: [view],
      orderBy: 'id ASC',
    );
  }

  // get button by view and cellsX and cellsY as id
  Future<Map<String, dynamic>?> getButtonByIdAndView(int id, String view) async {
    final db = await database;
    final result = await db.query(
      'buttons',
      where: 'id = ? AND view = ?',
      whereArgs: [id, view],
    );
    return result.isNotEmpty ? result.first : null;
  }
}
