import '/widgets/loading.dart';

import '/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../pages/cart.dart';
import '../pages/root.dart';

appBar(
  String title,
  bool leadingExists,
) =>
    AppBar(
        backgroundColor: Colors.transparent,
        leading: leadingExists
            ? IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(CupertinoIcons.back))
            : const SizedBox(),
        title: Text(title),
        actions: [
          cart(title),
        ]);

StreamBuilder<QuerySnapshot<Map<String, dynamic>>> cart(String title) {
  return StreamBuilder(
      stream: cartsRef.doc(currentUser.id).collection('userCart').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return loading();
        }
        return Padding(
            padding: const EdgeInsets.only(top: 8.0, right: 15.0),
            child: Badge(
              alignment: AlignmentDirectional.topEnd,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              label: Text(
                snapshot.data!.docs.length.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              child: IconButton(
                icon: const Icon(
                  CupertinoIcons.bag,
                  color: kThemeColor,
                  size: 23,
                ),
                onPressed: () {
                  Get.to(() => const Cart());
                },
              ),
            ));
      });
}

