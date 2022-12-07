import 'package:flutter/cupertino.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:notes_app/sql_database/sql_db_1/model/notebook.dart';

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
      width: _size.width / 2,
      height: _size.height / 3,
      child: Column(
        children: [
          Container(
            height: (_size.height / 3) - 30,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage(noteBook.image)),
            ),
          ),
          Text(noteBook.title),
        ],
      ),
    );
  }
}
