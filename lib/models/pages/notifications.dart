import 'package:appbeyoglu/models/order_model.dart';
import 'package:appbeyoglu/models/pages/chat_page.dart';

import '/widgets/loading.dart';

import '/models/pages/post_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/constants.dart';
import '/models/pages/root.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  String title = '';
  String desc = '';
  String postId = '.';
  String id = '.';
  String senderId = '.';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
      ),
      body: StreamBuilder(
          stream: notificationsRef
              .doc(currentUser.id)
              .collection('userNotifications')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return loading();
            }
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                Icon icon = const Icon(
                  Icons.abc,
                  size: 40,
                );
                String type = snapshot.data!.docs[index]['type'];
                Timestamp timestamp = snapshot.data!.docs[index]['timestamp'];
                var imageUrl;
                // bool isSuccessfulOrder() {
                //   if (snapshot.data!.docs[index]['type'] == 'successfulOrder') {
                //     return true;
                //   } else {
                //     return false;
                //   }
                // }
                switch (type) {
                  case 'comment':
                    imageUrl = snapshot.data!.docs[index]['userProfilePicture'];
                    postId = snapshot.data!.docs[index]['postId'];
                    break;
                  case 'follow':
                    imageUrl = snapshot.data!.docs[index]['userProfilePicture'];
                    break;
                  case 'like':
                    imageUrl = snapshot.data!.docs[index]['userProfilePicture'];
                    postId = snapshot.data!.docs[index]['postId'];

                    break;

                  case 'successfulOrder':
                    icon = const Icon(
                      CupertinoIcons.check_mark_circled,
                      color: kThemeColor,
                      size: 40,
                    );
                    id = snapshot.data!.docs[index]['id'];
                    break;
                  case 'newOrder':
                    icon = const Icon(
                      CupertinoIcons.check_mark_circled,
                      color: kThemeColor,
                      size: 40,
                    );
                    id = snapshot.data!.docs[index]['id'];
                    break;

                  case 'productApproved':
                    icon = const Icon(
                      CupertinoIcons.check_mark_circled,
                      color: kThemeColor,
                      size: 40,
                    );
                    break;
                  case 'accountApproved':
                    icon = const Icon(
                      CupertinoIcons.check_mark_circled,
                      color: kThemeColor,
                      size: 40,
                    );
                    break;
                  case 'productRejected':
                    icon = const Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 40,
                    );
                    break;
                  case 'orderRejected':
                    icon = const Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 40,
                    );
                    break;
                  case 'message':
                    icon = const Icon(
                      CupertinoIcons.mail,
                      color: kThemeColor,
                      size: 40,
                    );
                    senderId = snapshot.data!.docs[index]['senderId'];
                    break;
                  default:
                    break;
                }

//                 comment
//                 follow
//                 successfulOrder
//                 newOrder
//                 productApproved
//                 productRejected

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  margin: const EdgeInsets.fromLTRB(20, 0, 20.0, 10.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey, width: 0.75)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          //icon
                          type == 'successfulOrder' ||
                                  type == 'newOrder' ||
                                  type == 'productApproved' ||
                                  type == "accountApproved" ||
                                  type == 'productRejected' ||
                                  type == 'orderRejected' ||
                                  type == 'message'
                              ? Expanded(flex: 0, child: icon)
                              : Expanded(
                                  flex: 0,
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(imageUrl),
                                  ),
                                ),
                          const SizedBox(
                            width: 15,
                          ),
                          //column
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              //title
                              //desc
                              //timestamp
                              children: [
                                Text(
                                  snapshot.data!.docs[index]['title'],
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                Text(
                                  snapshot.data!.docs[index]['subTitle'],
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  timeago.format(timestamp.toDate()).toString(),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          //trailing
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              type == "comment" ||
                                      type == 'like' ||
                                      type == 'message'
                                  ? Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: trailingButton(type),
                                    )
                                  : Text(
                                      type == 'successfulOrder' ||
                                              type == 'newOrder'
                                          ? '${snapshot.data!.docs[index]['content']} ₺'
                                          : '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 19,
                                      ),
                                    ),
                            ],
                          ),
                        ],
                      ),
                      type == "newOrder" || type == "successfulOrder"
                          ? StreamBuilder(
                              stream: ordersRef.doc(id).snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return loading();
                                }
                                final listOfDocumentSnapshot =
                                    snapshot.data!.data()!;
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    top: 10.0,
                                  ),
                                  child: SizedBox(
                                    height: 40,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: CupertinoButton(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              padding: EdgeInsets.zero,
                                              color: kThemeColor,
                                              child: const Text('Siparişi gor'),
                                              onPressed: () {
                                                Get.to(
                                                  () => OrderDetails(
                                                    paymentMethod:
                                                        listOfDocumentSnapshot[
                                                            'paymentMethod'],
                                                    dormNumber:
                                                        listOfDocumentSnapshot[
                                                            'dormNumber'],
                                                    dormType:
                                                        listOfDocumentSnapshot[
                                                            'dormType'],
                                                    purchase:
                                                        listOfDocumentSnapshot[
                                                            'purchase'],
                                                    note:
                                                        listOfDocumentSnapshot[
                                                            'note'],
                                                    buyerId:
                                                        listOfDocumentSnapshot[
                                                            'buyerId'],
                                                    orderId:
                                                        listOfDocumentSnapshot[
                                                            'orderId'],
                                                    vendorId:
                                                        listOfDocumentSnapshot[
                                                            'vendorId'],
                                                    theList:
                                                        listOfDocumentSnapshot[
                                                            'theList'],
                                                    delivererId:
                                                        listOfDocumentSnapshot[
                                                            'delivererId'],
                                                    isAccepted:
                                                        listOfDocumentSnapshot[
                                                            'isAccepted'],
                                                    isCanceled:
                                                        listOfDocumentSnapshot[
                                                            'isCanceled'],
                                                  ),
                                                );
                                              }),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              })
                          : const SizedBox()
                    ],
                  ),
                  // ListTile(
                  //   leading: type == 'successfulOrder' ||
                  //           type == 'newOrder' ||
                  //           type == 'productApproved' ||
                  //           type == 'productRejected'
                  //       ? icon
                  //       : CircleAvatar(
                  //           backgroundImage: type == 'succesfulOrder' ||
                  //                   type == 'newOrder' ||
                  //                   type == 'productApproved' ||
                  //                   type == 'productRejected'
                  //               ? null
                  //               : NetworkImage(imageUrl),
                  //         ),
                  //   title: Text(
                  //     snapshot.data!.docs[index]['title'],
                  //     style: const TextStyle(color: Colors.white),
                  //   ),
                  //   subtitle: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Text(
                  //         snapshot.data!.docs[index]['subTitle'],
                  //         style: const TextStyle(color: Colors.grey),
                  //       ),
                  //       Text(
                  //         timeago.format(timestamp.toDate()).toString(),
                  //         style: const TextStyle(color: Colors.grey),
                  //       ),
                  //     ],
                  //   ),
                  //   trailing: Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       type == ""
                  //           ? trailingButton()
                  //           : Text(
                  //               type == 'successfulOrder' || type == 'newOrder'
                  //                   ? '${snapshot.data!.docs[index]['content']} ₺'
                  //                   : '',
                  //               style: const TextStyle(
                  //                 color: Colors.white,
                  //                 fontSize: 19,
                  //               ),
                  //             ),
                  //     ],
                  //   ),
                  // ),
                );
              },
            );
          }),
    );
  }

  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>> trailingButton(
      String type) {
    return StreamBuilder(
        stream: postsRef
            .doc(currentUser.id)
            .collection('userPosts')
            .doc(postId)
            .snapshots(),
        builder: (context, snapshot) {
          return SizedBox(
            height: 30,
            child: CupertinoButton(
                borderRadius: kCircleBorderRadius,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                color: Colors.white,
                child: Text(type == 'message' ? "Sohbete git" : "Postu gör",
                    style: TextStyle(
                      fontFamily: 'poppinsBold',
                      color: Colors.black,
                    )),
                onPressed: () {
                  if (type == 'message') {
                    Get.to(() => ChatPage(userId: senderId));
                  } else {
                    Get.to(() =>
                        PostDetails(userId: currentUser.id, postId: postId));
                  }
                }),
          );
        });
  }
}
