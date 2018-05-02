import 'package:flutter/material.dart';
import 'package:panovel_app/pages/home/HomeRankPage.dart';
import 'package:panovel_app/pages/home/HomeSubPage.dart';

///主页
class HomePage extends StatefulWidget {
  final ValueChanged<bool> hideBottom;
  HomePage({Key key, this.hideBottom}): super(key: key);

  @override
  _HomePageState createState() => new _HomePageState(hideBottom);
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController tabController;
  var _tabs = [
    new Tab(text: "玄幻"),
    new Tab(text: "仙侠"),
    new Tab(text: "都市"),
    new Tab(text: "历史"),
    new Tab(text: "网游"),
    new Tab(text: "科幻"),
    new Tab(text: "女生"),
    new Tab(text: "排行")
  ];

  var _tabBarView = <Widget>[];
  final ValueChanged<bool> hideBottom;
  _HomePageState(this.hideBottom) {
    _tabBarView = [
      new HomeSubPage(
        index: 1,
        hideBottom: hideBottom,
      ),
      new HomeSubPage(
        index: 2,
        hideBottom: hideBottom,
      ),
      new HomeSubPage(
        index: 3,
        hideBottom: hideBottom,
      ),
      new HomeSubPage(
        index: 4,
        hideBottom: hideBottom,
      ),
      new HomeSubPage(
        index: 5,
        hideBottom: hideBottom,
      ),
      new HomeSubPage(
        index: 6,
        hideBottom: hideBottom,
      ),
      new HomeSubPage(
        index: 7,
        hideBottom: hideBottom,
      ),
      new HomeRankPage()
    ];
  }

  @override
  void initState() {
    tabController = new TabController(length: _tabs.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: '欢迎来到flutter',
      theme: new ThemeData(
          primaryColor: Colors.green, indicatorColor: Colors.white),
      home: new Scaffold(
          appBar: new AppBar(
            title: new Text("爬小说"),
            bottom: new TabBar(
              isScrollable: true,
              controller: tabController,
              tabs: _tabs,
            ),
            actions: <Widget>[
              new IconButton(
                icon: new Icon(Icons.search),
                onPressed: onPress,
              ),
              new IconButton(
                icon: new Icon(Icons.share),
                onPressed: onPress,
              ),
            ],
          ),
          body: new TabBarView(
            controller: tabController,
            children: _tabBarView,
          )),
    );
  }

  void onPress() {}
}
