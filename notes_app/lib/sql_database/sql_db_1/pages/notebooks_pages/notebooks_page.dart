import 'package:flutter/material.dart';
import 'package:notes_app/values.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import 'package:notes_app/values.dart';

import '../../db/notes_database.dart';
import '../../model/notebook.dart';
import 'edit_notebook_page.dart';
import 'notebook_card_page.dart';
import 'notebook_detail_page.dart';

class NoteBooksPages extends StatefulWidget {
  @override
  _NoteBooksPagesState createState() => _NoteBooksPagesState();
}

class _NoteBooksPagesState extends State<NoteBooksPages> {
  late List<NoteBook> notebooks;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshNoteBooks();
  }

  @override
  void dispose() {
    NotesDatabase.instance.close();

    super.dispose();
  }

  Future refreshNoteBooks() async {
    setState(() => isLoading = true);

    this.notebooks = await NotesDatabase.instance.readAllNoteBooks();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'notebooks',
            style: const TextStyle(fontSize: 24),
          ),
          actions: [const Icon(Icons.search), const SizedBox(width: 12)],
        ),
        body: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : notebooks.isEmpty
                  ? Column(
                      children: const [
                        Text(
                          'Add Your First NoteBook',
                          style: TextStyle(color: Colors.purple, fontSize: 24),
                        ),
                      ],
                    )
                  : buildNoteBooks(),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          child: const Icon(Icons.add),
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => const AddEditNoteBookPage()),
            );

            refreshNoteBooks();
          },
        ),
      );

  Widget buildNoteBooks() => StaggeredGridView.countBuilder(
        padding: const EdgeInsets.all(8),
        itemCount: notebooks.length,
        staggeredTileBuilder: (index) => const StaggeredTile.fit(2),
        crossAxisCount: 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        itemBuilder: (context, index) {
          final notebook = notebooks[index];

          return GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    NoteBookDetailPage(notebookId: notebook.id!),
              ));
              refreshNoteBooks();
            },
            child: NoteBookCardWidget(noteBook: notebook, index: index),
          );
        },
      );
}
