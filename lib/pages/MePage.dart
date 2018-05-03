import 'package:flutter/material.dart';
/// 关于我
class MePage extends StatefulWidget {
  @override
  _MePageState createState() => new _MePageState();
}

class _MePageState extends State<MePage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("我的"),),
      body: new Center(child: new Text("敬请期待")),
    );
  }
}
