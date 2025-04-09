import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; //HTTP
import 'dart:convert'; //JSON

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tareas', //  Titulo pricipal
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TaskListScreen(), //  pantalla de inicio
    );
  }
}

//  nueva pantalla con tareas
class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<dynamic> tasks = []; // lista de tareas cargadas
  bool isLoading = true; // animacion mientras se carga lista

  @override
  void initState() {
    super.initState();
    fetchTasks(); // llamado a la función para cargar tareas de API
  }

  /////////////////////////////////////////////////////////////////////////////
  //  obtener tareas de la API
  Future<void> fetchTasks() async {
    final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/todos'),
    );
    if (response.statusCode == 200) {
      //solicitud exitosa
      setState(() {
        tasks = json.decode(
          response.body,
        ); // decodificacion y guarda las tareas
        isLoading = false; // animacion de carga
      });
    } else {
      throw Exception(
        'Failed to load tasks',
      ); // error de carga si no esta bueno
    }
  }

  ////////////////////////////////////////////////////////////////////////////////
  //  funcion eliminar tareas completadas
  void deleteCompletedTasks() {
    setState(() {
      tasks.removeWhere((task) => task['completed'] == true);
    });
  }

  //  funcion mostrar diálogo agregar tarea
  void _showAddTaskDialog(BuildContext context) {
    final taskController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Agregar Tarea"),
            content: TextField(
              controller: taskController,
              decoration: InputDecoration(hintText: "Escribe una nueva tarea"),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (taskController.text.isNotEmpty) {
                    final newTask = {
                      'id': tasks.length + 1,
                      'title': taskController.text,
                      'completed': false,
                    };

                    setState(() {
                      tasks.add(newTask); // agrega la nueva tarea
                    });

                    Navigator.of(context).pop(); // cierra el cuadro de diálogo
                  }
                },
                child: Text("Agregar"),
              ),
            ],
          ),
    );
  }

  //////////////////////////////////////////////////////////////////////////
  //  Método build dibuja o muestra lista de tareas
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lista de Tareas')),
      //  animacion si está cargando
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      title: Text(
                        task['title'],
                        //subrayar
                        style: TextStyle(
                          decoration:
                              task['completed']
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                        ),
                      ),
                      //chulear
                      leading: Checkbox(
                        value: task['completed'] ?? false,
                        onChanged: (value) {
                          setState(() {
                            task['completed'] = value!;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
      /////////////////////////////////////////////////////////////////////////////////
      //  botones flotantes
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // botón eliminar tareas completadas
          FloatingActionButton(
            heroTag: 'delete',
            onPressed: deleteCompletedTasks,
            child: Icon(Icons.delete),
            backgroundColor: Colors.red,
          ),
          SizedBox(width: 10),
          // botón agregar nueva tarea
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => _showAddTaskDialog(context),
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
