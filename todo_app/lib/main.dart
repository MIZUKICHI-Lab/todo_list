import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
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
  TextEditingController _textFieldController = TextEditingController();
  List<String> _todos = [];
  String _todo = '';

  @override
  void initState() {
    super.initState();

    syncDataWithProvider();
  }

  Future syncDataWithProvider() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = prefs.getStringList('listData');
    if (result != null) {
      setState(() {
        _todos = result;
      });
    }
  }

  Future _updateItem(List<String> todos) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // ④保存
    await prefs.setStringList('listData', todos);
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('add list'),
              content: TextField(
                //自動的にキーボードを開く
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    _todo = value;
                  });
                },
                controller: _textFieldController,
                decoration: InputDecoration(hintText: "What are you up to?"),
              ),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    onPrimary: Colors.black,
                  ),
                  child: Text('Add'),
                  onPressed: _todo.isEmpty
                      ? null
                      : () {
                          setState(() {
                            _todos.add(_todo);
                            _updateItem(_todos);
                            _textFieldController.clear();
                            Navigator.pop(context);
                          });
                        },
                ),
              ],
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text(
          'ToDoList',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        child: ListView.builder(

            ///きっちりスクロールできるやつ/////
            physics: ClampingScrollPhysics(),
            itemCount: _todos.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: index == 0
                    ? EdgeInsets.only(top: 30)
                    : EdgeInsets.only(top: 10),
                child: Slidable(
                    actionPane: SlidableDrawerActionPane(),
                    //actionExtentRatio: 0.25,
                    secondaryActions: [
                      IconSlideAction(
                        caption: '削除',
                        color: Colors.red,
                        icon: Icons.delete_outline,
                        onTap: () {
                          setState(() {
                            _todos.remove(_todos[index]);
                            _updateItem(_todos);
                          });
                        },
                      ),
                    ],
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(right: 20.0),
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0),
                        ),
                      ),
                      child: Text(
                        _todos[index],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _displayTextInputDialog(context);
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
