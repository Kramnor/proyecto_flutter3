import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú Principal'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, 'crud1');
              },
              child: const Text('Modulo Productos'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, 'crud2');
              },
              child: const Text('Modulo Proveedores'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, 'crud3');
              },
              child: const Text('Modulo Categorias'),
            ),
          ],
        ),
      ),
    );
  }
}
