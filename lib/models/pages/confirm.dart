import '/widgets/loading.dart';

import '/models/pages/ad_page.dart';
import '/widgets/snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:uuid/uuid.dart';
import '/constants.dart';
import '/models/user_model.dart';
import '/models/pages/root.dart';

class Confirm extends StatefulWidget {
  final List productIds;
  final String vendorId;
  final String buyerId;
  final double purchase;
  const Confirm({
    super.key,
    required this.vendorId,
    required this.buyerId,
    required this.productIds,
    required this.purchase,
  });

  @override
  State<Confirm> createState() => _ConfirmState();
}

class _ConfirmState extends State<Confirm> {
  int giftCoin = 0;
  String dormKind = '';
  List<Widget> dorms = [];
  TextEditingController noteController = TextEditingController();
  int dorm = 1;
  String payment = 'Nakit';
  @override
  void initState() {
    addDorm();
    // _initAd();
    super.initState();
  }

  // late InterstitialAd _interstitalAd;
  // bool _isAdLoaded = false;
  // _initAd() {
  //   InterstitialAd.load(
  //       adUnitId: TargetPlatform.iOS == true
  //           ? "ca-app-pub-9838840200304232/6313534084"
  //           : "ca-app-pub-9838840200304232/7144218268",
  //       request: const AdRequest(),
  //       adLoadCallback: InterstitialAdLoadCallback(
  //           onAdLoaded: onAdLoaded,
  //           onAdFailedToLoad: (error) {
  //             setState(() {
  //               _isAdLoaded = false;
  //             });
  //           }));
  // }

  // void onAdLoaded(InterstitialAd ad) {
  //   _interstitalAd = ad;
  //   setState(() {
  //     _isAdLoaded = true;
  //   });

  //   _interstitalAd.fullScreenContentCallback =
  //       FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
  //     Get.to(() => AdPage(
  //           giftCoin: giftCoin,
  //         ));
  //     _interstitalAd.dispose();
  //   }, onAdFailedToShowFullScreenContent: (ad, error) {
  //     _interstitalAd.dispose();
  //   });
  // }

  addDorm() {
    for (var i = 1; i <= 43; i++) {
      dorms.add(Center(
          child: Text(
        i.toString(),
        style: const TextStyle(color: Colors.white),
      )));
    }
  }

  List paymentMethod = [
    ['Nakit', true],
  ];
  List dormType = [
    ['İYC', false],
    ['DPY', false],
    ['DPY (yeni bina)', false]
  ];

  void changeCartProductsRef(String orderId) async {
    QuerySnapshot querySnapshot =
        await cartsRef.doc(currentUser.id).collection('userCart').get();
    for (var i = 0; i < querySnapshot.docs.length; i++) {
      QueryDocumentSnapshot doc = querySnapshot.docs[i];
      orderContentsRef
          .doc(currentUser.id)
          .collection('userOrders')
          .doc(orderId)
          .collection('contents')
          .add({
        "productId": doc['productId'],
        "vendorId": doc['vendorId'],
        "image": doc['image'],
        "type": doc['type'],
        "productTitle": doc['productTitle'],
        "productPrice": doc['productPrice'],
        "productDesc": doc['productDesc'],
        "myQuantity": doc['myQuantity'],
        "purchase": doc['purchase'],
      });
      cartsRef
          .doc(currentUser.id)
          .collection('userCart')
          .doc(querySnapshot.docs[i]['productId'])
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: dorm - 1);

    return StreamBuilder(
        stream: deliveryFeeRef.doc("deliveryFee").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return loading();
          }
          int deliveryFee = snapshot.data!.get('deliveryFee');
          return FutureBuilder(
              future: usersRef.doc(widget.vendorId).get(),
              builder: (context, vendorSnapshot) {
                if (!vendorSnapshot.hasData) {
                  return loading();
                }
                User vendor = User.fromDocument(vendorSnapshot.data!);
                return Scaffold(
                    appBar: AppBar(title: const Text("Onayla")),
                    body: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        StreamBuilder(
                            stream: cartsRef
                                .doc(currentUser.id)
                                .collection('userCart')
                                .snapshots(),
                            builder: (context, cartSnapshot) {
                              if (!cartSnapshot.hasData) {
                                return loading();
                              }

                              return userCard(vendor);
                            }),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                  width: 1, color: Colors.grey[700]!)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Yurt',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              SizedBox(
                                                height: 35,
                                                child: ListView.builder(
                                                  itemCount: dormType.length,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  shrinkWrap: true,
                                                  itemBuilder:
                                                      (context, index) {
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
                                            height: 7,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Yatakhane',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  showCupertinoModalPopup(
                                                      context: context,
                                                      builder: (context) {
                                                        return CupertinoTheme(
                                                            data: const CupertinoThemeData(
                                                                brightness:
                                                                    Brightness
                                                                        .dark,
                                                                primaryColor:
                                                                    kdarkGreyColor),
                                                            child:
                                                                CupertinoActionSheet(
                                                              cancelButton:
                                                                  CupertinoActionSheetAction(
                                                                      onPressed:
                                                                          () {
                                                                        Get.back();
                                                                      },
                                                                      child:
                                                                          const Text(
                                                                        'Tamam',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white70),
                                                                      )),
                                                              actions: [
                                                                SizedBox(
                                                                  height:
                                                                      Get.height /
                                                                          3,
                                                                  child:
                                                                      CupertinoPicker(
                                                                    scrollController:
                                                                        scrollController,
                                                                    backgroundColor:
                                                                        kdarkGreyColor,
                                                                    itemExtent:
                                                                        50,
                                                                    onSelectedItemChanged:
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        dorm =
                                                                            value +
                                                                                1;
                                                                      });
                                                                    },
                                                                    children: dorms
                                                                        .toList(),
                                                                  ),
                                                                ),
                                                              ],
                                                            ));
                                                      });
                                                },
                                                child: Container(
                                                  width: 40,
                                                  padding:
                                                      const EdgeInsets.all(7),
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey[900],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
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
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Divider(
                                      color: Colors.grey[700],
                                      thickness: 0.3,
                                      height: 0,
                                    ),
                                  ],
                                ),
                              ),

                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Ödeme',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    SizedBox(
                                      height: 35,
                                      child: ListView.builder(
                                        itemCount: paymentMethod.length,
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          return paymentMetho(
                                              paymentMethod, index);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),

                              Divider(
                                color: Colors.grey[700],
                                thickness: 0.3,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding:
                                        EdgeInsets.only(left: 15.0, bottom: 5),
                                    child: Text(
                                      'Not',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: CupertinoTextField(
                                      style:
                                          const TextStyle(color: Colors.white),
                                      controller: noteController,
                                      placeholder:
                                          'Ör. Soldan ikinci dolaba birakir misin (para kırmızı hırkanın altında)',
                                      placeholderStyle:
                                          const TextStyle(color: Colors.grey),
                                      maxLines: 6,
                                      decoration: BoxDecoration(
                                        color:
                                            const Color.fromARGB(255, 9, 9, 9),
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                            width: 1, color: Colors.grey[700]!),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 15.0, vertical: 5),
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       SizedBox(),
                              //       SizedBox(
                              //           height: 30,
                              //           child: CupertinoButton(
                              //             alignment: Alignment.center,
                              //             borderRadius: BorderRadius.circular(200),
                              //             padding: EdgeInsets.symmetric(horizontal: 15),
                              //             onPressed: () {},
                              //             color: kThemeColor,
                              //             child: Text(
                              //               'Kaydet',
                              //               style: TextStyle(fontSize: 14),
                              //             ),
                              //           )),
                              //     ],
                              //   ),
                              // )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 0.6),
                                borderRadius: BorderRadius.circular(13)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Getirme ucreti',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                Text(
                                  '${deliveryFee.toString()}₺',
                                  style: TextStyle(
                                      color: kThemeColor, fontSize: 18),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Text(
                          'Not: Siparişlerden komisyon almiyoruz',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        // RichText(
                        //   text: TextSpan(children: [
                        //     TextSpan(
                        //         text: 'Siparisiniz bir kurye tarafindan',
                        //         style: TextStyle(color: Colors.grey)),
                        //     TextSpan(
                        //         text: '\t\t( + 5₺ )\t\t',
                        //         style: TextStyle(color: kThemeColor)),
                        //     TextSpan(
                        //         text: 'en kisa surede size ulastirilacaktir',
                        //         style: TextStyle(color: Colors.grey)),
                        //   ]),
                        //   textAlign: TextAlign.center,
                        // ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                    bottomNavigationBar: StreamBuilder(
                        stream: cartsRef
                            .doc(currentUser.id)
                            .collection('userCart')
                            .snapshots(),
                        builder: (context, snapshot2) {
                          double purchase() {
                            double sum = 0;
                            List<double> purchases = [];
                            for (var i = 0;
                                i < snapshot2.data!.docs.length;
                                i++) {
                              double p = snapshot2.data!.docs[i]['purchase'];
                              purchases.add(p);
                              sum += purchases[i];
                            }

                            return sum;
                          }

                          if (!snapshot2.hasData) {
                            return loading();
                          }

                          return StreamBuilder(
                              stream: usersRef.doc(currentUser.id).snapshots(),
                              builder: (context, userSnapshot) {
                                if (!userSnapshot.hasData) {
                                  return loading();
                                }

                                return Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                      border: Border.symmetric(
                                          horizontal: BorderSide(
                                              color: Colors.grey[700]!,
                                              width: 0.75))),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Text(
                                                  'Fiyat',
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 17),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  '${purchase()}'
                                                  ' ₺',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 19),
                                                ),
                                                Text(
                                                  ' + ${deliveryFee.toString()}₺',
                                                  style: TextStyle(
                                                      color: kThemeColor,
                                                      fontSize: 19),
                                                ),
                                              ],
                                            ),
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.grey,
                                                    borderRadius:
                                                        kCircleBorderRadius),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                height: 2.5,
                                              ),
                                            ),
                                            Text(
                                              '${purchase() + deliveryFee}'
                                              ' ₺',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 19),
                                            ),
                                          ],
                                        ),
                                      ),
                                      StreamBuilder(
                                          stream: cartsRef
                                              .doc(currentUser.id)
                                              .collection('userCart')
                                              .snapshots(),
                                          builder: (context, cartSnapshot) {
                                            if (!cartSnapshot.hasData) {
                                              return loading();
                                            }

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15.0,
                                                      vertical: 10),
                                              child: SizedBox(
                                                width: Get.width,
                                                child: CupertinoButton(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    color: kThemeColor,
                                                    padding: EdgeInsets.zero,
                                                    child: const Text('Onayla'),
                                                    onPressed: () {
                                                      print(
                                                          "+++++${purchase()} -----${giftCoin}");
                                                      try {
                                                        coinsRef
                                                            .doc(widget.buyerId)
                                                            .get()
                                                            .then((doc) {
                                                          if (doc.exists) {
                                                            //20 TL and below
                                                            if (purchase() >
                                                                    0 &&
                                                                purchase() <=
                                                                    20) {
                                                              setState(() {
                                                                giftCoin = 10;
                                                                print(
                                                                    "+++++${purchase()} -----${giftCoin}");
                                                              });
                                                              doc.reference
                                                                  .update({
                                                                "coins": doc.get(
                                                                        'coins') +
                                                                    10,
                                                              });
                                                            }
                                                            //between 20 TL and 40

                                                            if (purchase() >
                                                                    20 &&
                                                                purchase() <=
                                                                    40) {
                                                              setState(() {
                                                                giftCoin = 15;
                                                                print(
                                                                    "+++++${purchase()} -----${giftCoin}");
                                                              });
                                                              doc.reference
                                                                  .update({
                                                                "coins": doc.get(
                                                                        'coins') +
                                                                    15,
                                                              });
                                                            }
                                                            if (purchase() >
                                                                    40 &&
                                                                purchase() <=
                                                                    80) {
                                                              setState(() {
                                                                giftCoin = 20;
                                                                print(
                                                                    "+++++${purchase()} -----${giftCoin}");
                                                              });
                                                              doc.reference
                                                                  .update({
                                                                "coins": doc.get(
                                                                        'coins') +
                                                                    20,
                                                              });
                                                            } else if (purchase() >
                                                                80) {
                                                              setState(() {
                                                                giftCoin = 30;
                                                                print(
                                                                    "+++++${purchase()} -----${giftCoin}");
                                                              });
                                                              doc.reference
                                                                  .update({
                                                                "coins": doc.get(
                                                                        'coins') +
                                                                    30,
                                                              });
                                                            }
                                                          }
                                                        });

                                                        // if (value == false) {
                                                        //   confirmPurchase(
                                                        //       purchase(), vendor);
                                                        //   updateBuyedGoods(
                                                        //     vendor,
                                                        //   );
                                                        //   Get.to(() => AdPage(
                                                        //         giftCoin: giftCoin,
                                                        //       ));
                                                        // } else
                                                        if (dormKind == '') {
                                                          snackbar(
                                                              'Hata',
                                                              'Lutfen bir yurt secin',
                                                              true);
                                                        } else {
                                                          confirmPurchase(
                                                              purchase() + deliveryFee,
                                                              vendor,deliveryFee);

                                                          updateBuyedGoods(
                                                              vendor);
                                                          Get.to(() => AdPage(
                                                                giftCoin:
                                                                    giftCoin,
                                                              ));
                                                        }
                                                        // _interstitalAd.show();
                                                      } catch (e) {
                                                        snackbar(
                                                          'Hata',
                                                          "Bir hata oluştu lütfen daha sonra tekrar deneyin",
                                                          true,
                                                        );
                                                      }
                                                    }),
                                              ),
                                            );

                                            return const SizedBox();
                                          }),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                    ],
                                  ),
                                );
                              });
                        }));
              });
        });
  }

  Container userCard(User vendor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          width: 1,
          color: Colors.grey[700]!,
        ),
      ),
      child: ListTile(
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star_rate_rounded,
              color: Colors.amber,
            ),
            Text(
              vendor.rating.toString(),
              style: const TextStyle(color: Colors.amber, fontSize: 19),
            )
          ],
        ),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(vendor.photoUrl),
        ),
        title: Text(
          vendor.username,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  double finalPurchase = 0;

  void confirmPurchase(double purchase, vendor,int deliveryFee) {
    try {
      String orderId = const Uuid().v4();
      changeCartProductsRef(orderId);
      addToBuyersOrders(
        purchase,
        orderId,
      );
      addToSellersOrders(
        purchase,
        orderId,
      );
      addToNotifications(orderId, vendor.id,deliveryFee);
      showAd();
    } catch (e) {
      print(e);
    }
  }

  showAd() {}

  void updateBuyedGoods(User vendor) async {
    List<String> prodIds = [];
    List<int> prodQuantities = [];
    cartsRef.doc(currentUser.id).collection('userCart').get().then((val) {
      for (var i = 0; i < val.docs.length; i++) {
        prodIds.add(val.docs[i]['productId']);
        prodQuantities.add(val.docs[i]['myQuantity']);
      }
      for (var j = 0; j < prodIds.length; j++) {
        productRef.doc(prodIds[j]).get().then((doc) {
          if (doc.exists) {
            doc.reference.update({
              "quantity": doc.get('quantity') - prodQuantities[j],
            });
          }
        });
      }
    });

    //

    // productRef.get().then((doc) {
    //   for (var i = 0; i < doc.docs.length; i++) {
    //     prodQuantity = doc.docs[i]['quantity'];
    //   }
    // });
    // cartsRef.doc(currentUser.id).collection('userCart').get().then((doc) {
    //   for (var i = 0; i < doc.docs.length; i++) {
    //     prodCartQuantity = doc.docs[i]['myQuantity'];
    //     prodId = doc.docs[i]['productId'];
    //   }
    //   productRef.get().then((proddoc) {
    //     for (var j = 0; j < proddoc.docs.length; j++) {
    //       prodQuantity = proddoc.docs[i]['quantity'];
    //       for (var k = 0; k < 5; k++) {
    //         productRef.doc(prodId).update({
    //           "quantity": prodQuantity - prodCartQuantity,
    //         });
    //       }
    //     }
    //   });
    // });
  }

  addToNotifications(
    orderId,
    vendorId,
    deliveryFee
  ) {
    String notificationId = const Uuid().v4();
    notificationsRef
        .doc(currentUser.id)
        .collection('userNotifications')
        .doc(notificationId)
        .set({
      "type": 'successfulOrder',
      "id": orderId,
      "title": 'Sipariş',
      "subTitle": 'Siparişiniz Alındı',
      "content": widget.purchase + deliveryFee,
      "timestamp": DateTime.now(),
    });

    notificationsRef
        .doc(vendorId)
        .collection('userNotifications')
        .doc(orderId)
        .set({
      "type": 'newOrder',
      "id": orderId,
      "title": 'Yeni Sipariş!',
      "subTitle": '${currentUser.username} sipariş verdi!',
      "content": widget.purchase,
      "timestamp": DateTime.now(),
    });
  }

  addToBuyersOrders(
    double purchase,
    String orderId,
  ) {
    ordersRef.doc(orderId).set({
      "isCanceled": false,
      "dormType": dormKind,
      "dormNumber": dorm,
      "paymentMethod": payment,
      "orderId": orderId,
      "purchase": purchase,
      "buyerId": currentUser.id,
      "vendorId": widget.vendorId,
      "note": noteController.text,
      "isCompleted": false,
      "isApproved": [],
      "theList": [currentUser.id, widget.vendorId],
      "delivererId": "",
      "isAccepted": false,
    });
  }

  addToSellersOrders(
    double purchase,
    String orderId,
  ) {
    ordersRef.doc(orderId).set({
      "isCanceled": false,
      "dormType": dormKind,
      "dormNumber": dorm,
      "paymentMethod": payment,
      "orderId": orderId,
      "purchase": purchase,
      "buyerId": currentUser.id,
      "vendorId": widget.vendorId,
      "note": noteController.text,
      "isCompleted": false,
      "isApproved": [],
      "theList": [currentUser.id, widget.vendorId],
      "delivererId": "",
      "isAccepted": false,
    });
  }

  // addToOrderContent(
  //     double purchase, String orderId, int myQuantity, Product product) {
  //   for (var i = 0; i < widget.productIds.length; i++) {
  //     orderContentsRef.doc(orderId).collection('contents').add({
  //       "productId": product.productId,
  //       "vendorId": product.vendor,
  //       "image": product.imageUrl,
  //       "type": product.type,
  //       "productTitle": product.title,
  //       "productPrice": product.price,
  //       "productDesc": product.price,
  //       "myQuantity": 1,
  //       "orderId": orderId,
  //       "buyerId": currentUser.id,
  //       "note": noteController.text,
  //     });
  //   }

  //   // orderContentsRef.doc(currentUser.id).collection('orders').doc(orderId).set({
  //   //   "productId": productId,
  //   //   "vendorId": vendor,
  //   //   "image": imageUrl,
  //   //   "type": type,
  //   //   "productTitle": title,
  //   //   "productPrice": price,
  //   //   "productDesc": description,
  //   //   "myQuantity": 1,
  //   //   "purchase": double.parse(price),
  //   //   "orderId": orderId,
  //   //   "purchase": purchase,
  //   //   "buyerId": currentUser.id,
  //   //   "vendorId": widget.vendorId,
  //   //   "note": noteController.text,
  //   // });
  // }

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

  paymentMetho(
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
          payment = list[index][0];
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
}
