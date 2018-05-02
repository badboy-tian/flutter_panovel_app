import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:panovel_app/bean/BkDetail.dart';
import 'package:panovel_app/bean/BklistItem.dart';
import 'package:panovel_app/bean/SavedBook.dart';
import 'package:panovel_app/pages/AllChapterPage.dart';
import 'package:panovel_app/pages/ReaderPage.dart';
import 'package:panovel_app/utils/MyCustomRoute.dart';
import 'package:panovel_app/utils/Tools.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html2md/html2md.dart' as html2md;
import 'package:panovel_app/bean/Chapter.dart';

/// 书籍详细界面
class BookDetailPage extends StatefulWidget {
  final ValueChanged<bool> hideBottom;
  final BklistItem bklistItem;

  BookDetailPage({this.hideBottom, this.bklistItem});

  @override
  _BookDetailPageState createState() =>
      new _BookDetailPageState(hideBottom, bklistItem);
}

class _BookDetailPageState extends State<BookDetailPage> {
  final ValueChanged<bool> hideBottom;
  final BklistItem bklistItem;
  BkDetail _bkDetail = new BkDetail();

  _BookDetailPageState(this.hideBottom, this.bklistItem) {
    _bkDetail.img = bklistItem.img;
    _bkDetail.name = bklistItem.title;
    _bkDetail.author = bklistItem.author;
  }

  SavedBookDao dao;
  @override
  void initState() {
    super.initState();
    init();
    loadingBookDetail();
  }

  Future init() async {
    dao = await SavedBookDao.getInstance();
    _isSaved = await dao.hasBook(bklistItem.bookID);
    setState(() {
      _isSaved = _isSaved;
    });
  }

  var _chapterID = "";

  void loadingBookDetail() async {
    var url = Tools.baseurl + bklistItem.url;
    print(url);
    http.get(url).then((response) {
      var doc = parser.parse(response.body);

      if (mounted)
        return setState(() {
          _bkDetail.readUrl = doc
              .querySelector("meta[property=\"og:url\"]")
              .attributes["content"];
          var l = _bkDetail.readUrl.substring(0, _bkDetail.readUrl.length - 1);
          _bkDetail.bookid = l.substring(l.lastIndexOf("/") + 1);

          doc.querySelector("div.directoryArea").children.forEach((element) {
            _bkDetail.chapters.add(Chapter(_bkDetail.bookid, element.text,
                Tools.getChapterID(element.querySelector("a").attributes["href"])));
          });
          _bkDetail.chapters.reversed;

          _bkDetail.name = doc
              .querySelector("meta[property=\"og:title\"]")
              .attributes["content"];
          _bkDetail.prewtext = doc
              .querySelector("meta[property=\"og:description\"]")
              .attributes["content"];
          _bkDetail.img = doc
              .querySelector("meta[property=\"og:image\"]")
              .attributes["content"];
          _bkDetail.type = doc
              .querySelector("meta[property=\"og:novel:category\"]")
              .attributes["content"];
          _bkDetail.author = doc
              .querySelector("meta[property=\"og:novel:author\"]")
              .attributes["content"];

          _bkDetail.state = doc
              .querySelector("meta[property=\"og:novel:status\"]")
              .attributes["content"];
          _bkDetail.updateDate = doc
              .querySelector("meta[property=\"og:novel:update_time\"]")
              .attributes["content"];
          _bkDetail.newName = doc
              .querySelector("meta[property=\"og:novel:latest_chapter_name\"]")
              .attributes["content"];
          _bkDetail.newUrl = doc
              .querySelector("meta[property=\"og:novel:latest_chapter_url\"]")
              .attributes["content"];
          _isLoading = false;

          _chapterID = Tools.getChapterID(_bkDetail.newUrl);
        });
    });
  }

  bool _isSaved = false;

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: _onWillPop,
        child: new Scaffold(
          appBar: new AppBar(
            title: new Text("${bklistItem.title}"),
            actions: <Widget>[
              new IconButton(
                  icon: new Icon(
                    _isSaved ? Icons.star : Icons.star_border,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    judeSave();
                  }),
              new IconButton(
                  icon: new Icon(
                    Icons.share,
                    color: Colors.white,
                  ),
                  onPressed: null)
            ],
          ),
          body: buildBody(),
        ));
  }

  Future judeSave() async {
    //print(await dao.get(_bkDetail.bookid));
    if (_isSaved) {
      await dao.delete(_bkDetail.bookid);
      Tools.showSnake(context, "已取消收藏");
      setState(() {
        _isSaved = false;
      });
    } else {
      await dao.insertOrUpdate(new SavedBook(
          _bkDetail.name,
          _bkDetail.img,
          _bkDetail.author,
          _bkDetail.bookid,
          _bkDetail.newName,
          Tools.getChapterID(_bkDetail.newUrl),
          "",
          ""));
      setState(() {
        _isSaved = true;
      });
      Tools.showSnake(context, "收藏成功");
    }

    //print(await dao.get(_bkDetail.bookid));
  }

  bool _isLoading = true;

  Widget buildBody() {
    if (_isLoading) {
      return new Center(child: CircularProgressIndicator());
    }

    return new SingleChildScrollView(
        child: new Column(children: <Widget>[
      //顶部详情
      new Padding(
          padding: new EdgeInsets.all(15.0),
          child: new SizedBox(
            height: 120.0,
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Image.network(
                  bklistItem.img,
                  width: 90.0,
                  height: 120.0,
                ),
                new Expanded(
                    child: new Padding(
                        padding: new EdgeInsets.only(right: 10.0),
                        child: new Padding(
                            padding: new EdgeInsets.only(left: 10.0),
                            child: new Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Text("作者：" + _bkDetail.author,
                                    style: Tools.buildTitle(16)),
                                new Text("类别：" + _bkDetail.type,
                                    style: Tools.buildSubTitle(13)),
                                new Text("状态：" + _bkDetail.state,
                                    style: Tools.buildSubTitle(13)),
                                new Text(
                                  "更新：" + _bkDetail.updateDate,
                                  style: Tools.buildSubTitle(13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                new GestureDetector(
                                    onTapUp: (_) {
                                      jumpToReader(new Chapter(_bkDetail.bookid,
                                          _bkDetail.newName, _chapterID));
                                    },
                                    child: new Text("最新：" + _bkDetail.newName,
                                        style: Tools.buildSubTitle(13))),
                              ],
                            ))))
              ],
            ),
          )),
      new Padding(
        padding: new EdgeInsets.only(left: 10.0, right: 10.0, top: 5.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Expanded(
                child: new Padding(
                    padding: new EdgeInsets.only(right: 5.0),
                    child: new RaisedButton(
                      onPressed: () {
                        Navigator.of(context).push(new MyCustomRoute(
                            builder: (_) => new AllChapterPage(_bkDetail.bookid,
                                _bkDetail.name, bklistItem.url, hideBottom)));
                      },
                      color: new Color(0xFF6AABF2),
                      textColor: Colors.white,
                      child: new Text("开始阅读"),
                    ))),
          ],
        ),
      ),
      new Padding(
        padding: new EdgeInsets.all(15.0),
        child: new Text(
          html2md.convert(_bkDetail.prewtext),
          style: Tools.buildSubTitle(13),
        ),
      ),
      new Padding(
          padding: new EdgeInsets.only(top: 10.0),
          child: new Row(children: <Widget>[
            new Expanded(
                child: new SizedBox(
              height: 35.0,
              child: new Container(
                  color: Theme.of(context).primaryColor,
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Padding(
                          padding: new EdgeInsets.only(left: 15.0),
                          child: new Text("更新时间：" + _bkDetail.updateDate,
                              style: Tools.buildStyle(Colors.white, 13))),
                      new Padding(
                          padding: new EdgeInsets.only(right: 15.0),
                          child: new GestureDetector(
                              onTapUp: (_) {
                                Navigator.of(context).push(new MyCustomRoute(
                                    builder: (_) => new AllChapterPage(
                                        _bkDetail.bookid,
                                        _bkDetail.name,
                                        bklistItem.url,
                                        hideBottom)));
                              },
                              child: new Text("全部章节",
                                  style: Tools.buildStyle(Colors.white, 13)))),
                    ],
                  )),
            ))
          ])),
      new Padding(
          padding: new EdgeInsets.all(10.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _bkDetail.chapters.reversed
                .map((chapter) => new SizedBox(
                    height: 40.0,
                    child: new Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          new Expanded(
                              child: new GestureDetector(
                                  onTapUp: (_) {
                                    jumpToReader(new Chapter(_bkDetail.bookid,
                                        chapter.name, chapter.chapterid));
                                  },
                                  child: new Text(
                                    chapter.name,
                                    style: Tools.buildSubTitle(14),
                                  )))
                        ])))
                .toList(),
          )),
    ]));
  }

  Widget buildList(BuildContext context, int index) {
    var item = _bkDetail.chapters[index];
    return new Text(item.name);
  }

  Future<bool> _onWillPop() {
    hideBottom(false);
    return new Future.value(true);
  }

  jumpToReader(Chapter chpter) {
    Navigator.push(context,
        new MyCustomRoute(builder: (_) => new ReaderPage(chpter, hideBottom)));
  }

  @override
  void dispose() {
    //dao.close();
    super.dispose();
  }
}
