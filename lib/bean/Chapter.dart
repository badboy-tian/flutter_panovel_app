class Chapter{
  String bookid;
  String name;
  String chapterid;

  Chapter(this.bookid, this.name, this.chapterid);

  @override
  String toString() {
    return 'Chapter{bookid: $bookid, name: $name, chapterid: $chapterid}';
  }


}