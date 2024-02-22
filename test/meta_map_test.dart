// import 'package:flutter/material.dart';
// import 'package:metamap_plugin_flutter/metamap_plugin_flutter.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Mati flutter plugin demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key}) : super(key: key);

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   void showMatiFlow() {
//     MatiFlutter.showMatiFlow("CLIENT_ID", "FLOW_ID", {});
//     MatiFlutter.resultCompleter.future.then((result) => Fluttertoast.showToast(
//         msg: result is ResultSuccess
//             ? "Success ${result.verificationId}"
//             : "Cancelled",
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text("Mati flutter plugin demo"),
//         ),
//         body: Center(
//             child: ElevatedButton(
//           onPressed: showMatiFlow,
//           child: const Text('Verify me'),
//         )));
//   }
// }
