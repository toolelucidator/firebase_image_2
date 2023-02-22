import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
      ),
      body: Column(
        children: <Widget>[
          (imageUrl != null)
              ? Container(
                  height: 480,
                  width: 480,
                  child: Image.network(imageUrl!),
                )
              : Container(
                  height: 480,
                  width: 640,
                ),
          SizedBox(
            height: 20,
          ),
          MaterialButton(
            onPressed: () => uploadImage(),
            child: Text('Subir Imagen'),
            color: Colors.redAccent,
          )
        ],
      ),
    );
  }

  uploadImage() async {
    final _storage = FirebaseStorage.instance;
    final _picker = ImagePicker();
    PickedFile? image;
    await Permission.photos.request();
    var PermisiionStatus = await Permission.photos.status;
    if (PermisiionStatus.isGranted) {
      image = await _picker.getImage(source: ImageSource.gallery);
      var file = File(image!.path);
      if (image != null) {
        var snapshot = await _storage
            .ref()
            .child('folderName/imageName' + file.path.split('picker').last)
            .putFile(file);

        var downloadUrl = await snapshot.ref.getDownloadURL();
        print("Download URL");
        print(downloadUrl);
        setState(() {
          imageUrl = downloadUrl;
          print(downloadUrl.toString());
        });
      } else {
        print("No path Received");
      }
    } else {
      print("No hay permisos para acceder a la galeria");
    }
  }
}
