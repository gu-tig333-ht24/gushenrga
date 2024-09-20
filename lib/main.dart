import 'package:flutter/material.dart';

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

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  // Lista med statiska To-Do-uppgifter
  final List<Map<String, dynamic>> todos = [
    {"task": "Skriva en bok", "isDone": false},
    {"task": "Göra läxor", "isDone": false},
    {"task": "Städa rummet", "isDone": false},
    {"task": "Titta på TV", "isDone": false},
    {"task": "Ta en tupplur", "isDone": false},
    {"task": "Handla mat", "isDone": false},
    {"task": "Ha kul", "isDone": false},
    {"task": "Meditera", "isDone": false}
  ];

  // Filtrering av To-Do: alla, gjorda, ogjorda
  String filter = 'all';

  @override
  Widget build(BuildContext context) {
    // Filtrera listan beroende på "filter"-variabeln
    List<Map<String, dynamic>> filteredTodos = todos.where((todo) {
      if (filter == 'done') {
        return todo['isDone'] == true;
      } else if (filter == 'undone') {
        return todo['isDone'] == false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900], // Mörkblå bakgrund för headern
        // Row för att placera menyn och titeln
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Centrerar titeln
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft, // Justerar menyn till vänster
                child: Theme(
                  data: Theme.of(context).copyWith(
                    cardColor: Colors.blue[700], // Mörkare bakgrund för popup-menyn
                  ),
                  child: PopupMenuButton<String>(
                    color: Colors.blue[100], // Bakgrundsfärg för menyalternativen
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
                          style: TextStyle(fontSize: 18, color: Colors.white), // Vit text
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'undone',
                        child: Text(
                          'Ogjorda',
                          style: TextStyle(fontSize: 18, color: Colors.white), // Vit text
                        ),
                      ),
                    ],
                    icon: const Icon(
                      Icons.filter_list, // Filter-ikon
                      color: Colors.white, // Vit ikonfärg för kontrast
                    ),
                  ),
                ),
              ),
            ),
            const Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  'TIG333 Att Göra', // Titeln centreras
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(), // Tom widget
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white, // Vit bakgrund
      body: ListView.builder(
        itemCount: filteredTodos.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Card(
              elevation: 4, // Skugga för att ge ett tydligt kortutseende
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.blue[900]!, width: 2), // Tydlig kant
              ),
              child: TodoItem(
                todo: filteredTodos[index]["task"],
                isDone: filteredTodos[index]["isDone"],
                onChanged: (bool? value) {
                  setState(() {
                    filteredTodos[index]["isDone"] = value;
                  });
                },
                onDelete: () {
                  setState(() {
                    todos.remove(filteredTodos[index]);
                  });
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[900], // Mörkblå färg för knappen
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTodoScreen(onAdd: (String task) {
              setState(() {
                todos.add({"task": task, "isDone": false});
              });
            })),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TodoItem extends StatelessWidget {
  final String todo;
  final bool isDone;
  final Function(bool?) onChanged;
  final Function onDelete;

  const TodoItem({super.key, required this.todo, required this.isDone, required this.onChanged, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(10), // Lite extra padding för att förbättra läsbarheten
      leading: Checkbox(
        value: isDone,
        onChanged: onChanged,
      ),
      title: Text(
        todo,
        style: TextStyle(
          fontSize: 18, // Tydligare text
          decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red), // Röd ikon för att markera radering
        onPressed: () => onDelete(),
      ),
    );
  }
}

class AddTodoScreen extends StatelessWidget {
  final TextEditingController textController = TextEditingController();
  final Function(String) onAdd;

  AddTodoScreen({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900], // Mörkblå header även här
        leading: const BackButton(),
        title: const Text('TIG333 Att Göra'),
      ),
      backgroundColor: Colors.white, // Vit bakgrund även här
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: 'Vad ska du göra?',
                border: OutlineInputBorder(), // ram runt textfältet
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900], // Mörkblå för knappen
              ),
              onPressed: () {
                String newTodo = textController.text;
                if (newTodo.isNotEmpty) {
                  onAdd(newTodo);
                  Navigator.pop(context);
                }
              },
              child: const Text('+ LÄGG TILL'),
            ),
          ],
        ),
      ),
    );
  }
}