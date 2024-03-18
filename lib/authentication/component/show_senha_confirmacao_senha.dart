import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopping_list_collaborative/authentication/services/auth_service.dart';
import 'package:shopping_list_collaborative/get_control.dart';

showSenhaConfirmacaoDialog({
  required String email,
}) {
  TextEditingController senhaConfirControl = TextEditingController();
  Get.dialog(
    AlertDialog(
      title: Text("Deseja remover a conta com o e-mail $email?"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Para confirmar a remoção da conta, insira a sua senha:"),
          TextFormField(
            controller: senhaConfirControl,
            obscureText: true,
            decoration: const InputDecoration(label: Text("Senha")),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            AuthService().removerConta(senha: senhaConfirControl.text).then(
              (String? erro) {
                if (erro == null) {
                  GetControll.isLoading.value = false;
                  Get.back();
                }
              },
            );
          },
          child: Text(
            "Excluir Conta".toUpperCase(),
          ),
        ),
      ],
    ),
  );
}
