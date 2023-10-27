import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Crud2 extends StatefulWidget {
  const Crud2({
    Key? key,
  }) : super(key: key);

  @override
  State<Crud2> createState() => _HomeState();
}

class _HomeState extends State<Crud2> {
  TextEditingController nombreController = TextEditingController();
  TextEditingController direccionController = TextEditingController();
  TextEditingController telefonoController = TextEditingController();

  _HomeState() {
    // Inicializa los controladores con valores iniciales
    nombreController.text = '';
    direccionController.text = '';
    telefonoController.text = '';
  }

  Future<void> _showProviderDetailsDialog(
    BuildContext context,
    String nombre,
    String direccion,
    String telefono,
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
                      text: 'Dirección: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: direccion),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    const TextSpan(
                      text: 'Teléfono: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: telefono),
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
        title: const Text('Menu de Proveedores'),
      ),
      body: FutureBuilder(
        future: getProviders(),
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
                final direccion = document?['direccion'];
                final telefono = document?['telefono'];
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
                            direccion,
                            telefono,
                          );
                        },
                        child: const Icon(Icons.business, size: 50),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nombre),
                          Text(
                            'Dirección: ' +
                                (direccion.length > 50
                                    ? direccion.substring(0, 20) + '...'
                                    : direccion),
                          ),
                          Text('Teléfono: $telefono'),
                          ElevatedButton(
                            onPressed: () {
                              _showEditProviderDialog(
                                context,
                                documentId!,
                                nombre,
                                direccion,
                                telefono,
                                nombreController,
                                direccionController,
                                telefonoController,
                              );
                            },
                            child: const Text('Editar'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              showDeleteConfirmation(context, documentId!);
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

Future<void> editProvider(
    String providerId, String nombre, String direccion, String telefono) async {
  final provider = {
    'nombre': nombre,
    'direccion': direccion,
    'telefono': telefono,
  };
  await FirebaseFirestore.instance
      .collection('proveedores')
      .doc(providerId)
      .update(provider);
}

Future<void> deleteProvider(String providerId) async {
  await FirebaseFirestore.instance
      .collection('proveedores')
      .doc(providerId)
      .delete();
}

Future<List<DocumentSnapshot>> getProviders() async {
  final providers =
      await FirebaseFirestore.instance.collection('proveedores').get();
  return providers.docs; // Devuelve una lista de DocumentSnapshot
}

Future<void> showDeleteConfirmation(
    BuildContext context, String providerId) async {
  return showDialog(
    context: context,
    barrierDismissible:
        false, // Evita que se cierre al tocar fuera del cuadro de diálogo
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Eliminar Proveedor'),
        content:
            const Text('¿Está seguro de que desea eliminar este proveedor?'),
        actions: [
          TextButton(
            child: const Text('Sí'),
            onPressed: () {
              // Si el usuario hace clic en "Sí", llama a la función para eliminar el proveedor
              deleteProvider(providerId);
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

Future<void> _showEditProviderDialog(
  BuildContext context,
  String providerId,
  String initialNombre,
  String initialDireccion,
  String initialTelefono,
  TextEditingController nombreController,
  TextEditingController direccionController,
  TextEditingController telefonoController,
) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Editar Proveedor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Campos para editar nombre, dirección y teléfono
              TextField(
                controller: nombreController..text = initialNombre,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: direccionController..text = initialDireccion,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
              TextField(
                controller: telefonoController..text = initialTelefono,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              editProvider(
                providerId,
                nombreController.text,
                direccionController.text,
                telefonoController.text,
              );

              // Cierra el diálogo
              Navigator.of(context).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      );
    },
  );
}
