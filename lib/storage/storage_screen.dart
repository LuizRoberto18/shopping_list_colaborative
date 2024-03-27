import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shopping_list_collaborative/authentication/component/show_snackbar.dart';
import 'package:shopping_list_collaborative/storage/models/image_custom_info.dart';
import 'package:shopping_list_collaborative/storage/service/storage_service.dart';
import 'package:shopping_list_collaborative/storage/widgets/source_modal_widget.dart';

import '../_core/my_colors.dart';
import 'package:image_picker/image_picker.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  String? urlPhoto;
  List<ImageCustomInfo> listFiles = [];
  final StorageService storageService = StorageService();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    reload();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Foto de Perfil"),
        actions: [
          IconButton(
            onPressed: () {
              uploadImage();
            },
            icon: const Icon(Icons.upload),
          ),
          IconButton(
            onPressed: () {
              reload();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            urlPhoto != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(64),
                    child: Image.network(
                      urlPhoto!,
                      height: 128,
                      width: 128,
                      fit: BoxFit.cover,
                    ),
                  )
                : CircleAvatar(
                    radius: 64,
                    backgroundColor: MyColors.purple,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Divider(color: Colors.black),
            ),
            const Text(
              "Histórico de Imagens",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
           const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(
                    listFiles.length,
                    (index) {
                      ImageCustomInfo imageInfo = listFiles[index];
                      return ListTile(
                        onTap: () {
                          selectImage(imageInfo);
                        },
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.network(
                            imageInfo.urlDownload,
                            height: 48,
                            width: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(imageInfo.name),
                        subtitle: Text(imageInfo.size),
                        trailing: IconButton(
                            onPressed: () {
                              deleteImage(imageInfo);
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            )),
                      );
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  uploadImage() {
    ImagePicker imagePicker = ImagePicker();
    showSourceModal().then(
      (bool? value) {
        ImageSource source = ImageSource.gallery;
        if (value != null) {
          if (value) {
            source = ImageSource.gallery;
          } else {
            source = ImageSource.camera;
          }
          imagePicker
              .pickImage(
            source: source,
            maxWidth: 2000,
            maxHeight: 2000,
            imageQuality: 50,
          )
              .then(
            (XFile? image) {
              if (image != null) {
                storageService.upload(file: File(image.path), fileName: DateTime.now().toString()).then((String urlDownload) {
                  setState(() {
                    urlPhoto = urlDownload;
                    reload();
                  });
                });
              } else {
                showSnackBar(context: context, msg: "Nenhuma imagem Selecionada");
              }
            },
          );
        }
      },
    );
  }

  reload() {
    setState(() {
      urlPhoto = firebaseAuth.currentUser!.photoURL;
    });
    storageService.listAllFiles().then((List<ImageCustomInfo> listFilesInfo) {
      setState(() {
        listFiles = listFilesInfo;
      });
    });
  }

  selectImage(ImageCustomInfo imageInfo) {
    firebaseAuth.currentUser!.updatePhotoURL(imageInfo.urlDownload);
    setState(() {
      urlPhoto = imageInfo.urlDownload;
    });
  }

  deleteImage(ImageCustomInfo imageInfo) {
    storageService.deleteByReference(imageInfo: imageInfo).then((value) {
      if (urlPhoto == imageInfo.urlDownload) {
        urlPhoto = null;
      }
      reload();
    });
  }
}
