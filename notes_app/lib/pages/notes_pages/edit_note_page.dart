import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../values.dart';
import '../../db/notes_database.dart';
import '../../model/note.dart';
import '../../model/notebook.dart';

class AddEditNotePage extends StatefulWidget {
  final Note? note;
  final NoteBook? noteBook;

  const AddEditNotePage({
    Key? key,
    this.note,
    this.noteBook,
  }) : super(key: key);
  @override
  _AddEditNotePageState createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _formKey = GlobalKey<FormState>();
  late bool isImportant;
  late bool isTask;
  late bool isCompleted;
  late int number;
  late String title;
  late String description;
  late String notebook;
  TextEditingController titleController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  int _duartion = 200;
  @override
  void initState() {
    super.initState();

    isImportant = widget.note?.isImportant ?? false;
    isTask = widget.note?.isTask ?? false;
    isCompleted = widget.note?.isCompleted ?? false;
    number = widget.note?.number ?? 0;
    title = widget.note?.title ?? '';
    description = widget.note?.description ?? '';
    notebook = widget.noteBook?.title ?? '';
    titleController = TextEditingController(text: title);
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
        actions: [buildButton()],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildChoiceButon(_size),
                const SizedBox(height: 8),
                // Row(
                //   children: [
                //     Switch(
                //       value: isImportant,
                //       onChanged: (isImportant) =>
                //           setState(() => this.isImportant = isImportant),
                //     ),
                //     Expanded(
                //       child: Slider(
                //         value: (number).toDouble(),
                //         min: 0,
                //         max: 5,
                //         divisions: 5,
                //         onChanged: (nmb) =>
                //             setState(() => number = nmb.toInt()),
                //       ),
                //     )
                //   ],
                // ),
                buildTitle(),
                const SizedBox(height: 8),
                buildDescription(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        // child: NoteFormWidget(
        //   isImportant: isImportant,
        //   number: number,
        //   title: title,
        //   description: description,
        //   onChangedImportant: (isImportant) =>
        //       setState(() => this.isImportant = isImportant),
        //   onChangedNumber: (number) => setState(() => this.number = number),
        //   onChangedTitle: (title) => setState(() => this.title = title),
        //   onChangedDescription: (description) =>
        //       setState(() => this.description = description),
        // ),
      ),
    );
  }

  Widget buildButton() {
    final isFormValid = /*title.isNotEmpty &&*/ description.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          onPrimary: Colors.white,
          primary: isFormValid ? null : Colors.grey.shade500,
        ),
        onPressed: addOrUpdateNote,
        child: Text('Save'),
      ),
    );
  }

  void addOrUpdateNote() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.note != null;

      if (isUpdating) {
        await updateNote();
      } else {
        await addNote();
      }

      Navigator.of(context).pop();
    }
  }

  Future updateNote() async {
    final note = widget.note!.copy(
      isTask: isTask,
      isImportant: isImportant,
      isCompleted: isCompleted,
      number: number,
      title: title,
      description: description,
    );

    await NotesDatabase.instance.update(note);
  }

  Future addNote() async {
    final note = Note(
      title: title == '' ? titleController.text : title,
      isImportant: false,
      isTask: isTask,
      isCompleted: isCompleted,
      number: number,
      description: description,
      notebook: notebook,
      createdTime: DateTime.now(),
    );

    await NotesDatabase.instance.create(note);
  }

  Widget buildTitle() => TextFormField(
        controller: titleController,
        maxLines: 1,
        // initialValue: title,
        style: GoogleFonts.courgette(fontSize: 22),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Title',
          hintStyle: TextStyle(color: pinkColor),
        ),
        validator: (title) =>
            title != null && title.isEmpty ? 'The title cannot be empty' : null,
        onChanged: (tl) => setState(() {
          title = tl;
        }),
      );

  Widget buildDescription() => TextFormField(
        maxLines: 5,
        initialValue: description,
        style: GoogleFonts.courgette(fontSize: 18),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Type something...',
          hintStyle: TextStyle(color: pinkColor),
        ),
        validator: (description) => description != null && description.isEmpty
            ? 'The description cannot be empty'
            : null,
        onChanged: (dsc) {
          setState(() {
            description = dsc;
            if (title == '') {
              // titleController.text = dsc.split(" ")[0];
              titleController.text = (dsc.split("\n")[0]).split(" ")[0];
            }
          });
        },
      );
  Widget buildChoiceButon(size) => Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Color(0xffffced9),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 48,
                  width: (size.width / 2) - 16,
                  decoration: const BoxDecoration(
                      // color: Colors.amber.withOpacity(0.2),
                      // boxShadow: [
                      //   BoxShadow(
                      //     blurRadius: 10.0,
                      //     color: pinkColor,
                      //   ),
                      //   BoxShadow(
                      //     offset: Offset(0.0, 0.0),
                      //     blurRadius: 8.0,
                      //     color: pinkColor,
                      //   ),
                      // ],
                      ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: (() {
                          setState(() {
                            isTask = false;
                          });
                        }),
                        child: Container(
                          height: 48,
                          child: Center(
                            child: Text(
                              "Note",
                              style: GoogleFonts.courgette(
                                  color: pinkColor, fontSize: 22),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: (() {
                          setState(() {
                            isTask = true;
                          });
                        }),
                        child: Container(
                          height: 48,
                          child: Center(
                            child: Text(
                              "Task",
                              style: GoogleFonts.courgette(
                                  color: pinkColor, fontSize: 22),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 300),
              tween: Tween<Offset>(
                  begin: const Offset(0, 0),
                  end: Offset(isTask ? (size.width / 2) - 16 : 0, 0.0)),
              builder: (BuildContext context, Offset value, Widget? child) {
                Size s = MediaQuery.of(context).size;
                return Transform.translate(
                  offset: value,
                  child: Container(
                    color: Colors.amber,
                    height: 2,
                    width: (s.width / 2) - 16,
                  ),
                );
              },
            ),
          ],
        ),
      );
}
