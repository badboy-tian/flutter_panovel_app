import 'package:panovel_app/bean/BklistItem.dart';
import 'package:panovel_app/pages/BookDetailPage.dart';
import 'package:panovel_app/common.dart';

/// 主页的子item
class HomeSubPage extends StatefulWidget {
  final int index;
  final ValueChanged<bool> hideBottom;

  HomeSubPage({Key key, this.index, this.hideBottom}) : super(key: key);

  @override
  _HomeItemState createState() => new _HomeItemState(index, this.hideBottom);
}

class _HomeItemState extends State<HomeSubPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  List<BklistItem> _datas = [];
  var index = 1;
  final ValueChanged<bool> hideBottom;
  ScrollController _scroller;

  _HomeItemState(this.index, this.hideBottom);

  @override
  Widget build(BuildContext context) {
    var content;
    if (_datas.isEmpty) {
      content = new Center(child: new CircularProgressIndicator());
    } else {
      content = new NotificationListener(
          onNotification: onNotification,
          child: new RefreshIndicator(
              key: _refreshIndicatorKey,
              child: new ListView.builder(
                physics: new AlwaysScrollableScrollPhysics(),
                controller: _scroller,
                itemCount: _datas.length,
                itemBuilder: buildBkItem,
                padding: new EdgeInsets.only(top: 10.0, bottom: 10.0),
              ),
              onRefresh: refresh));
    }

    return content;
  }

  bool onNotification(Notification notification) {
    if (notification is OverscrollNotification) {
      if (!isLoadingmore) {
        isLoadingmore = true;
        print("loading more");
        if (_currentPage > _totalPage) return true;
        setState(() {
          _currentPage++;
        });
        loadDatas(false);
      }
    }

    return true;
  }

  Future<Null> refresh() async {
    setState(() {
      _currentPage = 1;
    });
    await loadDatas(true);
  }

  @override
  void initState() {
    super.initState();
    _scroller = new ScrollController();
    //初始化加载数据
    loadDatas(false);
  }

  bool isLoadingmore = false;
  int _currentPage = 1;
  int _totalPage = 1;

  Future loadDatas(bool refresh) async {
    var url = "${Tools.baseurl}/bqgclass/$index/$_currentPage.html";
    print(url);
    var response = await get(url);
    var html = parse(response.body);
    var itemData = html.getElementsByClassName("hot_sale");
    _totalPage = int.parse(
        html.getElementById("txtPage").attributes["value"].split("/")[1]);

    if (isLoadingmore) {
      isLoadingmore = false;
    }
    if (!mounted) return;
    setState(() {
      if (refresh) {
        _datas.clear();
      }
      _datas.addAll(BklistItem.parse(itemData));
    });
  }

  Widget buildBkItem(BuildContext context, int index) {
    var item = _datas[index];
    return new InkWell(
        onTap: () {
          print(item.url);
          if (hideBottom != null) {
            hideBottom(true);
          }
          Navigator.push(
              context,
              new MyCustomRoute(
                  builder: (_) => new BookDetailPage(bookid: item.bookID)));
        },
        child: new Container(
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                child: new Image.network(item.img, width: 60.0, height: 80.0),
                padding: new EdgeInsets.only(
                    left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
              ),
              new Expanded(
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                    new Row(
                      children: <Widget>[
                        new Text(
                          item.title,
                          style: new TextStyle(
                              fontSize: 15.0, color: new Color(0xFF212121)),
                        )
                      ],
                    ),
                    new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new Text(
                            item.review,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: new TextStyle(
                                fontSize: 12.0, color: new Color(0xFF757575)),
                          ),
                        )
                      ],
                    ),
                    new Row(
                      children: <Widget>[
                        new Text(
                          item.author,
                          style: new TextStyle(
                              fontSize: 12.0, color: new Color(0xFF757575)),
                        )
                      ],
                    ),
                  ]))
            ],
          ),
          decoration: new BoxDecoration(
              border: new Border(
                  bottom: new BorderSide(color: Tools.lineColor, width: 0.5))),
        ));
  }
}
