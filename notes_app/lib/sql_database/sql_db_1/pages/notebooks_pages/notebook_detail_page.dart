import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../db/notes_database.dart';
import '../../model/notebook.dart';
import 'edit_notebook_page.dart';

class NoteBookDetailPage extends StatefulWidget {
  final int notebookId;
  const NoteBookDetailPage({
    Key? key,
    required this.notebookId,
  }) : super(key: key);

  @override
  _NoteBookDetailPageState createState() => _NoteBookDetailPageState();
}

class _NoteBookDetailPageState extends State<NoteBookDetailPage> {
  late NoteBook noteBook;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshNote();
  }

  Future refreshNote() async {
    setState(() => isLoading = true);

    this.noteBook =
        await NotesDatabase.instance.readNoteBook(widget.notebookId);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("NoteBookDetailPage"),
        actions: [editButton(), deleteButton()],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                height: double.infinity,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: _size.height / 4,
                      child: Image(
                        image: AssetImage(noteBook.image),
                      ),
                    ),
                    Text(
                      noteBook.title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat.yMMMd().format(noteBook.createdTime),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
    );
  }

  Widget editButton() => IconButton(
      icon: const Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditNoteBookPage(noteBook: noteBook),
        ));

        refreshNote();
      });

  Widget deleteButton() => IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () async {
          await NotesDatabase.instance.deleteNoteBokk(widget.notebookId);

          Navigator.of(context).pop();
        },
      );
}
