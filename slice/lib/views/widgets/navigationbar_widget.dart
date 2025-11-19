import 'package:flutter/material.dart';
import 'package:slice/data/notifiers.dart';

class NavigationbarWidget extends StatefulWidget {
  const NavigationbarWidget({super.key});

  @override
  State<NavigationbarWidget> createState() => _NavigationbarState();
}

class _NavigationbarState extends State<NavigationbarWidget> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentPageNotifier,
      builder: (context, currentPage, child) {
        return NavigationBar(
          height: 60.0,
          backgroundColor: Color.fromRGBO(153, 226, 145, 1),
          destinations: [
            NavigationDestination(
              icon: Padding(
                padding: EdgeInsets.only(top: 15.0),
                child: Icon(
                  Icons.home_rounded,
                  size: 35.0,
                  color: Colors.black,
                ),
              ),
              label: "",
            ),
            NavigationDestination(
              icon: Padding(
                padding: EdgeInsets.only(top: 15.0),
                child: Icon(
                  Icons.add_box_outlined,
                  size: 35.0,
                  color: Colors.black,
                ),
              ),
              label: "",
            ),
            NavigationDestination(
              icon: Padding(
                padding: EdgeInsets.only(top: 15.0),
                child: Icon(
                  Icons.account_circle,
                  size: 35.0,
                  color: Colors.black,
                ),
              ),
              label: "",
            ),
          ],
          onDestinationSelected: (int value) {
            currentPageNotifier.value = value;
          },
          selectedIndex: currentPage,
        );
      },
    );
  }
}
