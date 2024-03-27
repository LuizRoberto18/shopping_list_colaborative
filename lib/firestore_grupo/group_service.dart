import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'model/group.dart';

class GroupoService {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> adicionarListin({required Grupo listin}) async {
    return firestore.collection("grups").doc(listin.id).set(listin.toMap());
  }

  Future<List<Grupo>> lerGrupos() async {
    List<Grupo> temp = [];

    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore.collection("grups").get();

    for (var doc in snapshot.docs) {
      temp.add(Grupo.fromMap(doc.data()));
    }

    return temp;
  }

  Future<void> removerGrupo({required String listinId}) async {
    return firestore.collection("grups").doc(listinId).delete();
  }
}
