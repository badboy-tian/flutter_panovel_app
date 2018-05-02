import 'dart:async';
import 'package:panovel_app/utils/Tools.dart';
import 'package:sqflite/sqflite.dart';

final String columnId = "_id";
final String c_name = "name";
final String c_img = "img";
final String c_author = "author";
final String c_bookid = "bookid";
final String c_lastChapterName = "lastChapterName";
final String c_lastChapterID = "lastChapterID";
final String c_newChapterName = "newChapterName";
final String c_newChapterID = "newChapterID";

final String table = "SavedBook";

class SavedBook {
  int id;
  String name;
  String img;
  String author;
  String bookid;

  String lastChapterName;
  String lastChapterID;

  String newChapterName;
  String newChapterID;

  SavedBook(this.name, this.img, this.author, this.bookid, this.lastChapterName,
      this.lastChapterID, this.newChapterName, this.newChapterID);

  @override
  String toString() {
    return 'SavedBook{name: $name, img: $img, author: $author, bookid: $bookid, lastChapterName: $lastChapterName, lastChapterID: $lastChapterID, newChapterName: $newChapterName, newChapterID: $newChapterID}';
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      c_name: name,
      c_img: img,
      c_author: author,
      c_bookid: bookid,
      c_lastChapterName: lastChapterName,
      c_lastChapterID: lastChapterID,
      c_newChapterName: newChapterName,
      c_newChapterID: newChapterID
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  SavedBook.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map[c_name];
    img = map[c_img];
    author = map[c_author];
    bookid = map[c_bookid];
    lastChapterName = map[c_lastChapterName];
    lastChapterID = map[c_lastChapterID];
    newChapterName = map[c_newChapterName];
    newChapterID = map[c_newChapterID];
  }
}

class SavedBookDao {
  Database db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute("""
CREATE TABLE $table ( 
  $columnId integer primary key autoincrement, 
  $c_name text not null,
  $c_img text not null,
  $c_author text not null,
  $c_bookid text not null,
  $c_lastChapterName text not null,
  $c_lastChapterID text not null,
  $c_newChapterName text not null,
  $c_newChapterID text not null)
""");
    });
  }

  Future<SavedBook> _insert(SavedBook book) async {
    book.id = await db.insert(table, book.toMap());
    return book;
  }

  Future<SavedBook> insertOrUpdate(SavedBook book) async {
    //print("insertOrUpdate:$book");
    var data = await get(book.bookid);
    if (data == null) {
      _insert(book);
    } else {
      book.id = data.id;
      book.lastChapterName = data.lastChapterName;
      book.lastChapterID = data.lastChapterID;
      update(book);
    }

    return book;
  }

  Future<SavedBook> get(String bookid) async {
    List<Map> maps = await db.query(table,
        columns: [
          columnId,
          c_name,
          c_img,
          c_author,
          c_bookid,
          c_lastChapterName,
          c_lastChapterID,
          c_newChapterName,
          c_newChapterID
        ],
        where: "$c_bookid = ?",
        whereArgs: [bookid]);
    if (maps.length > 0) {
      return new SavedBook.fromMap(maps.first);
    }
    return null;
  }

  Future<List<SavedBook>> loadAll() async {
    List<Map> maps = await db.query(table, columns: [
      columnId,
      c_name,
      c_img,
      c_author,
      c_bookid,
      c_lastChapterName,
      c_lastChapterID,
      c_newChapterName,
      c_newChapterID
    ]);
    if (maps.length > 0) {
      return maps.map((item) => SavedBook.fromMap(item)).toList();
    }
    return new List<SavedBook>();
  }

  Future<int> delete(String bookid) async {
    return await db.delete(table, where: "$c_bookid = ?", whereArgs: [bookid]);
  }

  Future<int> update(SavedBook book) async {
    return await db.update(table, book.toMap(),
        where: "$c_bookid = ?", whereArgs: [book.bookid]);
  }

  Future close() async => db.close();

  Future<bool> hasBook(String bookID) async {
    return await get(bookID) != null;
  }

  static SavedBookDao _instance;
  static Future<SavedBookDao> getInstance() async {
    if(_instance == null){
        var path = await Tools.initDeleteDb("book.db");
        _instance = new SavedBookDao();
        await _instance.open(path);
    }

    return _instance;
  }
}
