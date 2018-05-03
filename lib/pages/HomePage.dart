import 'dart:async';

import 'package:panovel_app/pages/home/HomeRankPage.dart';
import 'package:panovel_app/pages/home/HomeSubPage.dart';
import 'package:panovel_app/common.dart';
import 'package:panovel_app/pages/home/SearchResultPage.dart';

///主页
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
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

  _HomePageState() {
    _tabBarView = [
      new HomeSubPage(
        index: 1,
      ),
      new HomeSubPage(
        index: 2,
      ),
      new HomeSubPage(
        index: 3,
      ),
      new HomeSubPage(
        index: 4,
      ),
      new HomeSubPage(
        index: 5,
      ),
      new HomeSubPage(
        index: 6,
      ),
      new HomeSubPage(
        index: 7,
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

  bool isSearch = false;

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: _requestPop,
        child: new MaterialApp(
          title: '欢迎来到flutter',
          theme: new ThemeData(
              primaryColor: Colors.green, indicatorColor: Colors.white),
          home: new Scaffold(
              appBar: new AppBar(
                title: isSearch ? buildSearchView() : new Text("抓小说"),
                bottom: new TabBar(
                  isScrollable: true,
                  controller: tabController,
                  tabs: _tabs,
                ),
                actions: buildActions(),
              ),
              body: new TabBarView(
                controller: tabController,
                children: _tabBarView,
              )),
        ));
  }

  int preClicked = 0;

  Future<bool> _requestPop() {
    if (isSearch) {
      setState(() {
        isSearch = false;
        editController.clear();
      });
      return new Future.value(false);
    }

    /*print("${DateTime.now().millisecond}---${preClicked}");
    if (DateTime.now().millisecond - preClicked > 2) {
      Tools.showSnake(context, "再次点击退出");
      preClicked = DateTime.now().millisecond;
      return new Future.value(false);
    }*/

    return new Future.value(true);
  }

  List<Widget> buildActions() {
    var list = <Widget>[];
    if (!isSearch) {
      list.add(new IconButton(
        icon: new Icon(Icons.search),
        onPressed: () {
          setState(() {
            isSearch = true;
          });
        },
      ));
    }

    list.add(new IconButton(
      icon: new Icon(Icons.share),
      onPressed: () {},
    ));

    return list;
  }

  var editController = TextEditingController();

  Widget buildSearchView() {
    return new TextField(
      controller: editController,
      style: Tools.buildStyle(Colors.white, 15),
      decoration: new InputDecoration(
          border: InputBorder.none,
          hintText: "书名/作者",
          hintStyle: Tools.buildStyle(Colors.white30, 15),
          suffixIcon: new Offstage(
            offstage:
                editController.text == null || editController.text.isEmpty,
            child: new IconButton(
                icon: Icon(
                  Icons.clear,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    editController.clear();
                  });
                }),
          ),
          prefixIcon: new IconButton(
              padding: new EdgeInsets.only(
                  left: 0.0, right: 8.0, top: 8.0, bottom: 8.0),
              icon: new Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  editController.clear();
                  isSearch = false;
                });
              })),
      onSubmitted: (text) {
        setState(() {
          editController.clear();
          isSearch = false;
        });
        Navigator.push(
            context,
            new MyCustomRoute(
                builder: (_) => new SearchResultPage(words: text)));
      },
      onChanged: (text) {
        setState(() {});
      },
    );
  }
}
