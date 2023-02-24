import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/to_do_list.dart';
import 'auth_manager.dart';
import 'auth_manager.dart';
import 'auth_manager.dart';


class ToDoListCollectionManager {
  List<ToDoList> latestEvents = [];
  final CollectionReference _ref;

  static final ToDoListCollectionManager instance =
  ToDoListCollectionManager._privateConstructor();

  ToDoListCollectionManager._privateConstructor()
      : _ref = FirebaseFirestore.instance.collection(kToDoListCollectionPath);


  StreamSubscription startListening(Function() observer,
      {bool isFilteredForMine = false}) {
    Query query = _ref.orderBy(kToDoList_lastTouched, descending: true);
    if (isFilteredForMine) {
      query = query.where(kToDoList_authorUid,
          isEqualTo: AuthManager.instance.uid);
    }
    return query.snapshots().listen((QuerySnapshot querySnapshot) {
      latestEvents =
          querySnapshot.docs.map((doc) => ToDoList.from(doc)).toList();
      observer();
       //print(latestPhotos);
    });
  }

  void stopListening(StreamSubscription? subscription) {
    subscription?.cancel();
  }

  Future<void> add({

    required String notes,
    required String desc,
    required String title,
  }) {
  print(AuthManager.instance.uid);

    return _ref
        .add({
      kToDoList_authorUid: AuthManager.instance.uid,
      kToDoEvent_Notes: notes,
      kToDoEvent_Desc: desc,
      kToDoEvent_Title: title,
      kToDoList_lastTouched: Timestamp.now(),
    })
        .then((DocumentReference docRef) =>
        print("Event added with id ${docRef.id}"))
        .catchError((error) => print("Failed to add event: $error"));
  }

  // Firebase UI Firestore stuff

  Query<ToDoList> get allEventsQuery => _ref
      .orderBy(kToDoList_lastTouched, descending: true)
      .withConverter<ToDoList>(
    fromFirestore: (snapshot, _) => ToDoList.from(snapshot),
    toFirestore: (mq, _) => mq.toMap(),
  );

  Query<ToDoList> get mineOnlyEventQuery => allEventsQuery
      .where(kToDoList_authorUid, isEqualTo: AuthManager.instance.uid);

}
