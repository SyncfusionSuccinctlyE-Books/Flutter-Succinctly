import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import '../model/model.dart';
import '../util/utils.dart';
import '../util/dbhelper.dart';

// Menu item
const menuDelete = "Delete";
final List<String> menuOptions = const <String> [
  menuDelete
];

class DocDetail extends StatefulWidget {
  Doc doc;
  final DbHelper dbh = DbHelper();

  DocDetail(this.doc);

  @override
  State<StatefulWidget> createState() => DocDetailState();
}

class DocDetailState extends State<DocDetail> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final int daysAhead = 5475; // 15 years in the future

  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController expirationCtrl = MaskedTextController(
      mask: '2000-00-00');

  bool fqYearCtrl = true;
  bool fqHalfYearCtrl = true;
  bool fqQuarterCtrl = true;
  bool fqMonthCtrl = true;
  bool fqLessMonthCtrl = true;

  // Initialization code
  void _initCtrls() {
    titleCtrl.text = widget.doc.title != null ? widget.doc.title : "";
    expirationCtrl.text = widget.doc.expiration != null ? widget.doc.expiration : "";

    fqYearCtrl = widget.doc.fqYear != null ? Val.IntToBool(widget.doc.fqYear) : false;
    fqHalfYearCtrl = widget.doc.fqHalfYear != null ? Val.IntToBool(widget.doc.fqHalfYear) : false;
    fqQuarterCtrl = widget.doc.fqQuarter != null ? Val.IntToBool(widget.doc.fqQuarter) : false;
    fqMonthCtrl = widget.doc.fqMonth != null ? Val.IntToBool(widget.doc.fqMonth) : false;
  }

  // Date Picker & Date functions
  Future _chooseDate(BuildContext context, String initialDateString) async {
    var now = new DateTime.now();
    var initialDate = DateUtils.convertToDate(initialDateString) ?? now;

    initialDate = (initialDate.year >= now.year && initialDate.isAfter(now) ? initialDate : now);

    DatePicker.showDatePicker(context, showTitleActions: true,
        onConfirm: (date) {
          setState(() {
            DateTime dt = date;
            String r = DateUtils.ftDateAsStr(dt);
            expirationCtrl.text = r;
          });
        },
        currentTime: initialDate);
  }

  // Upper Menu
  void _selectMenu(String value) async {
    switch (value) {
      case menuDelete:
        if (widget.doc.id == -1) {
          return;
        }
        await _deleteDoc(widget.doc.id);
    }
  }

  // Delete doc
  void _deleteDoc(int id) async {
    int r = await widget.dbh.deleteDoc(widget.doc.id);
    Navigator.pop(context, true);
  }

  // Save doc
  void _saveDoc () {
    widget.doc.title = titleCtrl.text;
    widget.doc.expiration = expirationCtrl.text;

    widget.doc.fqYear = Val.BoolToInt(fqYearCtrl);
    widget.doc.fqHalfYear = Val.BoolToInt(fqHalfYearCtrl);
    widget.doc.fqQuarter = Val.BoolToInt(fqQuarterCtrl);
    widget.doc.fqMonth = Val.BoolToInt(fqMonthCtrl);

    if (widget.doc.id > -1) {
      debugPrint("_update->Doc Id: " + widget.doc.id.toString());
      widget.dbh.updateDoc(widget.doc);
      Navigator.pop(context, true);
    }
    else {
      Future<int> idd = widget.dbh.getMaxId();
      idd.then((result) {
        debugPrint("_insert->Doc Id: " + widget.doc.id.toString());
        widget.doc.id = (result != null) ? result + 1 : 1;
        widget.dbh.insertDoc(widget.doc);
        Navigator.pop(context, true);
      });
    }
  }

  // Submit form
  void _submitForm() {
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      showMessage('Some data is invalid. Please correct.');
    } else {
      _saveDoc();
    }
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(backgroundColor: color, content: new Text(message)));
  }

  @override
  void initState() {
    super.initState();
    _initCtrls();
  }

  @override
  Widget build(BuildContext context) {
    const String cStrDays = "Enter a number of days";
    TextStyle tStyle = Theme.of(context).textTheme.title;
    String ttl = widget.doc.title;

    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
            title: Text(ttl != "" ? widget.doc.title : "New Document"),
            actions: (ttl == "") ? <Widget>[]: <Widget>[
              PopupMenuButton(
                onSelected: _selectMenu,
                itemBuilder: (BuildContext context) {
                  return menuOptions.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            ]
        ),
        body: Form(
            key: _formKey,
            autovalidate: true,
            child: SafeArea(
              top: false,
              bottom: false,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: <Widget>[
                  TextFormField (
                    inputFormatters: [
                      WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9 ]"))
                    ],
                    controller: titleCtrl,
                    style: tStyle,
                    validator: (val) => Val.ValidateTitle(val),
                    decoration: InputDecoration(
                      icon: const Icon(Icons.title),
                      hintText: 'Enter the document name',
                      labelText: 'Document Name',
                    ),
                  ),
                  Row(children: <Widget>[
                    Expanded(
                        child: TextFormField(
                          controller: expirationCtrl,
                          maxLength: 10,
                          decoration: InputDecoration(
                              icon: const Icon(Icons.calendar_today),
                              hintText: 'Expiry date (i.e. ' + DateUtils.daysAheadAsStr(daysAhead) + ')',
                              labelText: 'Expiry Date'
                          ),
                          keyboardType: TextInputType.number,
                          validator: (val) => DateUtils.isValidDate(val) ? null :
                            'Not a valid future date',
                        )),
                    IconButton(
                      icon: new Icon(Icons.more_horiz),
                      tooltip: 'Choose date',
                      onPressed: (() {
                        _chooseDate(context, expirationCtrl.text);
                      }),
                    )
                  ]),
                  Row(children: <Widget>[
                    Expanded(child: Text(' ')),
                  ]),
                  Row(children: <Widget>[
                    Expanded(child: Text('a: Alert @ 1.5 & 1 year(s)')),
                    Switch(
                        value: fqYearCtrl, onChanged: (bool value) {
                      setState(() {
                        fqYearCtrl = value;
                      });
                    }),
                  ]),
                  Row(children: <Widget>[
                    Expanded(child: Text('b: Alert @ 6 months')),
                    Switch(
                        value: fqHalfYearCtrl, onChanged: (bool value) {
                      setState(() {
                        fqHalfYearCtrl = value;
                      });
                    }),
                  ]),
                  Row(children: <Widget>[
                    Expanded(child: Text('c: Alert @ 3 months')),
                    Switch(
                        value: fqQuarterCtrl, onChanged: (bool value) {
                      setState(() {
                        fqQuarterCtrl = value;
                      });
                    }),
                  ]),
                  Row(children: <Widget>[
                    Expanded(child: Text('d: Alert @ 1 month or less')),
                    Switch(
                        value: fqMonthCtrl, onChanged: (bool value) {
                      setState(() {
                        fqMonthCtrl = value;
                      });
                    }),
                  ]),
                  Container(
                      padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                      child: RaisedButton(
                        child: Text("Save"),
                        onPressed: _submitForm,
                      )
                  ),
                ],
              ),
            )));
  }
}