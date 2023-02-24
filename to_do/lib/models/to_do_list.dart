import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_model_utils.dart';


const String kToDoListCollectionPath = "Events";
const String kToDoList_authorUid = "authorUid";
const String kToDoList_lastTouched = "lastTouched";
const String kToDoEvent_Title = "title";
const String kToDoEvent_Desc = "description";
const String kToDoEvent_Notes = "notes";

class ToDoList {
  String? documentId;
  String authorUid;
  Timestamp lastTouched;
  String desc;
  String notes;
  String title;

  ToDoList({
    this.documentId,
    required this.authorUid,
    required this.notes,
    required this.desc,
    required this.lastTouched,
    required this.title,
  });

  ToDoList.from(DocumentSnapshot doc)
      : this(
    documentId: doc.id,
    authorUid:
    FirestoreModelUtils.getStringField(doc, kToDoList_authorUid),
    lastTouched: FirestoreModelUtils.getTimestampField(
        doc, kToDoList_lastTouched),
    desc: FirestoreModelUtils.getStringField(doc, kToDoEvent_Desc),
    notes: FirestoreModelUtils.getStringField(doc, kToDoEvent_Notes),
    title: FirestoreModelUtils.getStringField(doc, kToDoEvent_Title),
  );

  Map<String, Object?> toMap() {
    return {
      kToDoList_authorUid: authorUid,
      kToDoList_lastTouched: lastTouched,
      kToDoEvent_Desc: desc,
      kToDoEvent_Notes: notes,
      kToDoEvent_Title: title,
    };
  }

  @override
  String toString() {
    return "$desc from the To Do List $title";
  }
}