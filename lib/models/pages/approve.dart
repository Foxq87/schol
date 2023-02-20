import 'package:appbeyoglu/models/pages/search.dart';
import 'package:appbeyoglu/models/user_model.dart';
import 'package:flutter/gestures.dart';

import '/widgets/loading.dart';

import '/models/pages/root.dart';
import '/widgets/product.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Approve extends StatefulWidget {
  const Approve({super.key});

  @override
  State<Approve> createState() => _ApproveState();
}

class _ApproveState extends State<Approve> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: productRef.where("approve", isEqualTo: 1).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return loading();
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final listOfDocumentSnapshot = snapshot.data!.docs[index];
                Product product = Product(
                  productId: listOfDocumentSnapshot['productId'],
                  type: listOfDocumentSnapshot['type'],
                  isLoaded: snapshot.hasData,
                  description: listOfDocumentSnapshot['productDesc'],
                  title: listOfDocumentSnapshot['productTitle'],
                  price: listOfDocumentSnapshot['productPrice'],
                  vendor: listOfDocumentSnapshot['vendorId'],
                  imageUrl: listOfDocumentSnapshot['image'],
                  quantity: listOfDocumentSnapshot['quantity'],
                  approve: listOfDocumentSnapshot['approve'],
                );

                return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                      border: Border.symmetric(
                          horizontal: BorderSide(
                              color: Colors.grey[600]!, width: 0.6))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Product(
                        productId: listOfDocumentSnapshot['productId'],
                        type: listOfDocumentSnapshot['type'],
                        isLoaded: snapshot.hasData,
                        description: listOfDocumentSnapshot['productDesc'],
                        title: listOfDocumentSnapshot['productTitle'],
                        price: listOfDocumentSnapshot['productPrice'],
                        vendor: listOfDocumentSnapshot['vendorId'],
                        imageUrl: listOfDocumentSnapshot['image'],
                        quantity: listOfDocumentSnapshot['quantity'],
                        approve: listOfDocumentSnapshot['approve'],
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            CupertinoButton(
                              borderRadius: BorderRadius.circular(100),
                              onPressed: () {
                                String notificationId = const Uuid().v4();

                                setState(() {
                                  productRef
                                      .doc(product.productId)
                                      .get()
                                      .then((doc) {
                                    doc.reference.update({"approve": 2});
                                  });
                                  notificationsRef
                                      .doc(product.vendor)
                                      .collection('userNotifications')
                                      .doc(notificationId)
                                      .set({
                                    "type": 'productApproved',
                                    "id": '',
                                    "title": 'Başarı',
                                    "subTitle": 'Ürünün kabul edildi',
                                    "content": '',
                                    "timestamp": DateTime.now(),
                                  });
                                });
                              },
                              color: Colors.green,
                              child: const Text(
                                'Onayla',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            CupertinoButton(
                              borderRadius: BorderRadius.circular(100),
                              onPressed: () {
                                String notificationId = const Uuid().v4();
                                setState(() {
                                  productRef
                                      .doc(product.productId)
                                      .get()
                                      .then((doc) {
                                    doc.reference.update({"approve": 0});
                                  });
                                  notificationsRef
                                      .doc(product.vendor)
                                      .collection('userNotifications')
                                      .doc(notificationId)
                                      .set({
                                    "type": 'productRejected',
                                    "id": '',
                                    "title": 'Hata',
                                    "subTitle": 'Ürünün reddedildi',
                                    "content": '',
                                    "timestamp": DateTime.now(),
                                  });
                                });
                              },
                              color: Colors.red,
                              child: const Text(
                                'Reddet',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
    );
  }
}

class UserApprove extends StatefulWidget {
  const UserApprove({super.key});

  @override
  State<UserApprove> createState() => _UserApproveState();
}

class _UserApproveState extends State<UserApprove> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: usersRef.where("approve", isEqualTo: 1).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return loading();
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final listOfDocumentSnapshot = snapshot.data!.docs[index];
                User user = User(
                  id: listOfDocumentSnapshot['id'],
                  username: listOfDocumentSnapshot['username'],
                  email: listOfDocumentSnapshot['email'],
                  photoUrl: listOfDocumentSnapshot['photoUrl'],
                  displayName: listOfDocumentSnapshot['displayName'],
                  bio: listOfDocumentSnapshot['bio'],
                  rating: listOfDocumentSnapshot['rating'],
                  isVendor: listOfDocumentSnapshot['isVendor'],
                  approve: listOfDocumentSnapshot['approve'],
                  grade: listOfDocumentSnapshot['grade'],
                  tripMode: listOfDocumentSnapshot['tripMode'],
                  password: listOfDocumentSnapshot['password'],
                  phoneNumber: listOfDocumentSnapshot['phoneNumber'],
                  schoolNumber: listOfDocumentSnapshot['schoolNumber'],
                  creation: listOfDocumentSnapshot['creation'],
                  isDeliverer: listOfDocumentSnapshot['isDeliverer'],
                  dormNumber: listOfDocumentSnapshot['dormNumber'],
                  dormType: listOfDocumentSnapshot['dormType'],
                );

                return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                      border: Border.symmetric(
                          horizontal: BorderSide(
                              color: Colors.grey[600]!, width: 0.6))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      UserResult(user: user),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CupertinoButton(
                              borderRadius: BorderRadius.circular(16),
                              onPressed: () {
                                String notificationId = const Uuid().v4();

                                setState(() {
                                  usersRef.doc(user.id).get().then((doc) {
                                    doc.reference.update({"approve": 2});
                                  });
                                  notificationsRef
                                      .doc(user.id)
                                      .collection('userNotifications')
                                      .doc(notificationId)
                                      .set({
                                    "type": 'accountApproved',
                                    "title": 'Başarı',
                                    "subTitle": 'Hesabın onaylandı',
                                    "timestamp": DateTime.now(),
                                  });
                                });
                              },
                              color: Colors.green,
                              child: const Text(
                                'Onayla',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: CupertinoButton(
                              borderRadius: BorderRadius.circular(16),
                              onPressed: () {
                                String notificationId = const Uuid().v4();
                                setState(() {
                                  usersRef.doc(user.id).get().then((doc) {
                                    doc.reference.update({"approve": 0});
                                  });
                                  notificationsRef
                                      .doc(user.id)
                                      .collection('userNotifications')
                                      .doc(notificationId)
                                      .set({
                                    "type": 'productRejected',
                                    "id": '',
                                    "title": 'Hata',
                                    "subTitle": 'Ürünün reddedildi',
                                    "content": '',
                                    "timestamp": DateTime.now(),
                                  });
                                });
                              },
                              color: Colors.red,
                              child: const Text(
                                'Reddet',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }),
    );
  }
}
