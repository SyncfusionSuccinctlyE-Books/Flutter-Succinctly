import '../util/utils.dart';

class Doc
{
  int id;
  String title;
  String expiration;

  int fqYear;

  int fqHalfYear;
  int fqQuarter;
  int fqMonth;

  Doc(this.title, this.expiration, this.fqYear,
      this.fqHalfYear, this.fqQuarter, this.fqMonth);

  Doc.withId(this.id, this.title, this.expiration, this.fqYear,
      this.fqHalfYear, this.fqQuarter, this.fqMonth);

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    map["title"] = this.title;
    map["expiration"] = this.expiration;

    map["fqYear"] = this.fqYear;
    map["fqHalfYear"] = this.fqHalfYear;
    map["fqQuarter"] = this.fqQuarter;
    map["fqMonth"] = this.fqMonth;

    if (id != null) {
      map["id"] = id;
    }

    return map;
  }

  Doc.fromOject(dynamic o) {
    this.id = o["id"];
    this.title = o["title"];
    this.expiration = DateUtils.TrimDate(o["expiration"]);

    this.fqYear = o["fqYear"];
    this.fqHalfYear = o["fqHalfYear"];
    this.fqQuarter = o["fqQuarter"];
    this.fqMonth = o["fqMonth"];
  }
}