import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:shopping_list_collaborative/_core/my_colors.dart';
import 'package:shopping_list_collaborative/firestore/pesentation/home_screen.dart';
import 'authentication/screens/auth_screen.dart';
import 'firebase_options.dart';
import 'get_control.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    // You can also use a `ReCaptchaEnterpriseProvider` provider instance as an
    // argument for `webProvider`
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Safety Net provider
    // 3. Play Integrity provider
    androidProvider: AndroidProvider.debug,
    // Default provider for iOS/macOS is the Device Check provider. You can use the "AppleProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Device Check provider
    // 3. App Attest provider
    // 4. App Attest provider with fallback to Device Check provider (App Attest provider is only available on iOS 14.0+, macOS 14.0+)
    appleProvider: AppleProvider.appAttest,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(Controller());
    return Obx(() => GetMaterialApp(
          title: 'Listin - Lista Colaborativa',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: MyColors.navy,
            scaffoldBackgroundColor: MyColors.wedding,
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: MyColors.purple,
            ),
            bottomSheetTheme: BottomSheetThemeData(backgroundColor: MyColors.wedding),
            listTileTheme: ListTileThemeData(
              iconColor: MyColors.purpleAccent,
            ),
            brightness: Controller.isDark.value ? Brightness.dark : Brightness.light,
            cardColor: MyColors.wedding,
            appBarTheme: AppBarTheme(
              toolbarHeight: 72,
              centerTitle: true,
              elevation: 0,
              backgroundColor: MyColors.navy,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
            ),
            progressIndicatorTheme: ProgressIndicatorThemeData(color: MyColors.purple),
            useMaterial3: false,
          ),
          home: const AuthScreen(),
        ));
  }
}

class RoutersScreen extends StatelessWidget {
  const RoutersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
