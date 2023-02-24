import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../managers/to_do_list_collection_manager.dart';
import '../models/to_do_list.dart';

class ToDoListRow extends StatelessWidget {
  final ToDoList toDoList;
  final Function() onTap;
  final CollectionReference _ref = FirebaseFirestore.instance.collection(kToDoListCollectionPath);

  ToDoListRow({
    required this.toDoList,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 1.0),
        child: Card(
          child: ListTile(
            leading: const Icon(Icons.event),
            trailing: IconButton(
              onPressed: () {
                final justDeletedNotes =
                    toDoList.notes;
                final justDeletedDesc =
                    toDoList.desc;
                final justDeletedTitle =
                    toDoList.title;

                _ref.doc(toDoList.documentId).delete();

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
              },
              icon: const Icon(Icons.done_outline_sharp),
            ),
            title: Text(
              toDoList.title,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
