import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Crud1 extends StatefulWidget {
  const Crud1({
    Key? key,
  }) : super(key: key);

  @override
  State<Crud1> createState() => _HomeState();
}

class _HomeState extends State<Crud1> {
  TextEditingController nombreController = TextEditingController();
  TextEditingController categoriaController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();
  TextEditingController precioController = TextEditingController();
  late String imageUrl = ''; // Almacenará la URL de la imagen

  _HomeState() {
    // Inicializa los controladores con valores iniciales
    nombreController.text = '';
    categoriaController.text = '';
    descripcionController.text = '';
    precioController.text = '0';
  }

  Future<void> _showProductDetailsDialog(
    BuildContext context,
    String nombre,
    int precio,
    String descripcion,
    String categoria,
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
                      text: 'Precio: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: '$precio'),
                  ],
                ),
              ),
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
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    const TextSpan(
                      text: 'Categoría: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: categoria),
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
        title: const Text('Menu de Productos'),
      ),
      body: FutureBuilder(
        future: getProducts(),
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
                final precio = document?['precio'];
                final descripcion = document?['descripcion'];
                final categoria = document?['categoria'];
                final documentId = document?.id;

                return Container(
                  margin: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showProductDetailsDialog(
                            context,
                            nombre,
                            precio,
                            descripcion,
                            categoria,
                          );
                        },
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: Image.network(document?['imageUrl']),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nombre),
                          Text('Precio: $precio'),
                          ElevatedButton(
                            onPressed: () {
                              _showEditProductDialog(
                                context,
                                documentId!,
                                nombre,
                                precio,
                                descripcion,
                                nombreController,
                                categoriaController,
                                descripcionController,
                                precioController,
                              );
                            },
                            child: const Text('Editar'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              showDeleteConfirmationDialog(
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

Future<void> editProduct(String productId, String nombre, String categoria,
    String descripcion, int precio) async {
  final product = {
    'nombre': nombre,
    'categoria': categoria,
    'descripcion': descripcion,
    'precio': precio,
  };
  await FirebaseFirestore.instance
      .collection('productos')
      .doc(productId)
      .update(product);
}

Future<void> deleteProduct(String productId) async {
  await FirebaseFirestore.instance
      .collection('productos')
      .doc(productId)
      .delete();
}

Future<List<DocumentSnapshot>> getProducts() async {
  final products =
      await FirebaseFirestore.instance.collection('productos').get();
  return products.docs; // Devuelve una lista de DocumentSnapshot
}

Future<void> showDeleteConfirmationDialog(
    BuildContext context, String productId) async {
  return showDialog(
    context: context,
    barrierDismissible:
        false, // Evita que se cierre al tocar fuera del cuadro de diálogo
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Eliminar Producto'),
        content:
            const Text('¿Está seguro de que desea eliminar este producto?'),
        actions: [
          TextButton(
            child: const Text('Sí'),
            onPressed: () {
              // Si el usuario hace clic en "Sí", llama a la función para eliminar el producto
              deleteProduct(productId);
              Navigator.of(context).pop(); // Cierra el cuadro de diálogo
            },
          ),
          TextButton(
            child: const Text('No'),
            onPressed: () {
              // Si el usuario hace clic en "No", simplemente cierra el cuadro de diálogo
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> _showEditProductDialog(
  BuildContext context,
  String productId,
  String initialNombre,
  int initialPrecio,
  String initialDescripcion,
  TextEditingController nombreController,
  TextEditingController descripcionController,
  TextEditingController precioController,
  TextEditingController categoriaController,
) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Editar Producto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Campos para editar nombre, descripción, y precio
              TextField(
                controller: nombreController..text = initialNombre,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: descripcionController..text = initialDescripcion,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              TextField(
                controller: precioController..text = initialPrecio.toString(),
                decoration: const InputDecoration(labelText: 'Precio'),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              int? precio = int.tryParse(precioController.text);

              if (precio != null) {
                editProduct(
                  productId,
                  nombreController.text,
                  categoriaController.text,
                  descripcionController.text,
                  precio,
                );

                // Cierra el diálogo
                Navigator.of(context).pop();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      );
    },
  );
}
