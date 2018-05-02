import 'package:html/dom.dart' as dom;

class BklistItem {
  String img;
  String title;
  String author;
  String review;
  String url;
  String bookID;

  @override
  String toString() {
    return 'BklistItem{img: $img, title: $title, author: $author, review: $review, url: $url, bookID: $bookID}';
  }

  static List<BklistItem> parse(List<dom.Element> es) {
    List<BklistItem> datas = [];
    es.forEach((e) {
      var item = BklistItem();
      item.title = e.querySelector("p.title").text.trim();
      item.author = e.querySelector("p.author").text.trim();
      item.img = e.querySelector("img.lazy").attributes["data-original"].trim();
      item.review = e.querySelector("p.review").text.trim();
      item.url = e.querySelector("a").attributes["href"].trim();
      item.bookID = item.url.replaceAll("/", "");
      datas.add(item);
    });

    return datas;
  }
}