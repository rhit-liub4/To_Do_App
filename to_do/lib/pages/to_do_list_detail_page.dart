import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../managers/auth_manager.dart';
import '../managers/to_do_list_collection_manager.dart';
import '../managers/to_do_list_document_manager.dart';

class ToDoListDetailPage extends StatefulWidget {
  final String documentId;
  const ToDoListDetailPage(this.documentId, {super.key});

  @override
  State<ToDoListDetailPage> createState() => _ToDoListDetailPageState();
}

class _ToDoListDetailPageState extends State<ToDoListDetailPage> {
  final notesTextController = TextEditingController();
  final descTextController = TextEditingController();
  final titleTextController = TextEditingController();

  StreamSubscription? toDoListSubscription;

  @override
  void initState() {
    super.initState();

    toDoListSubscription =
        ToDoListDocumentManager.instance.startListening(
      widget.documentId,
      () {
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    notesTextController.dispose();
    descTextController.dispose();
    titleTextController.dispose();
    ToDoListDocumentManager.instance.stopListening(toDoListSubscription);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showEditDelete =
        ToDoListDocumentManager.instance.latestToDoList != null &&
            AuthManager.instance.uid.isNotEmpty &&
            AuthManager.instance.uid ==
                ToDoListDocumentManager
                    .instance.latestToDoList!.authorUid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("To Do List"),
        actions: [
          Visibility(
            visible: showEditDelete,
            child: IconButton(
              onPressed: () {
                showEditToDoDialog(context);
              },
              icon: const Icon(Icons.edit),
            ),
          ),
          Visibility(
            visible: showEditDelete,
            child: IconButton(
              onPressed: () {
                final justDeletedNotes =
                    ToDoListDocumentManager.instance.latestToDoList!.notes;
                final justDeletedDesc = ToDoListDocumentManager
                    .instance.latestToDoList!.desc;
                final justDeletedTitle =
                    ToDoListDocumentManager.instance.latestToDoList!.title;

                ToDoListDocumentManager.instance.delete();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Event Deleted'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        ToDoListCollectionManager.instance.add(
                          notes: justDeletedNotes,
                          desc: justDeletedDesc,
                          title: justDeletedTitle,
                        );
                      },
                    ),
                  ),
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.cancel),
            ),

          ),
          Visibility(
            visible: showEditDelete,
            child: IconButton(
              onPressed: () {
                final justDeletedNotes =
                    ToDoListDocumentManager.instance.latestToDoList!.notes;
                final justDeletedDesc =
                    ToDoListDocumentManager.instance.latestToDoList!.desc;
                final justDeletedTitle =
                    ToDoListDocumentManager.instance.latestToDoList!.title;

                ToDoListDocumentManager.instance.delete();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Event Completed!'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        ToDoListCollectionManager.instance.add(
                          notes: justDeletedNotes,
                          desc: justDeletedDesc,
                          title: justDeletedTitle,
                        );
                      },
                    ),
                  ),
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.done),
            ),

          ),
          // const SizedBox(
          //   width: 40.0,
          // ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            LabelledTextDisplay(
              title: "Title:",
              content: ToDoListDocumentManager
                      .instance.latestToDoList?.title ??
                  "",
              iconData: Icons.title,
            ),
            LabelledTextDisplay(
              title: "Description:",
              content: ToDoListDocumentManager
                  .instance.latestToDoList?.desc ??
                  "",
              iconData: Icons.description,
            ),
            LabelledTextDisplay(
              title: "Notes:",
              content: ToDoListDocumentManager
                  .instance.latestToDoList?.notes ??
                  "",
              iconData: Icons.notes,
            ),

            LabelledTextDisplay(
              title: "Event Made by:",
              content: ToDoListDocumentManager.instance.latestToDoList?.authorUid ?? AuthManager.instance.email,
              iconData: Icons.person,
            ),


          ],
        ),
      ),
    );
  }

  Future<void> showEditToDoDialog(BuildContext context) {
    notesTextController.text =
        ToDoListDocumentManager.instance.latestToDoList?.notes ?? "";
    descTextController.text =
        ToDoListDocumentManager.instance.latestToDoList?.desc ?? "";
    titleTextController.text =
        ToDoListDocumentManager.instance.latestToDoList?.title ?? "";

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit this Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4.0),
                child: TextFormField(
                  controller: titleTextController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Title:',
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
                    labelText: 'Description:',
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
                    labelText: 'Notes:',
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
              child: const Text('Update'),
              onPressed: () {
                setState(() {
                  ToDoListDocumentManager.instance.update(
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
}

class LabelledTextDisplay extends StatelessWidget {
  final String title;
  final String content;
  final IconData iconData;

  const LabelledTextDisplay({
    super.key,
    required this.title,
    required this.content,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.w800,
                fontFamily: "Caveat"),
          ),
          Card(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Icon(iconData),
                  const SizedBox(
                    width: 8.0,
                  ),
                  Flexible(
                    child: Text(
                      content,
                      style: const TextStyle(
                        fontSize: 18.0,
                        // fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
