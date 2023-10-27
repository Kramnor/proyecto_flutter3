import 'package:crud_firebase2/screens.dart';
import 'package:flutter/material.dart';

class Approutes {
  static const initialRoute = 'login';

  static Map<String, Widget Function(BuildContext)> routes = {
    'login': (BuildContext context) => const AuthScreen(),
    'home': (BuildContext context) => const Home(),
    'crud1': (BuildContext context) => const Crud1(),
    'crud2': (BuildContext context) => const Crud2(),
    'crud3': (BuildContext context) => const Crud3(),
  };
}
