import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_banyette/firebase/firebase_api.dart';
import 'package:the_banyette/studio/laful_studio.dart';

void main() {
  // /* camera initialization */
  // WidgetsFlutterBinding.ensureInitialized();

  // /* google ad initialization */
  // MobileAds.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    /* firebase initialization */
    FirebaseApiService firebaseApiService = FirebaseApiService();

    firebaseApiService.initialization();

    return MaterialApp(
      theme: ThemeData(
        fontFamily: GoogleFonts.quicksand().fontFamily,
        cardColor: const Color.fromARGB(255, 100, 177, 103),
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
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  final String user = "amy";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LaFulStudio(
                      userName: user,
                    ),
                  ),
                );
              },
              child: const Text(
                " LaFul\nStudio",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 50,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
