import 'package:automatic_animated_list/automatic_animated_list.dart';
import 'package:complete_timer/complete_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/values.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import 'package:notes_app/values.dart';

import '../../db/notes_database.dart';
import '../../model/note.dart';
import '../../model/notebook.dart';
import '../../widegt/note_card_widget.dart';
import '../notes_pages/edit_note_page.dart';
import '../notes_pages/note_detail_page.dart';
import 'edit_notebook_page.dart';
import 'notebook_card_page.dart';
import 'notebook_detail_page.dart';

class NoteBooksPages extends StatefulWidget {
  @override
  _NoteBooksPagesState createState() => _NoteBooksPagesState();
}

class _NoteBooksPagesState extends State<NoteBooksPages>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late List<NoteBook> notebooks;
  late List<Note> notes;
  late List<Note> sortedNotes;
  double h = 0;
  bool isLoading = false;
  bool isListView = true;
  bool isImportant = true;
  late CompleteTimer normalTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    refreshNoteBooks();
    normalTimer = CompleteTimer(
      // must a non-negative Duration.
      duration: const Duration(seconds: 3),
      // If periodic sets true
      // The callback is invoked repeatedly with duration intervals until
      // canceled with the cancel function.
      // Defaults to false.
      periodic: false,
      // If autoStart sets true timer starts automatically, default to true.
      autoStart: false,
      // The callback function is invoked after the given duration.
      callback: (timer) {
        timer.stop();
        setState(() {
          h = 0;
        });
      },
    );
  }

  @override
  void dispose() {
    NotesDatabase.instance.close();
    _tabController.dispose();
    normalTimer.cancel();
    super.dispose();
  }

  Future refreshNoteBooks() async {
    setState(() => isLoading = true);
    notebooks = await NotesDatabase.instance.readAllNoteBooks();
    notes = await NotesDatabase.instance.readAllNotes();
    for (int i = 0; i < notes.length; i++) {
      if (notes[i].isImportant) {
        notes = rearrange(notes[i]);
      }
    }
    // sortedNotes = notes.sort((a, b) => a.number.compareTo(b.number));
    setState(() => isLoading = false);
  }

  List<Note> rearrange(Note input) {
    notes.remove(input);
    notes.insert(0, input);
    return notes;
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: accentPinkColor,
      appBar: AppBar(
        leading: const Icon(
          Icons.menu,
          color: plumColor,
        ),
        backgroundColor: accentPinkColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Text(
              "All",
              style: GoogleFonts.courgette(color: plumColor, fontSize: 22),
            ),
            Text(
              "NoteBooks",
              style: GoogleFonts.courgette(color: plumColor, fontSize: 22),
            )
          ],
        ),
        title: const Center(
          child: Text(
            'KS NoteBook',
            style: TextStyle(
                fontSize: 35, color: plumColor, fontFamily: "Valid_Harmony"),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              if (_tabController.index == 0) {
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const AddEditNotePage()));
              } else {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const AddEditNoteBookPage()),
                );
              }
              refreshNoteBooks();
            },
            child: const Icon(
              Icons.add,
              size: 32,
              color: plumColor,
            ),
          ),
          const SizedBox(width: 12)
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              curve: Curves.fastOutSlowIn,
              height: h,
              color: accentPinkColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        isListView = true;
                      });
                    },
                    child: Container(
                      height: 50,
                      width: (_size.width / 2) - 8,
                      child: Center(
                        child: Text(
                          "List View",
                          style: GoogleFonts.courgette(
                            fontSize: 18,
                            shadows: isListView
                                ? <Shadow>[
                                    const Shadow(
                                      blurRadius: 10.0,
                                      color: pinkColor,
                                    ),
                                    const Shadow(
                                      offset: Offset(0.0, 0.0),
                                      blurRadius: 8.0,
                                      color: pinkColor,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  VerticalDivider(),
                  InkWell(
                    onTap: () {
                      setState(() {
                        isListView = false;
                      });
                    },
                    child: Container(
                      height: 50,
                      width: (_size.width / 2) - 8,
                      child: Center(
                        child: Text(
                          "Grid View",
                          style: GoogleFonts.courgette(
                            fontSize: 18,
                            shadows: !isListView
                                ? <Shadow>[
                                    const Shadow(
                                      offset: Offset(0.0, 0.0),
                                      blurRadius: 10.0,
                                      color: pinkColor,
                                    ),
                                    const Shadow(
                                      offset: Offset(0.0, 0.0),
                                      blurRadius: 8.0,
                                      color: pinkColor,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: TabBarView(controller: _tabController, children: [
                      // isListView
                      //     ? buildListViewAllNotesAnimated(_size)
                      //     : buildStaggeredGridViewAllNotesAnimated(),
                      buildNotesPage(_size),
                      buildNoteBooksPage()
                    ]),
                  ),
          ],
        ),
      ),
    );
  }

  Widget buildNoteBooksPage() {
    return Center(
      child: isLoading
          ? const CircularProgressIndicator()
          : notebooks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Add Your First NoteBook',
                          // style: TextStyle(),
                          style: GoogleFonts.courgette(
                              color: pinkColor, fontSize: 24)),
                      Text('Tap \'+\' button in top right',
                          // style: TextStyle(),
                          style: GoogleFonts.courgette(
                              color: pinkColor, fontSize: 20)),
                    ],
                  ),
                )
              : buildNoteBooks(),
    );
  }

  Widget buildNotesPage(size) {
    return Center(
      child: isLoading
          ? const CircularProgressIndicator()
          : notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Add Your First Note or Task',
                          // style: TextStyle(),
                          style: GoogleFonts.courgette(
                              color: pinkColor, fontSize: 24)),
                      Text('Tap \'+\' button in top right',
                          // style: TextStyle(),
                          style: GoogleFonts.courgette(
                              color: pinkColor, fontSize: 20)),
                    ],
                  ),
                )
              : isListView
                  ? buildListViewAllNotesAnimated(size)
                  : buildStaggeredGridViewAllNotesAnimated(),
    );
  }

  Widget buildNoteBooks() {
    return StaggeredGridView.countBuilder(
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

  Widget buildListViewAllNotes(size) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          h = 50;
          normalTimer.start();
          refreshNoteBooks();
          // _countdownTimerController.isRunning;
        });
      },
      child: ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return GestureDetector(
              onDoubleTap: (() async {
                setState(() {
                  isImportant = !note.isImportant;
                });
                final nt = note.copy(
                  isImportant: isImportant,
                );
                await NotesDatabase.instance.update(nt);
                refreshNoteBooks();
              }),
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => NoteDetailPage(noteId: note.id!),
                  ),
                );
                refreshNoteBooks();
              },
              child: Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5)),
                height: size.height / 7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat.yMMMd().format(note.createdTime)),
                        Icon(
                          Icons.star,
                          color: note.isImportant
                              ? Colors.amber
                              : Colors.grey.shade100,
                        )
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      note.title,
                      style: GoogleFonts.courgette(
                        color: Color(0xff701B71),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      note.description,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.courgette(
                        color: Color.fromARGB(255, 62, 4, 71),
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Widget buildListViewAllNotesAnimated(size) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          h = 50;
          normalTimer.start();
          refreshNoteBooks();
          // _countdownTimerController.isRunning;
        });
      },
      child: AutomaticAnimatedList(
          items: notes,
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
                    refreshNoteBooks();
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
                          refreshNoteBooks();
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
                          refreshNoteBooks();
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
          }),
    );
  }

  Widget buildStaggeredGridViewAllNotes() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          h = 50;
          normalTimer.start();
          refreshNoteBooks();
        });
      },
      child: StaggeredGridView.countBuilder(
        padding: const EdgeInsets.all(0),
        itemCount: notes.length,
        staggeredTileBuilder: (index) => const StaggeredTile.fit(2),
        crossAxisCount: 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        itemBuilder: (context, index) {
          final note = notes[index];

          return GestureDetector(
            onDoubleTap: () async {
              setState(() {
                isImportant = !note.isImportant;
              });
              final nt = note.copy(
                isImportant: isImportant,
              );
              await NotesDatabase.instance.update(nt);
              refreshNoteBooks();
            },
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NoteDetailPage(noteId: note.id!),
              ));
              refreshNoteBooks();
            },
            child: NoteCardWidget(note: note, index: index),
          );
        },
      ),
    );
  }

  Widget buildStaggeredGridViewAllNotesAnimated() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          h = 50;
          normalTimer.start();
          refreshNoteBooks();
        });
      },
      child: AnimationLimiter(
        child: StaggeredGridView.countBuilder(
          padding: const EdgeInsets.all(0),
          itemCount: notes.length,
          staggeredTileBuilder: (index) => const StaggeredTile.fit(2),
          crossAxisCount: 4,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          itemBuilder: (context, index) {
            final note = notes[index];

            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 375),
              columnCount: 2,
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: GestureDetector(
                    onDoubleTap: (() async {
                      setState(() {
                        isImportant = !note.isImportant;
                      });
                      final nt = note.copy(
                        isImportant: isImportant,
                      );
                      await NotesDatabase.instance.update(nt);
                      refreshNoteBooks();
                    }),
                    onTap: () async {
                      await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => NoteDetailPage(noteId: note.id!),
                      ));
                      refreshNoteBooks();
                    },
                    child: NoteCardWidget(note: note, index: index),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
