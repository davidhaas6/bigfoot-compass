import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bigfoot/views/compass.dart';
import 'package:bigfoot/controllers/app_context.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ChangeNotifierProvider(
    create: (context) => AppContext(),
    child: MaterialApp(
      title: 'Bigfooter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bigfooter'),
        ),
        body: Compass(),
      ),
    ),
  ));
}
