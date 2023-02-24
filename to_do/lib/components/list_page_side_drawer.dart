import 'package:flutter/material.dart';

import '../managers/auth_manager.dart';


class ListPageSideDrawer extends StatelessWidget {
  final Function() showAllCallback;
  final Function() showOnlyMineCallback;
  const ListPageSideDrawer({
    required this.showAllCallback,
    required this.showOnlyMineCallback,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        // Important: Remove any padding from the ListView.
        // padding: EdgeInsets.zero,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const Text(
              "To Do List",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 28.0,
                color: Colors.white,
              ),
            ),
          ),

          ListTile(
            title: const Text("Show Events For Project"),
            leading: const Icon(Icons.people),
            onTap: () {
              showAllCallback();
              Navigator.of(context).pop();
            },
          ),
          const Spacer(),
          ListTile(
            title: const Text("Logout"),
            leading: const Icon(Icons.logout),
            onTap: () {
              Navigator.of(context).pop();
              AuthManager.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}