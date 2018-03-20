import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

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

  @override
  void initState() {
    super.initState();
    listOne = [];
    listTwo = [];
  }

  Future<Null> addString() async {
    final SharedPreferences prefs = await _sPrefs;
    listOne.add(controller.text);
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
  }

  Future<Null> getStrings() async {
    final SharedPreferences prefs = await _sPrefs;
    listTwo = prefs.getStringList('list');
    setState(() {});
  }

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
    getStrings();
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
