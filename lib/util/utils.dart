import 'package:intl/intl.dart';

class Val {
  // Validations
  static String ValidateTitle(String val) {
    return (val != null && val != "") ? null : "Title cannot be empty";
  }

  static String GetExpiryStr(String expires) {
    var e = DateUtils.convertToDate(expires);
    var td = new DateTime.now();

    Duration dif = e.difference(td);
    int dd = dif.inDays + 1;
    return (dd > 0) ? dd.toString() : "0";
  }

  static bool StrToBool(String str) {
    return (int.parse(str) > 0) ? true : false;
  }

  static bool IntToBool(int val) {
    return (val > 0) ? true : false;
  }

  static String BoolToStr(bool val) {
    return (val == true) ? "1" : "0";
  }

  static int BoolToInt(bool val) {
    return (val == true) ? 1 : 0;
  }
}

class DateUtils {
  static DateTime convertToDate(String input) {
    try
    {
      var d = new DateFormat("yyyy-MM-dd").parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  static String convertToDateFull(String input) {
    try
    {
      var d = new DateFormat("yyyy-MM-dd").parseStrict(input);
      var formatter = new DateFormat('dd MMM yyyy');
      return formatter.format(d);
    } catch (e) {
      return null;
    }
  }

  static String convertToDateFullDt(DateTime input) {
    try
    {
      var formatter = new DateFormat('dd MMM yyyy');
      return formatter.format(input);
    } catch (e) {
      return null;
    }
  }

  static bool isDate(String dt) {
    try
    {
      var d = new DateFormat("yyyy-MM-dd").parseStrict(dt);
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool isValidDate(String dt) {
    if (dt.isEmpty || !dt.contains("-") || dt.length < 10) return false;

    List<String> dtItems = dt.split("-");
    var d = DateTime(int.parse(dtItems[0]),
        int.parse(dtItems[1]), int.parse(dtItems[2]));

    return d != null && isDate(dt) &&
        d.isAfter(new DateTime.now());
  }

  // String functions
  static String daysAheadAsStr(int daysAhead) {
    var now = new DateTime.now();
    DateTime ft = now.add(new Duration(days: daysAhead));
    return ftDateAsStr(ft);
  }

  static String ftDateAsStr(DateTime ft) {
    return ft.year.toString() + "-" +
        ft.month.toString().padLeft(2, "0") + "-" +
        ft.day.toString().padLeft(2, "0");
  }

  static String TrimDate(String dt) {
    if (dt.contains(" ")) {
      List<String> p = dt.split(" ");
      return p[0];
    }
    else
      return dt;
  }
}