import 'package:flutter/material.dart';
import 'package:slice/data/notifiers.dart';
import 'package:slice/login_page.dart';
import 'package:slice/views/pages/addfriend_page.dart';
import 'package:slice/views/pages/creategroup_page.dart';
import 'package:slice/views/pages/home_page.dart';
import 'package:slice/views/pages/profile_page.dart';
import 'widgets/navigationbar_widget.dart';

List<Widget> pages = [
  HomePage(),
  CreateGroupPage(),
  ProfilePage(),
];


class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 255, 245, 1),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(246, 255, 245, 1),
        toolbarHeight: 80,
        title: Text(
          "Chats",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add, size: 35, color: Colors.black),
            tooltip: 'Add Friend',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return AddFriendPage();
              },));

            },
          ),
        ],
      ),

      body: ValueListenableBuilder(valueListenable: currentPageNotifier, builder:(context, currentPage, child) {
        return pages.elementAt(currentPage);
      },),

      // body: SingleChildScrollView(
      //   child: Column(
      //     children: <Widget>[
      //       SafeArea(
      //         child: Padding(
      //           padding: EdgeInsets.only(left: 16,top: 16),
      //           child: Row(
      //             children: <Widget>[
      //               Text("[Insert Conversations]",style: TextStyle(fontSize: 20),)
      //             ]
      //           )
      //         )
      //       )
      //     ]
      //   ),
      // ),
      bottomNavigationBar: NavigationbarWidget()
    );
  }
}