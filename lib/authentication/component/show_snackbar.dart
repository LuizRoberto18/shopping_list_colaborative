import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

showSnackBar({required BuildContext context, required String msg, bool isErro = true}) {
  SnackBar snackBar = SnackBar(
    content: Text(msg),
    backgroundColor: (isErro) ? Colors.red : Colors.green,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
