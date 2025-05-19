import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/note.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(NoteAdapter());
  await Hive.openBox<Note>('notes');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notes',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: NotesPage(),
    );
  }
}

class NotesPage extends StatelessWidget {
  final Box<Note> noteBox = Hive.box<Note>('notes');

  void _addNoteDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('New Note', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: 'Content',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.deepPurple.shade300),
            ),
          ),
          TextButton(
            onPressed: () {
              final title = titleController.text;
              final content = contentController.text;
              if (title.isNotEmpty && content.isNotEmpty) {
                noteBox.add(Note(title: title, content: content));
              }
              Navigator.pop(context);
            },
            child: Text(
              'Save',
              style: TextStyle(color: Colors.pinkAccent.shade100),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade200, Colors.deepPurple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('My Notes', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.blueAccent.shade100,
                Colors.purple.shade300,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: FloatingActionButton(
            backgroundColor: Colors.transparent,
            elevation: 0,
            onPressed: () => _addNoteDialog(context),
            child: Icon(Icons.add, color: Colors.white),
          ),
        ),

          body: ValueListenableBuilder(
            valueListenable: noteBox.listenable(),
            builder: (context, Box<Note> box, _) {
              if (box.values.isEmpty) {
                return Center(
                  child: Text('No notes yet.', style: GoogleFonts.poppins(fontSize: 18)),
                );
              }
              return SingleChildScrollView(
                child: Column(
                  children: box.values.map((note) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.purple.shade50,
                              Colors.pink.shade100,
                              Colors.purple.shade200,
                              Colors.pinkAccent.shade100,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            stops: [0.0, 0.3, 0.5, 0.7, 1.0],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.3),
                              offset: Offset(0, 6),
                              blurRadius: 12,
                            ),
                            BoxShadow(
                              color: Colors.pinkAccent.withOpacity(0.15),
                              offset: Offset(4, 8),
                              blurRadius: 25,
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(note.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          subtitle: Text(note.content, style: GoogleFonts.poppins()),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Color(0xFFF43662)),
                            onPressed: () => note.delete(),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
      ),
    );
  }
}
