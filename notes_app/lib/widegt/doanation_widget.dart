// import 'package:animated_text_kit/animated_text_kit.dart';
// import 'package:dotted_line/dotted_line.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:pay/pay.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../../values.dart';

// class DonationWidget extends StatelessWidget {
//   DonationWidget({Key? key}) : super(key: key);
//   final String _url = 'https://www.buymeacoffee.com/kaiselmabrf';
//   final String _urlPatreon = 'https://www.patreon.com/user?u=66710574';
//   final String _urlkofi = 'https://ko-fi.com/kaies';
//   void _launchURL() async => await canLaunch(_url)
//       ? await launch(_url)
//       : throw 'Could not launch $_url';
//   void _launchURLPatreon() async => await canLaunch(_urlPatreon)
//       ? await launch(_urlPatreon)
//       : throw 'Could not launch $_urlPatreon';
//   void _launchURLKofi() async => await canLaunch(_urlkofi)
//       ? await launch(_urlkofi)
//       : throw 'Could not launch $_urlkofi';

//   void onGooglePayResult(paymentResult) {
//     debugPrint(paymentResult.toString());
//   }

//   void onApplePayResult(paymentResult) {
//     debugPrint(paymentResult.toString());
//   }

//   final List<PaymentItem> _paymentItems = [
//     const PaymentItem(
//       label: 'Total',
//       amount: '99.99',
//       status: PaymentItemStatus.final_price,
//     )
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             Stack(children: [
//               Container(
//                 height: 230,
//                 width: 300,
//                 decoration: BoxDecoration(
//                     color: accentPinkColor,
//                     borderRadius: BorderRadius.circular(10)),
//                 child: Lottie.asset(
//                   "assets/animations/helpgrow.json",
//                 ),
//               ),
//               AnimatedTextKit(isRepeatingAnimation: false, animatedTexts: [
//                 TyperAnimatedText(
//                   'Don\'t Forget Donation !! \nYour Support Help us\nKeep going',
//                   speed: const Duration(milliseconds: 100),
//                   textStyle: const TextStyle(
//                     color: plumColor,
//                     fontFamily: "Valid_Harmony",
//                     fontSize: 25,
//                   ),
//                 ),
//               ]),
//             ]),
//             Container(
//               height: 230,
//               // constraints: BoxConstraints.expand(),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // InkWell(
//                   //   onTap: () async {
//                   //     // await Navigator.of(context).push(
//                   //     //     MaterialPageRoute(
//                   //     //         builder: (context) =>
//                   //     //             const BrainTree()));
//                   //   },
//                   //   child: Container(
//                   //     height: 50,
//                   //     width: 50,
//                   //     decoration: BoxDecoration(
//                   //         borderRadius: BorderRadius.circular(10),
//                   //         color: Colors.white,
//                   //         border: Border.all(color: pinkColor),
//                   //         image: const DecorationImage(
//                   //             image: AssetImage("assets/images/paypal.png"))),
//                   //   ),
//                   // ),
//                   GooglePayButton(
//                     paymentConfigurationAsset:
//                         'default_payment_profile_google_pay.json',
//                     paymentItems: _paymentItems,
//                     type: GooglePayButtonType.buy,
//                     margin: const EdgeInsets.only(top: 15.0),
//                     onPaymentResult: onGooglePayResult,
//                     loadingIndicator: const Center(
//                       child: CircularProgressIndicator(),
//                     ),
//                   ),
//                   ApplePayButton(
//                     paymentConfigurationAsset:
//                         'default_payment_profile_apple_pay.json',
//                     paymentItems: _paymentItems,
//                     style: ApplePayButtonStyle.black,
//                     type: ApplePayButtonType.buy,
//                     margin: const EdgeInsets.only(top: 15.0),
//                     onPaymentResult: onApplePayResult,
//                     loadingIndicator: const Center(
//                       child: CircularProgressIndicator(),
//                     ),
//                   ),
//                   InkWell(
//                     onTap: () {
//                       _launchURL();
//                     },
//                     child: Container(
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(color: pinkColor),
//                           color: Colors.white,
//                           image: const DecorationImage(
//                             image: AssetImage("assets/images/coffee.png"),
//                             fit: BoxFit.fill,
//                           )),
//                       height: 50,
//                       width: 50,
//                     ),
//                   ),
//                   InkWell(
//                     onTap: (() {
//                       _launchURLPatreon();
//                     }),
//                     child: Container(
//                       padding: const EdgeInsets.all(5),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: pinkColor),
//                         color: Colors.white,
//                       ),
//                       height: 50,
//                       width: 50,
//                       child: const Image(
//                         image: AssetImage("assets/images/patreon.png"),
//                       ),
//                     ),
//                   ),
//                   InkWell(
//                     onTap: (() {
//                       _launchURLKofi();
//                     }),
//                     child: Container(
//                       padding: EdgeInsets.all(5),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: pinkColor),
//                         color: Colors.white,
//                       ),
//                       height: 50,
//                       width: 50,
//                       child: const Image(
//                           image: AssetImage("assets/images/kofi.png")),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//         const SizedBox(height: 10),
//         const DottedLine(
//           dashColor: accentPinkColor,
//         ),
//       ],
//     );
//   }
// }
