import 'package:flutter/material.dart';
import 'package:the_banyette/firebase/firebase_api.dart';

import 'studio/laful_studio.dart';

void main() {
  /* camera initialization */
  WidgetsFlutterBinding.ensureInitialized();

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

    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Hello",
          style: TextStyle(fontSize: 10),
        ),
        toolbarHeight: 20,
        backgroundColor: const Color.fromARGB(255, 64, 228, 152),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "TheLaFul",
              style: TextStyle(
                color: Color.fromARGB(255, 100, 177, 103),
                fontSize: 50,
              ),
            ),
            const Text(
              "STUDIO",
              style: TextStyle(
                color: Color.fromARGB(255, 115, 211, 118),
                fontStyle: FontStyle.normal,
                fontSize: 40,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  label: const Text("작품 보기"),
                  icon: const Icon(
                    Icons.image_search_outlined,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LaFulStudio(),
                      ),
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
