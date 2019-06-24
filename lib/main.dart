import 'package:flutter/material.dart';
import './ui/doclist.dart';

void main() => runApp(DocExpiryApp());

class DocExpiryApp extends StatelessWidget
{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DocExpire',
      theme: new ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: DocList(),
    );
  }
}