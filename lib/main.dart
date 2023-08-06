import 'package:example/screen/safer.dart';
import 'package:flutter/material.dart';
import 'package:example/screen/Remote.dart';
import 'package:example/public/menu_bottom.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void onItemTapped(int index) {
    setState(() {
      selectIndex = index;
    });

    print(selectIndex);
  }

  // 각 탭에 표시할 콘텐츠 위젯들을 리스트로 준비합니다.
  final List<Widget> _tabs = [
    Safer(),    // 0
    Remote(),   // 1
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[selectIndex], // 현재 선택된 탭에 해당하는 콘텐츠를 표시
      bottomNavigationBar: BottomNavigationBar(
        onTap: onItemTapped,
        currentIndex: selectIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Safer'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_remote), label: 'Remote'),
        ],
      ),
    );
  }


  // 탭이 선택되었을 때 호출되는 함수
  void _onTabTapped(int index) {
    setState(() {
      selectIndex = index; // 선택된 탭의 인덱스를 변경하고 화면을 다시 그립니다.
    });
  }


}