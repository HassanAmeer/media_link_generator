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
              // get token directly
              var result = await MediaLink().generateTokenByEmail(
                "yourEmail@gmail.com",
                shouldPrint: true,
              );
              debugPrint(result.toString()); // 37160f2e00721d906831565829ae1de7

              //// set token
              MediaLink().setToken(
                result!,
              ); // if  can get from user dashboard from website
              // token like: 37160f2e00721d906831565829ae1de7
            },
            child: Text("Generate And Set Token One Time Only"),
          ),

          /////// 2 . Upload File & Generate Link
          Text("Upload Simple Files For Generate Link"),
          ElevatedButton(
            onPressed: () async {
              var getLink = await MediaLink().uploadSimpleFile(
                File("filePath"),
                folderName: "items",
                isSecret:
                    false, // fully secured file only can see by generated link and file can not be opend without this generate link
                fromDeviceName: "iphone 16 pro",
                shouldPrint: true,
                onUploadProgress: (uploadingPercentage) {
                  debugPrint(uploadingPercentage.toString());
                },
              );

              debugPrint(getLink.toJson().toString());
            },
            child: Text("Upload File with encyption"),
          ),

          /////// 3 . Upload File Bytes & Generate Link
          Text("Upload File Bytes For Generate Link"),
          ElevatedButton(
            onPressed: () async {
              var getLink = await MediaLink().uploadFileInBytes(
                await File("filePath").readAsBytes(),
                folderName: "items",
                isSecret:
                    false, // fully secured file only can see by generated link and file can not be opend without this generate link
                fromDeviceName: "iphone 16 pro",
                shouldPrint: true,
                onUploadProgress: (uploadingPercentage) {
                  debugPrint(uploadingPercentage.toString());
                },
              );

              debugPrint(getLink.toJson().toString());
            },
            child: Text("Upload File with encyption"),
          ),

          /////////// 4. Delete Token
          ElevatedButton(
            onPressed: () async {
              var result = await MediaLink().deleteFile(
                "fileLink", //  https://domain.com/image1.png
                shouldPrint: true,
              );
              if (result) {
                debugPrint("Deleted");
              } else {
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
