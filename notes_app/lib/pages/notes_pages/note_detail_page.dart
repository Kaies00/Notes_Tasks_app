import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../../../values.dart';
import '../../db/notes_database.dart';
import '../../model/note.dart';
import 'edit_note_page.dart';

class NoteDetailPage extends StatefulWidget {
  final int noteId;

  const NoteDetailPage({
    Key? key,
    required this.noteId,
  }) : super(key: key);

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage>
    with TickerProviderStateMixin {
  late Note note;
  bool isLoading = false;
  late AnimationController _controllerCheckMarker;
  bool isImportant = true;

  @override
  void initState() {
    super.initState();
    _controllerCheckMarker = AnimationController(vsync: this);
    refreshNote();
  }

  Future refreshNote() async {
    setState(() => isLoading = true);
    note = await NotesDatabase.instance.readNote(widget.noteId);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: accentPinkColor,
      appBar: AppBar(
        backgroundColor: accentPinkColor,
        foregroundColor: pinkColor,
        elevation: 0,
        actions: [
          isLoading
              ? Container()
              : note.isTask
                  ? starButton()
                  : Container(),
          isLoading
              ? Container()
              : note.isTask
                  ? completitonButton()
                  : Container(),
          editButton(),
          deleteButton()
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          note.title,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.courgette(
                            color: const Color(0xff701B71),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            decoration: note.isTask && note.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            note.isImportant
                                ? Icons.star
                                : Icons.star_border_outlined,
                            color: note.isImportant
                                ? Colors.amber
                                : Colors.pink.withOpacity(0.2),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          note.isTask
                              ? note.isCompleted
                                  ? Icon(Icons.check_box,
                                      color: Colors.green.withOpacity(0.8))
                                  : Icon(
                                      Icons.check_box_outline_blank,
                                      color: Colors.pink.withOpacity(0.2),
                                    )
                              : Container(),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  DottedLine(),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat.yMMMd().format(note.createdTime),
                    style: const TextStyle(color: Colors.black26),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    note.description,
                    style: GoogleFonts.courgette(
                      color: Color.fromARGB(255, 62, 4, 71),
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
    );
  }

  Widget editButton() => IconButton(
      icon: const Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditNotePage(note: note),
        ));

        refreshNote();
      });

  Widget deleteButton() => IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () async {
          await NotesDatabase.instance.delete(widget.noteId);

          Navigator.of(context).pop();
        },
      );
  Widget starButton() => IconButton(
        icon: note.isImportant
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
                    note.isImportant
                        ? "assets/animations/dismiss.json"
                        : "assets/animations/star.json",
                    controller: _controllerCheckMarker,
                    onLoaded: (composition) {
                      // Configure the AnimationController with the duration of the
                      // Lottie file and start the animation.
                      _controllerCheckMarker
                        ..duration = composition.duration
                        ..forward()
                            .whenComplete(() => Navigator.of(context).pop());
                    },
                  ),
                ),
              );
            },
          );
          setState(() {
            _controllerCheckMarker.reverse();
            isImportant = !note.isImportant;
          });
          final nt = note.copy(
            isImportant: isImportant,
          );
          await NotesDatabase.instance.update(nt);
          refreshNote();
        }),
      );
  Widget completitonButton() => IconButton(
        icon: note.isCompleted
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
                    note.isCompleted
                        ? "assets/animations/dismiss.json"
                        : "assets/animations/checkmark.json",
                    controller: _controllerCheckMarker,
                    onLoaded: (composition) {
                      _controllerCheckMarker
                        ..duration = composition.duration
                        ..forward()
                            .whenComplete(() => Navigator.of(context).pop());
                    },
                  ),
                ),
              );
            },
          );
          setState(() {
            _controllerCheckMarker.reverse();
            isImportant = !note.isCompleted;
          });
          final nt = note.copy(
            isCompleted: isImportant,
          );
          await NotesDatabase.instance.update(nt);
          refreshNote();
        }),
      );
}
