import 'package:flutter/material.dart';

void main() {
  runApp(TodoApp());
}

// Huvudklass
class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TIG333 Att Göra',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: TodoListScreen(), // Startskärmen är TodoListScreen
    );
  }
}

// Skärm som visar att göra-listan
class TodoListScreen extends StatelessWidget {
  // Statisk lista över att göra-uppgifter
  final List<String> todos = [
    "Läsa en bok",
    "Göra inlämning",
    "Städa",
    "Gym",
    "Powernap",
    "Handla",
    "Ha kul",
    "Gibb"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Bakgrundsfärgen på skärmen sätts till vit
      appBar: AppBar(
        backgroundColor: Colors.indigo[900], // Mörkblå bakgrundsfärg för AppBar
        title: Text('TIG333 Att Göra'), // Titel på appbaren
        actions: [
          // Popupmeny för att välja filtrering
          PopupMenuButton<String>(
            onSelected: (String result) {
              // Här kan filtreringslogik implementeras
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'all',
                child: Text('Alla'), // Val för att visa alla uppgifter
              ),
              const PopupMenuItem<String>(
                value: 'done',
                child: Text('Gjorda'), // Val för att visa bara gjorda uppgifter
              ),
              const PopupMenuItem<String>(
                value: 'undone',
                child: Text('Ogjorda'), // Val för att visa bara ogjorda uppgifter
              ),
            ],
          ),
        ],
      ),
      // Lista över uppgifter
      body: ListView.builder(
        itemCount: todos.length, // Antal uppgifter i listan
        itemBuilder: (context, index) {
          // Skapar en TodoItem för varje uppgift
          return TodoItem(todo: todos[index], isDone: index == 2); 
          // Markera "Städa" som gjord (index 2)
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // När man trycker på + knappen öppnas en ny skärm för att lägga till uppgift
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTodoScreen()),
          );
        },
        child: Icon(Icons.add), // Plus-ikon för att lägga till nya uppgifter
      ),
    );
  }
}

// Visuellt element för en enskild att göra-uppgift
class TodoItem extends StatelessWidget {
  final String todo; // Namnet på uppgiften
  final bool isDone; // Om uppgiften är klar eller inte

  TodoItem({required this.todo, this.isDone = false}); // Konstruktor

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: isDone, // Checkbox för att markera om uppgiften är klar
        onChanged: (bool? value) {
          // Här kan logik för att markera som klar implementeras
        },
      ),
      title: Text(
        todo, // Visar uppgiftens namn
        style: TextStyle(
          decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
          // Stryker över text om uppgiften är klar
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete), // Soptunneikon för att ta bort uppgiften
        onPressed: () {
          // Här kan logik för att ta bort uppgift implementeras
        },
      ),
    );
  }
}

// Skärm för att lägga till nya uppgifter
class AddTodoScreen extends StatelessWidget {
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Sätter bakgrundsfärgen till vit även här
      appBar: AppBar(
        backgroundColor: Colors.indigo[900], // Mörkblå bakgrundsfärg för AppBar
        leading: BackButton(), // Tillbaka-knapp i appbaren
        title: Text('TIG333 Att Göra'), // Titel på appbaren
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Textfält för att skriva in en ny uppgift
            TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'Vad ska du göra?', // Plats för input från användaren
              ),
            ),
            SizedBox(height: 20), // Tomt utrymme mellan textfältet och knappen
            ElevatedButton(
              onPressed: () {
                // Här kan logik för att lägga till en ny uppgift implementeras
              },
              child: Text('+ LÄGG TILL'), // Text på knappen
            ),
          ],
        ),
      ),
    );
  }
}