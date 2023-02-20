import '/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FirebaseNotificationService {
  late final FirebaseMessaging messaging;

  void settingNotification() async {
    await messaging.requestPermission(
      alert: true,
      sound: true,
      badge: true,
    );
  }

  void connectNotification() async {
    await Firebase.initializeApp();
    messaging = FirebaseMessaging.instance;
    messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      sound: true,
      badge: true,
    );
    settingNotification();
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      Get.snackbar(

          "${event.notification!.title}", "${event.notification!.body}",
          snackPosition: SnackPosition.TOP,
          icon: const Icon(
            CupertinoIcons.cube_box,
            color: kThemeColor,
            size: 28,
          ),
          borderWidth: 1.2,
          borderColor: kThemeColor,
          colorText: Colors.white,
          backgroundColor: Colors.black.withOpacity(0.8));

      //print("Gelen bildim başlığı: ${event.notification?.title}");
    });

    messaging.getToken().then((value) => print("Token: $value" "FCM Token"));
  }

  static Future<void> backgroundMessage(RemoteMessage message) async {
    await Firebase.initializeApp();

    //print("Handling a background message: ${message.messageId}");
  }
}
