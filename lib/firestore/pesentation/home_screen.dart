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

import '../../get_control.dart';
import '../listin_service.dart';
import '../models/listin.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirestoreAnalytics analytics = FirestoreAnalytics();
  // late StreamSubscription _listener;
  Rx<bool> isLoading = false.obs;
  ListinService listinService = ListinService();
  @override
  void initState() {
    GetControll.isLoading.value = true;
    listinService.setupListeners();
    analytics.incrementarAcessosTotais();
    super.initState();
  }

  @override
  void dispose() {
    listinService.listener.cancel();
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
                showSenhaConfirmacaoDialog(
                    email: _firebaseAuth.currentUser!.email!);
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
            : listinService.listListins.isEmpty
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
                      return listinService.refresh();
                    },
                    child: ListView(
                      children: List.generate(
                        listinService.listListins.length,
                        (index) {
                          Listin model = listinService.listListins[index];
                          return Dismissible(
                            key: ValueKey<Listin>(model),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 10),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) {
                              ListinService().removerListin(listinId: model.id);
                            },
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProdutoScreen(listin: model),
                                  ),
                                );
                              },
                              onLongPress: () {
                                showFormModal(model: model);
                              },
                              leading: const Icon(Icons.list_alt_rounded),
                              title: Text(model.name),
                              subtitle: Text(DateFormat("dd//MM/yy HH:mm")
                                  .format(
                                      DateTime.parse(model.date).toLocal())),
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
                decoration:
                    const InputDecoration(label: Text("Nome do Listin")),
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
                      Listin listin = Listin(
                          id: const Uuid().v1(),
                          name: nameController.text,
                          date: DateTime.now().toLocal().toString());
                      if (model != null) {
                        listin.id = model.id;
                      }
                      ListinService().adicionarListin(listin: listin);
                      analytics.incrementarListasAdicionadas();
                      //fechar o modal
                      Navigator.pop(context);
                    },
                    child: Text(confirmationButton),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
