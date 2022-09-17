import 'package:driver_app/tabPages/earningTabPage.dart';
import 'package:driver_app/tabPages/homeTabPage.dart';
import 'package:driver_app/tabPages/profileTabPage.dart';
import 'package:driver_app/tabPages/ratingTabPage.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "MainScreen";

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  int selectedindex = 0;

  void onItemClicked(int index) {
    setState(() {
      selectedindex = index;
      tabController.index = selectedindex;
    });
  }

  @override
  void initState() {
    super.initState();
    tabController = new TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          controller: tabController,
          children: [
            HomeTabPage(),
            EarningTabPage(),
            ProfileTabPage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.credit_card),
              label: 'Earnings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Account',
            ),
          ],
          unselectedItemColor: Colors.black54,
          selectedItemColor: Colors.yellow,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontSize: 12.0),
          showSelectedLabels: true,
          currentIndex: selectedindex,
          onTap: onItemClicked,
        ));
  }
}
