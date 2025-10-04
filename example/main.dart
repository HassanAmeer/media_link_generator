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

            /////////// 1. Generate Token 
            //// can set from main function one time only
            ElevatedButton(
            onPressed: () async {
              var result = await MediaLink().generateAndSetToken(
               "yourEmail@gmail.com", shouldPrint: true
                );
                debugPrint(result.toString());
              },
              child: Text("Generate Token One Time Only"),
            ),








          /////// 2 . Generate Link
          Text("Upload Media Files For Generate Link"),
          ElevatedButton(
            onPressed: () async {
              var getLink = await MediaLink().uploadFile(
                 File("filePath"),
                folderName: "items",
                isSecret: false, // fully secured file only can see by generated link and file can not be opend without this generate link
                fromDeviceName: "iphone 16 pro",
                shouldPrint: true,
                onUploadProgress: (uploadingPercentage) {
                  debugPrint(uploadingPercentage.toString());
                },
              );

              debugPrint(getLink!.toJson().toString());
            },
            child: Text("Upload File with encyption"),
          ),












            /////////// 3. Delete Token 
            ElevatedButton(
            onPressed: () async {
                var result = await MediaLink().deleteFile(
                "fileLink", shouldPrint: true
                );
                if(result){
                  debugPrint("Deleted");
                  }else{
                  debugPrint("Not Deleted");
                }
              },
              child: Text("Delete File"),
            ),
        ],
      ),
    );
  }
}
