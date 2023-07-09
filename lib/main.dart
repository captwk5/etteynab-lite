import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_banyette/firebase/firebase_api.dart';
import 'package:the_banyette/studio/laful_studio.dart';

void main() {
  runApp(const MyApp());
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  String? loadGoogleFontStyle() {
    String? fontStyle = "";
    try {
      fontStyle = GoogleFonts.quicksand().fontFamily;
    } catch (e) {
      debugPrint("network error ${e.toString()}");
    }
    return fontStyle;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    /* firebase initialization */
    FirebaseApiService firebaseApiService = FirebaseApiService();

    firebaseApiService.initialization();

    return MaterialApp(
      theme: ThemeData(
        /* TODO : Use default fontStyle when network is unavailable. */
        fontFamily: loadGoogleFontStyle(),
        cardColor: const Color.fromARGB(255, 100, 177, 103),
        shadowColor: const Color.fromARGB(255, 209, 235, 216),
        textTheme: const TextTheme(
          displaySmall: TextStyle(
            fontSize: 15,
            color: Colors.green,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      home: Home(),
    );
  }
}

// ignore: must_be_immutable
class Home extends StatelessWidget {
  Home({super.key});

  final String user = "amy";

  TextEditingController artistTxtIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 50,
            ),
            SizedBox(
              width: 300,
              child: TextField(
                controller: artistTxtIdController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  prefixIconColor: Colors.green,
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(30),
                side: const BorderSide(color: Colors.green),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
              ),
              onPressed: () {
                var searchTxt = artistTxtIdController.text;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LaFulStudio(
                      userName: searchTxt,
                      dataMap: FirebaseApiService.instance
                          .createMasterPieceInfo(searchTxt),
                    ),
                  ),
                );
              },
              child: const Text(
                "Find Artist",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
