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
    final result = await _database?.rawQuery('SELECT name FROM sqlite_master WHERE type=\'table\'');
    print(result);
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'audio_files.db');
    return await openDatabase(
      path,
      version: 5,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE generated_audio_files (
            id TEXT PRIMARY KEY,
            content BLOB,
            input TEXT,
            gender TEXT,
            provider TEXT,
            model TEXT,
            language_code TEXT
          );
          CREATE TABLE settings (
            id INTEGER PRIMARY KEY,
            model TEXT,
            language_code TEXT,
            gender TEXT,
            voice TEXT,
            custom_input BOOLEAN            
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 5) {
          await db.execute('''
          CREATE TABLE settings (
            id INTEGER PRIMARY KEY,
            model TEXT,
            language_code TEXT,
            gender TEXT,
            voice TEXT,
            custom_input BOOLEAN            
          )
        ''');
        }
      }
    );
  }

  Future<int> insertAudioFile(String input, String gender, String provider, String model, String languageCode, Uint8List content) async {
    final db = await database;
    final id = '$input-$gender-$provider-$model-$languageCode';
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
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getAudioFile(
      String input, String gender, String provider, String model, String languageCode) async {
    final db = await database;
    final id = '$input-$gender-$provider-$model-$languageCode';
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
      String input, String gender, String provider, String model, String languageCode) async {
    final db = await database;
    final id = '$input-$gender-$provider-$model-$languageCode';
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
    print(result);
    if (result.isNotEmpty) {
      final result = await db.query('settings');
      print(result);
      return result.isNotEmpty;
    }
    return result.isNotEmpty;
  }
}
