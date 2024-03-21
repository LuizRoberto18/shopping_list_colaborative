import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../get_control.dart';
import 'models/listin.dart';

class ListinService {
  RxList<Listin> listListins = <Listin>[].obs;
  String uid = FirebaseAuth.instance.currentUser!.uid;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late StreamSubscription listener;
  Future<void> adicionarListin({required Listin listin}) async {
    return firestore.collection(uid).doc(listin.id).set(listin.toMap());
  }

  Future<List<Listin>> lerListins() async {
    List<Listin> temp = [];

    QuerySnapshot<Map<String, dynamic>> snapshot =
        await firestore.collection(uid).get();

    for (var doc in snapshot.docs) {
      temp.add(Listin.fromMap(doc.data()));
    }

    return temp;
  }

  Future<void> removerListin({required String listinId}) async {
    return firestore.collection(uid).doc(listinId).delete();
  }

  setupListeners() {
    listener = firestore.collection(uid).snapshots().listen(
      (snapshot) {
        refresh(snapshot: snapshot);
      },
    );
  }

  refresh({QuerySnapshot<Map<String, dynamic>>? snapshot}) async {
    GetControll.isLoading.value = true;
    List<Listin> temp = [];
    snapshot ??= await firestore.collection(uid).get();
    GetControll.isLoading.value = false;
    verificarAlteracoes(snapshot);
    for (var doc in snapshot.docs) {
      temp.add(Listin.fromMap(doc.data()));
    }

    listListins.value = temp;
  }

  verificarAlteracoes(QuerySnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.docChanges.length == 1) {
      for (var change in snapshot.docChanges) {
        Map<String, dynamic>? data = change.doc.data();
        String descricao = "";
        Color? cor;
        switch (change.type) {
          case DocumentChangeType.added:
            descricao = "Lista: ${data!["name"]} adicionada!";
            cor = Colors.green;
            break;
          case DocumentChangeType.modified:
            descricao = "Lista: ${data!["name"]} alterada!";
            cor = Colors.amber;
            break;
          case DocumentChangeType.removed:
            descricao = "Lista: ${data!["name"]} removida!";
            cor = Colors.red;
            break;
        }
        Get.snackbar("Atenção", descricao, backgroundColor: cor);
      }
    }
  }
}
