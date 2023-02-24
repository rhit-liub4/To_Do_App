import 'dart:async';

import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:to_do/managers/to_do_list_document_manager.dart';
import 'package:to_do/pages/to_do_list_detail_page.dart';


import '../components/list_page_side_drawer.dart';
import '../components/to_do_list_row_component.dart';
import '../managers/auth_manager.dart';
import '../managers/to_do_list_collection_manager.dart';
import '../models/to_do_list.dart';
import 'login_front_page.dart';

class ToDoListPage extends StatefulWidget {
  const ToDoListPage({super.key});

  @override
  State<ToDoListPage> createState() => _ToDoListPageState();
}

class _ToDoListPageState extends State<ToDoListPage> {
  final notesTextController = TextEditingController();
  final descTextController = TextEditingController();
  final titleTextController = TextEditingController();

  bool _isShowingAllEvents = true;

  UniqueKey? _loginObserverKey;
  UniqueKey? _logoutObserverKey;

  @override
  void initState() {
    super.initState();

    _showAllEvents();

    _loginObserverKey = AuthManager.instance.addLoginObserver(() {
      setState(() {});
    });

    _logoutObserverKey = AuthManager.instance.addLogoutObserver(() {
      _showAllEvents();
      setState(() {});
    });
  }

  void _showAllEvents() {
    setState(() {
      _isShowingAllEvents = true;
    });
  }

  void _showOnlyMyEvents() {
    setState(() {
      _isShowingAllEvents = false;
    });
  }

  @override
  void dispose() {
    notesTextController.dispose();
    descTextController.dispose();
    titleTextController.dispose();
    AuthManager.instance.removeObserver(_loginObserverKey);
    AuthManager.instance.removeObserver(_logoutObserverKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("To Do List \n Welcome ${!AuthManager.instance.isSignedIn
            ? "No User"
            : AuthManager.instance.email}"),
        actions: AuthManager.instance.isSignedIn
            ? null
            : [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (BuildContext context) {
                  return const LoginFrontPage();
                },
              ));
            },
            tooltip: "Log in",
            icon: const Icon(Icons.login),
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: FirestoreListView<ToDoList>(
        query: _isShowingAllEvents
            ? ToDoListCollectionManager.instance.allEventsQuery
            : ToDoListCollectionManager.instance.mineOnlyEventQuery,
        itemBuilder: (context, snapshot) {
          ToDoList mq = snapshot.data();
          return ToDoListRow(
            toDoList: mq,
            onTap: () async {
              //print("You clicked on the Event ${mq.notes} - ${mq.desc}");
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return ToDoListDetailPage(
                        mq.documentId!); // In Firebase use a documentId
                  },
                ),
              );
              setState(() {});
            },
            
          );
          
        },
      ),
      drawer: AuthManager.instance.isSignedIn
          ? ListPageSideDrawer(
        showAllCallback: () {
          print("ToDoListPage: Callback to Show all events");
          _showAllEvents();
        },
        showOnlyMineCallback: () {
          print("ToDoListPage: Callback to Show only my events");
          _showOnlyMyEvents();
        },
      )
          : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (AuthManager.instance.isSignedIn) {
            showCreateEventCaption(context);
          } else {
            showMustLogInDialog(context);
          }
        },
        tooltip: 'Create',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> showCreateEventCaption(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create a Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4.0),
              child: TextFormField(
                controller: titleTextController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter the Title',
                ),
              ),
            ),

              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4.0),
                child: TextFormField(
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 3,
                  controller: descTextController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Enter a Description',
                  ),
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4.0),
                child: TextFormField(
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 5,
                  controller: notesTextController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Enter some notes',
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Create'),
              onPressed: () {
                setState(() {
                  ToDoListCollectionManager.instance.add(
                    notes: notesTextController.text,
                    desc: descTextController.text,
                    title: titleTextController.text,
                  );
                  notesTextController.text = "";
                  descTextController.text = "";
                  titleTextController.text = "";
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showMustLogInDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Login Required"),
          content: const Text(
              "You must be signed in to post.  Would you like to sign in now?"),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text("Go sign in"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(
                  builder: (BuildContext context) {
                    return const LoginFrontPage();
                  },
                ));
              },
            ),
          ],
        );
      },
    );
  }
}
