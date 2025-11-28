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
  final response = await http
      .get(Uri.parse("https://todoapp-api.apps.k8s.gu.se/todos?key=$apiKey"));

  if (response.statusCode == 200) {
    final List<dynamic> jsonResponse = jsonDecode(response.body);
    return jsonResponse.map((todo) => Todo.fromJson(todo)).toList();
  } else {
    throw Exception("Kunde inte ladda todos");
  }
}

Future<void> addTodo(String apiKey, Todo todo) async {
  final response = await http.post(
    Uri.parse("https://todoapp-api.apps.k8s.gu.se/todos?key=$apiKey"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(todo.toJson()),
  );

  if (response.statusCode != 200) {
    throw Exception("Kunde inte lägga till todo");
  }
}

Future<void> updateTodo(String apiKey, Todo todo) async {
  final response = await http.put(
    Uri.parse("https://todoapp-api.apps.k8s.gu.se/todos/${todo.id}?key=$apiKey"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(todo.toJson()),
  );

  if (response.statusCode != 200) {
    throw Exception("Kunde inte uppdatera todo");
  }
}

Future<void> deleteTodo(String apiKey, String id) async {
  final response = await http.delete(
    Uri.parse("https://todoapp-api.apps.k8s.gu.se/todos/$id?key=$apiKey"),
  );

  if (response.statusCode != 200) {
    throw Exception("Kunde inte ta bort todo");
  }
}

class AddTodoScreen extends StatefulWidget {
  final Function(String) onAdd;

  const AddTodoScreen({super.key, required this.onAdd});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lägg till ny uppgift"),
        backgroundColor: Colors.blue[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Uppgift",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900],
              ),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  widget.onAdd(_controller.text);
                  Navigator.pop(context);
                }
              },
              child: const Text("Lägg till"),
            )
          ],
        ),
      ),
    );
  }
}


class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late Future<List<Todo>> futureTodos;


  final String apiKey = "7baca196-fd3b-4afb-9613-02c61f5bb9d2";

  final TextEditingController textController = TextEditingController();
  bool isDarkMode = false;
  String filter = "all";

  @override
  void initState() {
    super.initState();
    futureTodos = fetchTodos(apiKey);
  }


  void _navigateToAddTodo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTodoScreen(
          onAdd: (String title) {
            Todo newTodo = Todo(id: "", title: title, done: false);
            addTodo(apiKey, newTodo).then((_) {
              setState(() {
                futureTodos = fetchTodos(apiKey);
              });
            });
          },
        ),
      ),
    );
  }


  void _editTodoName(Todo todo) {
    textController.text = todo.title;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Redigera Todo"),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: "Ändra uppgiftens namn"),
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
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("Spara"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Avbryt"),
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
        futureTodos = fetchTodos(apiKey);
      });
    });
  }

  void _deleteTodo(Todo todo) {
    deleteTodo(apiKey, todo.id).then((_) {
      setState(() {
        futureTodos = fetchTodos(apiKey);
      });
    });
  }

  void _toggleTheme() {
    setState(() => isDarkMode = !isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Row(
          children: [
            PopupMenuButton<String>(
              color: Colors.blue[100],
              onSelected: (String result) {
                setState(() => filter = result);
              },
              itemBuilder: (BuildContext context) => const [
                PopupMenuItem(value: 'all', child: Text("Alla")),
                PopupMenuItem(value: 'done', child: Text("Gjorda")),
                PopupMenuItem(value: 'undone', child: Text("Ogjorda")),
              ],
              icon: const Icon(Icons.filter_list, color: Colors.white),
            ),
            const Spacer(),
            const Text("TIG333 Att Göra",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(
              icon: Icon(
                isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                color: Colors.white,
              ),
              onPressed: _toggleTheme,
            )
          ],
        ),
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: FutureBuilder<List<Todo>>(
        future: futureTodos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final todos = snapshot.data ?? [];

          List<Todo> filteredTodos = todos;
          if (filter == "done") {
            filteredTodos = todos.where((t) => t.done).toList();
          } else if (filter == "undone") {
            filteredTodos = todos.where((t) => !t.done).toList();
          }

          return ListView.builder(
            itemCount: filteredTodos.length,
            itemBuilder: (context, index) {
              return Card(
                child: TodoItem(
                  todo: filteredTodos[index],
                  onChanged: (value) => _toggleTodoDone(filteredTodos[index]),
                  onEdit: () => _editTodoName(filteredTodos[index]),
                  onDelete: () => _deleteTodo(filteredTodos[index]),
                  isDarkMode: isDarkMode,
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTodo,
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
      leading: Checkbox(value: todo.done, onChanged: onChanged),
      title: Text(
        todo.title,
        style: TextStyle(
          decoration: todo.done ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () => onEdit()),
          IconButton(icon: const Icon(Icons.delete), onPressed: () => onDelete()),
        ],
      ),
    );
  }
}
