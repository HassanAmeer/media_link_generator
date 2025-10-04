# Media Link Generator
### free to use 

A Flutter package for uploading, managing, and generating secure links for media files. This package provides a Firebase alternative for file storage with encryption support.

## Features

- Upload any type of files and get generated links
- Firebase alternative for file storage
- Secure file encryption with secret links
- Upload progress tracking
- File deletion capabilities
- Debug and production mode support
- Cross-platform compatibility
- free to use


## Documentaion
<a href="https://thelocalrent.com/link/apidocuments.php" target="_blank">API Documentation</a>


### Screenshots
 <img src="https://github.com/HassanAmeer/mediagetter_filemanager_flutter_package/blob/main/screenshots/demo.png?raw=true" style="width:50%">
 

## Installation
Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  media_link_generator: ^latest_version
```





# initilized in main function or others
```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_link_generator/media_link_generator.dart';

void main() {

      // Generate Token One Time Only
      var result = await MediaLink().generateAndSetToken(
                         "yourEmail@gmail.com", shouldPrint: true
                   );
      ebugPrint(result.toString());

      runApp(MaterialApp(home: HomePage()));
}
```

# for upload 
```dart
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

```


# for delete 
```dart
            /////////// 3. Delete Token 
            ElevatedButton(
            onPressed: () async {
                var result = await MediaLink().deleteFile(
                "fileLink", shouldPrint: true
                //// example like 
                //// https://filelink.com/link/v.php?t=1759519999&tk=37160f2e00721d906831565829ae1de7
                );
                if(result){
                  debugPrint("Deleted");
                  }else{
                  debugPrint("Not Deleted");
                }
              },
              child: Text("Delete File"),
            ),
```

