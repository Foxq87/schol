import '/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:uuid/uuid.dart';
import '/constants.dart';
import '/models/user_model.dart';
import '/models/pages/root.dart';

class Bim extends StatefulWidget {
  const Bim({super.key});

  @override
  State<Bim> createState() => _BimState();
}

class _BimState extends State<Bim> {
  String formatted(DateTime date) {
    String hours = date.hour.toString();
    String minutes = date.minute.toString();
    return '$hours:$minutes';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bim'),
        actions: [
          SizedBox(
            width: 120,
            child: IconButton(
              onPressed: () {},
              icon: SizedBox(
                height: 35,
                child: CupertinoButton(
                  borderRadius: BorderRadius.circular(10000),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  color: kThemeColor,
                  child: const Text("Bim'e Git"),
                  onPressed: () {
                    showCupertinoModalBottomSheet(
                        backgroundColor: kdarkGreyColor,
                        context: context,
                        builder: (context) => const BimBottomSheet());
                  },
                ),
              ),
            ),
          )
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            child: Text(
              "Bim'e gidenler",
              style: TextStyle(
                  color: Colors.white, fontSize: 22, fontFamily: 'poppinsBold'),
            ),
          ),
          StreamBuilder(
              stream: bimRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return loading();
                }
                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return StreamBuilder(
                        stream: usersRef
                            .doc(snapshot.data!.docs[index]['userId'])
                            .snapshots(),
                        builder: (context, userSnapshot) {
                          Timestamp time = snapshot.data!.docs[index]['time'];
                          User user = User.fromDocument(userSnapshot.data!);

                          return GestureDetector(
                            onTap: () {
                              Get.to(
                                  () => BimMessage(
                                        user: user,
                                      ),
                                  transition: Transition.cupertino);
                            },
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                              decoration: BoxDecoration(
                                  color: kdarkGreyColor,
                                  borderRadius: BorderRadius.circular(15)),
                              child: ListTile(
                                title: Text(
                                  user.username,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Max alıcı : 2 / ${snapshot.data!.docs[index]['maxPerson']}'),
                                    Text(
                                      'Saat :${formatted(time.toDate())}',
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    )
                                  ],
                                ),
                                trailing: Text(
                                  'Bütçe : ${snapshot.data!.docs[index]['budget']} ₺',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          );
                        });
                  },
                );
              })
        ],
      ),
    );
  }
}

class BimBottomSheet extends StatefulWidget {
  const BimBottomSheet({super.key});

  @override
  State<BimBottomSheet> createState() => _BimBottomSheetState();
}

class _BimBottomSheetState extends State<BimBottomSheet> {
  List budgets = [
    [20, false],
    [30, false],
    [40, false],
    [50, false],
    [75, false],
    [100, false]
  ];
  List maxPerson = [
    [1, false],
    [2, false],
    [3, false],
    [4, false],
    [5, false],
  ];
  DateTime date = DateTime.now();

  int mxPerson = 0;
  int budget = 0;

  String formatted(DateTime date) {
    String hours = date.hour.toString();
    String minutes = date.minute.toString();
    return '$hours:$minutes';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: CupertinoButton(
          borderRadius: BorderRadius.circular(200),
          color: kThemeColor,
          child: const Text("Bim'e Git"),
          onPressed: () {
            bimRef.doc(currentUser.id).set({
              "userId": currentUser.id,
              "time": date,
              "maxPerson": mxPerson,
              "budget": budget,
            });
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(children: [
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Zaman',
                style: TextStyle(
                    inherit: false,
                    color: Colors.white,
                    fontSize: 22,
                    fontFamily: 'poppinsBold'),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Saat',
                    style: TextStyle(
                        inherit: false,
                        color: Colors.white,
                        fontSize: 19,
                        fontFamily: 'poppinsBold'),
                  ),
                  GestureDetector(
                    onTap: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (context) => Container(
                          decoration: const BoxDecoration(
                              color: kdarkGreyColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              )),
                          height: Get.height / 2.2,
                          child: CupertinoTheme(
                            data: const CupertinoThemeData(
                              brightness: Brightness.dark,
                            ),
                            child: CupertinoDatePicker(
                              initialDateTime: DateTime.now(),
                              minimumDate: DateTime.now(),
                              use24hFormat: true,
                              onDateTimeChanged: (val) {
                                setState(() {
                                  date = val;
                                });
                              },
                              mode: CupertinoDatePickerMode.time,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 7, horizontal: 12),
                      decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(7)),
                      child: Text(
                        formatted(date).toString(),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 18, inherit: false),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Bütçe',
                style: TextStyle(
                    inherit: false,
                    color: Colors.white,
                    fontSize: 22,
                    fontFamily: 'poppinsBold'),
              ),
              const SizedBox(
                height: 10,
              ),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: budgets.length,
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisExtent: 45,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10),
                itemBuilder: (context, index) {
                  return budgetContainer(index);
                },
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Maksimum Kişi',
                style: TextStyle(
                    inherit: false,
                    color: Colors.white,
                    fontSize: 22,
                    fontFamily: 'poppinsBold'),
              ),
              const SizedBox(
                height: 10,
              ),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: maxPerson.length,
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisExtent: 45,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10),
                itemBuilder: (context, index) {
                  return maxPersonContainer(index);
                },
              ),
              const SizedBox(
                height: 20,
              ),

              // CupertinoDatePicker(
              //   onDateTimeChanged: (val) {},
              //   mode: CupertinoDatePickerMode.time,
              // ),
            ],
          ),
        ),
      ]),
    );
  }

  budgetContainer(int index) {
    return GestureDetector(
      onTap: () {
        for (var i = 0; i < budgets.length; i++) {
          setState(() {
            budgets[i][1] = false;
          });
        }
        setState(() {
          budget = budgets[index][0];
          budgets[index][1] = true;
        });
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: budgets[index][1] ? kThemeColor : Colors.grey[900],
            borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Text(
          '${budgets[index][0]} ₺',
          style: const TextStyle(
              color: Colors.white, fontSize: 19, inherit: false),
        ),
      ),
    );
  }

  maxPersonContainer(int index) {
    return GestureDetector(
      onTap: () {
        for (var i = 0; i < maxPerson.length; i++) {
          setState(() {
            maxPerson[i][1] = false;
          });
        }
        setState(() {
          mxPerson = maxPerson[index][0];
          maxPerson[index][1] = true;
        });
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: maxPerson[index][1] ? kThemeColor : Colors.grey[900],
            borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Text(
          '${maxPerson[index][0]}',
          style: const TextStyle(
              color: Colors.white, fontSize: 19, inherit: false),
        ),
      ),
    );
  }
}

class BimMessage extends StatefulWidget {
  final User user;
  const BimMessage({super.key, required this.user});

  @override
  State<BimMessage> createState() => _BimMessageState();
}

class _BimMessageState extends State<BimMessage> {
  TextEditingController messageController = TextEditingController();
  String contactId = const Uuid().v4();
  buildBackButton() {
    return GestureDetector(
      onTap: () {
        Get.back();
      },
      child: const CircleAvatar(
        radius: 15,
        backgroundColor: kdarkGreyColor,
        child: Center(
            child: Icon(
          FeatherIcons.arrowLeft,
          color: Colors.white,
          size: 18,
        )),
      ),
    );
  }

  messageTemplate(String message, String senderId) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            alignment: senderId == currentUser.id
                ? Alignment.centerRight
                : Alignment.centerLeft,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: senderId == currentUser.id
                    ? Colors.grey[800]
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
              child: Text(
                message,
                style: const TextStyle(
                    color: Colors.white, fontFamily: 'poppinsBold'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: usersRef.doc(widget.user.id).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return loading();
          }
          User user = User.fromDocument(snapshot.data!);
          return Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                    onPressed: () {}, icon: const Icon(FeatherIcons.info)),
                const SizedBox(
                  width: 10,
                )
              ],
              centerTitle: true,
              elevation: 0,
              leading: IconButton(
                icon: buildBackButton(),
                onPressed: () => Get.back(),
              ),
              title: Text(user.username),
            ),
            body: Stack(
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
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 50),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          return Align(
                            alignment: snapshot.data!.docs[index]['senderId'] ==
                                    currentUser.id
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                messageTemplate(
                                    snapshot.data!.docs[index]['message'],
                                    snapshot.data!.docs[index]['senderId'])
                              ],
                            ),
                          );
                        },
                      );
                    }),
                const SizedBox(
                  height: 25,
                ),
                buildWriteMessage()
              ],
            ),
          );
        });
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
                      horizontal: BorderSide(color: Colors.grey[600]!))),
              alignment: Alignment.bottomCenter,
              child: Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 0,
                      child: IconButton(
                          onPressed: () {},
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
                            if (messageController.text.isNotEmpty) {
                              String messageId = const Uuid().v4();
                              messagesRef
                                  .doc(currentUser.id)
                                  .collection('contacts')
                                  .doc(widget.user.id)
                                  .set({
                                "userId": widget.user.id,
                              });
                              messagesRef
                                  .doc(widget.user.id)
                                  .collection('contacts')
                                  .doc(currentUser.id)
                                  .set({
                                "userId": currentUser.id,
                              });
                              //for current user
                              messagesRef
                                  .doc(currentUser.id)
                                  .collection('contacts')
                                  .doc(widget.user.id)
                                  .collection('messages')
                                  .doc(messageId)
                                  .set({
                                "contactId": contactId,
                                "senderId": currentUser.id,
                                "senderName": currentUser.username,
                                "message": messageController.text,
                                "timestamp": DateTime.now()
                              });
                              //for other user
                              messagesRef
                                  .doc(widget.user.id)
                                  .collection('contacts')
                                  .doc(currentUser.id)
                                  .collection('messages')
                                  .doc(messageId)
                                  .set({
                                "contactId": contactId,
                                "senderId": currentUser.id,
                                "senderName": currentUser.username,
                                "message": messageController.text,
                                "timestamp": DateTime.now()
                              });

                              messageController.clear();
                            }
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
}
