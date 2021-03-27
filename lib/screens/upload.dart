import 'package:flutter/material.dart';
import 'package:electura/services/auth_service.dart';
import 'package:electura/provider_widget.dart';
import 'package:file_picker/file_picker.dart';
//import 'package:path/path.dart' as p;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:electura/services/crud.dart';
import 'dart:io';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

// current problem : its getting uploaded but it is not shown on the page

class Upload extends StatefulWidget {
  final String username;
  Upload({this.username});
  @override
  State<StatefulWidget> createState() => _UploadState(username: this.username);
}

class _UploadState extends State<Upload> {
  String username;
  _UploadState({this.username});
  String _path;
  String filename;
  Stream files;
  CrudMethods crudobj = CrudMethods();
  static List<StorageUploadTask> _tasks = <StorageUploadTask>[];
  final GlobalKey<ScaffoldState> _scaffoldstate =
      new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    Firebase.initializeApp();
    crudobj.getData(username).then((results) {
      setState(() {
        files = results;
      });
    });
    super.initState();
  }

  Future<void> _uploadFile() async {
    _path = await FilePicker.getFilePath();
    String filename = _path.split('/').last;
    print("Filename in Upload task $filename");
    String filepath = _path;
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child("$username/$filename");
    StorageUploadTask uploadTask = storageReference.putFile(File(filepath));
    StorageTaskSnapshot snapshot = await uploadTask.onComplete;
    String downloadURL = await snapshot.ref.getDownloadURL();
    setState(() {
      //_tasks.add(uploadTask); //'tasks': uploadTask
      crudobj.addData(username, {
        'file': filename,
        'DownloadURl': downloadURL
      }).then((value) => print("adding file thru upload file"));
    });
  }

  //Preview picture
  Future<void> previewFile(String url) async {
    final http.Response downloadData = await http.get(url);
    var bodyBytes = downloadData.bodyBytes;
    _scaffoldstate.currentState.showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        content: Image.memory(
          bodyBytes,
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Future<void> downloadFile(String url, String filename) async {
    //final String url = await ref.getDownloadURL();
    // final http.Response downloadData = await http.get(url);
    final directory = await getExternalStorageDirectory();
    final dirPath = Directory('${directory.path}/Electura');

    /* 
    They are creating a temporary file for saving Image from Url
    final File tempFile = File('${systemTempDir.path}/tmp.jpg');
    */
    /*  If you want to store it on phone's internal memory or in external memory then just create a File with storage path and pass it to FileDownloadTask.
    */
// Create direcorty if not exists
    if ((await dirPath.exists())) {
      print("exists");
    } else {
      await dirPath.create();
    }
    String path = "${dirPath.path}/$filename";
    final File file = new File("$path");
    FirebaseStorage _storage = FirebaseStorage.instance;
    StorageReference _ref = await _storage.getReferenceFromUrl(url);
    final StorageFileDownloadTask task = _ref.writeToFile(file);
    print("Path inside phone : $path");
    /*final StorageFileDownloadTask task = ref.writeToFile(tempFile);
    final int byteCount = (await task.future).totalByteCount; */
    /*final String name = await ref.getName();
    final String path = await ref.getPath();
    print(
      'Success!\nDownloaded $name \nUrl: $url'
      '\npath: $path \nBytes Count :: $byteCount',
    );*/
    print("Success Downloaded URL: $url");
    _scaffoldstate.currentState.showSnackBar(
      SnackBar(
          backgroundColor: Colors.white,
          content: Text(
            "File is downloaded successfully. Location  internal storage -> android ->data ->com.example.electura -> files-> electura",
            softWrap: true,
            style: TextStyle(
                color: Colors.black, fontSize: 24, fontFamily: "Lobster"),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (files == null) {
      return Scaffold(
        key: _scaffoldstate,
        body: Center(),
        appBar: AppBar(
          title: Text(
            (username != null) ? username : "Username",
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            FlatButton(
              child: Text(
                "Sign Out",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: "Lobster",
                ),
              ),
              onPressed: () async {
                try {
                  AuthService auth = Provider.of(context).auth;
                  await auth.signOut();
                  print("Signed Out!");
                  Navigator.pop(context);
                } catch (e) {
                  print(e);
                }
              },
            )
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _uploadFile();
          },
          icon: Icon(Icons.add),
          label: Text("Add File"),
        ),
      );
    } else {
      return Scaffold(
        key: _scaffoldstate,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _uploadFile();
          },
          icon: Icon(Icons.add),
          label: Text("Add File"),
        ),
        appBar: AppBar(
          title: Text(
            (username != null) ? username : "Username",
            style: TextStyle(
                color: Colors.black, fontSize: 24, fontFamily: "Lobster"),
          ),
          actions: [
            FlatButton(
              child: Text(
                "Sign Out",
                style: TextStyle(color: Colors.black, fontSize: 24),
              ),
              onPressed: () async {
                try {
                  AuthService auth = Provider.of(context).auth;
                  await auth.signOut();
                  print("Signed Out!");
                  Navigator.pop(context);
                } catch (e) {
                  print(e);
                }
              },
            )
          ],
        ),
        body: Container(
          padding: EdgeInsets.all(26.0),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/UploadApp.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: StreamBuilder(
              stream: files,
              builder: (context, snapshot) {
                if (snapshot.data.documents == null)
                  return CircularProgressIndicator();
                else {
                  return ListView.builder(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      itemCount: snapshot.data.docs.length ?? 1,
                      itemBuilder: (BuildContext context, int i) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (i == 0)
                              SizedBox(
                                height: 10,
                              ),
                            SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 45,
                              child: Card(
                                // margin: EdgeInsets.only(top: 15),
                                elevation: 5.0,
                                shadowColor: Colors.black,
                                //shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(20)),
                                child: Slidable(
                                  actionPane: SlidableDrawerActionPane(),
                                  closeOnScroll: true,
                                  actionExtentRatio: 0.25,
                                  secondaryActions: <Widget>[
                                    IconSlideAction(
                                      caption: 'Delete',
                                      color: Colors.red,
                                      icon: Icons.delete,
                                      onTap: () async {
                                        // delete from the main list
                                        crudobj.deleteData(
                                            username,
                                            snapshot
                                                .data.documents[i].documentID);
                                        var downloadURL = snapshot
                                            .data.documents[i]
                                            .data()['DownloadURl'];
                                        FirebaseStorage _storage =
                                            FirebaseStorage.instance;
                                        StorageReference _ref = await _storage
                                            .getReferenceFromUrl(downloadURL);
                                        _ref.delete();
                                      },
                                    ),
                                    IconSlideAction(
                                        caption: 'Download',
                                        color: Colors.black,
                                        icon: Icons.download_outlined,
                                        onTap: () {
                                          var downloadURL = snapshot
                                              .data.documents[i]
                                              .data()['DownloadURl'];
                                          var filename = snapshot
                                              .data.documents[i]
                                              .data()['file'];
                                          print(
                                              "Download url in scaffold $downloadURL");
                                          downloadFile(downloadURL, filename);
                                        }),
                                    IconSlideAction(
                                        caption: 'Preview',
                                        color: Colors.black,
                                        icon: MdiIcons.eye,
                                        onTap: () {
                                          var downloadURL = snapshot
                                              .data.documents[i]
                                              .data()['DownloadURl'];
                                          previewFile(downloadURL);
                                        }),
                                  ],
                                  child: Text(
                                    "  " +
                                            snapshot.data.documents[i]
                                                .data()['file'] ??
                                        "HII",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 24,
                                        fontFamily: "Lobster"),
                                  ),
                                ),
                                color: Colors.orange[300],

                                /* IconButton(
                                icon: Icon(Icons.download_outlined),
                                onPressed: () {
                                  var downloadURL = snapshot.data.documents[i]
                                      .data()['DownloadURl'];
                                  var filename =
                                      snapshot.data.documents[i].data()['file'];
                                  print(
                                      "Download url in scaffold $downloadURL");
                                  downloadFile(downloadURL, filename);
                                })*/
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        );
                      });
                }
              },
            ),
          ),
        ),
      );
    }
  }
}
