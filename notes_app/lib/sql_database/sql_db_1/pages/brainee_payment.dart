// import 'package:flutter/material.dart';
// import 'package:flutter_braintree/flutter_braintree.dart';

// class BrainTree extends StatefulWidget {
//   const BrainTree({Key? key}) : super(key: key);

//   @override
//   State<BrainTree> createState() => _BrainTreeState();
// }

// class _BrainTreeState extends State<BrainTree> {
//   @override
//   static final String tokenizationKey = '780ed99a0bae0e72b352c67cd2241e6b';

//   void showNonce(BraintreePaymentMethodNonce nonce) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Payment method nonce:'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             Text('Nonce: ${nonce.nonce}'),
//             const SizedBox(height: 16),
//             Text('Type label: ${nonce.typeLabel}'),
//             const SizedBox(height: 16),
//             Text('Description: ${nonce.description}'),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Braintree example app'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             ElevatedButton(
//               onPressed: () async {
//                 var request = BraintreeDropInRequest(
//                   tokenizationKey: tokenizationKey,
//                   collectDeviceData: true,
//                   googlePaymentRequest: BraintreeGooglePaymentRequest(
//                     totalPrice: '4.20',
//                     currencyCode: 'USD',
//                     billingAddressRequired: false,
//                   ),
//                   paypalRequest: BraintreePayPalRequest(
//                     amount: '4.20',
//                     displayName: 'Example company',
//                   ),
//                   cardEnabled: true,
//                 );
//                 final result = await BraintreeDropIn.start(request);
//                 if (result != null) {
//                   showNonce(result.paymentMethodNonce);
//                 }
//               },
//               child: Text('LAUNCH NATIVE DROP-IN'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 final request = BraintreeCreditCardRequest(
//                   cardNumber: '4111111111111111',
//                   expirationMonth: '12',
//                   expirationYear: '2021',
//                   cvv: '123',
//                 );
//                 final result = await Braintree.tokenizeCreditCard(
//                   tokenizationKey,
//                   request,
//                 );
//                 if (result != null) {
//                   showNonce(result);
//                 }
//               },
//               child: Text('TOKENIZE CREDIT CARD'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 final request = BraintreePayPalRequest(
//                   billingAgreementDescription:
//                       'I hereby agree that flutter_braintree is great.',
//                   displayName: 'Your Company',
//                 );
//                 final result = await Braintree.requestPaypalNonce(
//                   tokenizationKey,
//                   request,
//                 );
//                 if (result != null) {
//                   showNonce(result);
//                 }
//               },
//               child: Text('PAYPAL VAULT FLOW'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 final request = BraintreePayPalRequest(amount: '13.37');
//                 final result = await Braintree.requestPaypalNonce(
//                   tokenizationKey,
//                   request,
//                 );
//                 if (result != null) {
//                   showNonce(result);
//                 }
//               },
//               child: Text('PAYPAL CHECKOUT FLOW'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
