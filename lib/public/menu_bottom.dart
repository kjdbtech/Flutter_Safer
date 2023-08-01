import 'package:example/screen/Remote.dart';
import 'package:example/screen/safer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class MenuBottom extends StatefulWidget {

  const MenuBottom({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MenuBottomState();

}

class _MenuBottomState extends State<MenuBottom> {
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

  final List<Widget> tabList = <Widget> [
    Safer(),
    Remote()
  ];


  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: onItemTapped,
      currentIndex: selectIndex,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Safer'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_remote), label: 'Remote'),
      ],
    );
  }
}






