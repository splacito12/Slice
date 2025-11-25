import 'package:flutter/material.dart';
import 'package:slice/data/notifiers.dart';
import 'package:slice/views/pages/home_page.dart';
import 'package:slice/views/pages/profile_page.dart';
import 'widgets/navigationbar_widget.dart';

List<Widget> pages = [
  HomePage(),
  ProfilePage(),
];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(246, 255, 245, 1),

      body: ValueListenableBuilder(
        valueListenable: currentPageNotifier,
        builder: (context, currentPage, child) {
          return pages.elementAt(currentPage);
        },
      ),

      bottomNavigationBar: const NavigationbarWidget(),
    );
  }
}
