import 'dart:convert';

import 'package:api_demo/const.dart';
import 'package:api_demo/main.dart';
import 'package:api_demo/tour_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Container(
        child: FutureBuilder(
          future: getTours(),
          builder: (context, snap) {
            if (snap.hasData) {
              List<TourModel> tours = snap.data;
              return ListView.builder(
                  itemCount: tours.length,
                  itemBuilder: (context, index) {
                    return Container(
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          border: Border.all(width: 1.0),
                        ),
                        margin: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tours[index].title,
                              style: TextStyle(
                                fontSize: 23.0,
                                color: Colors.orange,
                              ),
                            ),
                            Text(tours[index].description),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Image.asset(
                                    tours[index].coverPhotoURL,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: OutlineButton(
                                    onPressed: () {
                                      _deleteTour(tourId: tours[index].id);
                                    },
                                    child: Text("Delete"),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: OutlineButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => CreatePage(
                                                    isUpdate: true,
                                                    tourModel: TourModel(
                                                      id: tours[index].id,
                                                      title: tours[index].title,
                                                      description: tours[index]
                                                          .description,
                                                      coverPhotoURL:
                                                          tours[index]
                                                              .coverPhotoURL,
                                                    ),
                                                  )));
                                    },
                                    child: Text("Update"),
                                  ),
                                )
                              ],
                            )
                          ],
                        ));
                  });
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  Future<List<TourModel>> getTours() async {
    var response = await http.get("${Constant.API_URL}/api/v1/getTours");
    if (response.statusCode == 200) {
      List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(
          jsonDecode(response.body.toString())['tours']);
      List<TourModel> tours =
          List<TourModel>.from(list.map((e) => TourModel.fromMap(e)).toList());
      return tours;
    } else {
      Fluttertoast.showToast(
          msg: jsonDecode(response.body)['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          fontSize: 16.0);
      return null;
    }
  }

  void _deleteTour({String tourId}) async {
    Map<String, dynamic> data = {'id': tourId};
    var response =
        await http.post("${Constant.API_URL}/api/v1/deleteTour", body: data);
    if (response.statusCode == 204) {
      Fluttertoast.showToast(
          msg: "Delete tour successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: jsonDecode(response.body)['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          fontSize: 16.0);
    }
  }
}
