import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:notes_app/sql_database/sql_db_1/model/notebook.dart';

import '../../../../values.dart';

class NoteBookCardWidget extends StatelessWidget {
  final NoteBook noteBook;
  final int index;
  const NoteBookCardWidget({
    Key? key,
    required this.noteBook,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.all(5),
      width: _size.width / 2 - 30,
      height: _size.height / 5,
      decoration: BoxDecoration(
        color: accentPinkColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Hero(
            tag: noteBook.image,
            child: Container(
              height: (_size.height / 5) - 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                    image: AssetImage(noteBook.image), fit: BoxFit.contain),
              ),
            ),
          ),
          Text(
            noteBook.title,
            style: GoogleFonts.courgette(fontSize: 20, color: plumColor),
          ),
        ],
      ),
    );
  }
}
