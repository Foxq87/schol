import 'dart:io';

import '/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '/models/pages/root.dart';
import 'package:firebase_core/firebase_core.dart';
import '/provider/data.dart';

//hey
final _service = FirebaseNotificationService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    name: 'appBey',
    options: FirebaseOptions(
        apiKey: "AIzaSyB13XAt1HFpA1HBc469uKYnj9yAJKsnBKw",
        appId: Platform.isIOS ? "1:256943613795:ios:3dd04555330211db8bd556" : "1:256943613795:android:149f50e5cff2f59f8bd556",
        messagingSenderId: "256943613795",
        projectId: "appbeyoglu"),
  );
  FirebaseMessaging.onBackgroundMessage(
      FirebaseNotificationService.backgroundMessage);
  _service.connectNotification();
  await MobileAds.instance.initialize();

  runApp(ChangeNotifierProvider(
    create: (BuildContext context) {
      return Data();
    },
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(1, 0, 56, 64),
          centerTitle: true,
          elevation: 0,
        ),
        fontFamily: 'poppins',
        textTheme: const TextTheme(
          bodySmall: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      home: const Root(),
      // home: const SocialMediaRoot(),
    );
  }
}
