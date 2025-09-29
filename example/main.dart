import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_link_generator/media_link_generator.dart';

void main() {
  runApp(MaterialApp(home: HomePage()));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Media Files")),
      body: Column(
        children: [
          Text("Generate Media Files Link"),
          ElevatedButton(
            onPressed: () async {
              var getLink = await MediaLink.generate(
                file: File("filePath"),
                folderName: "items",
                isSecret: false,
                fromDeviceName: "itel",
              );

              debugPrint(getLink.toString());
            },
            child: Text("Upload"),
          ),
        ],
      ),
    );
  }
}
