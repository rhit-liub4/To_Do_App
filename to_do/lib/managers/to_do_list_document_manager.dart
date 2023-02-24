import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/to_do_list.dart';


class ToDoListDocumentManager {
  ToDoList? latestToDoList;
  final CollectionReference _ref;

  static final ToDoListDocumentManager instance =
  ToDoListDocumentManager._privateConstructor();

  ToDoListDocumentManager._privateConstructor()
      : _ref = FirebaseFirestore.instance.collection(kToDoListCollectionPath);


  StreamSubscription startListening(String documentId, Function() observer) {
    return _ref
        .doc(documentId)
        .snapshots()
        .listen((DocumentSnapshot docSnapshot) {
      latestToDoList = ToDoList.from(docSnapshot);
      observer();
    });
  }

  void stopListening(StreamSubscription? subscription) =>
      subscription?.cancel();

  void update({
    required String notes,
    required String desc,
    required String title,
  }) {
    if (latestToDoList == null) {
      return;
    }
    _ref.doc(latestToDoList!.documentId!).update({
      kToDoEvent_Notes: notes,
      kToDoEvent_Desc: desc,
      kToDoEvent_Title: title,
      kToDoList_lastTouched: Timestamp.now(),
    }).catchError((error) => print("Failed to update the Event: $error"));
  }

  Future<void> delete() {
    return _ref.doc(latestToDoList?.documentId!).delete();
  }
}
