// ignore_for_file: must_be_immutable, no_logic_in_create_state
import 'dart:math';

import 'package:appbeyoglu/widgets/snackbar.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:unicons/unicons.dart';
import 'package:uuid/uuid.dart';

import '/widgets/loading.dart';

import '../pages/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/models/user_model.dart';
import '../pages/root.dart';

class Order extends StatefulWidget {
  int? index;
  String orderId;
  String buyerId;
  String note;
  double purchase;
  String vendorId;
  String dormType;
  String paymentMethod;
  int dormNumber;
  bool isCompleted;
  bool isAccepted;
  bool isCanceled;
  List isApproved;
  List theList;
  String delivererId;

  Order({
    super.key,
    this.index,
    required this.paymentMethod,
    required this.dormNumber,
    required this.dormType,
    required this.note,
    required this.buyerId,
    required this.orderId,
    required this.purchase,
    required this.vendorId,
    required this.isApproved,
    required this.isCompleted,
    required this.theList,
    required this.delivererId,
    required this.isCanceled,
    required this.isAccepted,
  });

  // factory Order.fromDocument(DocumentSnapshot doc) {
  //   return Order(
  //     orderId: doc['orderId'],
  //     purchase: doc['purchase'],
  //     vendorId: doc['vendorId'],
  //     buyerId: doc['buyerId'],
  //     note: doc['note'],
  //     dormNumber: doc['dormNumber'],
  //     dormType: doc['dormType'],
  //     paymentMethod: doc['paymentMethod'],
  //     isComplete: doc['isCompleted'],
  //     bringMe: doc['bringMe'],
  //   );
  // }

  @override
  // ignore: library_private_types_in_public_api
  _OrderState createState() => _OrderState(
        index: index,
        purchase: purchase,
        vendorId: vendorId,
        orderId: orderId,
        note: note,
        buyerId: buyerId,
        dormType: dormType,
        dormNumber: dormNumber,
        paymentMethod: paymentMethod,
        isApproved: isApproved,
        isCompleted: isCompleted,
        theList: theList,
        delivererId: delivererId,
        isAccepted: isAccepted,
        isCanceled: isCanceled,
      );
}

class _OrderState extends State<Order> {
  int? index;
  String orderId;
  double purchase;
  String vendorId;
  String buyerId;
  String note;
  String dormType;
  String delivererId;
  int dormNumber;
  String paymentMethod;
  bool isCompleted;
  bool isAccepted;
  bool isCanceled;
  List isApproved;
  List theList;

  _OrderState({
    this.index,
    required this.paymentMethod,
    required this.dormNumber,
    required this.dormType,
    required this.purchase,
    required this.note,
    required this.buyerId,
    required this.orderId,
    required this.vendorId,
    required this.isApproved,
    required this.isCompleted,
    required this.theList,
    required this.delivererId,
    required this.isCanceled,
    required this.isAccepted,
  });
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: orderContentsRef
            .doc(buyerId)
            .collection('userOrders')
            .doc(orderId)
            .collection('contents')
            .snapshots(),
        builder: (context, cartSnapshot) {
          if (!cartSnapshot.hasData && cartSnapshot.data == null) {
            return loading();
          }
          // CartProduct.fromDocument(cartSnapshot.data!.docs[0]);
          return GestureDetector(
            onTap: () {
              Get.to(
                  () => OrderDetails(
                        index: index,
                        paymentMethod: paymentMethod,
                        dormNumber: dormNumber,
                        dormType: dormType,
                        note: note,
                        buyerId: buyerId,
                        orderId: orderId,
                        purchase: purchase,
                        vendorId: vendorId,
                        theList: theList,
                        delivererId: delivererId,
                        isAccepted: isAccepted,
                        isCanceled: isCanceled,
                      ),
                  transition: Transition.cupertino);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 15, 15, 0),
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(width: 1, color: Colors.grey[700]!)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ListView.builder(
                    //   physics: const NeverScrollableScrollPhysics(),
                    //   scrollDirection: Axis.vertical,
                    //   shrinkWrap: true,
                    //   itemCount: cartSnapshot.data!.docs.length,
                    //   itemBuilder: (context, index) {
                    //     String price =
                    //         cartSnapshot.data!.docs[index]['productPrice'];
                    //     return Row(
                    //       children: [
                    //         Column(
                    //           crossAxisAlignment: CrossAxisAlignment.center,
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           children: [
                    //             ClipRRect(
                    //                 borderRadius: BorderRadius.circular(10),
                    //                 child: Image.network(
                    //                   cartSnapshot.data!.docs[index]['image'],
                    //                   height: 70,
                    //                   width: 70,
                    //                   fit: BoxFit.cover,
                    //                 )),
                    //             index + 1 == cartSnapshot.data!.docs.length
                    //                 ? const SizedBox(
                    //                     height: 10,
                    //                   )
                    //                 : Container(
                    //                     color: Colors.grey,
                    //                     width: 3,
                    //                     height: 25,
                    //                   ),
                    //           ],
                    //         ),
                    //         SizedBox(
                    //           width: 10,
                    //         ),
                    //         Text(
                    //           cartSnapshot.data!.docs[index]['productTitle'],
                    //           style:
                    //               TextStyle(color: Colors.white, fontSize: 18),
                    //         ),
                    //         SizedBox(
                    //           width: 15,
                    //         ),
                    //         Text(
                    //           '$price ₺',
                    //           style:
                    //               TextStyle(color: Colors.white, fontSize: 18),
                    //         ),
                    //         SizedBox(
                    //           width: 15,
                    //         ),
                    //         Container(
                    //           height: 35,
                    //           width: 35,
                    //           padding: EdgeInsets.all(7),
                    //           decoration: BoxDecoration(
                    //               color: Colors.grey[900],
                    //               borderRadius: BorderRadius.circular(5)),
                    //           child: Center(
                    //             child: Text(
                    //               'x${cartSnapshot.data!.docs[index]['myQuantity']}',
                    //               style: TextStyle(
                    //                   color: Colors.white, fontSize: 18),
                    //             ),
                    //           ),
                    //         )
                    //       ],
                    //     );
                    //   },
                    // ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FutureBuilder(
                            future: usersRef.doc(vendorId).get(),
                            builder: (context, vendorSnapshot) {
                              if (!vendorSnapshot.hasData) {
                                return loading();
                              }
                              return FutureBuilder(
                                  future: usersRef.doc(buyerId).get(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return loading();
                                    }
                                    User vendor =
                                        User.fromDocument(vendorSnapshot.data!);
                                    User buyer =
                                        User.fromDocument(snapshot.data!);
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Text(
                                                  'Alıcı : ',
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 15,
                                                      fontFamily:
                                                          'poppinsBold'),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  buyer.username,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 17,
                                                      fontFamily:
                                                          'poppinsBold'),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Text(
                                                  'Satıcı : ',
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 15,
                                                      fontFamily:
                                                          'poppinsBold'),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  vendor.username,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 17,
                                                      fontFamily:
                                                          'poppinsBold'),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                            Text('$purchase ₺',
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14)),
                                            widget.isCompleted == true
                                                ? Column(children: [
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 6),
                                                      height: 25,
                                                      decoration: BoxDecoration(
                                                          color: kThemeColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5)),
                                                      child: const Center(
                                                        child: Text(
                                                          'Tamamlandı',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  ])
                                                : const SizedBox(),
                                          ],
                                        ),
                                      ],
                                    );
                                  });
                            }),
                        const SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                    note == ''
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Not',
                                  style: TextStyle(
                                      color: kThemeColor, fontSize: 18),
                                ),
                                Text(
                                  note,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 7),
                              decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(5)),
                              child: Text(
                                dormType,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                dormNumber.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 7),
                              decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(5)),
                              child: Text(
                                paymentMethod.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.more_horiz_rounded,
                            color: Colors.grey,
                          ),
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
                                                      color: Colors.white),
                                                )),
                                        actions: [
                                          CupertinoActionSheetAction(
                                              onPressed: () {
                                                Get.to(
                                                    ChatPage(
                                                        userId: widget
                                                                    .buyerId ==
                                                                currentUser.id
                                                            ? widget.vendorId
                                                            : widget.buyerId),
                                                    transition:
                                                        Transition.cupertino);
                                              },
                                              child: Text(
                                                widget.buyerId == currentUser.id
                                                    ? 'Satıcıyla iletişime geç'
                                                    : 'Alıcıyla iletişime geç',
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              )),
                                          // CupertinoActionSheetAction(
                                          //     onPressed: () {
                                          //       Get.back();
                                          //       showDialog(
                                          //         context: context,
                                          //         builder: (context) =>
                                          //             AlertDialog(
                                          //           backgroundColor:
                                          //               kdarkGreyColor,
                                          //           title: Text(
                                          //             'Emin misiniz?',
                                          //             style: TextStyle(
                                          //                 color: Colors.white),
                                          //           ),
                                          //           content: Text(
                                          //             'Siparişiniz iptal edilecek',
                                          //             style: TextStyle(
                                          //                 color: Colors.red,
                                          //                 fontFamily:
                                          //                     'poppinsBold'),
                                          //           ),
                                          //           actions: [
                                          //             Padding(
                                          //               padding:
                                          //                   const EdgeInsets
                                          //                           .symmetric(
                                          //                       horizontal:
                                          //                           10.0),
                                          //               child: Row(
                                          //                 children: [
                                          //                   Expanded(
                                          //                     child:
                                          //                         CupertinoButton(
                                          //                             padding:
                                          //                                 EdgeInsets
                                          //                                     .zero,
                                          //                             color:
                                          //                                 kThemeColor,
                                          //                             child: Text(
                                          //                                 'Geri',
                                          //                                 style: TextStyle(
                                          //                                     color: Colors
                                          //                                         .white)),
                                          //                             onPressed:
                                          //                                 () {
                                          //                               Get.back();
                                          //                             }),
                                          //                   ),
                                          //                   SizedBox(
                                          //                     width: 10,
                                          //                   ),
                                          //                   Expanded(
                                          //                       child:
                                          //                           CupertinoButton(
                                          //                               padding: EdgeInsets.symmetric(
                                          //                                   horizontal:
                                          //                                       5),
                                          //                               color: Colors
                                          //                                   .red,
                                          //                               child:
                                          //                                   Text(
                                          //                                 'Siparişi iptal et',
                                          //                                 style:
                                          //                                     TextStyle(color: Colors.white),
                                          //                                 textAlign:
                                          //                                     TextAlign.center,
                                          //                               ),
                                          //                               onPressed:
                                          //                                   () {
                                          //                                 //cancel order
                                          //                                 ordersRef
                                          //                                     .doc(currentUser.id)
                                          //                                     .collection('orders')
                                          //                                     .doc(orderId)
                                          //                                     .delete();
                                          //                                 //show notification for vendor
                                          //                                 //show snackbar for currentuser
                                          //                                 Get.back();
                                          //                               }))
                                          //                 ],
                                          //               ),
                                          //             ),
                                          //           ],
                                          //         ),
                                          //       );
                                          //     },
                                          //     child: const Text(
                                          //       'Siparişi iptal et',
                                          //       style: TextStyle(
                                          //           color: Colors.red),
                                          //     ))
                                        ],
                                      ),
                                    ));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class OrderDetails extends StatefulWidget {
  int? index;
  String orderId;
  double purchase;
  String vendorId;
  String buyerId;
  String note;
  String dormType;
  bool isAccepted;
  bool isCanceled;
  int dormNumber;
  List theList;
  String paymentMethod;
  String delivererId;

  OrderDetails({
    super.key,
    this.index,
    required this.paymentMethod,
    required this.dormNumber,
    required this.dormType,
    required this.purchase,
    required this.note,
    required this.buyerId,
    required this.orderId,
    required this.vendorId,
    required this.theList,
    required this.delivererId,
    required this.isAccepted,
    required this.isCanceled,
  });
  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  String dormKind = '';
  List<Widget> dorms = [];
  TextEditingController noteController = TextEditingController();
  int dorm = 1;
  @override
  void initState() {
    // TODO: implement initState
    addDorm();
    super.initState();
  }

  addDorm() {
    for (var i = 1; i <= 43; i++) {
      dorms.add(Center(
          child: Text(
        i.toString(),
        style: const TextStyle(color: Colors.white),
      )));
    }
  }

  List dormType = [
    ['İYC', false],
    ['DPY', false],
    ['DPY (yeni bina)', false]
  ];

  @override
  Widget build(BuildContext context) {
    FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: dorm - 1);
    return CupertinoPageScaffold(
      child: NestedScrollView(
        physics: const BouncingScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          CupertinoSliverNavigationBar(
            border: innerBoxIsScrolled
                ? const Border(
                    bottom: BorderSide(
                        color: CupertinoColors.systemGrey, width: 0.25))
                : const Border(bottom: BorderSide()),
            backgroundColor: innerBoxIsScrolled
                ? const Color.fromARGB(255, 19, 19, 19).withOpacity(0.9)
                : const Color.fromARGB(255, 3, 3, 3),
            automaticallyImplyLeading: false,
            previousPageTitle: 'Siparişler',
            largeTitle: const Text(
              'Sipariş detayları',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        body: Material(
          color: Colors.transparent,
          child: ListView(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            children: [
              StreamBuilder(
                  stream: orderContentsRef
                      .doc(widget.buyerId)
                      .collection('userOrders')
                      .doc(widget.orderId)
                      .collection('contents')
                      .snapshots(),
                  builder: (context, cartSnapshot) {
                    if (!cartSnapshot.hasData) {
                      return loading();
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.only(left: 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.81,
                        crossAxisSpacing: 20,
                      ),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: cartSnapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey[600]!, width: 0.65),
                                borderRadius: BorderRadius.circular(15)),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey[600]!,
                                        width: 0.65,
                                      ),
                                    ),
                                  ),
                                  child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15)),
                                      child: Image.network(
                                        cartSnapshot.data!.docs[index]['image'],
                                        height: 120,
                                        width: 250,
                                        fit: BoxFit.cover,
                                      )),
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0),
                                  child: FutureBuilder(
                                      future: usersRef
                                          .doc(cartSnapshot.data!.docs[index]
                                              ['vendorId'])
                                          .get(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return loading();
                                        }
                                        User user =
                                            User.fromDocument(snapshot.data!);
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                user.photoUrl,
                                                height: 40,
                                                width: 40,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: 53,
                                                  child: Text(
                                                    cartSnapshot
                                                            .data!.docs[index]
                                                        ['productTitle'],
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontFamily:
                                                            'poppinsBold'),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Text(
                                                    '${cartSnapshot.data!.docs[index]['productPrice']} ₺',
                                                    style: const TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 11)),
                                                // Text('@ ' + user.username,
                                                //     style: TextStyle(
                                                //         color: Colors.grey, fontSize: 11)),
                                              ],
                                            ),
                                          ],
                                        );
                                      }),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Expanded(
                                  child: Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(7, 0, 7, 7),
                                    width: 1000,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: kdarkGreyColor,
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "x${cartSnapshot.data!.docs[index]['myQuantity']}",
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 17),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
              const SizedBox(
                height: 10,
              ),
              const Divider(
                height: 0.0,
                color: Colors.white,
              ),
              widget.buyerId == currentUser.id
                  ? buildApproveButton()
                  : StreamBuilder<DocumentSnapshot>(
                      stream: ordersRef.doc(widget.orderId).snapshots(),
                      builder: (context, mySnapshot) {
                        if (!mySnapshot.hasData) {
                          return loading();
                        }

                        return buildApprovedStatus(
                          mySnapshot.data!.get('isApproved'),
                          mySnapshot.data!.get('isAccepted'),
                          mySnapshot.data!.get('isCompleted'),
                          scrollController,
                          mySnapshot.data!.get('isCanceled'),
                        );
                      }),
            ],
          ),
        ),
      ),
    );
  }

  Padding buildApprovedStatus(
      List isApproved,
      bool isAccepted,
      bool isCompleted,
      FixedExtentScrollController scrollController,
      bool isCanceled) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Center(
        child: isCanceled
            ? Text(
                'Sipariş reddedildi',
                style: TextStyle(color: Colors.white),
              )
            : isCompleted
                ? Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            backgroundColor: kThemeColor,
                            radius: 15,
                            child: Icon(
                              CupertinoIcons.check_mark,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            width: Get.width / 8,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            height: 2.5,
                            decoration: BoxDecoration(
                                borderRadius: kCircleBorderRadius,
                                color: kThemeColor),
                          ),
                          const CircleAvatar(
                            backgroundColor: kThemeColor,
                            radius: 15,
                            child: Icon(
                              CupertinoIcons.check_mark,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            width: Get.width / 8,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            height: 2.5,
                            decoration: BoxDecoration(
                                borderRadius: kCircleBorderRadius,
                                color: kThemeColor),
                          ),
                          const CircleAvatar(
                            backgroundColor: kThemeColor,
                            radius: 15,
                            child: Icon(
                              CupertinoIcons.check_mark,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            width: Get.width / 8,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            height: 2.5,
                            decoration: BoxDecoration(
                                borderRadius: kCircleBorderRadius,
                                color: kThemeColor),
                          ),
                          const CircleAvatar(
                            backgroundColor: kThemeColor,
                            radius: 15,
                            child: Icon(
                              CupertinoIcons.check_mark,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Teslim edildi',
                        style: TextStyle(color: kThemeColor, fontSize: 20),
                      ),
                      SizedBox(
                        width: 200,
                        child: Center(
                          child: Lottie.network(
                              "https://assets4.lottiefiles.com/packages/lf20_pWVo9w.json"),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      isApproved.isEmpty
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Yurt',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      SizedBox(
                                        height: 35,
                                        child: ListView.builder(
                                          itemCount: dormType.length,
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            return choice(
                                              dormType,
                                              index,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Yatakhane',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          showCupertinoModalPopup(
                                              context: context,
                                              builder: (context) {
                                                return CupertinoTheme(
                                                    data:
                                                        const CupertinoThemeData(
                                                            brightness:
                                                                Brightness.dark,
                                                            primaryColor:
                                                                kdarkGreyColor),
                                                    child: CupertinoActionSheet(
                                                      cancelButton:
                                                          CupertinoActionSheetAction(
                                                              onPressed: () {
                                                                Get.back();
                                                              },
                                                              child: const Text(
                                                                'Tamam',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white70),
                                                              )),
                                                      actions: [
                                                        SizedBox(
                                                          height:
                                                              Get.height / 3,
                                                          child:
                                                              CupertinoPicker(
                                                            scrollController:
                                                                scrollController,
                                                            backgroundColor:
                                                                kdarkGreyColor,
                                                            itemExtent: 50,
                                                            onSelectedItemChanged:
                                                                (value) {
                                                              setState(() {
                                                                dorm =
                                                                    value + 1;
                                                              });
                                                            },
                                                            children:
                                                                dorms.toList(),
                                                          ),
                                                        ),
                                                      ],
                                                    ));
                                              });
                                        },
                                        child: Container(
                                          width: 40,
                                          padding: const EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                              color: Colors.grey[900],
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Center(
                                              child: Text(
                                            dorm.toString(),
                                            style: const TextStyle(
                                                color: Colors.white),
                                          )),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  CupertinoTextField(
                                    style: const TextStyle(color: Colors.white),
                                    controller: noteController,
                                    placeholder: 'not',
                                    placeholderStyle:
                                        const TextStyle(color: Colors.grey),
                                    maxLines: 6,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 9, 9, 9),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                          width: 1, color: Colors.grey[700]!),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            )
                          : isApproved.length == 1
                              ? Column(
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const CircleAvatar(
                                          backgroundColor: kThemeColor,
                                          radius: 15,
                                          child: Icon(
                                            CupertinoIcons.check_mark,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Container(
                                          width: Get.width / 8,
                                          margin:
                                              const EdgeInsets.only(left: 5),
                                          height: 3.5,
                                          decoration: BoxDecoration(
                                              borderRadius: kCircleBorderRadius,
                                              color: kThemeColor),
                                        ),
                                        const CircleAvatar(
                                          backgroundColor: kThemeColor,
                                          radius: 15,
                                          child: Icon(
                                            CupertinoIcons.check_mark,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Container(
                                          width: Get.width / 16,
                                          margin:
                                              const EdgeInsets.only(left: 5),
                                          height: 3.5,
                                          decoration: BoxDecoration(
                                              borderRadius: kCircleBorderRadius,
                                              color: kThemeColor),
                                        ),
                                        Container(
                                          width: Get.width / 16,
                                          margin:
                                              const EdgeInsets.only(right: 5),
                                          height: 3.5,
                                          decoration: BoxDecoration(
                                              borderRadius: kCircleBorderRadius,
                                              color: Colors.grey),
                                        ),
                                        const CircleAvatar(
                                          backgroundColor: Colors.grey,
                                          radius: 15,
                                        ),
                                        Container(
                                          width: Get.width / 8,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          height: 3.5,
                                          decoration: BoxDecoration(
                                              borderRadius: kCircleBorderRadius,
                                              color: Colors.grey),
                                        ),
                                        const CircleAvatar(
                                          backgroundColor: Colors.grey,
                                          radius: 15,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 160,
                                      child: Center(
                                        child: Lottie.network(
                                            // "https://assets3.lottiefiles.com/packages/lf20_310RH0.json"),
                                            "https://assets3.lottiefiles.com/packages/lf20_xwdz8akv.json"),
                                      ),
                                    ),
                                    const Text(
                                      'Kurye yaniniza gelecek',
                                      style: TextStyle(
                                        color: kThemeColor,
                                        fontSize: 20,
                                      ),
                                    )
                                  ],
                                )
                              : isApproved.length == 2
                                  ? Column(
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const CircleAvatar(
                                              backgroundColor: kThemeColor,
                                              radius: 15,
                                              child: Icon(
                                                CupertinoIcons.check_mark,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Container(
                                              width: Get.width / 8,
                                              margin: const EdgeInsets.only(
                                                  left: 5),
                                              height: 3.5,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      kCircleBorderRadius,
                                                  color: kThemeColor),
                                            ),
                                            const CircleAvatar(
                                              backgroundColor: kThemeColor,
                                              radius: 15,
                                              child: Icon(
                                                CupertinoIcons.check_mark,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Container(
                                              width: Get.width / 8,
                                              margin: const EdgeInsets.only(
                                                  left: 5),
                                              height: 3.5,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      kCircleBorderRadius,
                                                  color: kThemeColor),
                                            ),
                                            const CircleAvatar(
                                              backgroundColor: kThemeColor,
                                              radius: 15,
                                              child: Icon(
                                                CupertinoIcons.check_mark,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Container(
                                              width: Get.width / 16,
                                              margin: const EdgeInsets.only(
                                                  left: 5),
                                              height: 3.5,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      kCircleBorderRadius,
                                                  color: kThemeColor),
                                            ),
                                            Container(
                                              width: Get.width / 16,
                                              margin: const EdgeInsets.only(
                                                  right: 5),
                                              height: 3.5,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      kCircleBorderRadius,
                                                  color: Colors.grey),
                                            ),
                                            const CircleAvatar(
                                              backgroundColor: Colors.grey,
                                              radius: 15,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: 200,
                                          child: Center(
                                            child: Lottie.network(
                                                "https://assets3.lottiefiles.com/packages/lf20_310RH0.json"),
                                          ),
                                        ),
                                        const Text(
                                          'Yolda',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontFamily: 'poppinsBold'),
                                        )
                                      ],
                                    )
                                  : const SizedBox(),
                      isApproved.isNotEmpty
                          ? const SizedBox()
                          : Column(
                              children: [
                                Container(
                                  width: Get.width - 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: isApproved.length == 1
                                        ? Border.all(
                                            width: 0.7,
                                            color: Colors.grey[700]!)
                                        : null,
                                  ),
                                  child: CupertinoButton(
                                      borderRadius: BorderRadius.circular(16),
                                      color: isApproved.length == 1 ||
                                              isApproved.length == 2
                                          ? Colors.transparent
                                          : kThemeColor,
                                      child: const Text('Siparişi al'),
                                      onPressed: () {
                                        if (isApproved.isEmpty &&
                                            dormKind != '') {
                                          try {
                                            usersRef
                                                .doc(currentUser.id)
                                                .get()
                                                .then((doc) {
                                              if (doc.exists) {
                                                doc.reference.update({
                                                  "dormNumber": dorm,
                                                  "dormType": dormKind,
                                                });
                                              }
                                            });
                                            ordersRef
                                                .doc(widget.orderId)
                                                .get()
                                                .then((doc) {
                                              if (doc.exists) {
                                                doc.reference.update({
                                                  "isApproved":
                                                      FieldValue.arrayUnion(
                                                          [Uuid().v4()]),
                                                  "isAccepted": true,
                                                  "vendorsNote":
                                                      noteController.text,
                                                });
                                              }
                                            });
                                          } catch (e) {
                                            //print(e);
                                          }
                                        } else if (isApproved.isEmpty &&
                                            dormKind == '') {
                                          snackbar('Hata',
                                              'Lutfen yurt turunu secin', true);
                                        }
                                      }),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: Get.width - 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: isApproved.length == 1
                                        ? Border.all(
                                            width: 0.7,
                                            color: Colors.grey[700]!)
                                        : null,
                                  ),
                                  child: CupertinoButton(
                                      borderRadius: BorderRadius.circular(16),
                                      color: isApproved.length == 1 ||
                                              isApproved.length == 2
                                          ? Colors.transparent
                                          : Colors.red,
                                      child: const Text('Siparişi reddet'),
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                  backgroundColor:
                                                      kdarkGreyColor,
                                                  title: const Text(
                                                    'Emin Misin?',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  content: const Text(
                                                      'Sana gelen siparişi reddediyorsun',
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                  actions: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child:
                                                              CupertinoButton(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  color:
                                                                      kThemeColor,
                                                                  child: const Text(
                                                                      'İptal'),
                                                                  onPressed:
                                                                      () {
                                                                    Get.back();
                                                                  }),
                                                        ),
                                                        const SizedBox(
                                                          width: 15,
                                                        ),
                                                        Expanded(
                                                          child:
                                                              CupertinoButton(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  color: Colors
                                                                      .red,
                                                                  child:
                                                                      const Text(
                                                                          'Evet'),
                                                                  onPressed:
                                                                      () {
                                                                    String
                                                                        notificationId =
                                                                        Uuid()
                                                                            .v4();
                                                                    // 1) Cancel the order (add "isCanceled" property to order)
                                                                    ordersRef
                                                                        .doc(widget
                                                                            .orderId)
                                                                        .get()
                                                                        .then(
                                                                            (doc) {
                                                                      if (doc
                                                                          .exists) {
                                                                        doc.reference
                                                                            .update({
                                                                          "isCanceled":
                                                                              true,
                                                                        });
                                                                      }
                                                                    });

                                                                    // 2) Send notification to the customer
                                                                    notificationsRef
                                                                        .doc(widget
                                                                            .buyerId)
                                                                        .collection(
                                                                            'userNotifications')
                                                                        .doc(
                                                                            notificationId)
                                                                        .set({
                                                                      "type":
                                                                          "orderRejected",
                                                                      "title":
                                                                          "Siparişin reddedildi",
                                                                      "subTitle":
                                                                          "${currentUser.username} siparişini reddetti",
                                                                      "userId":
                                                                          currentUser
                                                                              .id,
                                                                      "userProfilePicture":
                                                                          currentUser
                                                                              .photoUrl,
                                                                      "timestamp":
                                                                          DateTime
                                                                              .now(),
                                                                    });
                                                                    Get.back();
                                                                  }),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ));
                                        try {
                                          // usersRef
                                          //     .doc(currentUser.id)
                                          //     .get()
                                          //     .then((doc) {
                                          //   if (doc.exists) {
                                          //     doc.reference.update({
                                          //       "dormNumber": dorm,
                                          //       "dormType": dormKind,
                                          //     });
                                          //   }
                                          // });
                                          // ordersRef
                                          //     .doc(widget.orderId)
                                          //     .get()
                                          //     .then((doc) {
                                          //   if (doc.exists) {
                                          //     doc.reference.update({
                                          //       "isApproved":
                                          //           FieldValue.arrayUnion(
                                          //               [currentUser.id]),
                                          //       "isAccepted": true,
                                          //       "vendorsNote":
                                          //           noteController.text,
                                          //     });
                                          //   }
                                          // });
                                        } catch (e) {
                                          //print(e);
                                        }
                                      }),
                                ),
                              ],
                            ),
                    ],
                  ),
      ),
    );
  }

  choice(
    list,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        for (var i = 0; i < list.length; i++) {
          setState(() {
            list[i][1] = false;
          });
        }
        setState(() {
          list[index][1] = true;
          dormKind = list[index][0];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(left: 7),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
            color: list[index][1] ? kThemeColor : Colors.grey[900],
            borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: Text(
            list[index][0],
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Padding buildApproveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StreamBuilder<DocumentSnapshot>(
                  stream: ordersRef.doc(widget.orderId).snapshots(),
                  builder: (context, orderSnapshot) {
                    if (!orderSnapshot.hasData) {
                      return loading();
                    } else if (orderSnapshot.data!.exists == false) {
                      return Container();
                    }
                    bool isCompleted = orderSnapshot.data!.get('isCompleted');
                    List isApprovedList = orderSnapshot.data!.get('isApproved');
                    if (isCompleted) {
                      return Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircleAvatar(
                                backgroundColor: kThemeColor,
                                radius: 15,
                                child: Icon(
                                  CupertinoIcons.check_mark,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                width: Get.width / 8,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                height: 2.5,
                                decoration: BoxDecoration(
                                    borderRadius: kCircleBorderRadius,
                                    color: kThemeColor),
                              ),
                              const CircleAvatar(
                                backgroundColor: kThemeColor,
                                radius: 15,
                                child: Icon(
                                  CupertinoIcons.check_mark,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                width: Get.width / 8,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                height: 2.5,
                                decoration: BoxDecoration(
                                    borderRadius: kCircleBorderRadius,
                                    color: kThemeColor),
                              ),
                              const CircleAvatar(
                                backgroundColor: kThemeColor,
                                radius: 15,
                                child: Icon(
                                  CupertinoIcons.check_mark,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                width: Get.width / 8,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                height: 2.5,
                                decoration: BoxDecoration(
                                    borderRadius: kCircleBorderRadius,
                                    color: kThemeColor),
                              ),
                              const CircleAvatar(
                                backgroundColor: kThemeColor,
                                radius: 15,
                                child: Icon(
                                  CupertinoIcons.check_mark,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            'Teslim edildi',
                            style: TextStyle(color: kThemeColor, fontSize: 20),
                          ),
                          SizedBox(
                            width: 200,
                            child: Center(
                              child: Lottie.network(
                                  "https://assets4.lottiefiles.com/packages/lf20_pWVo9w.json"),
                            ),
                          ),
                        ],
                      );
                    } else if (orderSnapshot.data!.get('isCanceled')) {
                      return Column(
                        children: [
                          const Text(
                            'Siparişiniz reddedildi',
                            style: TextStyle(color: Colors.red, fontSize: 20),
                          ),
                          SizedBox(
                            width: 200,
                            child: Center(
                                child: Lottie.network(
                                    "https://assets9.lottiefiles.com/packages/lf20_s2ezQQs32F.json")
                                // "https://assets3.lottiefiles.com/packages/lf20_xwdz8akv.json"),
                                ),
                          ),
                        ],
                      );
                    } else if (isApprovedList.length == 0) {
                      return Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircleAvatar(
                                backgroundColor: kThemeColor,
                                radius: 15,
                                child: Icon(
                                  CupertinoIcons.check_mark,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                width: Get.width / 16,
                                margin: const EdgeInsets.only(left: 5),
                                height: 3.5,
                                decoration: BoxDecoration(
                                    borderRadius: kCircleBorderRadius,
                                    color: kThemeColor),
                              ),
                              Container(
                                width: Get.width / 16,
                                margin: const EdgeInsets.only(right: 5),
                                height: 3.5,
                                decoration: BoxDecoration(
                                    borderRadius: kCircleBorderRadius,
                                    color: Colors.grey),
                              ),
                              const CircleAvatar(
                                backgroundColor: Colors.grey,
                                radius: 15,
                                child: Icon(
                                  CupertinoIcons.check_mark,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                width: Get.width / 16,
                                margin: const EdgeInsets.only(left: 5),
                                height: 3.5,
                                decoration: BoxDecoration(
                                    borderRadius: kCircleBorderRadius,
                                    color: Colors.grey),
                              ),
                              Container(
                                width: Get.width / 16,
                                margin: const EdgeInsets.only(right: 5),
                                height: 3.5,
                                decoration: BoxDecoration(
                                    borderRadius: kCircleBorderRadius,
                                    color: Colors.grey),
                              ),
                              const CircleAvatar(
                                backgroundColor: Colors.grey,
                                radius: 15,
                              ),
                              Container(
                                width: Get.width / 8,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                height: 3.5,
                                decoration: BoxDecoration(
                                    borderRadius: kCircleBorderRadius,
                                    color: Colors.grey),
                              ),
                              const CircleAvatar(
                                backgroundColor: Colors.grey,
                                radius: 15,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            'Onay bekliyor',
                            style: TextStyle(color: kThemeColor, fontSize: 20),
                          ),
                          SizedBox(
                            width: 200,
                            child: Center(
                                child: Lottie.network(
                                    "https://assets7.lottiefiles.com/packages/lf20_OA8ICC0HnA.json")
                                // "https://assets3.lottiefiles.com/packages/lf20_xwdz8akv.json"),
                                ),
                          ),
                        ],
                      );
                    } else if (isApprovedList.length == 1) {
                      return Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircleAvatar(
                                backgroundColor: kThemeColor,
                                radius: 15,
                                child: Icon(
                                  CupertinoIcons.check_mark,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                width: Get.width / 8,
                                margin: const EdgeInsets.only(left: 5),
                                height: 3.5,
                                decoration: BoxDecoration(
                                    borderRadius: kCircleBorderRadius,
                                    color: kThemeColor),
                              ),
                              const CircleAvatar(
                                backgroundColor: kThemeColor,
                                radius: 15,
                                child: Icon(
                                  CupertinoIcons.check_mark,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                width: Get.width / 16,
                                margin: const EdgeInsets.only(left: 5),
                                height: 3.5,
                                decoration: BoxDecoration(
                                    borderRadius: kCircleBorderRadius,
                                    color: kThemeColor),
                              ),
                              Container(
                                width: Get.width / 16,
                                margin: const EdgeInsets.only(right: 5),
                                height: 3.5,
                                decoration: BoxDecoration(
                                    borderRadius: kCircleBorderRadius,
                                    color: Colors.grey),
                              ),
                              const CircleAvatar(
                                backgroundColor: Colors.grey,
                                radius: 15,
                              ),
                              Container(
                                width: Get.width / 8,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                height: 3.5,
                                decoration: BoxDecoration(
                                    borderRadius: kCircleBorderRadius,
                                    color: Colors.grey),
                              ),
                              const CircleAvatar(
                                backgroundColor: Colors.grey,
                                radius: 15,
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 160,
                            child: Center(
                              child: Lottie.network(
                                  // "https://assets3.lottiefiles.com/packages/lf20_310RH0.json"),
                                  "https://assets3.lottiefiles.com/packages/lf20_xwdz8akv.json"),
                            ),
                          ),
                          const Text(
                            'Hazirlaniyor',
                            style: TextStyle(
                              color: kThemeColor,
                              fontSize: 20,
                            ),
                          )
                        ],
                      );
                    } else if (isApprovedList.length == 2) {
                      return Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircleAvatar(
                                backgroundColor: kThemeColor,
                                radius: 15,
                                child: Icon(
                                  CupertinoIcons.check_mark,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                width: Get.width / 8,
                                margin: const EdgeInsets.only(left: 5),
                                height: 3.5,
                                decoration: BoxDecoration(
                                    borderRadius: kCircleBorderRadius,
                                    color: kThemeColor),
                              ),
                              const CircleAvatar(
                                backgroundColor: kThemeColor,
                                radius: 15,
                                child: Icon(
                                  CupertinoIcons.check_mark,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                width: Get.width / 8,
                                margin: const EdgeInsets.only(left: 5),
                                height: 3.5,
                                decoration: BoxDecoration(
                                    borderRadius: kCircleBorderRadius,
                                    color: kThemeColor),
                              ),
                              const CircleAvatar(
                                backgroundColor: kThemeColor,
                                radius: 15,
                                child: Icon(
                                  CupertinoIcons.check_mark,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                width: Get.width / 16,
                                margin: const EdgeInsets.only(left: 5),
                                height: 3.5,
                                decoration: BoxDecoration(
                                    borderRadius: kCircleBorderRadius,
                                    color: kThemeColor),
                              ),
                              Container(
                                width: Get.width / 16,
                                margin: const EdgeInsets.only(right: 5),
                                height: 3.5,
                                decoration: BoxDecoration(
                                    borderRadius: kCircleBorderRadius,
                                    color: Colors.grey),
                              ),
                              const CircleAvatar(
                                backgroundColor: Colors.grey,
                                radius: 15,
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 200,
                            child: Center(
                              child: Lottie.network(
                                  "https://assets3.lottiefiles.com/packages/lf20_310RH0.json"),
                            ),
                          ),
                          const Text(
                            'Yolda',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontFamily: 'poppinsBold'),
                          )
                        ],
                      );
                    }
                    return Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: orderSnapshot.data!.get('isCompleted') == true
                              ? Border.all(width: 0.5, color: Colors.grey[700]!)
                              : null,
                        ),
                        child: Text(
                            orderSnapshot.data!.get('isCompleted') == true
                                ? 'Onaylandı'
                                : 'Onay'),
                      ),
                    );
                  }),
            ],
          ),
        ],
      ),
    );
  }
}
