import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Storage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String imageLink;
  bool _isImagePicked = false;
  File _image;
  bool _isLoading = false;
  bool _taskUploaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: double.infinity,
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: <Widget>[
                SizedBox(
                  height: 64,
                ),
                _isImagePicked
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32.0),
                        child: Container(
                            height: 150.0,
                            decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 0.20,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                image: DecorationImage(
                                    image: FileImage(_image),
                                    fit: BoxFit.cover))),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Container(
                          height: 150.0,
                          decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 0.20,
                                  color: Colors.grey[500],
                                ),
                              ),
                              color: Colors.black),
                          child: Align(
                            alignment: Alignment.center,
                            child: Center(
                                child: Text(
                              "Please Select an Image",
                              style: TextStyle(color: Colors.white),
                            )),
                          ),
                        ),
                      ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: RaisedButton(
                        child: Text('Pick Image'),
                        onPressed: () async {
                          var imageTemp = await ImagePicker.pickImage(
                              source: ImageSource.gallery);
                          setState(() {
                            _image = imageTemp;
                            _isImagePicked = true;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10.0),
                    Expanded(
                      flex: 1,
                      child: Builder(
                        builder: (context) => RaisedButton(
                          child: Text('Upload Image'),
                          onPressed: () async {
                            if (_isImagePicked) {
                              setState(() {
                                _isLoading = true;
                              });
                              FirebaseStorage fs = FirebaseStorage.instance;
                              StorageReference mRef =
                                  fs.ref().child("pictures");
                              mRef
                                  .putFile(_image)
                                  .onComplete
                                  .then((storageTask) async {
                                String link =
                                    await storageTask.ref.getDownloadURL();

                                setState(() {
                                  _isLoading = false;
                                  _taskUploaded = true;
                                  imageLink = link;
                                });
                              });
                            } else {
                              var mSnackBar = SnackBar(
                                content: Text(
                                    "Please Pick an Image, before uploading"),
                                duration: Duration(seconds: 3),
                              );
                              Scaffold.of(context).showSnackBar(mSnackBar);
                            }
                          },
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text("Image Uploaded to Strorage: ",
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500)),
                _taskUploaded
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          width: double.infinity,
                          height: 150.0,
                          child: Image.network(imageLink),
                        ),
                      )
                    : Container(
                        height: 50.0,
                        child: Align(
                            alignment: Alignment.center,
                            child: Center(child: Text("None"))))
              ],
            ),
    ));
  }
}
