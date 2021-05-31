import 'package:bigfoot/controllers/database.dart';
import 'package:flutter/material.dart';

class AppContext extends ChangeNotifier {
  final Color primaryColor = Color.fromRGBO(41, 60, 79, 1);

  AppContext() {
    print('context initialized');
  }

  Future<bool> init() async {
    // preferences = await SharedPreferences.getInstance();

    await initDatabase();

    return true; //TODO
  }

  Future<void> initDatabase() async => await SightingsDB.instance.database;
}
