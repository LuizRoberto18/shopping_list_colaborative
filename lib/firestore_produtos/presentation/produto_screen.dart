import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list_collaborative/firestore_produtos/helpers/enum_order.dart';
import 'package:uuid/uuid.dart';
import '../../firestore/models/listin.dart';
import '../model/produto.dart';
import 'widgets/list_tile_produto.dart';

class ProdutoScreen extends StatefulWidget {
  final Listin listin;

  const ProdutoScreen({super.key, required this.listin});

  @override
  State<ProdutoScreen> createState() => _ProdutoScreenState();
}

class _ProdutoScreenState extends State<ProdutoScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Produto> listaProdutosPlanejados = [];

  List<Produto> listaProdutosPegos = [];

  OrdemProduto ordem = OrdemProduto.name;
  bool isDecrescente = false;

  late StreamSubscription _listener;

  @override
  void initState() {
    setupListeners();
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
      appBar: AppBar(
        title: Text(widget.listin.name),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: OrdemProduto.name,
                  child: Text("Ordenar por nome"),
                ),
                PopupMenuItem(
                  value: OrdemProduto.amount,
                  child: Text("Ordenar por quantidade"),
                ),
                PopupMenuItem(
                  value: OrdemProduto.price,
                  child: Text("Ordenar por preço"),
                ),
              ];
            },
            onSelected: (value) {
              setState(() {
                if (ordem == value) {
                  isDecrescente = !isDecrescente;
                } else {
                  ordem = value;
                  isDecrescente = false;
                }
              });
              refresh();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormModal();
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return refresh();
        },
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Text(
                    "R\$${calcularPrecoPegos().toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 42),
                  ),
                  const Text(
                    "total previsto para essa compra",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(thickness: 2),
            ),
            const Text(
              "Produtos Planejados",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              children: List.generate(
                listaProdutosPlanejados.length,
                (index) {
                  Produto produto = listaProdutosPlanejados[index];

                  return ListTileProduto(
                    showModal: showFormModal,
                    produto: produto,
                    isComprado: false,
                    iconClick: alternarComprado,
                    refresh: refresh,
                    remove: remove,
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Divider(thickness: 2),
            ),
            const Text(
              "Produtos Comprados",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Column(
              children: List.generate(
                listaProdutosPegos.length,
                (index) {
                  Produto produto = listaProdutosPegos[index];
                  return ListTileProduto(
                    showModal: showFormModal,
                    produto: produto,
                    isComprado: true,
                    iconClick: alternarComprado,
                    refresh: refresh,
                    remove: remove,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  showFormModal({Produto? model}) {
    // Labels à serem mostradas no Modal
    String labelTitle = "Adicionar Produto";
    String labelConfirmationButton = "Salvar";
    String labelSkipButton = "Cancelar";

    // Controlador dos campos do produto
    TextEditingController nameController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    TextEditingController priceController = TextEditingController();

    bool isComprado = false;

    // Caso esteja editando
    if (model != null) {
      labelTitle = "Editando ${model.name}";
      nameController.text = model.name;

      if (model.price != null) {
        priceController.text = model.price.toString();
      }

      if (model.amount != null) {
        amountController.text = model.amount.toString();
      }

      isComprado = model.isComprado;
    }

    // Função do Flutter que mostra o modal na tela
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Define que as bordas verticais serão arredondadas
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(32.0),

          // Formulário com Título, Campo e Botões
          child: ListView(
            children: [
              Text(labelTitle, style: Theme.of(context).textTheme.headlineSmall),
              TextFormField(
                controller: nameController,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  label: Text("Nome do Produto*"),
                  icon: Icon(Icons.abc_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: false,
                ),
                decoration: const InputDecoration(
                  label: Text("Quantidade"),
                  icon: Icon(Icons.numbers),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: false,
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  label: Text("Preço"),
                  icon: Icon(Icons.attach_money_rounded),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(labelSkipButton),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Criar um objeto Produto com as infos
                      Produto produto = Produto(
                        id: const Uuid().v1(),
                        name: nameController.text,
                        isComprado: isComprado,
                      );

                      // Usar id do model
                      if (model != null) {
                        produto.id = model.id;
                      }

                      if (amountController.text != "") {
                        produto.amount = double.parse(amountController.text);
                      }

                      if (priceController.text != "") {
                        produto.price = double.parse(priceController.text);
                      }

                      // Salvar no Firestore
                      firestore.collection("listins").doc(widget.listin.id).collection("produtos").doc(produto.id).set(produto.toMap());

                      // Fechar o Modal
                      Navigator.pop(context);
                    },
                    child: Text(labelConfirmationButton),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  refresh({QuerySnapshot<Map<String, dynamic>>? snapshot}) async {
    List<Produto> temp = [];
    snapshot ??= await firestore
        .collection("listins")
        .doc(widget.listin.id)
        .collection("produtos")
        // .where("isComprado", isEqualTo: isComprado)
        .orderBy(ordem.name, descending: isDecrescente)
        .get();
    verificarAlteracoes(snapshot);
    for (var doc in snapshot.docs) {
      Produto produto = Produto.fromMap(doc.data());
      temp.add(produto);
    }

    filtarProduto(temp);
  }

  filtarProduto(List<Produto> listProdutos) {
    List<Produto> tempPlanejados = [];
    List<Produto> tempPegos = [];
    for (var produto in listProdutos) {
      if (produto.isComprado == true) {
        tempPegos.add(produto);
      } else {
        tempPlanejados.add(produto);
      }
    }
    setState(() {
      listaProdutosPegos = tempPegos;
      listaProdutosPlanejados = tempPlanejados;
    });
  }

  alternarComprado(Produto produto) async {
    produto.isComprado = !produto.isComprado;
    await firestore.collection("listins").doc(widget.listin.id).collection("produtos").doc(produto.id).update({"isComprado": produto.isComprado});
  }

  setupListeners() {
    _listener = firestore
        .collection("listins")
        .doc(widget.listin.id)
        .collection("produtos")
        .orderBy(ordem.name, descending: isDecrescente)
        .snapshots()
        .listen(
      (snapshot) {
        refresh(snapshot: snapshot);
      },
    );
  }

  void remove(Produto produto) async {
    await firestore.collection("listins").doc(widget.listin.id).collection("produtos").doc(produto.id).delete();
  }

  verificarAlteracoes(QuerySnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.docChanges.length == 1) {
      for (var change in snapshot.docChanges) {
        Map<String, dynamic>? data = change.doc.data();
        String descricao = "";
        Color? cor;
        switch (change.type) {
          case DocumentChangeType.added:
            descricao = "Produto: ${data!["name"]} adicionado!";
            cor = Colors.green;
            break;
          case DocumentChangeType.modified:
            descricao = "Produto: ${data!["name"]} alterado!";
            cor = Colors.amber[600];
            break;
          case DocumentChangeType.removed:
            descricao = "Produto: ${data!["name"]} removido!";
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

  double calcularPrecoPegos() {
    double total = 0;
    for (Produto produto in listaProdutosPegos) {
      if (produto.amount != null && produto.price != null) {
        total += (produto.amount! * produto.price!);
      }
    }
    return total;
  }
}
