import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopping_list_collaborative/_core/my_colors.dart';

Future<bool?> showSourceModal() {
  return Get.bottomSheet(
    backgroundColor: MyColors.wedding,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    Container(
      height: 128,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, size: 48),
                Text(
                  "Câmera",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(result: true);
            },
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, size: 48),
                Text(
                  "Galeria",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
