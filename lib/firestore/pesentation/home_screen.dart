import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shopping_list_collaborative/authentication/component/show_senha_confirmacao_senha.dart';
import 'package:shopping_list_collaborative/authentication/screens/auth_screen.dart';
import 'package:shopping_list_collaborative/authentication/services/auth_service.dart';
import 'package:shopping_list_collaborative/firestore/firestore_analytics.dart';
import 'package:shopping_list_collaborative/firestore_produtos/presentation/produto_screen.dart';
import 'package:uuid/uuid.dart';

import '../models/listin.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Listin> listListins = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirestoreAnalytics analytics = FirestoreAnalytics();
  late StreamSubscription _listener;
  Rx<bool> isLoading = false.obs;

  @override
  void initState() {
    isLoading.value = true;
    setupListeners();
    analytics.incrementarAcessosTotais();
    super.initState();
  }

  @override
  void dispose() {
    _listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
              title: const Text("Remover conta"),
              onTap: () {
                showSenhaConfirmacaoDialog(email: _firebaseAuth.currentUser!.email!);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Sair"),
              onTap: () {
                AuthService().deslogar();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("Listin - Feira Colaborativa"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormModal();
        },
        child: const Icon(Icons.add),
      ),
      body: Obx(
        () => isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : listListins.isEmpty
                ? const Center(
                    child: Text(
                      "Nenhuma lista ainda.\nVamos criar a primeira?",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () {
                      analytics.incrementarAtualizacoesManuais();
                      return refresh();
                    },
                    child: ListView(
                      children: List.generate(
                        listListins.length,
                        (index) {
                          Listin model = listListins[index];
                          return Dismissible(
                            key: ValueKey<Listin>(model),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 10),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              remove(model);
                            },
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProdutoScreen(listin: model),
                                  ),
                                );
                              },
                              onLongPress: () {
                                showFormModal(model: model);
                              },
                              leading: const Icon(Icons.list_alt_rounded),
                              title: Text(model.name),
                              subtitle: Text(DateFormat("dd//MM/yy HH:mm").format(DateTime.parse(model.date).toLocal())),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
      ),
    );
  }

  showFormModal({Listin? model}) {
    // Labels à serem mostradas no Modal
    String title = "Adicionar Listin";
    String confirmationButton = "Salvar";
    String skipButton = "Cancelar";

    // Controlador do campo que receberá o nome do Listin
    TextEditingController nameController = TextEditingController();

    //CAso esteja editando
    if (model != null) {
      title = "Editando ${model.name}";
      nameController.text = model.name;
    }
    // Função do Flutter que mostra o modal na tela
    showModalBottomSheet(
      context: context,

      // Define que as bordas verticais serão arredondadas
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(32.0),

          // Formulário com Título, Campo e Botões
          child: ListView(
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(label: Text("Nome do Listin")),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(skipButton),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                      onPressed: () {
                        Listin listin = Listin(id: const Uuid().v1(), name: nameController.text, date: DateTime.now().toLocal().toString());
                        if (model != null) {
                          listin.id = model.id;
                        }
                        print(listin.toString());
                        firestore.collection("listins").doc(listin.id).set(listin.toMap());
                        analytics.incrementarListasAdicionadas();
                        //fechar o modal
                        Navigator.pop(context);
                      },
                      child: Text(confirmationButton)),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  refresh({QuerySnapshot<Map<String, dynamic>>? snapshot}) async {
    isLoading.value = true;
    List<Listin> temp = [];
    snapshot ??= await firestore.collection("listins").get();
    isLoading.value = false;
    verificarAlteracoes(snapshot);
    for (var doc in snapshot.docs) {
      temp.add(Listin.fromMap(doc.data()));
    }
    setState(() {
      listListins = temp;
    });
  }

  setupListeners() {
    _listener = firestore.collection("listins").snapshots().listen(
      (snapshot) {
        refresh(snapshot: snapshot);
      },
    );
  }

  void remove(Listin model) {
    firestore.collection("listins").doc(model.id).delete();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: cor,
            content: Text(descricao),
          ),
        );
      }
    }
  }
}
