



## Features

- Can upload any type of files and get generated link
- Firebase alternative 
- can use for testing purpose
- can use for debug mode and deploye mode


# just make the object
- and call the function 
 - example

```dart
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
```

