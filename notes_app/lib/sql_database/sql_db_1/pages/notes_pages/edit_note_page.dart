import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/sql_database/sql_db_1/model/notebook.dart';

import '../../../../values.dart';
import '../../db/notes_database.dart';
import '../../model/note.dart';
import '../../widegt/note_form_widget.dart';

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
  late int number;
  late String title;
  late String description;
  late String notebook;
  TextEditingController titleController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  @override
  void initState() {
    super.initState();

    isImportant = widget.note?.isImportant ?? false;
    number = widget.note?.number ?? 0;
    title = widget.note?.title ?? '';
    description = widget.note?.description ?? '';
    notebook = widget.noteBook?.title ?? '';
    titleController = TextEditingController(text: title);
  }

  @override
  Widget build(BuildContext context) {
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
      isImportant: isImportant,
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
          print(tl);
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
              titleController.text = dsc.split(" ")[0];
            }
          });
        },
      );
}
