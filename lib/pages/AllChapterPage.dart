import 'package:flutter/material.dart';
import 'package:panovel_app/bean/BkDetail.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:panovel_app/bean/Chapter.dart';
import 'package:panovel_app/pages/ReaderPage.dart';
import 'package:panovel_app/utils/MyCustomRoute.dart';
import 'package:panovel_app/utils/Tools.dart';

class AllChapterPage extends StatefulWidget {
  final String name;
  final String bookid;
  AllChapterPage(this.bookid, this.name);

  @override
  _AllChapterPageState createState() => new _AllChapterPageState(this.bookid, this.name);
}

class _AllChapterPageState extends State<AllChapterPage> {
  var _isLoading = true;
  var _scrollController = ScrollController();
  var _datas = <Chapter>[];
  final String name;
  final String bookid;
  _AllChapterPageState(this.bookid, this.name);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  var _title = "全部目录";
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(_title),
        actions: <Widget>[
          new IconButton(icon: Icon(Icons.share), onPressed: () {})
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.arrow_downward),
        onPressed: () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        },
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if (_isLoading) return new Center(child: new CircularProgressIndicator());
    return new ListView.builder(
      itemCount: _datas.length,
      controller: _scrollController,
      itemBuilder: buildItem,
    );
  }

  Widget buildItem(BuildContext context, int index) {
    var item = _datas[index];
    return new InkWell(
      child: new SizedBox(
          height: 40.0,
          child: new Container(
            child: new ListTile(
              title: new Text(
                item.name,
                style: TextStyle(color: Colors.black54),
              ),
              isThreeLine: false,
            ),
            decoration: new BoxDecoration(
                border: new Border(
                    bottom:
                    new BorderSide(color: Tools.lineColor, width: 0.5))),
          )),
      onTap: () {
        Navigator.push(context, new MyCustomRoute(builder: (_)=> new ReaderPage(new Chapter(bookid, item.name, item.chapterid))));
        print(index);
      },
    );
  }

  void loadData() async {
    var url = Tools.baseurl + "/" +  this.bookid + "/all.html";
    print(url);
    http.get(url).then((resp) {
      var root =  parser.parse(resp.body);
      root.querySelectorAll("div.directoryArea > p")
          .forEach((e) {
        var element = e.querySelector("a");
        var href = element.attributes["href"];
        if (href != "#bottom") {
          _datas.add(Chapter(bookid, element.text, Tools.getChapterID(href)));
        }
      });
      
      setState(() {
        _title = root.querySelector("header > span.title").text;
        _isLoading = false;
      });
    }).catchError((error) {
      print(error.toString());
    });
  }
}
