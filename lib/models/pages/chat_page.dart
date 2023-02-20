import 'dart:io';
import 'dart:ui';

import 'package:appbeyoglu/models/pages/account.dart';
import 'package:appbeyoglu/models/post_model.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '/widgets/snackbar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '/constants.dart';
import '/models/pages/root.dart';

import '../user_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatPage extends StatefulWidget {
  String userId;
  ChatPage({super.key, required this.userId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  File? image;
  String url = '';
  ScrollController scrollController = ScrollController();
  TextEditingController messageController = TextEditingController();
  String contactId = const Uuid().v4();
  buildBackButton(bool close) {
    return GestureDetector(
      onTap: () {
        if (close) {
          setState(() {
            image = null;
          });
        } else {
          Get.back();
        }
      },
      child: CircleAvatar(
        radius: 15,
        backgroundColor: kdarkGreyColor,
        child: Center(
            child: Icon(
          close ? CupertinoIcons.clear : FeatherIcons.arrowLeft,
          color: Colors.white,
          size: 18,
        )),
      ),
    );
  }

  messageTemplate(
      String message, String senderId, Timestamp dateTime, String imageUrl) {
    return FittedBox(
      fit: BoxFit.fill,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              alignment: senderId == currentUser.id
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              padding:
                  imageUrl != "" ? EdgeInsets.zero : const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: senderId == currentUser.id
                      ? kdarkGreyColor
                      : Colors.grey[900],
                  borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: senderId == currentUser.id
                          ? const Radius.circular(20)
                          : const Radius.circular(0),
                      bottomRight: senderId == currentUser.id
                          ? const Radius.circular(0)
                          : const Radius.circular(20))),
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 250,
                  minWidth: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    imageUrl != ""
                        ? GestureDetector(
                            onTap: () {
                              Get.to(() => Photo(mediaUrl: imageUrl));
                            },
                            child: Container(
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 0.5),
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10)),
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10)),
                                child: Image.network(
                                  imageUrl,
                                  height: 125,
                                  width: 400,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(),
                    message == ""
                        ? const SizedBox()
                        : Padding(
                            padding: imageUrl != ""
                                ? senderId == currentUser.id
                                    ? const EdgeInsets.only(
                                        right: 10, left: 10, top: 10)
                                    : const EdgeInsets.only(
                                        left: 10, right: 10, top: 10)
                                : EdgeInsets.zero,
                            child: Text(
                              message,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'poppinsBold',
                                  fontSize: 17,
                                  inherit: false),
                            ),
                          ),
                    Padding(
                      padding: imageUrl != ""
                          ? senderId == currentUser.id
                              ? const EdgeInsets.only(
                                  bottom: 5, right: 10, left: 10)
                              : const EdgeInsets.only(
                                  bottom: 5,
                                  left: 10,
                                  right: 10,
                                )
                          : EdgeInsets.zero,
                      child: Text(
                        timeago.format(dateTime.toDate()),
                        style:
                            const TextStyle(color: Colors.grey, inherit: false),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: usersRef.doc(widget.userId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return loading();
          }
          User user = User.fromDocument(snapshot.data!);
          return Scaffold(
            appBar: AppBar(
              actions: [
                image != null
                    ? const SizedBox()
                    : IconButton(
                        onPressed: () {
                          showCupertinoModalBottomSheet(
                              backgroundColor: kdarkGreyColor,
                              context: context,
                              builder: (context) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0, vertical: 20),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: kCircleBorderRadius,
                                            child: Image.network(
                                              user.photoUrl,
                                              height: 55,
                                              width: 55,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            user.username,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                inherit: false,
                                                fontSize: 21),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.grey[900]),
                                      width: Get.width - 40,
                                      child: Column(children: [
                                        Text(
                                          user.email,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 19,
                                              inherit: false),
                                        )
                                      ]),
                                    ),
                                    const SizedBox(height: 15),
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                border: Border.all(
                                                    width: 0.8,
                                                    color: Colors.white)),
                                            child: CupertinoButton(
                                                onPressed: () {
                                                  Get.back();
                                                },
                                                child: const Text(
                                                  'Geri',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: CupertinoButton(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              padding: EdgeInsets.zero,
                                              color: kThemeColor,
                                              onPressed: () {
                                                Get.to(() => Account(
                                                    profileId: user.id,
                                                    previousPage: 'Mesajlar'));
                                              },
                                              child: const Text(
                                                'Profili gör',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                  ],
                                );
                              });
                        },
                        icon: const Icon(FeatherIcons.info)),
                const SizedBox(
                  width: 10,
                )
              ],
              centerTitle: true,
              elevation: 0,
              leading: IconButton(
                icon: buildBackButton(image != null),
                onPressed: () => Get.back(),
              ),
              title: Text(user.username),
            ),
            body: image != null
                ? Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: 0,
                        child: Image.file(
                          image!,
                          fit: BoxFit.fill,
                          width: Get.width,
                          height: Get.height,
                        ),
                      ),
                      Positioned(child: buildWriteMessage())
                    ],
                  )
                : Stack(
                    children: [
                      StreamBuilder<QuerySnapshot>(
                          stream: messagesRef
                              .doc(currentUser.id)
                              .collection('contacts')
                              .doc(user.id)
                              .collection('messages')
                              .orderBy('timestamp', descending: false)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return loading();
                            }
                            return ListView.builder(
                              controller: scrollController,
                              physics: const BouncingScrollPhysics(),
                              padding:
                                  const EdgeInsets.fromLTRB(15, 10, 15, 50),
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                return Align(
                                  alignment: snapshot.data!.docs[index]
                                              ['senderId'] ==
                                          currentUser.id
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Material(
                                        color: Colors.transparent,
                                        child: CupertinoContextMenu(
                                            previewBuilder:
                                                (context, animation, child) {
                                              return child;
                                            },
                                            actions: [
                                              CupertinoTheme(
                                                data: const CupertinoThemeData(
                                                    brightness:
                                                        Brightness.dark),
                                                child:
                                                    CupertinoContextMenuAction(
                                                        onPressed: () {
                                                          if (snapshot.data!
                                                                          .docs[
                                                                      index][
                                                                  'senderId'] ==
                                                              currentUser.id) {
                                                            messagesRef
                                                                .doc(currentUser
                                                                    .id)
                                                                .collection(
                                                                    'contacts')
                                                                .doc(user.id)
                                                                .collection(
                                                                    'messages')
                                                                .doc(snapshot
                                                                        .data!
                                                                        .docs[index]
                                                                    [
                                                                    'messageId'])
                                                                .delete();
                                                            messagesRef
                                                                .doc(user.id)
                                                                .collection(
                                                                    'contacts')
                                                                .doc(currentUser
                                                                    .id)
                                                                .collection(
                                                                    'messages')
                                                                .doc(snapshot
                                                                        .data!
                                                                        .docs[index]
                                                                    [
                                                                    'messageId'])
                                                                .delete();
                                                          } else {
                                                            messagesRef
                                                                .doc(currentUser
                                                                    .id)
                                                                .collection(
                                                                    'contacts')
                                                                .doc(user.id)
                                                                .collection(
                                                                    'messages')
                                                                .doc(snapshot
                                                                        .data!
                                                                        .docs[index]
                                                                    [
                                                                    'messageId'])
                                                                .delete();
                                                          }
                                                          Get.back();
                                                        },
                                                        trailingIcon:
                                                            CupertinoIcons
                                                                .delete,
                                                        child: Text(
                                                          snapshot.data!.docs[
                                                                          index]
                                                                      [
                                                                      'senderId'] ==
                                                                  currentUser.id
                                                              ? 'Sil'
                                                              : 'Benden sil',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        )),
                                              ),
                                              CupertinoTheme(
                                                data: const CupertinoThemeData(
                                                    brightness:
                                                        Brightness.dark),
                                                child:
                                                    CupertinoContextMenuAction(
                                                        onPressed: () {
                                                          Get.back();
                                                        },
                                                        child: const Text(
                                                            'Cancel')),
                                              ),
                                            ],
                                            child: messageTemplate(
                                              snapshot.data!.docs[index]
                                                  ['message'],
                                              snapshot.data!.docs[index]
                                                  ['senderId'],
                                              snapshot.data!.docs[index]
                                                  ['timestamp'],
                                              snapshot.data!.docs[index]
                                                  ['imageUrl'],
                                            )),
                                      )
                                    ],
                                  ),
                                );
                              },
                            );
                          }),
                      buildWriteMessage()
                    ],
                  ),
          );
        });
  }

  Future pickImage(
    bool camera,
  ) async {
    final image = await ImagePicker()
        .pickImage(source: camera ? ImageSource.camera : ImageSource.gallery);

    if (image == null) return;

    final imageTemporary = File(image.path);
    this.image = imageTemporary;

    handleDatabase();
  }

  handleDatabase() async {
    String imageId = const Uuid().v4();
    final storageImage = FirebaseStorage.instance
        .ref()
        .child('messageImages')
        .child('$imageId.jpg');
    var task = storageImage.putFile(image!);

    url = await (await task.whenComplete(() => null)).ref.getDownloadURL();
  }

  Align buildWriteMessage() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 0),
              decoration: BoxDecoration(
                color: kdarkGreyColor,
                border: Border.symmetric(
                  horizontal: BorderSide(
                    color: Colors.grey[600]!,
                  ),
                ),
              ),
              alignment: Alignment.bottomCenter,
              child: Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 0,
                      child: IconButton(
                          onPressed: () {
                            showCupertinoModalPopup(
                                context: context,
                                builder: (context) => CupertinoTheme(
                                      data: const CupertinoThemeData(
                                          brightness: Brightness.dark),
                                      child: CupertinoActionSheet(
                                        cancelButton:
                                            CupertinoActionSheetAction(
                                          onPressed: () {
                                            Get.back();
                                          },
                                          child: const Text(
                                            'Geri',
                                            style: TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                        actions: [
                                          CupertinoActionSheetAction(
                                              onPressed: () {
                                                Get.back();

                                                pickImage(
                                                  true,
                                                );
                                              },
                                              child: const Text(
                                                "Fotoğraf çek",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              )),
                                          CupertinoActionSheetAction(
                                              onPressed: () {
                                                Get.back();

                                                pickImage(false);
                                              },
                                              child: const Text(
                                                "Galeri",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              )),
                                        ],
                                      ),
                                    ));
                          },
                          icon: const Icon(
                            FeatherIcons.image,
                            color: Color.fromARGB(255, 231, 231, 231),
                          )),
                    ),
                    Expanded(
                        child: SizedBox(
                      height: 35,
                      child: CupertinoTextField(
                        style: const TextStyle(color: Colors.white),
                        controller: messageController,
                        placeholder: 'Write your message..',
                        placeholderStyle:
                            const TextStyle(color: Colors.grey, fontSize: 16),
                        decoration: BoxDecoration(
                            color: kdarkGreyColor,
                            borderRadius: BorderRadius.circular(200)),
                      ),
                    )),
                    Expanded(
                      flex: 0,
                      child: IconButton(
                          onPressed: () {
                            String messageId = const Uuid().v4();
                            try {
                              //image is null and text is empty
                              if (image == null &&
                                  messageController.text.isEmpty) {
                              }
                              //image is null and text is not empty
                              else if (image == null &&
                                  messageController.text.isNotEmpty) {
                                messagesRef
                                    .doc(currentUser.id)
                                    .collection('contacts')
                                    .doc(widget.userId)
                                    .set({
                                  "userId": widget.userId,
                                });
                                messagesRef
                                    .doc(widget.userId)
                                    .collection('contacts')
                                    .doc(currentUser.id)
                                    .set({
                                  "userId": currentUser.id,
                                });
                                //for current user
                                messagesRef
                                    .doc(currentUser.id)
                                    .collection('contacts')
                                    .doc(widget.userId)
                                    .collection('messages')
                                    .doc(messageId)
                                    .set({
                                  "contactId": contactId,
                                  "senderId": currentUser.id,
                                  "senderName": currentUser.username,
                                  "message": messageController.text,
                                  "timestamp": DateTime.now(),
                                  "imageUrl": "",
                                  "messageId": messageId,
                                });
                                //for other user
                                messagesRef
                                    .doc(widget.userId)
                                    .collection('contacts')
                                    .doc(currentUser.id)
                                    .collection('messages')
                                    .doc(messageId)
                                    .set({
                                  "contactId": contactId,
                                  "senderId": currentUser.id,
                                  "senderName": currentUser.username,
                                  "message": messageController.text,
                                  "timestamp": DateTime.now(),
                                  "imageUrl": "",
                                  "messageId": messageId,
                                });
                                sendNotification(
                                  type: "message",
                                  message: messageController.text,
                                  imageUrl: "",
                                  messageId: messageId,
                                  senderId: currentUser.id,
                                );
                              }
                              //image is not null and text is empty
                              else if (image != null &&
                                  messageController.text.isEmpty) {
                                messagesRef
                                    .doc(currentUser.id)
                                    .collection('contacts')
                                    .doc(widget.userId)
                                    .set({
                                  "userId": widget.userId,
                                });
                                messagesRef
                                    .doc(widget.userId)
                                    .collection('contacts')
                                    .doc(currentUser.id)
                                    .set({
                                  "userId": currentUser.id,
                                });
                                //for current user
                                messagesRef
                                    .doc(currentUser.id)
                                    .collection('contacts')
                                    .doc(widget.userId)
                                    .collection('messages')
                                    .doc(messageId)
                                    .set({
                                  "contactId": contactId,
                                  "senderId": currentUser.id,
                                  "senderName": currentUser.username,
                                  "message": "",
                                  "timestamp": DateTime.now(),
                                  "imageUrl": url,
                                });
                                //for other user
                                messagesRef
                                    .doc(widget.userId)
                                    .collection('contacts')
                                    .doc(currentUser.id)
                                    .collection('messages')
                                    .doc(messageId)
                                    .set({
                                  "contactId": contactId,
                                  "senderId": currentUser.id,
                                  "senderName": currentUser.username,
                                  "message": "",
                                  "timestamp": DateTime.now(),
                                  "imageUrl": url,
                                });
                                sendNotification(
                                  type: "message",
                                  message: "",
                                  imageUrl: url,
                                  messageId: messageId,
                                  senderId: currentUser.id,
                                );
                              }
                              //image is not null and text is not empty
                              else if (image != null &&
                                  messageController.text.isNotEmpty) {
                                messagesRef
                                    .doc(currentUser.id)
                                    .collection('contacts')
                                    .doc(widget.userId)
                                    .set({
                                  "userId": widget.userId,
                                });
                                messagesRef
                                    .doc(widget.userId)
                                    .collection('contacts')
                                    .doc(currentUser.id)
                                    .set({
                                  "userId": currentUser.id,
                                });
                                //for current user
                                messagesRef
                                    .doc(currentUser.id)
                                    .collection('contacts')
                                    .doc(widget.userId)
                                    .collection('messages')
                                    .doc(messageId)
                                    .set({
                                  "contactId": contactId,
                                  "senderId": currentUser.id,
                                  "senderName": currentUser.username,
                                  "message": messageController.text,
                                  "timestamp": DateTime.now(),
                                  "imageUrl": url,
                                  "messageId": messageId,
                                });
                                //for other user
                                messagesRef
                                    .doc(widget.userId)
                                    .collection('contacts')
                                    .doc(currentUser.id)
                                    .collection('messages')
                                    .doc(messageId)
                                    .set({
                                  "contactId": contactId,
                                  "senderId": currentUser.id,
                                  "senderName": currentUser.username,
                                  "message": messageController.text,
                                  "timestamp": DateTime.now(),
                                  "imageUrl": url,
                                  "messageId": messageId,
                                });
                                sendNotification(
                                  type: "message",
                                  message: messageController.text,
                                  imageUrl: url,
                                  messageId: messageId,
                                  senderId: currentUser.id,
                                );
                              } else {}
                            } catch (e) {
                              snackbar(
                                  "Hata",
                                  "Beklenmeyen bir hata oluştu. Lütfen daha sonra tekrar deneyin",
                                  true);
                            }
                            messageController.clear();

                            setState(() {
                              image = null;
                              url = '';
                            });

                            scrollController.animateTo(
                                scrollController.position.maxScrollExtent,
                                curve: Curves.easeInOut,
                                duration: const Duration(
                                    seconds: 1, milliseconds: 50));
                          },
                          icon: const Icon(Icons.send, color: Colors.white)),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  sendNotification({
    String? type,
    String? message,
    String? imageUrl,
    String? messageId,
    String? senderId,
  }) {
    String notificationId = Uuid().v4();
    //notification
    notificationsRef
        .doc(widget.userId)
        .collection('userNotifications')
        .doc(notificationId)
        .set({
      "notificationId": notificationId,
      "type": type,
      "message": message,
      "title": "${currentUser.username} size bir mesaj gonderdi",
      "subTitle": imageUrl == "" ? message : "Resim 🖼️",
      "messageId": messageId,
      "senderId": currentUser.id,
      "senderName": currentUser.username,
      "timestamp": DateTime.now(),
    });
  }
}
