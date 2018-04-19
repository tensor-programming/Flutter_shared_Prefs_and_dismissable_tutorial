import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

//RXDart implementation is commented out, just remove the controllers around the published subject and it will work properly. 

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Shared_Prefs Example'),
        ),
        body: Home(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  Future<SharedPreferences> _sPrefs = SharedPreferences.getInstance();
  final TextEditingController controller = TextEditingController();
  List<String> listOne, listTwo;
  // final PublishSubject subject = PublishSubject<List<String>>();
  final StreamController<List<String>> streamController = StreamController();

  @override
  void initState() {
    super.initState();
    clearItems();
    // subject.stream.listen(setListener);
    streamController.stream.listen(setListener);
  }

  @override
  void dispose() {
    // subject.close();
    super.dispose();
  }

  Future setListener(list) async {
    listTwo = await _sPrefs.then((sprefs) {
      return sprefs.getStringList('list');
    });
  }

  Future<Null> addString() async {
    final SharedPreferences prefs = await _sPrefs;
    listOne.add(controller.text);
    // subject.add(listOne);
    streamController.add(listOne);
    prefs.setStringList('list', listOne);
    setState(() {
      controller.text = '';
    });
  }

  Future<Null> clearItems() async {
    final SharedPreferences prefs = await _sPrefs;
    prefs.clear();
    setState(() {
      listOne = [];
      listTwo = [];
    });
    // subject.add(listTwo);
    streamController.add(listTwo);
  }

  // Future<Null> getStrings() async {
  //   final SharedPreferences prefs = await _sPrefs;
  //   listTwo = prefs.getStringList('list');
  //   setState(() {});
  // }

  Future<Null> updateStrings(String str) async {
    final SharedPreferences prefs = await _sPrefs;
    setState(() {
      listOne.remove(str);
      listTwo.remove(str);
    });
    prefs.setStringList('list', listOne);
  }

  @override
  Widget build(BuildContext context) {
    // getStrings();
    return Center(
      child: ListView(
        children: <Widget>[
          TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Type in something...',
              )),
          RaisedButton(
            child: Text("Submit"),
            onPressed: () {
              addString();
            },
          ),
          RaisedButton(
            child: Text("Clear"),
            onPressed: () {
              clearItems();
            },
          ),
          Flex(
            direction: Axis.vertical,
            children: listTwo == null
                ? []
                : listTwo
                    .map((String s) => Dismissible(
                        key: Key(s),
                        onDismissed: (direction) {
                          updateStrings(s);
                        },
                        child: ListTile(
                          title: Text(s),
                        )))
                    .toList(),
          )
        ],
      ),
    );
  }
}
