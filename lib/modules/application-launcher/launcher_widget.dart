import "package:flutter/material.dart";

class LauncherWidget extends StatefulWidget {
  const LauncherWidget({super.key});

  @override
  State<LauncherWidget> createState() => LauncherState();
}

class LauncherState extends State<LauncherWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.blue, height: 400, width: 400, child: TextFormField());
  }
}
