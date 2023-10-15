import 'package:flutter/material.dart';
import 'package:the_banyette/firebase/firebase_api.dart';

class SettingHome extends StatefulWidget {
  const SettingHome({super.key});

  @override
  State<SettingHome> createState() => _SettingHomeState();
}

class _SettingHomeState extends State<SettingHome> {
  final _formKey = GlobalKey<FormState>();

  String? message;
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        toolbarHeight: 50,
        backgroundColor: Theme.of(context).shadowColor,
      ),
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // const Text("Version 0.0.1-beta"),
            // const SizedBox(
            //   height: 15,
            // ),
            const Text("더 나은 앱을 위해 여러분의 의견을 보내주세요."),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
              onPressed: () => {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: SizedBox(
                          height: 300,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: <Widget>[
                                const Text("이런 부분이 개선되었으면 좋겠어요"),
                                const SizedBox(
                                  height: 15,
                                ),
                                SizedBox(
                                  width: 240,
                                  child: TextFormField(
                                    controller: myController,
                                    maxLength: 30,
                                    maxLines: null,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: '30자 이내',
                                    ),
                                    // The validator receives the text that the user has entered.
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter some text';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => {
                                    FirebaseApiService.instance.reportMessage(myController.text),
                                    myController.text = "",
                                    Navigator.pop(context)
                                  },
                                  child: const Text("보내기"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    })
              },
              child: const Text("제보 하기"),
            ),
            const SizedBox(
              height: 15,
            ),
            const Text("version : 0.0.1")
          ],
        ),
      ),
    );
  }
}
