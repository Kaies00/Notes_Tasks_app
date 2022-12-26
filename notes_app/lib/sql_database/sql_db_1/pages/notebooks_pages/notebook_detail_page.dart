import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import '../../../../values.dart';
import '../../db/notes_database.dart';
import '../../model/note.dart';
import '../../model/notebook.dart';
import '../../widegt/note_card_widget.dart';
import '../notes_pages/edit_note_page.dart';
import '../notes_pages/note_detail_page.dart';
import 'edit_notebook_page.dart';
import 'notebooks_page.dart';

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
  late List<Note> notes;

  @override
  void initState() {
    super.initState();
    refreshNoteBook();
    refreshNotes();
  }

  Future refreshNoteBook() async {
    setState(() => isLoading = true);
    this.noteBook =
        await NotesDatabase.instance.readNoteBook(widget.notebookId);
    this.notes = await NotesDatabase.instance.readAllNotes();
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    // NotesDatabase.instance.close();
    super.dispose();
  }

  Future refreshNotes() async {
    setState(() => isLoading = true);

    this.notes = await NotesDatabase.instance.readAllNotes();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "NoteBookDetailPage",
          style: TextStyle(fontFamily: "Valid_Harmony"),
        ),
        actions: [editButton(), deleteButton(), bottomPageChoice(context)],
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.black,
      //   child: const Icon(Icons.add),
      //   onPressed: () async {
      //     await Navigator.of(context).push(
      //       MaterialPageRoute(builder: (context) => const AddEditNotePage()),
      //     );
      //     refreshNotes();
      //   },
      // ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                height: double.infinity,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: _size.height / 8,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                            color: aColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Hero(
                              tag: noteBook.image,
                              child: Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                      image: AssetImage(noteBook.image),
                                      fit: BoxFit.fill),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  noteBook.title,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Valid_Harmony",
                                    fontSize: 32,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  DateFormat.yMMMd()
                                      .format(noteBook.createdTime),
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        child: Center(
                          child: isLoading
                              ? const CircularProgressIndicator()
                              : notes.isEmpty
                                  ? Column(
                                      children: const [
                                        Text(
                                          'Add Your First Note',
                                          style: TextStyle(
                                              color: Colors.purple,
                                              fontSize: 24),
                                        ),
                                      ],
                                    )
                                  : buildNotes(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => AddEditNotePage(
                      noteBook: noteBook,
                    )),
          );

          refreshNotes();
        },
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

        refreshNoteBook();
      });

  Widget deleteButton() => IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () async {
          await NotesDatabase.instance.deleteNoteBook(widget.notebookId);

          Navigator.of(context).pop();
        },
      );
  Widget bottomPageChoice(ctx) {
    return IconButton(
      icon: const Icon(FontAwesomeIcons.ellipsisVertical),
      onPressed: () async {
        showModalBottomSheet(
            isDismissible: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            enableDrag: true,
            context: ctx,
            builder: (ctx) {
              return FractionallySizedBox(
                heightFactor: 0.25,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text("edit"),
                      onTap: () async {
                        if (isLoading) return;

                        await Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) =>
                              AddEditNoteBookPage(noteBook: noteBook),
                        ));

                        refreshNoteBook();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.delete),
                      title: Text("Delete"),
                      onTap: () async {
                        await NotesDatabase.instance
                            .deleteNoteBook(widget.notebookId);
                        await Navigator.of(ctx)
                            .pushReplacement(MaterialPageRoute(
                          builder: (ctx) => NoteBooksPages(),
                        ));
                        Navigator.of(ctx).pop();
                      },
                    )
                  ],
                ),
              );
            });
      },
    );
  }

  Widget buildNotes() => StaggeredGridView.countBuilder(
        padding: const EdgeInsets.all(0),
        itemCount: notes.length,
        staggeredTileBuilder: (index) => const StaggeredTile.fit(2),
        crossAxisCount: 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        itemBuilder: (context, index) {
          final note = notes[index];

          return GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NoteDetailPage(noteId: note.id!),
              ));
              refreshNotes();
            },
            child: NoteCardWidget(note: note, index: index),
          );
        },
      );
}
