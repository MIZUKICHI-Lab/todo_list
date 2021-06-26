import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/list.model.dart';

class AddScreen extends StatefulWidget {
  final List<Todo>? todoList;
  const AddScreen({this.todoList});

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _istexted = false;
  String _todo = '';
  SharedPreferences? prefs;

  final _formKey = GlobalKey<FormState>();
  List<Todo> _todos = [];

  @override
  void initState() {
    super.initState();
    _todos = widget.todoList!;
  }

  Future _updateSharedPrefrences(Todo todo) async {
    _todos.add(todo);

    // ①Map型変換→②Json形式にエンコード→③リスト化
    List<String> myLists = _todos.map((f) => json.encode(f.toJson())).toList();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // ④保存
    await prefs.setStringList('listData', myLists);
    Navigator.pop(context);

    print('updateSharedPrefrences: $myLists');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '追加',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  print('asd');
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 300,
                    decoration: BoxDecoration(
                      color: Color(0xFF398AE5),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(5.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(),
                      child: Form(
                        key: _formKey,
                        child: TextField(
                          style: TextStyle(color: Colors.white),
                          textInputAction: TextInputAction.newline,
                          maxLength: 100,
                          keyboardType: TextInputType.multiline,
                          maxLines: 3,
                          controller: _textController,
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (comment) {
                            setState(() {
                              _istexted = comment.length > 0;
                              _todo = comment;
                            });
                          },
                          decoration:
                              InputDecoration.collapsed(hintText: 'すること'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: _istexted ? Colors.orange : Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _updateSharedPrefrences(
                              Todo(name: _todo, check: false));
                        });
                      },
                      child: Text(
                        _istexted ? '追加' : '入力して下さい',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _istexted ? Colors.white : Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
