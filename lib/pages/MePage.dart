import 'package:flutter/material.dart';
import 'package:panovel_app/common.dart';
/// 关于我
class MePage extends StatefulWidget {
  @override
  _MePageState createState() => new _MePageState();
}

class _MePageState extends State<MePage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("我的"),
        //backgroundColor: currentColor,
      ),
      body: new Center(child: new Text("敬请期待")),
    );
  }
}
