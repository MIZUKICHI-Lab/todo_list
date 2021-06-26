import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/add_screen.dart';
import 'package:todo_app/list.model.dart';

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
  List<Todo> _todos = [];

  @override
  void initState() {
    super.initState();
    syncDataWithProvider();
  }

  Future syncDataWithProvider() async {
    print('syncDataWithProvider');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    // ①読み出し
    var result = prefs.getStringList('listData');

    print('result:$result');

    // 読み出し確認
    if (result != null) {
      // ②デコード→③MapオブジェクトをClockModelに代入→④リストに変換
      setState(() {
        _todos = result.map((f) => Todo.fromJson(json.decode(f))).toList();
      });
    } else {
      // 必要に応じて初期化
    }
  }

  Future _deleteItem(Todo todo) async {
    _todos.remove(todo);
    // ①Map型変換→②Json形式にエンコード→③リスト化
    List<String> myLists = _todos.map((f) => json.encode(f.toJson())).toList();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // ④保存
    await prefs.setStringList('listData', myLists);

    print('updateSharedPrefrences: $myLists');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text(
          'トゥードゥーリストぅ',
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
                            _deleteItem(_todos[index]);
                          });
                        },
                      ),
                    ],
                    child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _todos[index] = Todo(
                                name: _todos[index].name,
                                check: !_todos[index].check!);
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 20.0),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          decoration: BoxDecoration(
                            color: _todos[index].check!
                                ? Colors.orange
                                : Colors.blue,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20.0),
                              bottomRight: Radius.circular(20.0),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text(
                                _todos[index].name!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Checkbox(
                                value: _todos[index].check,

                                ///valueは押した時に変更された値
                                onChanged: (value) {
                                  setState(() {
                                    _todos[index] = Todo(
                                      name: _todos[index].name,
                                      check: value,
                                    );
                                  });
                                },
                              )
                              ////アイコン/////
                            ],
                          ),
                        ))),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddScreen(
                  todoList: _todos,
                ),
              )).then((value) => syncDataWithProvider());
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
