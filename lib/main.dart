import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TIG333 Att Göra',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const TodoListScreen(),
    );
  }
}

class Todo {
  final String id;
  final String title;
  final bool done;

  Todo({
    required this.id,
    required this.title,
    required this.done,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      done: json['done'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'done': done,
    };
  }

  Todo copyWith({String? id, String? title, bool? done}) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      done: done ?? this.done,
    );
  }
}

Future<List<Todo>> fetchTodos(String apiKey) async {
  final response = await http.get(Uri.parse('https://todoapp-api.apps.k8s.gu.se/todos?key=$apiKey'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonResponse = jsonDecode(response.body);
    return jsonResponse.map((todo) => Todo.fromJson(todo)).toList();
  } else {
    throw Exception('Kunde inte ladda todos');
  }
}

Future<void> addTodo(String apiKey, Todo todo) async {
  final response = await http.post(
    Uri.parse('https://todoapp-api.apps.k8s.gu.se/todos?key=$apiKey'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(todo.toJson()),
  );

  if (response.statusCode != 200) {
    throw Exception('Kunde inte lägga till todo');
  }
}

Future<void> updateTodo(String apiKey, Todo todo) async {
  final response = await http.put(
    Uri.parse('https://todoapp-api.apps.k8s.gu.se/todos/${todo.id}?key=$apiKey'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(todo.toJson()),
  );

  if (response.statusCode != 200) {
    throw Exception('Kunde inte uppdatera todo');
  }
}

Future<void> deleteTodo(String apiKey, String id) async {
  final response = await http.delete(
    Uri.parse('https://todoapp-api.apps.k8s.gu.se/todos/$id?key=$apiKey'),
  );

  if (response.statusCode != 200) {
    throw Exception('Kunde inte ta bort todo');
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late Future<List<Todo>> futureTodos;
  final String apiKey = '554bd97b-6e56-4aa7-8c47-4d3b30f598b4';
  final TextEditingController textController = TextEditingController();
  bool isDarkMode = false;
  String filter = 'all';

  @override
  void initState() {
    super.initState();
    futureTodos = fetchTodos(apiKey);
  }

  void _addTodo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Lägg till ny uppgift'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: 'Skriv uppgiftens namn'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String newTodoTitle = textController.text;
                if (newTodoTitle.isNotEmpty) {
                  Todo newTodo = Todo(id: '', title: newTodoTitle, done: false);
                  addTodo(apiKey, newTodo).then((_) {
                    setState(() {
                      futureTodos = fetchTodos(apiKey);
                    });
                    textController.clear();
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Lägg till'),
            ),
            TextButton(
              onPressed: () {
                textController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Avbryt'),
            ),
          ],
        );
      },
    );
  }

  void _editTodoName(Todo todo) {
    textController.text = todo.title;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Redigera Todo'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: 'Ändra uppgiftens namn'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String updatedTitle = textController.text;
                if (updatedTitle.isNotEmpty) {
                  Todo updatedTodo = todo.copyWith(title: updatedTitle);
                  updateTodo(apiKey, updatedTodo).then((_) {
                    setState(() {
                      futureTodos = fetchTodos(apiKey);
                    });
                    textController.clear();
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Spara'),
            ),
            TextButton(
              onPressed: () {
                textController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Avbryt'),
            ),
          ],
        );
      },
    );
  }

  void _toggleTodoDone(Todo todo) {
    final updatedTodo = todo.copyWith(done: !todo.done);
    updateTodo(apiKey, updatedTodo).then((_) {
      setState(() {
        futureTodos = futureTodos.then((todos) {
          return todos.map((t) => t.id == todo.id ? updatedTodo : t).toList();
        });
      });
    }).catchError((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kunde inte uppdatera uppgiften')),
      );
    });
  }

  void _deleteTodo(Todo todo) {
    deleteTodo(apiKey, todo.id).then((_) {
      setState(() {
        futureTodos = fetchTodos(apiKey);
      });
    }).catchError((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kunde inte ta bort uppgiften')),
      );
    });
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Row(
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                cardColor: Colors.blue[700],
              ),
              child: PopupMenuButton<String>(
                color: Colors.blue[100],
                onSelected: (String result) {
                  setState(() {
                    filter = result;
                  });
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'all',
                    child: Text(
                      'Alla',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'done',
                    child: Text(
                      'Gjorda',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'undone',
                    child: Text(
                      'Ogjorda',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
                icon: const Icon(
                  Icons.filter_list,
                  color: Colors.white,
                ),
              ),
            ),
            const Spacer(),
            const Center(
              child: Text(
                'TIG333 Att Göra',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round, color: Colors.white),
              onPressed: _toggleTheme,
            ),
          ],
        ),
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: FutureBuilder<List<Todo>>(
        future: futureTodos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final todos = snapshot.data!;
          List<Todo> filteredTodos = todos;

          if (filter == 'done') {
            filteredTodos = todos.where((todo) => todo.done).toList();
          } else if (filter == 'undone') {
            filteredTodos = todos.where((todo) => !todo.done).toList();
          }

          return ListView.builder(
            itemCount: filteredTodos.length,
            itemBuilder: (context, index) {
              return Card(
                key: ValueKey(filteredTodos[index].id),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.blue[900]!, width: 2),
                ),
                child: TodoItem(
                  todo: filteredTodos[index],
                  onChanged: (bool? value) {
                    _toggleTodoDone(filteredTodos[index]);
                  },
                  onDelete: () {
                    _deleteTodo(filteredTodos[index]);
                  },
                  onEdit: () {
                    _editTodoName(filteredTodos[index]);
                  },
                  isDarkMode: isDarkMode,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        backgroundColor: Colors.blue[900],
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TodoItem extends StatelessWidget {
  final Todo todo;
  final Function(bool?) onChanged;
  final Function onDelete;
  final Function onEdit;
  final bool isDarkMode;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onChanged,
    required this.onDelete,
    required this.onEdit,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(10),
      leading: Checkbox(
        value: todo.done,
        onChanged: onChanged,
      ),
      title: Text(
        todo.title,
        style: TextStyle(
          fontSize: 18,
          decoration: todo.done ? TextDecoration.lineThrough : TextDecoration.none,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => onEdit(),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => onDelete(),
          ),
        ],
      ),
      tileColor: isDarkMode ? Colors.grey[800] : Colors.white,
    );
  }
}
