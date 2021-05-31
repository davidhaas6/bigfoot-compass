import 'package:flutter/widgets.dart';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:maps_toolkit/maps_toolkit.dart';


import '../models/sighting.dart';

class SightingsDB {
  // https://suragch.medium.com/simple-sqflite-database-example-in-flutter-e56a5aaa3f91

  static final _databaseName = "sightings.db";
  // static final _databaseVersion = 1;

  static final table = 'sightings';
  static final idCol = 'number';

  // make this a singleton class
  SightingsDB._privateConstructor();
  static final SightingsDB instance = SightingsDB._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    // Avoid errors caused by flutter upgrade.
    WidgetsFlutterBinding.ensureInitialized();

    // Open the database and store the reference.
    var dbPath = await getDatabasesPath();
    print(dbPath);
    return await openDatabase(
      join(dbPath, _databaseName),
    );
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Sighting sighting) async {
    Database db = await instance.database;
    return await db.insert(
      table,
      sighting.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Sighting>> queryAll() async {
    Database db = await instance.database;
    return await db.query(table).then(
          (rows) => rows
              .map((row) => Sighting.fromMap(row))
              .toList(), // Map each row to a sighting
        );
  }

  Future<List<LatLng>> queryCoords() async {
    Database db = await instance.database;
    return await db.query(table, columns: ['latitude', 'longitude']).then(
      (rows) => rows
          .map((row) => LatLng(row['latitude'] as double, row['longitude'] as double))
          .toList(), // Map each row to a sighting
    );
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[idCol];
    return await db.update(table, row, where: '$idCol = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$idCol = ?', whereArgs: [id]);
  }
}
