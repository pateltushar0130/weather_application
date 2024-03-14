import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class WeatherDatabase {
  static final WeatherDatabase instance = WeatherDatabase._init();

  static Database? _database;

  WeatherDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('weather.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
        CREATE TABLE weather_cards (id INTEGER PRIMARY KEY AUTOINCREMENT,city_name TEXT NOT NULL,temperature INTEGER NOT NULL,description TEXT NOT NULL)
''');
  }

  Future<List<Map<String, dynamic>>> getWeatherCards() async {
    final db = await instance.database;

    return await db.query('weather_cards');
  }

  Future<int> insertWeatherCard(Map<String, dynamic> card) async {
    final db = await instance.database;
    return await db.insert('weather_cards', card);
  }
  Future<void> deleteWeatherCard(int id) async {
    final db = await instance.database;
    await db.delete(
      'weather_cards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllWeatherCards() async {
    final db = await instance.database;
    await db.delete('weather_cards');
  }
}