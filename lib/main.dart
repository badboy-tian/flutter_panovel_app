import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:panovel_app/pages/BookDetailPage.dart';
import 'package:panovel_app/pages/HomePage.dart';
import 'package:panovel_app/pages/MePage.dart';
import 'package:panovel_app/pages/SavePage.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //debugPaintSizeEnabled = true;
    return new MaterialApp(
        title: '欢迎来到flutter',
        theme: new ThemeData(
            primaryColor: Colors.green, indicatorColor: Colors.white),
        home: PaNovel());
  }
}

class PaNovel extends StatefulWidget {
  @override
  _PaNovelState createState() => new _PaNovelState();
}

class _PaNovelState extends State<PaNovel> {
  var _hideBottomNavBar = false;

  var _currentIndex = 0;

  void hideBottomNavBar(bool isHide) {
    setState(() {
      _hideBottomNavBar = isHide;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Stack(
          children: <Widget>[
            new Offstage(
                offstage: _currentIndex != 0,
                child: new TickerMode(
                  enabled: _currentIndex == 0,
                  child: new HomePage(hideBottom: hideBottomNavBar),
                )),
            new Offstage(
                offstage: _currentIndex != 1,
                child: new TickerMode(
                  enabled: _currentIndex == 1,
                  child: new SavePage(),
                )),
            new Offstage(
                offstage: _currentIndex != 2,
                child: new TickerMode(
                  enabled: _currentIndex == 2,
                  child: new MePage(),
                )),
          ],
        ),
        bottomNavigationBar: _hideBottomNavBar ? null : buildBottomNavBar());
  }

  BottomNavigationBar buildBottomNavBar() {
    return new BottomNavigationBar(
      items: [
        new BottomNavigationBarItem(
            icon: new Icon(Icons.home), title: new Text("首页")),
        new BottomNavigationBarItem(
            icon: new Icon(Icons.menu), title: new Text("追书")),
        new BottomNavigationBarItem(
            icon: new Icon(Icons.account_box), title: new Text("我的")),
      ],
      currentIndex: _currentIndex,
      onTap: (int index) {
        setState(() {
          this._currentIndex = index;
        });
      },
    );
  }
}
