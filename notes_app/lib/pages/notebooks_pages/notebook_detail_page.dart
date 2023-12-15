import 'package:automatic_animated_list/automatic_animated_list.dart';
import 'package:complete_timer/timer/complete_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import '../../../../values.dart';
import '../../db/notes_database.dart';
import '../../model/note.dart';
import '../../model/notebook.dart';
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

class _NoteBookDetailPageState extends State<NoteBookDetailPage>
    with TickerProviderStateMixin {
  late NoteBook noteBook;
  bool isLoading = false;
  late List<Note> notes;
  late List<Note> filteredNotes;
  bool _isListView = false;
  bool isImportant = true;
  bool modifTabIsClosed = true;
  bool noteEditMode = false;
  bool filterTask = true;
  bool filterNote = true;
  late Note _selectedNote;
  double h = 0;
  double noteModifHeigher = 0;
  late CompleteTimer normalTimer;
  late AnimationController _controllerCheckMarker;

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
    if (filterTask && !filterNote) {
      filteredNotes =
          filteredNotes.where((element) => element.isTask == true).toList();
    }
    if (!filterTask && filterNote) {
      filteredNotes =
          filteredNotes.where((element) => element.isTask == false).toList();
    }
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _controllerCheckMarker = AnimationController(vsync: this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    refresh();
    _selectedNote = Note(
        isImportant: false,
        isTask: false,
        isCompleted: false,
        number: 0,
        title: "",
        description: "description",
        notebook: "",
        createdTime: DateTime.now());
    normalTimer = CompleteTimer(
      // must a non-negative Duration.
      duration: const Duration(seconds: 2),
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
          noteModifHeigher = 0;
          noteEditMode = false;
        });
      },
    );
  }

  @override
  void dispose() {
    // NotesDatabase.instance.close();
    normalTimer.cancel();
    _controllerCheckMarker.dispose();
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
        // title: Text(
        //   "NoteBookDetailPage",
        //   style: GoogleFonts.courgette(
        //     fontSize: 18,
        //   ),
        // ),
        actions: [/*editButton(), deleteButton(),*/ bottomPageChoice(context)],
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
                              : filteredNotes.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text('Add Your First Note or Task',
                                              // style: TextStyle(),
                                              style: GoogleFonts.courgette(
                                                  color: pinkColor,
                                                  fontSize: 24)),
                                          Text(
                                              'Tap \'+\' button in bottom right',
                                              // style: TextStyle(),
                                              style: GoogleFonts.courgette(
                                                  color: pinkColor,
                                                  fontSize: 20)),
                                        ],
                                      ),
                                    )
                                  : buildNotesPage(_size),
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
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          enableDrag: true,
          context: ctx,
          builder: (ctx) {
            return StatefulBuilder(
              builder: (BuildContext context,
                  void Function(void Function()) setModalState) {
                return FractionallySizedBox(
                  heightFactor: 0.7,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(5.0),
                        height: 5,
                        width: 100,
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      ListTile(
                        leading:
                            const Icon(Icons.edit_outlined, color: pinkColor),
                        title: const Text(
                          "Edit NoteBook",
                          style: TextStyle(color: pinkColor),
                        ),
                        onTap: () async {
                          if (isLoading) return;

                          await Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => AddEditNoteBookPage(
                                noteBook: noteBook, notes: filteredNotes),
                          ));

                          refresh();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete, color: pinkColor),
                        title: const Text(
                          "Delete NoteBook",
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
                        leading: const Icon(Icons.task, color: pinkColor),
                        trailing: builsSwitcher(filterTask),
                        title: const Text(
                          "Tasks",
                          style: TextStyle(color: pinkColor),
                        ),
                        onTap: () async {
                          if (isLoading) return;
                          setModalState(() {
                            filterTask = !filterTask;
                            !filterTask && !filterNote
                                ? filterNote = !filterNote
                                : filterNote = filterNote;
                          });
                          refresh();
                          // Navigator.of(ctx).pop();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.notes, color: pinkColor),
                        trailing: builsSwitcher(filterNote),
                        title: const Text(
                          "Notes",
                          style: TextStyle(color: pinkColor),
                        ),
                        onTap: () async {
                          setModalState(() {
                            filterNote = !filterNote;
                            !filterTask && !filterNote
                                ? filterTask = !filterTask
                                : filterTask = filterTask;
                          });
                          refresh();
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
              },
            );
          },
        );
      },
    );
  }

  Widget buildListViewAllNotesAnimated(size) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          // h = 50;
          // normalTimer.start();
          // refreshNoteBooks();
          // _countdownTimerController.isRunning;
        });
      },
      child: AutomaticAnimatedList(
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
                  onTap: (() {
                    setState(() {
                      noteModifHeigher == 50
                          ? noteModifHeigher = 0
                          : noteModifHeigher = 50;
                      _selectedNote = item;
                      noteEditMode = !noteEditMode;
                      // modifTabIsClosed = !modifTabIsClosed;
                      normalTimer.start();
                    });
                  }),
                  // onDoubleTap: () async {
                  //   setState(() {
                  //     isImportant = !note.isImportant;
                  //   });
                  //   final nt = note.copy(
                  //     isImportant: isImportant,
                  //   );
                  //   await NotesDatabase.instance.update(nt);
                  //   refreshNoteBooks();
                  // },
                  child: Stack(
                    alignment: AlignmentDirectional.topEnd,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.all(15),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3),
                          border: _selectedNote.id == note.id && noteEditMode
                              ? Border.all(color: Colors.red)
                              : null,
                        ),
                        height: size.height / 7,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(DateFormat.yMMMd()
                                    .format(note.createdTime)),
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
                                  child: Icon(
                                    note.isImportant
                                        ? Icons.star
                                        : Icons.star_border_outlined,
                                    color: note.isImportant
                                        ? Colors.amber
                                        : Colors.pink.withOpacity(0.2),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    note.title,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.courgette(
                                      color: const Color(0xff701B71),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      decoration:
                                          note.isTask && note.isCompleted
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                    ),
                                  ),
                                ),
                                note.isTask
                                    ? note.isCompleted
                                        ? Icon(Icons.check_box,
                                            color:
                                                Colors.green.withOpacity(0.8))
                                        : Icon(
                                            Icons.check_box_outline_blank,
                                            color: Colors.pink.withOpacity(0.2),
                                          )
                                    : Container(),
                              ],
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
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  Widget buildStaggeredGridViewAllNotesAnimated() {
    return Container(
      color: accentPinkColor,
      child: RefreshIndicator(
        onRefresh: () async {
          // setState(() {
          //   h = 50;
          //   normalTimer.start();
          //   // refreshNoteBooks();
          // });
        },
        child: AnimationLimiter(
          child: StaggeredGridView.countBuilder(
            padding: const EdgeInsets.all(0),
            itemCount: filteredNotes.length,
            staggeredTileBuilder: (index) => const StaggeredTile.fit(2),
            crossAxisCount: 4,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            itemBuilder: (context, index) {
              final note = notes[index];
              final color = lightColors[index % lightColors.length];
              final time = DateFormat.yMMMd().format(note.createdTime);
              final minHeight = getMinHeight(index);
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 375),
                columnCount: 2,
                child: ScaleAnimation(
                  child: FadeInAnimation(
                    child: GestureDetector(
                      onTap: (() {
                        setState(() {
                          noteModifHeigher == 50
                              ? noteModifHeigher = 0
                              : noteModifHeigher = 50;
                          _selectedNote = note;
                          noteEditMode = !noteEditMode;
                          // modifTabIsClosed = !modifTabIsClosed;
                          normalTimer.start();
                        });
                      }),
                      // child: NoteCardWidget(note: note, index: index),
                      child: Card(
                        color: color,
                        child: Container(
                          constraints: BoxConstraints(minHeight: minHeight),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: _selectedNote.id == note.id && noteEditMode
                                ? Border.all(color: Colors.red)
                                : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    time,
                                    style:
                                        TextStyle(color: Colors.grey.shade700),
                                  ),
                                  Icon(
                                    Icons.star,
                                    size: 20,
                                    color: note.isImportant
                                        ? Colors.amber
                                        : Colors.grey.shade300,
                                    shadows: const <Shadow>[
                                      Shadow(
                                        blurRadius: 5.0,
                                        color: Colors.white,
                                      ),
                                      Shadow(
                                        offset: Offset(0.0, 0.0),
                                        blurRadius: 8.0,
                                        color: Colors.white,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      note.title,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.courgette(
                                        color: const Color(0xff701B71),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        decoration: note.isCompleted
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                  note.isTask
                                      ? note.isCompleted
                                          ? Icon(Icons.check_box,
                                              color:
                                                  Colors.green.withOpacity(0.8))
                                          : Icon(
                                              Icons.check_box_outline_blank,
                                              color:
                                                  Colors.pink.withOpacity(0.2),
                                            )
                                      : Container(),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                note.description,
                                maxLines: minHeight == 100 ? 2 : 4,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.courgette(
                                    color: const Color.fromARGB(255, 62, 4, 71),
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  double getMinHeight(int index) {
    switch (index % 4) {
      case 0:
        return 100;
      case 1:
        return 150;
      case 2:
        return 150;
      case 3:
        return 100;
      default:
        return 100;
    }
  }

  Widget buildNotesPage(size) {
    return Column(
      children: [
        notes.isEmpty
            ? Container()
            : AnimatedContainer(
                duration: const Duration(seconds: 1),
                curve: Curves.fastOutSlowIn,
                height: noteModifHeigher,
                color: accentPinkColor,
                onEnd: (() {
                  setState(() {
                    modifTabIsClosed = !modifTabIsClosed;
                  });
                }),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // if (!modifTabIsClosed || noteModifHeigher > 0)
                    IconButton(
                        icon: const Icon(
                          Icons.description_sharp,
                          color: pinkColor,
                        ),
                        onPressed: () async {
                          setState(() {
                            noteModifHeigher = 0;
                          });
                          if (isLoading) return;
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  NoteDetailPage(noteId: _selectedNote.id!),
                            ),
                          );
                          refresh();
                        }),
                    // onTap: () async {
                    //   await Navigator.of(context).push(
                    //     MaterialPageRoute(
                    //       builder: (context) =>
                    //           NoteDetailPage(noteId: note.id!),
                    //     ),
                    //   );
                    //   refreshNoteBooks();
                    // },
                    const VerticalDivider(
                      indent: 7,
                      endIndent: 7,
                    ),
                    IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: pinkColor,
                        ),
                        onPressed: () async {
                          setState(() {
                            noteModifHeigher = 0;
                          });
                          if (isLoading) return;
                          await Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                AddEditNotePage(note: _selectedNote),
                          ));
                          refresh();
                        }),
                    const VerticalDivider(
                      indent: 7,
                      endIndent: 7,
                    ),
                    // if (!modifTabIsClosed || noteModifHeigher > 0)
                    IconButton(
                      icon: _selectedNote.isImportant
                          ? const Icon(
                              Icons.star,
                              color: Colors.amber,
                            )
                          : const Icon(
                              Icons.star_border_outlined,
                              color: pinkColor,
                            ),
                      onPressed: (() async {
                        await showDialog<void>(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              content: Container(
                                color: Colors.transparent,
                                child: Lottie.asset(
                                  _selectedNote.isImportant
                                      ? "assets/animations/cancel.json"
                                      : "assets/animations/star.json",
                                  controller: _controllerCheckMarker,
                                  onLoaded: (composition) {
                                    // Configure the AnimationController with the duration of the
                                    // Lottie file and start the animation.
                                    _controllerCheckMarker
                                      ..duration = composition.duration
                                      ..forward().whenComplete(
                                          () => Navigator.of(context).pop());
                                  },
                                ),
                              ),
                            );
                          },
                        );
                        setState(() {
                          _controllerCheckMarker.reverse();
                          noteModifHeigher = 0;
                          isImportant = !_selectedNote.isImportant;
                        });
                        final nt = _selectedNote.copy(
                          isImportant: isImportant,
                        );
                        await NotesDatabase.instance.update(nt);
                        refresh();
                      }),
                    ),
                    if (_selectedNote.isTask)
                      const VerticalDivider(
                        indent: 7,
                        endIndent: 7,
                      ),
                    if (_selectedNote.isTask)
                      IconButton(
                        icon: _selectedNote.isCompleted
                            ? Icon(
                                Icons.check_box,
                                color: Colors.green.withOpacity(0.8),
                              )
                            : const Icon(
                                Icons.check,
                                color: pinkColor,
                              ),
                        onPressed: (() async {
                          await showDialog<void>(
                            barrierColor: Colors.transparent,
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                content: Container(
                                  color: Colors.transparent,
                                  child: Lottie.asset(
                                    _selectedNote.isCompleted
                                        ? "assets/animations/cancel.json"
                                        : "assets/animations/checkmark.json",
                                    controller: _controllerCheckMarker,
                                    onLoaded: (composition) {
                                      _controllerCheckMarker
                                        ..duration = composition.duration
                                        ..forward().whenComplete(
                                            () => Navigator.of(context).pop());
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                          setState(() {
                            _controllerCheckMarker.reverse();
                            noteModifHeigher = 0;
                            isImportant = !_selectedNote.isCompleted;
                          });
                          final nt = _selectedNote.copy(
                            isCompleted: isImportant,
                          );
                          await NotesDatabase.instance.update(nt);
                          refresh();
                        }),
                      ),
                    const VerticalDivider(
                      indent: 7,
                      endIndent: 7,
                    ),
                    // if (!modifTabIsClosed || noteModifHeigher > 0)
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: pinkColor,
                      ),
                      onPressed: () async {
                        await showDialog<void>(
                          barrierColor: Colors.transparent,
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              content: Container(
                                color: Colors.transparent,
                                child: Lottie.asset(
                                  "assets/animations/delete.json",
                                  controller: _controllerCheckMarker,
                                  onLoaded: (composition) {
                                    // Configure the AnimationController with the duration of the
                                    // Lottie file and start the animation.
                                    _controllerCheckMarker
                                      ..duration = composition.duration
                                      ..forward().whenComplete(
                                          () => Navigator.of(context).pop());
                                  },
                                ),
                              ),
                            );
                          },
                        );
                        setState(() {
                          _controllerCheckMarker.reverse();
                          noteModifHeigher = 0;
                        });
                        await NotesDatabase.instance.delete(_selectedNote.id!);
                        refresh();
                      },
                    ),
                  ],
                ),
              ),
        Expanded(
          child: Center(
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
                    : _isListView
                        ? buildListViewAllNotesAnimated(size)
                        : buildStaggeredGridViewAllNotesAnimated(),
          ),
        ),
      ],
    );
  }

  Widget builsSwitcher(bool filterActivation) {
    double wd = 50;
    double ht = 20;
    return Stack(alignment: AlignmentDirectional.centerStart, children: [
      Container(
        height: ht,
        width: wd,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color:
              filterActivation ? accentPinkColor : Colors.grey.withOpacity(0.5),
        ),
      ),
      TweenAnimationBuilder(
        duration: const Duration(milliseconds: 300),
        tween: Tween<Offset>(
            begin: const Offset(0, 0),
            end: Offset(filterActivation ? (wd / 2) : 0, 0.0)),
        builder: (BuildContext context, Offset value, Widget? child) {
          Size s = MediaQuery.of(context).size;
          return Transform.translate(
            offset: value,
            child: Container(
              height: ht,
              width: (wd / 2),
              decoration: BoxDecoration(
                color: pinkColor,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          );
        },
      ),
    ]);
  }
}
