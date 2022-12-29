import 'package:automatic_animated_list/automatic_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
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
  late List<Note> filteredNotes;
  bool _isListView = true;
  bool isImportant = true;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future refresh() async {
    setState(() => isLoading = true);
    noteBook = await NotesDatabase.instance.readNoteBook(widget.notebookId);
    notes = await NotesDatabase.instance.readAllNotes();
    filteredNotes =
        notes.where((element) => element.notebook == noteBook.title).toList();
    for (int i = 0; i < filteredNotes.length; i++) {
      if (filteredNotes[i].isImportant) {
        filteredNotes = rearrange(filteredNotes[i]);
      }
    }
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    // NotesDatabase.instance.close();
    super.dispose();
  }

  List<Note> rearrange(Note input) {
    filteredNotes.remove(input);
    filteredNotes.insert(0, input);
    return filteredNotes;
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: accentPinkColor,

      appBar: AppBar(
        backgroundColor: accentPinkColor,
        foregroundColor: pinkColor,
        elevation: 0,
        title: Text(
          "NoteBookDetailPage",
          style: GoogleFonts.courgette(
            fontSize: 18,
          ),
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
                            color: Color.fromARGB(255, 255, 165, 209),
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
                                  style: GoogleFonts.courgette(
                                    color: Color(0xff701B71),
                                    fontSize: 30,
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
                                  : _isListView
                                      ? buildListViewAllNotesAnimated(_size)
                                      : buildNotesGridView(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: pinkColor,
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => AddEditNotePage(
                      noteBook: noteBook,
                    )),
          );

          refresh();
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

        refresh();
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
                heightFactor: 0.4,
                child: Column(
                  children: [
                    ListTile(
                      leading:
                          const Icon(Icons.edit_outlined, color: pinkColor),
                      title: const Text(
                        "Edit",
                        style: TextStyle(color: pinkColor),
                      ),
                      onTap: () async {
                        if (isLoading) return;

                        await Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) =>
                              AddEditNoteBookPage(noteBook: noteBook),
                        ));

                        refresh();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete, color: pinkColor),
                      title: const Text(
                        "Delete",
                        style: TextStyle(color: pinkColor),
                      ),
                      onTap: () async {
                        await NotesDatabase.instance
                            .deleteNoteBook(widget.notebookId);
                        await Navigator.of(ctx)
                            .pushReplacement(MaterialPageRoute(
                          builder: (ctx) => NoteBooksPages(),
                        ));
                        Navigator.of(ctx).pop();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.list, color: pinkColor),
                      title: Text(
                        _isListView ? "Grid View" : "List View",
                        style: TextStyle(color: pinkColor),
                      ),
                      onTap: () async {
                        setState(() {
                          _isListView = !_isListView;
                        });
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
              );
            });
      },
    );
  }

  Widget buildNotesGridView() {
    return StaggeredGridView.countBuilder(
      padding: const EdgeInsets.all(0),
      itemCount: filteredNotes.length,
      staggeredTileBuilder: (index) => const StaggeredTile.fit(2),
      crossAxisCount: 4,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      itemBuilder: (context, index) {
        final note = filteredNotes[index];

        return GestureDetector(
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => NoteDetailPage(noteId: note.id!),
            ));
            refresh();
          },
          child: NoteCardWidget(note: note, index: index),
        );
      },
    );
  }

  Widget buildNotesListView(size) {
    return ListView.builder(
        itemCount: filteredNotes.length,
        itemBuilder: (context, index) {
          final note = filteredNotes[index];
          return GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NoteDetailPage(noteId: note.id!),
                ),
              );
              refresh();
            },
            child: Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(5)),
              height: size.height / 7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat.yMMMd().format(note.createdTime)),
                  SizedBox(height: 4),
                  Text(
                    note.title,
                    style: const TextStyle(
                        color: Color(0xff701B71),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Valid_Harmony"),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    note.description,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 62, 4, 71),
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        fontFamily: "Valid_Harmony"),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget buildListViewAllNotesAnimated(size) {
    return AutomaticAnimatedList(
        items: filteredNotes,
        insertDuration: const Duration(seconds: 1),
        removeDuration: const Duration(seconds: 1),
        keyingFunction: (Note item) => Key(item.id.toString()),
        itemBuilder:
            (BuildContext context, Note item, Animation<double> animation) {
          final note = item;
          return FadeTransition(
            key: Key(item.id.toString()),
            opacity: animation,
            child: SizeTransition(
              sizeFactor: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
                reverseCurve: Curves.easeIn,
              ),
              child: GestureDetector(
                onDoubleTap: () async {
                  setState(() {
                    isImportant = !note.isImportant;
                  });
                  final nt = note.copy(
                    isImportant: isImportant,
                  );
                  await NotesDatabase.instance.update(nt);
                  refresh();
                },
                child: Stack(
                  alignment: AlignmentDirectional.topEnd,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                NoteDetailPage(noteId: note.id!),
                          ),
                        );
                        refresh();
                      },
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.all(15),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5)),
                        height: size.height / 7,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat.yMMMd().format(note.createdTime)),
                            const SizedBox(height: 4),
                            Text(
                              note.title,
                              style: GoogleFonts.courgette(
                                color: const Color(0xff701B71),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              note.description,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: GoogleFonts.courgette(
                                color: Color.fromARGB(255, 62, 4, 71),
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          isImportant = !note.isImportant;
                        });
                        final nt = note.copy(
                          isImportant: isImportant,
                        );
                        await NotesDatabase.instance.update(nt);
                        refresh();
                      },
                      child: Container(
                        height: 70,
                        width: 70,
                        // color: Colors.red,
                        child: Icon(
                          Icons.star,
                          color: note.isImportant
                              ? Colors.amber
                              : Colors.grey.shade100,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
