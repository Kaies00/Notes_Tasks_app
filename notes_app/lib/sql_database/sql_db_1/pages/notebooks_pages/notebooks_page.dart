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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: accentPinkColor,
      appBar: AppBar(
        leading: Icon(
          Icons.menu,
          color: plumColor,
        ),
        backgroundColor: accentPinkColor,
        elevation: 0,
        title: Center(
          child: Text(
            'Note Books',
            style: TextStyle(
                fontSize: 35, color: plumColor, fontFamily: "Valid_Harmony"),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const AddEditNoteBookPage()),
              );

              refreshNoteBooks();
            },
            child: Icon(
              Icons.add,
              size: 32,
              color: plumColor,
            ),
          ),
          const SizedBox(width: 12)
        ],
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
    );
  }

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
