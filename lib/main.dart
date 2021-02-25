import 'dart:convert';

import 'package:api_demo/const.dart';
import 'package:api_demo/tour_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CreatePage(
        isUpdate: false,
        tourModel: null,
      ),
    );
  }
}

class CreatePage extends StatefulWidget {
  final bool isUpdate;
  final TourModel tourModel;

  const CreatePage({Key key, this.tourModel, this.isUpdate}) : super(key: key);
  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  PickedFile _imageFile;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    _nameController = TextEditingController(
        text: widget.isUpdate && widget.tourModel != null
            ? widget.tourModel.title
            : '');
    _descriptionController = TextEditingController(
        text: widget.isUpdate && widget.tourModel != null
            ? widget.tourModel.description
            : '');
    super.initState();
  }

  Future<String> _readImage({String name}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("****read image: ${prefs.get("${_nameController.text}-cover")}");
  }

  @override
  Widget build(BuildContext context) {
    _readImage();
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Tour"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Name"),
                SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  controller: _nameController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Field Can't be empty";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal)),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text("Description"),
                SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  controller: _descriptionController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Field Can't be empty";
                    }
                    return null;
                  },
                  maxLines: 5,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal)),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text("Cover Photo"),
                SizedBox(
                  height: 10.0,
                ),
                GestureDetector(
                  onTap: () {
                    _showPicker();
                  },
                  child: Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.brown),
                    ),
                    // child: widget.isUpdate
                    //     ? Image.asset(widget.tourModel.coverPhotoURL)
                    //     : (_imageFile == null
                    //         ? Icon(
                    //             Icons.upload_rounded,
                    //             size: 50.0,
                    //             color: Colors.brown,
                    //           )
                    //         : Image.asset(
                    //             _imageFile.path,
                    //             fit: BoxFit.cover,
                    //           ))
                    child: _imageFile != null
                        ? Image.asset(_imageFile.path)
                        : (widget.isUpdate
                            ? Image.asset(widget.tourModel.coverPhotoURL)
                            : Icon(
                                Icons.upload_rounded,
                                size: 50.0,
                                color: Colors.brown,
                              )),
                  ),
                ),
                FlatButton(
                  color: widget.isUpdate ? Colors.red : Colors.blueAccent,
                  onPressed: () {
                    widget.isUpdate ? _updateTour() : _uploadTour();
                  },
                  child: Text(
                    widget.isUpdate ? "UPDATE TOUR" : "UPLOAD TOUR",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPicker() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
              child: Container(
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(Icons.photo),
                  title: Text("Photo Gallery"),
                  onTap: () {
                    _photoFromGallery();
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt),
                  title: Text("Camera"),
                  onTap: () {
                    _photoFromCamera();
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          ));
        });
  }

  void _photoFromGallery() async {
    final _pickedFile = await _picker.getImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxWidth: 200,
      maxHeight: 200,
    );
    setState(() {
      _imageFile = _pickedFile;
    });
  }

  void _photoFromCamera() async {
    final _pickedFile = await _picker.getImage(
      source: ImageSource.camera,
      imageQuality: 100,
      maxWidth: 200,
      maxHeight: 200,
    );
    setState(() {
      _imageFile = _pickedFile;
    });
  }

  void _uploadTour() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (_imageFile != null) {
        _uploadTourToDB();
      } else {
        Fluttertoast.showToast(
            msg: "Please Upload Tour cover photo",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            fontSize: 16.0);
      }
    }
  }

  void _updateTour() async {
    Map<String, dynamic> data = {
      'title': _nameController.text,
      'description': _descriptionController.text,
      'coverPhoto':
          _imageFile != null ? _imageFile.path : widget.tourModel.coverPhotoURL,
    };
    var response = await http.patch(
        "${Constant.API_URL}/api/v1/updateTour/${widget.tourModel.id}",
        body: data);
    print("**response ${response.body}");
    if (response.statusCode == 200) {
      _saveImgToSf();
      Fluttertoast.showToast(
          msg: json.decode(response.body)['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          fontSize: 16.0);

      Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()));
    } else {
      Fluttertoast.showToast(
          msg: json.decode(response.body)['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          fontSize: 16.0);
    }
  }

  void _saveImgToSf() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("${_nameController.text}-cover", _imageFile.path);
  }

  void _uploadTourToDB() async {
    Map<String, dynamic> tourData = {
      'title': _nameController.text,
      'description': _descriptionController.text,
      'coverPhoto': _imageFile.path,
    };
    var response = await http.post("${Constant.API_URL}/api/v1/createTour",
        body: tourData);
    if (response.statusCode == 201) {
      print("*** create tour successfully");
      _saveImgToSf();
      Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()));
    } else if (response.statusCode == 409) {
      Fluttertoast.showToast(
          msg: json.decode(response.body)['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          fontSize: 16.0);
    } else {
      print("****faild: ${json.decode(response.body)}");
      Fluttertoast.showToast(
          msg: json.decode(response.body)['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          fontSize: 16.0);
    }
  }
}
