import 'package:flutter/material.dart';

void main() {
runApp(MaterialApp(home: HomePage(),));
}


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(title: Text("Upload Media Files")),
      body: Column(children: [Text("Generate Media Files Link"), ElevatedButton(onPressed: (){

      }, child: Text("Upload"))],),
    );
  }
}
