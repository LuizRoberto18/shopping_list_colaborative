import 'package:flutter/material.dart';
import '../../model/produto.dart';

class ListTileProduto extends StatelessWidget {
  final Produto produto;
  final bool isComprado;
  final Function showModal;
  final Function iconClick;
  final Function remove;
  final Function refresh;

  const ListTileProduto({
    super.key,
    required this.produto,
    required this.isComprado,
    required this.showModal,
    required this.iconClick,
    required this.remove,
    required this.refresh,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey<Produto>(produto),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 10),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text("Atenção"),
              content: const Text("Deseja excluir o item da lista?"),
              actions: [
                TextButton(
                  onPressed: () {
                    refresh();
                    Navigator.pop(context);
                  },
                  child: const Text("Não"),
                ),
                ElevatedButton(
                  onPressed: () {
                    remove(produto);
                    Navigator.pop(context);
                  },
                  child: const Text("Sim"),
                ),
              ],
            );
          },
        );
      },
      child: ListTile(
        onTap: () {
          showModal(model: produto);
        },
        leading: IconButton(
          onPressed: () {
            iconClick(produto);
          },
          icon: Icon(
            (isComprado) ? Icons.library_add_check : Icons.check_box_outline_blank,
          ),
        ),
        title: Text(
          (produto.amount == null) ? produto.name : "${produto.name} (x${produto.amount!})",
        ),
        subtitle: Text(
          (produto.price == null) ? "Clique para adicionar preço" : "R\$ ${produto.price!}",
        ),
      ),
    );
  }
}
