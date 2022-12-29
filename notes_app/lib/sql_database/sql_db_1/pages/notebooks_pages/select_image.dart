// import 'package:flutter/material.dart';

// class SelectPicture extends StatelessWidget {
//   List<String> _noteBooksPics = [
//     "assets/images/bk1.JPG",
//     "assets/images/bk2.JPG",
//     "assets/images/bk3.JPG",
//     "assets/images/bk4.JPG",
//     "assets/images/bk5.JPG",
//     "assets/images/bk6.JPG",
//     "assets/images/bk7.JPG",
//     "assets/images/bk8.JPG",
//     "assets/images/bk9.JPG",
//     "assets/images/bk9.JPG",
//     "assets/images/3d1.png",
//     "assets/images/3d2.webp",
//     "assets/images/3d3.jpg",
//     "assets/images/3d4.webp",
//     "assets/images/3d5.PNG",
//   ];
//   SelectPicture({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("SelectPicture")),
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         child: Expanded(
//           child: GridView.builder(
//               gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
//                   maxCrossAxisExtent: 200,
//                   childAspectRatio: 3 / 2,
//                   crossAxisSpacing: 20,
//                   mainAxisSpacing: 20),
//               itemCount: _noteBooksPics.length,
//               itemBuilder: (BuildContext ctx, index) {
//                 return GestureDetector(
//                   child: Container(
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                         image: DecorationImage(
//                             image: AssetImage(_noteBooksPics[index])),
//                         color: Colors.amber,
//                         borderRadius: BorderRadius.circular(15)),
//                     // child: Image(
//                     //   image: AssetImage(
//                     //     _noteBooksPics[index],
//                     //   ),
//                     // ),
//                   ),
//                 );
//               }),
//         ),
//       ),
//     );
//   }
// }
