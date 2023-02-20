import 'package:appbeyoglu/widgets/product.dart';
import 'package:appbeyoglu/widgets/snackbar.dart';

import '/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/models/pages/confirm.dart';
import '/models/pages/root.dart';
import '/widgets/cart_product.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  List<int> productQuantities = [];
  List<int> cartQuantities = [];
  int count = 0;

  @override
  void initState() {
    super.initState();
  }

  // @override
  // void initState() {
  //   // showAd();
  //   // TODO: implement initState
  //   super.initState();
  // }

  // showAd() {
  //   _initAd();
  //   if (_isAdLoaded) {
  //     _interstitalAd.show();
  //   }
  // }

  // void onAdLoaded(InterstitialAd ad) {
  //   setState(() {
  //     _interstitalAd = ad;
  //     _isAdLoaded = true;

  //     _interstitalAd.fullScreenContentCallback =
  //         FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
  //       _interstitalAd.dispose();
  //     }, onAdFailedToShowFullScreenContent: (ad, error) {
  //       _interstitalAd.dispose();
  //     });
  //   });
  // }

  // _initAd() {
  //   InterstitialAd.load(
  //       adUnitId: TargetPlatform.iOS == true
  //           ? "ca-app-pub-9838840200304232/6313534084"
  //           : "ca-app-pub-9838840200304232/7144218268",
  //       request: AdRequest(),
  //       adLoadCallback: InterstitialAdLoadCallback(
  //           onAdLoaded: onAdLoaded, onAdFailedToLoad: (error) {}));
  // }

  List productIds = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: cartsRef.doc(currentUser.id).collection('userCart').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return loading();
          } else if (snapshot.data!.docs.isEmpty) {
            return Material(
              color: Colors.transparent,
              child: Scaffold(
                appBar: AppBar(),
                body: const Center(
                  child: Text(
                    'Sepetiniz Boş',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          }
          return Material(
            color: Colors.transparent,
            child: Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(CupertinoIcons.back),
                  ),
                  title: const Text('Sepet'),
                ),
                body: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return CartProduct(
                      document: CartProductModel(
                        purchase: snapshot.data!.docs[index]['purchase'],
                        title: snapshot.data!.docs[index]['productTitle'],
                        price: snapshot.data!.docs[index]['productPrice'],
                        productId: snapshot.data!.docs[index]['productId'],
                        vendor: snapshot.data!.docs[index]['vendorId'],
                        description: snapshot.data!.docs[index]['productDesc'],
                        imageUrl: snapshot.data!.docs[index]['image'],
                        myQuantity: snapshot.data!.docs[index]['myQuantity'],
                      ),
                    );
                  },
                ),
                bottomNavigationBar: StreamBuilder<QuerySnapshot>(
                    stream: cartsRef
                        .doc(currentUser.id)
                        .collection('userCart')
                        .snapshots(),
                    builder: (context, snapshot2) {
                      if (!snapshot2.hasData) {
                        return loading();
                      }
                      for (var i = 0; i < snapshot2.data!.docs.length; i++) {
                        if (productIds.contains(
                                snapshot2.data!.docs[i]['productId']) ==
                            false) {
                          cartQuantities
                              .add(snapshot2.data!.docs[i]['myQuantity']);
                          productIds.add(snapshot2.data!.docs[i]['productId']);
                        }
                      }
                      double purchase() {
                        double sum = 0;
                        List<double> purchases = [];
                        for (var i = 0; i < snapshot.data!.docs.length; i++) {
                          double p = snapshot.data!.docs[i]['purchase'];
                          purchases.add(p);
                          sum += purchases[i];
                        }
                        return sum;
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                            border: Border.symmetric(
                                horizontal: BorderSide(
                                    color: Colors.grey[700]!, width: 0.75))),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            const Text(
                              'Toplam',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 17),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              purchase().toStringAsFixed(2),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 19),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                                child: SizedBox(
                              height: 45,
                              child: CupertinoButton(
                                  borderRadius: BorderRadius.circular(500),
                                  color: kThemeColor,
                                  padding: EdgeInsets.zero,
                                  child: const Text('Devam Et'),
                                  onPressed: () {
                                    try {
                                      for (var i = 0;
                                          i < productIds.length;
                                          i++) {
                                        productRef
                                            .doc(productIds[i])
                                            .get()
                                            .then((doc) {
                                          if (doc.exists) {
                                            usersRef
                                                .doc(doc.get('vendorId'))
                                                .get()
                                                .then((doc2) {
                                              if (doc2.get('tripMode') ==
                                                  false) {
                                                productQuantities
                                                    .add(doc.get('quantity'));
                                              } else {
                                                snackbar("Hata",
                                                    "Satici mesgul", true);
                                              }
                                            });
                                          } else {
                                            snackbar(
                                                "Hata",
                                                "Sepetinizdeki urun artik bulunmamakta veya stokta yok",
                                                true);
                                          }
                                        });
                                        if (productQuantities[i] >=
                                            cartQuantities[i]) {
                                          Get.to(
                                            () => Confirm(
                                              vendorId: snapshot
                                                  .data!.docs.first['vendorId'],
                                              buyerId: currentUser.id,
                                              productIds: productIds,
                                              purchase: snapshot
                                                  .data!.docs.first['purchase'],
                                            ),
                                            transition: Transition.cupertino,
                                          );
                                        } else {
                                          snackbar(
                                            "Hata",
                                            "Sepetinizdeki urun artik bulunmamakta veya stokta yok",
                                            true,
                                          );
                                        }
                                      }
                                    } catch (e) {}
                                  }),
                            )),
                            const SizedBox(
                              width: 20,
                            ),
                          ],
                        ),
                      );
                    })),
          );
        });
  }
}
