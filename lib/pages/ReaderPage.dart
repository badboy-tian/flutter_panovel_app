import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:logging/logging.dart';
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:html2md/html2md.dart' as html2md;
import 'package:panovel_app/bean/Chapter.dart';
import 'package:panovel_app/bean/SavedBook.dart';
import 'package:panovel_app/pages/AllChapterPage.dart';
import 'package:panovel_app/utils/MyCustomRoute.dart';
import 'package:panovel_app/utils/Tools.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:panovel_app/common.dart';

/// 阅读界面
class ReaderPage extends StatefulWidget {
  @override
  _ReaderPageState createState() => new _ReaderPageState(chapter);

  final Chapter chapter;

  ReaderPage(this.chapter);
}

class _ReaderPageState extends State<ReaderPage> {
  final Chapter chapter;

  _ReaderPageState(this.chapter);

  @override
  void initState() {
    super.initState();
    _title = chapter.name;
    //监听滑动
    _controller.addListener(() {
      if (_controller.position.userScrollDirection == ScrollDirection.reverse) {
        setState(() {
          _lvVisable = true;
        });
      } else if (_controller.position.userScrollDirection ==
          ScrollDirection.forward) {
        setState(() {
          _lvVisable = false;
        });
      }
    });

    loadData();
  }

  var _loading = false;
  var _lvVisable = true;
  var _title = "";

  @override
  Widget build(BuildContext context) {
    print(chapter.chapterid);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(_title),
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.share), onPressed: () {})
        ],
      ),
      body: buildBody(),
      floatingActionButton: new Opacity(
          opacity: _lvVisable ? 1.0 : 0.0,
          child: new FloatingActionButton(
            onPressed: () {
              _controller.animateTo(_controller.position.maxScrollExtent,
                  duration: new Duration(milliseconds: 300),
                  curve: Curves.easeOut);
            },
            child: new Icon(Icons.arrow_downward),
          )),
    );
  }

  var _controller = ScrollController();

  Widget buildBody() {
    if (_loading)
      return new Center(
        child: new CircularProgressIndicator(),
      );

    return new Column(
      children: <Widget>[
        new Expanded(
            child: new SingleChildScrollView(
          controller: _controller,
          child: new Column(children: <Widget>[
            new Padding(
                padding: new EdgeInsets.all(10.0),
                child: Text(
                  html2md.convert(text),
                  style: Tools.buildStyle(new Color(0xFFF333333), 16),
                )),
            new Divider(
              height: 1.0,
            ),
            new Container(
                child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new FlatButton(
                    onPressed: () {
                      if (lasturl != "./") {
                        print(lasturl);
                        setState(() {
                          chapter.chapterid = lasturl.replaceAll(".html", "");
                          loadData();
                        });
                      } else {
                        Scaffold.of(context).showSnackBar(
                            new SnackBar(content: new Text("没有上一章了")));
                      }
                    },
                    child: new Text(
                      "上一章",
                    )),
                new FlatButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          new MyCustomRoute(
                              builder: (_) =>
                                  new AllChapterPage(chapter.bookid, "目录")));
                    },
                    child: new Text("目录")),
                new FlatButton(
                    onPressed: () {
                      if (nexturl != "./") {
                        setState(() {
                          chapter.chapterid = nexturl.replaceAll(".html", "");
                          loadData();
                        });
                      } else {
                        Scaffold.of(context).showSnackBar(
                            new SnackBar(content: new Text("没有下一章了")));
                      }
                    },
                    child: new Text("下一章")),
              ],
            ))
          ]),
        ))
      ],
    );
  }

  var text = "";

  var REGEX_SCRIPT = "<script[^>]*?>[\\s\\S]*?<\\/script>";
  var P_SCRIPT = "<p[^>]*?>[\\s\\S]*?<\\/p>";
  var lasturl = "";
  var nexturl = "";
  var dir = "";
  var url = "";

  void loadData() async {
    setState(() {
      _loading = true;
    });
    url = "${Tools.baseurl}/${chapter.bookid}/${chapter.chapterid}.html";
    print("loadData: " + url);
    http.get(url, headers: Tools.header).then((resp) {
      if (!mounted) return;

      setState(() {
        var root = parser.parse(resp.body);
        _title = root.querySelector("title").text;
        chapter.name = _title;
        lasturl = root.querySelector("a#pt_prev").attributes["href"];
        nexturl = root.querySelector("a#pt_next").attributes["href"];
        dir = root.querySelector("a#pt_mulu").attributes["href"];
        text = root
            .querySelector("div.Readarea")
            .innerHtml
            .replaceAll(new RegExp(REGEX_SCRIPT), "")
            .replaceAll(new RegExp(P_SCRIPT), "");
        _loading = false;
      });
      //更新最新阅读的章节
      SavedBookDao.getInstance().then((value) async {
        var old = await value.get(chapter.bookid);
        if (old != null) {
          old.lastChapterID = chapter.chapterid;
          old.lastChapterName = chapter.name;
          value.update(old).then((value){
            eventBus.fire("updateNewChapter");
          });
        }
      });
    }).catchError((onError) {
      Fluttertoast.showToast(msg: "错误:${onError.toString()}");
      Navigator.of(context).pop();
      print(onError.toString());
    });
  }
}
