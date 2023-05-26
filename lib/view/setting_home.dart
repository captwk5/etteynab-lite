import 'package:flutter/material.dart';

class SettingHome extends StatelessWidget {
  const SettingHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Theme.of(context).cardColor,
      ),
      resizeToAvoidBottomInset: false,
      body: const Center(
        child: Text("Setting"),
      ),
    );
  }
}
