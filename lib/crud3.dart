import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Crud3 extends StatefulWidget {
  const Crud3({
    Key? key,
  }) : super(key: key);

  @override
  State<Crud3> createState() => _HomeState();
}

class _HomeState extends State<Crud3> {
  TextEditingController nombreController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();

  _HomeState() {
    // Inicializa los controladores con valores iniciales
    nombreController.text = '';
    descripcionController.text = '';
  }

  Future<void> _showProviderDetailsDialog(
    BuildContext context,
    String nombre,
    String descripcion,
  ) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    const TextSpan(
                      text: 'Descripción: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: descripcion),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu de Categorías'),
      ),
      body: FutureBuilder(
        future: getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('No data available.');
          } else {
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                final document = snapshot.data?[index];
                final nombre = document?['nombre'];
                final descripcion = document?['descripcion'];
                final documentId = document?.id;

                return Container(
                  margin: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showProviderDetailsDialog(
                            context,
                            nombre,
                            descripcion,
                          );
                        },
                        child: const Icon(Icons.category, size: 50),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nombre),
                          Text(
                            'Descripción: ' +
                                (descripcion.length > 50
                                    ? descripcion.substring(0, 20) + '...'
                                    : descripcion),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _showEditCategoryDialog(
                                context,
                                documentId!,
                                nombre,
                                descripcion,
                                nombreController,
                                descripcionController,
                              );
                            },
                            child: const Text('Editar'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              showDeleteConfirmationCategory(
                                  context, documentId!);
                            },
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

Future<void> editCategory(
    String categoryId, String nombre, String descripcion) async {
  final category = {
    'nombre': nombre,
    'descripcion': descripcion,
  };
  await FirebaseFirestore.instance
      .collection('categorias')
      .doc(categoryId)
      .update(category);
}

Future<void> deleteCategory(String categoryId) async {
  await FirebaseFirestore.instance
      .collection('categorias')
      .doc(categoryId)
      .delete();
}

Future<List<DocumentSnapshot>> getCategories() async {
  final categories =
      await FirebaseFirestore.instance.collection('categorias').get();
  return categories.docs;
}

Future<void> showDeleteConfirmationCategory(
    BuildContext context, String categoryId) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Eliminar Categoría'),
        content:
            const Text('¿Está seguro de que desea eliminar esta categoría?'),
        actions: [
          TextButton(
            child: const Text('Sí'),
            onPressed: () {
              deleteCategory(categoryId);
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> _showEditCategoryDialog(
  BuildContext context,
  String categoryId,
  String initialNombre,
  String initialDescripcion,
  TextEditingController nombreController,
  TextEditingController descripcionController,
) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Editar Categoría'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController..text = initialNombre,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: descripcionController..text = initialDescripcion,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              editCategory(
                categoryId,
                nombreController.text,
                descripcionController.text,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      );
    },
  );
}
