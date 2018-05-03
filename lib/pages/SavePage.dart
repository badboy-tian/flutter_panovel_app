import 'package:panovel_app/bean/Chapter.dart';
import 'package:panovel_app/bean/SavedBook.dart';
import 'package:panovel_app/common.dart';
import 'package:panovel_app/pages/BookDetailPage.dart';
import 'package:panovel_app/pages/ReaderPage.dart';

/// 书架
class SavePage extends StatefulWidget {
  @override
  _SavePageState createState() => new _SavePageState();
}

class _SavePageState extends State<SavePage> {
  var _loading = true;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("追书"),
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if (_loading) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    }

    return new RefreshIndicator(
        child: new ListView.builder(
          itemBuilder: buildItem,
          itemCount: datas.length,
        ),
        onRefresh: _onRefresh);
  }

  Future<Null> _onRefresh() async {
    await loadData();
  }

  @override
  void initState() {
    super.initState();
    loadData();

    eventBus.on().listen((event) {
      if (event.toString() == "updateSaved") {
        loadData();
      } else if (event.toString() == "updateNewChapter") {
        loadData();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  var datas = <SavedBook>[];
  SavedBookDao dao;

  Future loadData() async {
    dao = await SavedBookDao.getInstance();
    var books = await dao.loadAll();
    await readNew();
    setState(() {
      datas.clear();
      datas.addAll(books);
      _loading = false;
    });
  }

  Future readNew() async {
    datas.forEach((book) async {
      var url = Tools.baseurl + "/" + book.bookid;
      print("readNew: " + url);
      var resp = await get(url);
      var doc = parse(resp.body);
      book.newChapterName = doc
          .querySelector("meta[property=\"og:novel:latest_chapter_name\"]")
          .attributes["content"];
      book.newChapterID = Tools.getChapterID(doc
          .querySelector("meta[property=\"og:novel:latest_chapter_url\"]")
          .attributes["content"]);
      dao.update(book);
    });
  }

  Widget buildItem(BuildContext context, int index) {
    var book = datas[index];
    return new Dismissible(
        background: new Container(color: Colors.red),
        onDismissed: (_) async {
          await dao.delete(book.bookid);
          datas.removeAt(index);
          setState(() {});
        },
        key: new Key(book.toString()),
        child: new InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  new MyCustomRoute(
                      builder: (_) => new BookDetailPage(bookid: book.bookid)));
            },
            child: new Container(
              child: new Row(
                children: <Widget>[
                  new Container(
                    child:
                        new Image.network(book.img, width: 60.0, height: 80.0),
                    padding: new EdgeInsets.only(
                        left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                  ),
                  new Expanded(
                      child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Row(
                        children: <Widget>[
                          new Text(book.name, style: Tools.buildTitle(14))
                        ],
                      ),
                      new Row(
                        children: <Widget>[
                          new Text(
                            "作者:  " + book.author,
                            style: Tools.buildSubTitle(12),
                          )
                        ],
                      ),
                      new GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                new MyCustomRoute(
                                    builder: (_) => new ReaderPage(new Chapter(
                                        book.bookid,
                                        book.newChapterName,
                                        book.newChapterID))));
                          },
                          child: new Row(
                            children: <Widget>[
                              new Text(
                                "最近更新:  ",
                                style: Tools.buildSubTitle(12),
                              ),
                              new Expanded(
                                  child: new Text(
                                book.newChapterName,
                                style: Tools.buildStyle(Colors.redAccent, 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),
                            ],
                          )),
                      new GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                new MyCustomRoute(
                                    builder: (_) => new ReaderPage(new Chapter(
                                        book.bookid,
                                        book.lastChapterName,
                                        book.lastChapterID))));
                          },
                          child: new Row(
                            children: <Widget>[
                              new Text(
                                "上次阅读:  ",
                                style: Tools.buildSubTitle(12),
                              ),
                              new Expanded(
                                  child: new Text(
                                book.lastChapterName,
                                style: Tools.buildStyle(Colors.redAccent, 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),
                            ],
                          ))
                    ],
                  ))
                ],
              ),
              decoration: new BoxDecoration(
                  border: new Border(
                      bottom:
                          new BorderSide(color: Tools.lineColor, width: 0.5))),
            )));
  }
}
