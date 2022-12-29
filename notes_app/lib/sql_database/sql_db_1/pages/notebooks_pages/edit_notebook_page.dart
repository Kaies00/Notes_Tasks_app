import 'package:flutter/material.dart';
import 'package:notes_app/sql_database/sql_db_1/model/notebook.dart';
import '../../../../values.dart';
import '../../db/notes_database.dart';

class AddEditNoteBookPage extends StatefulWidget {
  final NoteBook? noteBook;

  const AddEditNoteBookPage({
    Key? key,
    this.noteBook,
  }) : super(key: key);
  @override
  _AddEditNoteBookPageState createState() => _AddEditNoteBookPageState();
}

class _AddEditNoteBookPageState extends State<AddEditNoteBookPage>
    with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController animationController;
  final List<String> _noteBooksPics = [
    "assets/images/icon3d1.png",
    "assets/images/icon3d2.png",
    "assets/images/icon3d3.png",
    "assets/images/icon3d4.png",
    "assets/images/icon3d5.png",
    "assets/images/icon3d6.png",
    "assets/images/icon3d7.png",
    "assets/images/icon3d8.png",
    "assets/images/icon3d9.png",
    "assets/images/icon3d10.png",
    "assets/images/icon3d11.png",
    "assets/images/icon3d12.png",
    "assets/images/icon3d13.png",
    "assets/images/icon3d14.png",
    "assets/images/icon3d15.png",
    "assets/images/icon3d16.png",
    "assets/images/icon3d17.png",
    "assets/images/icon3d18.png",
    "assets/images/icon3d19.png",
    "assets/images/icon3d20.png",
    "assets/images/icon3d21.png",
    "assets/images/icon3d22.png",
    "assets/images/icon3d23.png",
    "assets/images/icon3d24.png",
    "assets/images/icon3d25.png",
    "assets/images/icon3d26.png",
    "assets/images/icon3d27.png",
    "assets/images/icon3d28.png",
    "assets/images/icon3d29.png",
    "assets/images/icon3d30.png",
    "assets/images/icon3d31.png",
    "assets/images/icon3d32.png",
    "assets/images/icon3d33.png",
    "assets/images/icon3d34.png",
    "assets/images/icon3d35.png",
    "assets/images/icon3d36.png",
    "assets/images/icon3d37.png",
    "assets/images/icon3d38.png",
    "assets/images/icon3d39.png",
    "assets/images/icon3d40.png",
    "assets/images/icon3d41.png",
    "assets/images/icon3d42.png",
    "assets/images/icon3d43.png",
    "assets/images/icon3d44.png",
    "assets/images/icon3d45.png",
    "assets/images/icon3d46.png",
    "assets/images/icon3d47.png",
    "assets/images/icon3d48.png",
    "assets/images/icon3d49.png",
    "assets/images/icon3d50.png",
    "assets/images/icon3d51.png",
    "assets/images/icon3d52.png",
    "assets/images/icon3d53.png",
    "assets/images/icon3d54.png",
    "assets/images/icon3d55.png",
    "assets/images/icon3d56.png"
  ];
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String image;

  @override
  void initState() {
    super.initState();

    title = widget.noteBook?.title ?? '';
    image = widget.noteBook?.image ?? 'assets/images/emptypic.jpg';

    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1))
          ..repeat(reverse: true);
    animation = Tween<double>(begin: 0.8, end: 1).animate(animationController)
      ..addListener(() {
        setState(() {});
      });
    // animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
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
      body: Container(
        padding: EdgeInsets.all(20),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => selectPicture(context),
              child: image == 'assets/images/emptypic.jpg'
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: _size.height / 6,
                          width: _size.width / 2,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(image), fit: BoxFit.fill),
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        Transform.scale(
                          scale: animation.value,
                          child: Container(
                            height: _size.height / 6,
                            width: _size.width / 2 - 30,
                            child: const Image(
                              image: AssetImage('assets/images/taphere.png'),
                            ),
                          ),
                        )
                      ],
                    )
                  : Container(
                      height: _size.height / 6,
                      width: _size.width / 2,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(image), fit: BoxFit.contain),
                          color: Colors.pink.shade100,
                          borderRadius: BorderRadius.circular(15)),
                    ),
            ),
            const SizedBox(
              height: 20,
            ),
            Form(
              key: _formKey,
              child: TextFormField(
                initialValue: title,
                decoration: InputDecoration(
                  label: const Text(
                    "Title",
                    style: TextStyle(fontSize: 20),
                  ),
                  border: OutlineInputBorder(),
                  hintText: title == '' ? "Title" : title,
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
          ],
        ),
      ),
    );
  }

  selectPicture(ctx) {
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        enableDrag: true,
        context: ctx,
        builder: (ctx) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Expanded(
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20),
                  itemCount: _noteBooksPics.length,
                  itemBuilder: (BuildContext ctx, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          image = _noteBooksPics[index];
                        });
                        Navigator.of(ctx).pop();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(_noteBooksPics[index])),
                            color: accentPinkColor,
                            borderRadius: BorderRadius.circular(15)),
                        // child: Image(
                        //   image: AssetImage(_noteBooksPics[index]),
                        // ),
                      ),
                    );
                  }),
            ),
          );
        });
  }

  Widget buildButton() {
    final isFormValid =
        title.isNotEmpty & (image != 'assets/images/emptypic.jpg');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          onPrimary: Colors.white,
          primary: isFormValid ? pinkColor : Colors.grey.shade700,
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
      image: image,
    );

    await NotesDatabase.instance.updateNoteBook(NoteBook);
  }

  Future addNoteBook() async {
    final noteBook = NoteBook(
      title: title,
      image: image,
      createdTime: DateTime.now(),
    );

    await NotesDatabase.instance.createNoteBook(noteBook);
  }
}
