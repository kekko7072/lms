import 'package:flutter/material.dart';

class LeftMenu extends StatelessWidget {
  const LeftMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Groups',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Group 1'),
            onTap: () {
              // Do something when the user taps on this menu item
            },
          ),
          ListTile(
            title: const Text('Group 2'),
            onTap: () {
              // Do something when the user taps on this menu item
            },
          ),
          ListTile(
            title: const Text('Group 3'),
            onTap: () {
              // Do something when the user taps on this menu item
            },
          ),
        ],
      ),
    );
  }
}
