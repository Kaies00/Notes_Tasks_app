import 'package:automatic_animated_list/automatic_animated_list.dart';
import 'package:complete_timer/complete_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:notes_app/values.dart';
import 'package:pay/pay.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import '../../db/notes_database.dart';
import '../../model/note.dart';
import '../../model/notebook.dart';
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
  late AnimationController _controllerCheckMarker;
  late List<NoteBook> notebooks;
  late List<Note> notes;
  late List<Note> sortedNotes;
  late Note _selectedNote;
  double h = 0;
  double noteModifHeigher = 0;
  bool isLoading = false;
  bool isListView = false;
  bool isImportant = true;
  bool modifTabIsClosed = true;
  bool noteEditMode = false;
  bool filterTask = true;
  bool filterNote = true;
  late CompleteTimer normalTimer;

  @override
  void initState() {
    super.initState();
    _controllerCheckMarker = AnimationController(vsync: this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    _tabController = TabController(vsync: this, length: 2);
    refreshNoteBooks();
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
    NotesDatabase.instance.close();
    _tabController.dispose();
    normalTimer.cancel();
    _controllerCheckMarker.dispose();
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
    if (filterTask && !filterNote) {
      notes = notes.where((element) => element.isTask == true).toList();
    }
    if (!filterTask && filterNote) {
      notes = notes.where((element) => element.isTask == false).toList();
    }

    // sortedNotes = notes.sort((a, b) => a.number.compareTo(b.number));
    setState(() => isLoading = false);
  }

  List<Note> rearrange(Note input) {
    notes.remove(input);
    notes.insert(0, input);
    return notes;
  }

  void onGooglePayResult(paymentResult) {
    debugPrint(paymentResult.toString());
  }

  void onApplePayResult(paymentResult) {
    debugPrint(paymentResult.toString());
  }

  final List<PaymentItem> _paymentItems = [
    const PaymentItem(
      label: 'Total',
      amount: '99.99',
      status: PaymentItemStatus.final_price,
    )
  ];
  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: accentPinkColor,
      appBar: AppBar(
        leading: bottomPageMenu(context),
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
            'Notes & Tasks',
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
                  const VerticalDivider(),
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
                          refreshNoteBooks();
                        }),
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
                          refreshNoteBooks();
                        }),
                    const VerticalDivider(
                      indent: 7,
                      endIndent: 7,
                    ),
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
                        refreshNoteBooks();
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
                          refreshNoteBooks();
                        }),
                      ),
                    const VerticalDivider(
                      indent: 7,
                      endIndent: 7,
                    ),
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
                        refreshNoteBooks();
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
                                style: GoogleFonts.courgette(
                                    color: pinkColor, fontSize: 24)),
                            Text('Tap \'+\' button in top right',
                                style: GoogleFonts.courgette(
                                    color: pinkColor, fontSize: 20)),
                          ],
                        ),
                      )
                    : isListView
                        ? buildListViewAllNotesAnimated(size)
                        : buildStaggeredGridViewAllNotesAnimated(),
          ),
        ),
      ],
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
                      GestureDetector(
                        // onTap: () async {
                        //   await Navigator.of(context).push(
                        //     MaterialPageRoute(
                        //       builder: (context) =>
                        //           NoteDetailPage(noteId: note.id!),
                        //     ),
                        //   );
                        //   refreshNoteBooks();
                        // },
                        child: Container(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                      refreshNoteBooks();
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                              color:
                                                  Colors.pink.withOpacity(0.2),
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
            itemCount: notes.length,
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

  Widget bottomPageMenu(ctx) {
    return IconButton(
      icon: const Icon(
        Icons.menu_outlined,
        color: plumColor,
      ),
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
                  heightFactor: 0.5,
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
                      const SizedBox(height: 10),
                      // DonationWidget(),
                      // GooglePayButton(
                      //   height: 50,
                      //   width: 300,
                      //   paymentConfigurationAsset:
                      //       'default_payment_profile_google_pay.json',
                      //   paymentItems: _paymentItems,
                      //   type: GooglePayButtonType.buy,
                      //   margin: const EdgeInsets.only(top: 15.0),
                      //   onPaymentResult: onGooglePayResult,
                      //   loadingIndicator: const Center(
                      //     child: CircularProgressIndicator(),
                      //   ),
                      // ),
                      // ApplePayButton(
                      //   paymentConfigurationAsset:
                      //       'default_payment_profile_apple_pay.json',
                      //   paymentItems: _paymentItems,
                      //   style: ApplePayButtonStyle.black,
                      //   type: ApplePayButtonType.buy,
                      //   margin: const EdgeInsets.only(top: 15.0),
                      //   onPaymentResult: onApplePayResult,
                      //   loadingIndicator: const Center(
                      //     child: CircularProgressIndicator(),
                      //   ),
                      // ),
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
                          refreshNoteBooks();
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
                          refreshNoteBooks();
                        },
                      ),
                      ListTile(
                        leading: isListView
                            ? const Icon(Icons.dashboard, color: pinkColor)
                            : const Icon(Icons.list, color: pinkColor),
                        title: Text(
                          isListView ? "Grid View" : "List View",
                          style: const TextStyle(color: pinkColor),
                        ),
                        onTap: () async {
                          setState(() {
                            isListView = !isListView;
                          });
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
}
