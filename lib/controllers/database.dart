import 'dart:io';

import 'package:flutter/widgets.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';

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
    //https://github.com/tekartik/sqflite/blob/master/sqflite/doc/opening_asset_db.md

    // Open the database and store the reference.

    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, _databaseName);

    // Check if the database exists
    var exists = await databaseExists(path);

    print('path: ${databasesPath}  /  db exists: ${exists}');

    // if (!exists) {
    // Should happen only the first time you launch your application
    print("Creating new db copy from asset");

    // Make sure the parent directory exists
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}

    // Copy from asset
    ByteData data =
        await rootBundle.load(join("assets", "data", _databaseName));
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // Write and flush the bytes written
    await File(path).writeAsBytes(bytes, flush: true);
    // } else {
    //   print("Opening existing database");
    // }
    // open the database
    print("Opening database");
    return await openDatabase(path, readOnly: true);
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

    return await db.query(table).then((rows) {
      // print(rows[0]);
      return rows.map((row) => Sighting.fromMap(row)).toList();
    } // Map each row to a sighting
        );
  }

  Future<List<LatLng>> queryCoords() async {
    Database db = await instance.database;
    return await db.query(table, columns: ['latitude', 'longitude']).then(
      (rows) => rows
          .map((row) =>
              LatLng(row['latitude'] as double, row['longitude'] as double))
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

  printTables() async {
    Database db = await instance.database;
    var tableNames = (await db
            .query('sqlite_master', where: 'type = ?', whereArgs: ['table']))
        .map((row) => row['name'] as String)
        .toList(growable: false);

    print('tables:');
    print(tableNames);
  }
}
