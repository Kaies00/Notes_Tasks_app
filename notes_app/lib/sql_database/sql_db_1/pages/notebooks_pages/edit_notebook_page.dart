import 'package:flutter/material.dart';
import 'package:notes_app/sql_database/sql_db_1/model/notebook.dart';

import '../../db/notes_database.dart';
import '../../model/note.dart';
import '../../widegt/note_form_widget.dart';

class AddEditNoteBookPage extends StatefulWidget {
  final NoteBook? noteBook;

  const AddEditNoteBookPage({
    Key? key,
    this.noteBook,
  }) : super(key: key);
  @override
  _AddEditNoteBookPageState createState() => _AddEditNoteBookPageState();
}

class _AddEditNoteBookPageState extends State<AddEditNoteBookPage> {
  List<String> _noteBooksPics = [
    "assets/images/bk1.JPG",
    "assets/images/bk2.JPG",
    "assets/images/bk3.JPG",
    "assets/images/bk4.JPG",
    "assets/images/bk5.JPG",
    "assets/images/bk6.JPG",
    "assets/images/bk7.JPG",
    "assets/images/bk8.JPG",
    "assets/images/bk9.JPG",
  ];
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String image;

  @override
  void initState() {
    super.initState();

    title = widget.noteBook?.title ?? '';
    image = widget.noteBook?.image ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton()],
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: TextFormField(
                  decoration: InputDecoration(
                    label: Text(
                      "Title",
                      style: TextStyle(fontSize: 20),
                    ),
                    border: OutlineInputBorder(),
                    hintText: title.isNotEmpty ? "title" : title,
                  ),
                  validator: (value) {
                    if (value == "") {
                      return "you should type a title";
                    }
                    return null;
                  },
                  onChanged: ((value) {
                    setState(() {
                      title = value;
                    });
                  }),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            childAspectRatio: 3 / 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20),
                    itemCount: _noteBooksPics.length,
                    itemBuilder: (BuildContext ctx, index) {
                      return Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(15)),
                        child: Image(
                          image: AssetImage(_noteBooksPics[index]),
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      );

  Widget buildButton() {
    final isFormValid = title.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          onPrimary: Colors.white,
          primary: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateNoteBook,
        child: Text('Save'),
      ),
    );
  }

  void addOrUpdateNoteBook() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.noteBook != null;

      if (isUpdating) {
        await updateNoteBook();
      } else {
        await addNoteBook();
      }
      Navigator.of(context).pop();
    }
  }

  Future updateNoteBook() async {
    final NoteBook = widget.noteBook!.copy(
      title: title,
      image: "assets/images/bk1.JPG",
    );

    await NotesDatabase.instance.updateNoteBook(NoteBook);
  }

  Future addNoteBook() async {
    final noteBook = NoteBook(
      title: title,
      image: "assets/images/bk1.JPG",
      createdTime: DateTime.now(),
    );

    await NotesDatabase.instance.createNoteBook(noteBook);
  }
}
