import '/models/pages/create.dart';
import '/widgets/loading.dart';
import '/models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/models/user_model.dart';
import '/models/pages/account.dart';
import '/models/pages/root.dart';
import 'app_bar.dart';

class Product extends StatefulWidget {
  String productId;
  String title;
  String price;
  String type;
  String vendor;
  String imageUrl;
  String description;
  int approve;
  int quantity;
  bool? isLoaded;

  Product({
    super.key,
    required this.type,
    required this.productId,
    required this.title,
    required this.price,
    required this.vendor,
    required this.imageUrl,
    required this.description,
    required this.quantity,
    required this.approve,
    this.isLoaded,
  });

  @override
  _ProductState createState() => _ProductState(
        type: type,
        title: title,
        price: price,
        imageUrl: imageUrl,
        vendor: vendor,
        productId: productId,
        description: description,
        quantity: quantity,
        approve: approve,
        isLoaded: isLoaded,
      );
}

class _ProductState extends State<Product> {
  String productId;
  String type;
  String title;
  String price;
  String description;
  String vendor;
  String imageUrl;
  int quantity;
  int approve;
  bool? isLoaded;
  _ProductState({
    this.isLoaded,
    required this.description,
    required this.type,
    required this.productId,
    required this.title,
    required this.price,
    required this.vendor,
    required this.imageUrl,
    required this.quantity,
    required this.approve,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (vendor == currentUser.id) {
          productOptions(context);
        }
      },
      onTap: () {
        Get.to(
            () => ProductDetails(
                  productId: productId,
                ),
            transition: Transition.cupertino);
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: Container(
          width: 155,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[600]!, width: 0.65),
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
                    child: isLoaded! == false
                        ? Container(
                            height: 120,
                            width: 250,
                            color: kdarkGreyColor,
                          )
                        : Image.network(
                            widget.imageUrl,
                            height: 120,
                            width: 250,
                            fit: BoxFit.cover,
                          )),
              ),
              const SizedBox(
                height: 7,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: FutureBuilder(
                    future: usersRef.doc(widget.vendor).get(),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) {
                        return loading();
                      }
                      User user = User.fromDocument(userSnapshot.data!);
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
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
                          isLoaded! == false
                              ? Container(
                                  height: 20,
                                  width: 250,
                                  decoration: BoxDecoration(
                                      color: kdarkGreyColor,
                                      borderRadius: BorderRadius.circular(10)),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 53,
                                      child: Text(
                                        widget.title,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontFamily: 'poppinsBold'),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text('${widget.price} ₺',
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 11)),
                                    // Text('@ ' + user.username,
                                    //     style: TextStyle(
                                    //         color: Colors.grey, fontSize: 11)),
                                  ],
                                ),
                        ],
                      );
                    }),
              ),
              const SizedBox(height: 10),
              StreamBuilder(
                  stream: usersRef.doc(vendor).snapshots(),
                  builder: (context, onlineSnapshot) {
                    if (!onlineSnapshot.hasData) {
                      return loading();
                    }
                    return childMan(vendor == currentUser.id
                        ? "editProduct"
                        : onlineSnapshot.data!.get('tripMode') == true
                            ? "tripMode"
                            : quantity <= 0
                                ? "outOfOrder"
                                : "addToCart");
                  })
            ],
          ),
        ),
      ),
    );
  }

  String buttonText(String type) {
    if (type == "addToCart" && quantity > 0) {
      return 'Sepete ekle';
    } else if (type == "tripMode") {
      return 'Offline';
    } else if (type == "editProduct") {
      return 'Ürünü düzenle';
    } else if (quantity <= 0) {
      return 'Stokta yok';
    } else {
      return "Hata";
    }
  }

  Padding buttons(String type) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5.0,
      ),
      child: SizedBox(
        height: 30,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          color: type == "addToCart" && quantity >= 0
              ? kThemeColor
              : kdarkGreyColor,
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: Text(
              buttonText(type),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          onPressed: () {
            if (type == "editProduct") {
              try {
                Get.to(() => CreatePage(
                      productId: productId,
                      imageUrl: imageUrl,
                      type: type,
                      title: title,
                      price: price.toString(),
                      desc: description,
                      quantity: quantity,
                      editing: true,
                    ));
              } catch (e) {
                //print(e);
              }
            } else if (type != "tripMode" &&
                type != "outOfOrder" &&
                vendor != currentUser.id) {
              try {
                createProductInCart();
              } catch (e) {
                //print(e);
              }
            } else {}
          },
        ),
      ),
    );
  }

  // double asaf(
  //     double matNot, int matSaat, double cografyaNot, int cografyaSaat) {
  //   return (matNot * matSaat + cografyaNot * cografyaSaat) /
  //       (matSaat + cografyaSaat);
  // }

  Future<dynamic> productOptions(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                  child: const Text('Ürünü Paylaş',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                  onPressed: () {
                    Get.back();
                  }),
              const Divider(
                color: Colors.grey,
              ),
              CupertinoButton(
                  child: const Text('Ürünü Düzenle',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                  onPressed: () {
                    Get.to(() => CreatePage(
                          productId: productId,
                          imageUrl: imageUrl,
                          type: type,
                          title: title,
                          price: price.toString(),
                          desc: description,
                          quantity: quantity,
                          editing: true,
                        ));
                  }),
              CupertinoButton(
                  child: const Text('Ürünü Sil',
                      style: TextStyle(
                        color: Colors.red,
                      )),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              backgroundColor: kdarkGreyColor,
                              title: const Text(
                                "Silme",
                                style: TextStyle(color: Colors.white),
                              ),
                              content: const Text(
                                'Ürünü silmek istediğinize emin misiniz?',
                                style: TextStyle(color: Colors.white),
                              ),
                              actions: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: CupertinoButton(
                                          padding: EdgeInsets.zero,
                                          color: kThemeColor,
                                          child: const Text("Geri"),
                                          onPressed: () {
                                            Get.back();
                                          }),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: CupertinoButton(
                                          padding: EdgeInsets.zero,
                                          color: Colors.red,
                                          child: const Text("Sil"),
                                          onPressed: () {
                                            productRef.doc(productId).delete();
                                          }),
                                    ),
                                  ],
                                )
                              ],
                            ));
                  }),
            ],
          ),
          backgroundColor: kdarkGreyColor,
          // title: Text('Daha Fazla'),
          alignment: Alignment.center,
          // actions: [
          //   CupertinoButton(
          //       child: Text('Ürünü Sil',
          //           style: TextStyle(
          //             color: Colors.red,
          //           )),
          //       onPressed: () {
          //         setState(() {
          //           productRef.doc(productId).delete();
          //         });
          //       }),
          // ],
        );
      },
    );
  }

  createProductInCart() {
    cartsRef.doc(currentUser.id).collection('userCart').get().then((val) {
      if (val.docs.isEmpty) {
        cartsRef.doc(currentUser.id).collection('userCart').doc(productId).set({
          "productId": productId,
          "vendorId": vendor,
          "image": imageUrl,
          "type": type,
          "productTitle": title,
          "productPrice": price,
          "productDesc": description,
          "myQuantity": 1,
          "purchase": double.parse(price),
        });
      } else {
        cartsRef.doc(currentUser.id).collection('userCart').get().then((val) {
          if (val.docs.first.data()['vendorId'] == vendor) {
            cartsRef
                .doc(currentUser.id)
                .collection('userCart')
                .doc(productId)
                .set({
              "productId": productId,
              "vendorId": vendor,
              "image": imageUrl,
              "type": type,
              "productTitle": title,
              "productPrice": price,
              "productDesc": description,
              "myQuantity": 1,
              "purchase": double.parse(price),
            });
          } else {
            showDialog(
                context: context,
                builder: ((context) => AlertDialog(
                      backgroundColor: kdarkGreyColor,
                      title: const Text(
                        'Bir siparişte sadece bir satıcının ürününü sipariş edebilirisiniz',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Text(
                        'Diğer ürünü çıkartıp bu ürünü eklemek için Tamam\'a basın',
                        style: TextStyle(color: Colors.grey),
                      ),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  color: kThemeColor,
                                  child: const Text('Geri'),
                                  onPressed: () {
                                    Get.back();
                                  }),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  color: Colors.red,
                                  child: const Text('Tamam'),
                                  onPressed: () {
                                    cartsRef
                                        .doc(currentUser.id)
                                        .collection('userCart')
                                        .get()
                                        .then((value) async {
                                      for (var doc in value.docs) {
                                        await doc.reference.delete();
                                      }

                                      cartsRef
                                          .doc(currentUser.id)
                                          .collection('userCart')
                                          .doc(productId)
                                          .set({
                                        "productId": productId,
                                        "vendorId": vendor,
                                        "image": imageUrl,
                                        "type": type,
                                        "productTitle": title,
                                        "productPrice": price,
                                        "productDesc": description,
                                        "myQuantity": 1,
                                        "purchase": double.parse(price),
                                      });
                                      Get.back();
                                    });
                                  }),
                            ),
                          ],
                        ),
                      ],
                    )));
          }
        });
      }
    });
  }

  Widget childMan(String type) {
    // cartsRef.doc(currentUser.id).collection('userCart').get().then((value) {
    //   setState(() {
    //   });
    // });
    return StreamBuilder(
      stream: cartsRef
          .doc(currentUser.id)
          .collection('userCart')
          .doc(productId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData) {
          return const CupertinoActivityIndicator();
        } else if (snapshot.data!.exists) {
          return updateQuantity();
        } else {
          return buttons(type);
        }
      },
    );
    // if (exists) {
    //   return updateQuantity();
    // } else {
    //   return addToCartButton();
    // }
    // if (cmon) {
    //   return updateQuantity();
    // } else {
    //   //print('$exists  $cmon');
    //   return addToCartButton();
    // }
  }

  Row updateQuantity() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
            width: 30,
            height: 30,
            child: CupertinoButton(
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(10),
                color: kThemeColor,
                child: const Text('-'),
                onPressed: () {
                  cartsRef
                      .doc(currentUser.id)
                      .collection('userCart')
                      .doc(productId)
                      .get()
                      .then((doc) {
                    int myQuantityData = doc.get("myQuantity");
                    double purchaseData = doc.get("purchase");
                    if (myQuantityData > 1) {
                      doc.reference.update(
                        {
                          "myQuantity": myQuantityData - 1,
                          "purchase": purchaseData -
                              double.parse(
                                price,
                              ),
                        },
                      );
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                backgroundColor: kdarkGreyColor,
                                title: const Text(
                                  'Emin Misin?',
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: const Text(
                                    'Ürün Sepetinden kaldırılacak',
                                    style: TextStyle(color: Colors.white)),
                                actions: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CupertinoButton(
                                            padding: EdgeInsets.zero,
                                            color: kThemeColor,
                                            child: const Text('İptal'),
                                            onPressed: () {
                                              Get.back();
                                            }),
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Expanded(
                                        child: CupertinoButton(
                                            padding: EdgeInsets.zero,
                                            color: Colors.red,
                                            child: const Text('Evet'),
                                            onPressed: () {
                                              cartsRef
                                                  .doc(currentUser.id)
                                                  .collection('userCart')
                                                  .doc(productId)
                                                  .delete();

                                              Get.back();
                                            }),
                                      ),
                                    ],
                                  ),
                                ],
                              ));
                    }
                  });
                  // Provider.of<Data>(context,
                  //         listen: false)
                  //     .decreasemyQuantity(
                  //         index2, context);
                })),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: StreamBuilder<DocumentSnapshot>(
              stream: cartsRef
                  .doc(currentUser.id)
                  .collection('userCart')
                  .doc(productId)
                  .snapshots(),
              builder: (context, qSnapshot) {
                if (!qSnapshot.hasData) {
                  return loading();
                }
                return Text(
                  qSnapshot.data!['myQuantity'].toString(),
                  style: const TextStyle(color: Colors.white),
                );
              }),
        ),
        SizedBox(
            width: 30,
            height: 30,
            child: CupertinoButton(
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(10),
                color: kThemeColor,
                child: const Text('+'),
                onPressed: () {
                  cartsRef
                      .doc(currentUser.id)
                      .collection('userCart')
                      .doc(productId)
                      .get()
                      .then((doc) {
                    double purchaseData = doc.get("purchase");

                    int data = doc.get("myQuantity");
                    if (data < quantity) {
                      doc.reference.update(
                        {
                          "myQuantity": data + 1,
                          "purchase": purchaseData +
                              double.parse(
                                price,
                              ),
                        },
                      );
                    }
                  });
                  // //print(Provider.of<Data>(
                  //         context,
                  //         listen: false)
                  //     .cartProducts[index2][1]);
                  // Provider.of<Data>(context,
                  //         listen: false)
                  //     .increasemyQuantity(0);
                })),
      ],
    );
  }
}

class ProductDetails extends StatefulWidget {
  String productId;

  ProductDetails({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: productRef.doc(widget.productId).snapshots(),
        builder: (context, productSnapshot) {
          if (!productSnapshot.hasData) {
            return loading();
          }
          return Scaffold(
            appBar: appBar(productSnapshot.data!.get('productTitle'), true),
            body: FutureBuilder(
                future:
                    usersRef.doc(productSnapshot.data!.get('vendorId')).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const Center(child: CupertinoActivityIndicator());
                  }
                  User user = User.fromDocument(userSnapshot.data!);
                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 20),
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => Photo(
                              mediaUrl: productSnapshot.data!.get('image')));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                productSnapshot.data!.get("image"),
                                fit: BoxFit.cover,
                                height: 250,
                                width: Get.width - 40,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                          left: 25.0,
                          bottom: 5,
                          top: 10.0,
                        ),
                        child: Text(
                          'Bilgiler',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: kdarkGreyColor,
                              borderRadius: BorderRadius.circular(15)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productSnapshot.data!.get('productTitle'),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              Divider(
                                color: Colors.grey[700],
                              ),
                              Text(
                                '${productSnapshot.data!.get('productPrice')} ₺',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 18),
                              ),
                              Divider(
                                color: Colors.grey[700],
                              ),
                              Text(
                                'Stok : ${productSnapshot.data!.get('quantity')}',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(left: 25.0, bottom: 5, top: 10),
                        child: Text(
                          'Açıklama',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          decoration: BoxDecoration(
                              color: kdarkGreyColor,
                              borderRadius: BorderRadius.circular(15)),
                          child: Text(
                            productSnapshot.data!.get('productDesc'),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(left: 25.0, bottom: 5, top: 10),
                        child: Text(
                          'Satıcı ',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => Account(
                                profileId:
                                    productSnapshot.data!.get('vendorId'),
                                previousPage: 'Ürün',
                              ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 10),
                              decoration: BoxDecoration(
                                  color: kdarkGreyColor,
                                  borderRadius: BorderRadius.circular(15)),
                              child: ListTile(
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rate_rounded,
                                      color: Colors.amber,
                                    ),
                                    Text(
                                      user.rating.toString(),
                                      style: const TextStyle(
                                          color: Colors.amber, fontSize: 19),
                                    )
                                  ],
                                ),
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(user.photoUrl),
                                ),
                                title: Text(
                                  user.username,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              )),
                        ),
                      ),
                    ],
                  );
                }),
            bottomNavigationBar: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(
                  height: 0,
                  color: Colors.grey,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const SizedBox(
                          width: 20,
                        ),
                        Text(
                          '${productSnapshot.data!.get('productPrice')} ₺',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 22),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                    StreamBuilder(
                        stream: cartsRef
                            .doc(currentUser.id)
                            .collection('userCart')
                            .doc(widget.productId)
                            .snapshots(),
                        builder: (context, cartSnapshot) {
                          if (cartSnapshot.hasData) {
                            return StreamBuilder(
                              stream: usersRef
                                  .doc(productSnapshot.data!.get('vendorId'))
                                  .snapshots(),
                              builder: (context, vendorSnapshot) {
                                if (vendorSnapshot.hasData &&
                                    vendorSnapshot.data!.get('tripMode') &&
                                    productSnapshot.data!.get('vendorId') !=
                                        currentUser.id) {
                                  return Expanded(
                                    child: SizedBox(
                                      height: 45,
                                      child: CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        borderRadius: BorderRadius.circular(15),
                                        color: Colors.grey[900],
                                        child: const Text(
                                          'Offline',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        onPressed: () {},
                                      ),
                                    ),
                                  );
                                } else if (vendorSnapshot.hasData &&
                                    cartSnapshot.data!.exists) {
                                  return Expanded(
                                      child: updateQuantity(productSnapshot));
                                } else if (vendorSnapshot.hasData &&
                                    productSnapshot.data!.get('quantity') <=
                                        0 &&
                                    productSnapshot.data!.get('vendorId') !=
                                        currentUser.id) {
                                  return Row(
                                    // ignore: prefer_const_literals_to_create_immutables
                                    children: [
                                      const Text(
                                        'Stokta yok',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                    ],
                                  );
                                } else if (vendorSnapshot.hasData &&
                                    productSnapshot.data!.get('vendorId') !=
                                        currentUser.id) {
                                  return addToCartButton(
                                      context, productSnapshot);
                                } else {
                                  return Expanded(
                                    child: SizedBox(
                                      height: 45,
                                      child: CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        borderRadius: BorderRadius.circular(15),
                                        color: Colors.deepPurple,
                                        child: const Text(
                                          'Ürünü düzenle',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        onPressed: () {
                                          Get.to(
                                              () => CreatePage(
                                                    productId: productSnapshot
                                                        .data!
                                                        .get('productId'),
                                                    imageUrl: productSnapshot
                                                        .data!
                                                        .get('image'),
                                                    type: productSnapshot.data!
                                                        .get('type'),
                                                    title: productSnapshot.data!
                                                        .get('productTitle'),
                                                    price: productSnapshot.data!
                                                        .get('productPrice')
                                                        .toString(),
                                                    desc: productSnapshot.data!
                                                        .get('productDesc'),
                                                    quantity: productSnapshot
                                                        .data!
                                                        .get('quantity'),
                                                    editing: true,
                                                  ),
                                              transition: Transition.downToUp);
                                        },
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          } else {
                            return loading();
                          }
                        }),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  Expanded addToCartButton(BuildContext context,
      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> productSnapshot) {
    return Expanded(
      child: SizedBox(
        height: 45,
        child: CupertinoButton(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(15),
            color: kThemeColor,
            child: const Text('Sepete Ekle'),
            onPressed: () {
              if (productSnapshot.data!.get('vendorId') == currentUser.id) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return const AlertDialog(
                      title: Text('Kendi Ürününüzü Sepetinize Ekleyemezsiniz'),
                    );
                  },
                );
              } else {
                createProductInCart(productSnapshot);
              }
            }),
      ),
    );
  }

  Row updateQuantity(
      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 45,
          height: 45,
          child: CupertinoButton(
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(15),
              color: kThemeColor,
              child: const Center(
                child: Text(
                  '-',
                  style: TextStyle(),
                ),
              ),
              onPressed: () {
                cartsRef
                    .doc(currentUser.id)
                    .collection('userCart')
                    .doc(widget.productId)
                    .get()
                    .then((doc) {
                  if (doc.exists) {
                    int myQuantityData = doc.get("myQuantity");
                    double purchaseData = doc.get("purchase");
                    if (myQuantityData > 1) {
                      doc.reference.update(
                        {
                          "myQuantity": myQuantityData - 1,
                          "purchase": purchaseData -
                              double.parse(
                                snapshot.data!.get('productPrice'),
                              ),
                        },
                      );
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                backgroundColor: kdarkGreyColor,
                                title: const Text(
                                  'Emin Misin?',
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: const Text(
                                    'Ürün Sepetinden kaldırılacak',
                                    style: TextStyle(color: Colors.white)),
                                actions: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CupertinoButton(
                                            padding: EdgeInsets.zero,
                                            color: kThemeColor,
                                            child: const Text('İptal'),
                                            onPressed: () {
                                              Get.back();
                                            }),
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Expanded(
                                        child: CupertinoButton(
                                            padding: EdgeInsets.zero,
                                            color: Colors.red,
                                            child: const Text('Evet'),
                                            onPressed: () {
                                              cartsRef
                                                  .doc(currentUser.id)
                                                  .collection('userCart')
                                                  .doc(widget.productId)
                                                  .delete();

                                              Get.back();
                                            }),
                                      ),
                                    ],
                                  ),
                                ],
                              ));
                    }
                  }
                });
                // Provider.of<Data>(context,
                //         listen: false)
                //     .decreasemyQuantity(
                //         index2, context);
              }),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: StreamBuilder<DocumentSnapshot>(
              stream: cartsRef
                  .doc(currentUser.id)
                  .collection('userCart')
                  .doc(widget.productId)
                  .snapshots(),
              builder: (context, qSnapshot) {
                if (!qSnapshot.hasData) {
                  return loading();
                }
                return Text(
                  qSnapshot.data!['myQuantity'].toString(),
                  style: const TextStyle(color: Colors.white),
                );
              }),
        ),
        SizedBox(
          width: 45,
          height: 45,
          child: CupertinoButton(
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(15),
              color: kThemeColor,
              child: const Text('+'),
              onPressed: () {
                cartsRef
                    .doc(currentUser.id)
                    .collection('userCart')
                    .doc(widget.productId)
                    .get()
                    .then((doc) {
                  double purchaseData = doc.get("purchase");

                  int data = doc.get("myQuantity");
                  if (data < snapshot.data!.get('quantity')) {
                    doc.reference.update(
                      {
                        "myQuantity": data + 1,
                        "purchase": purchaseData +
                            double.parse(
                              snapshot.data!.get('productPrice'),
                            ),
                      },
                    );
                  }
                });
                // //print(Provider.of<Data>(
                //         context,
                //         listen: false)
                //     .cartProducts[index2][1]);
                // Provider.of<Data>(context,
                //         listen: false)
                //     .increasemyQuantity(0);
              }),
        ),
      ],
    );
  }

  createProductInCart(
      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> productSnapshot) {
    cartsRef.doc(currentUser.id).collection('userCart').get().then((val) {
      if (val.docs.isEmpty) {
        cartsRef
            .doc(currentUser.id)
            .collection('userCart')
            .doc(widget.productId)
            .set({
          "productId": widget.productId,
          "vendorId": productSnapshot.data!.get('vendorId'),
          "image": productSnapshot.data!.get('image'),
          "type": productSnapshot.data!.get('type'),
          "productTitle": productSnapshot.data!.get('productTitle'),
          "productPrice": productSnapshot.data!.get('productPrice'),
          "productDesc": productSnapshot.data!.get('productDesc'),
          "myQuantity": 1,
          "purchase": double.parse(productSnapshot.data!.get('productPrice')),
        });
      } else {
        cartsRef.doc(currentUser.id).collection('userCart').get().then((val) {
          if (val.docs.first.data()['vendorId'] ==
              productSnapshot.data!.get('vendorId')) {
            cartsRef
                .doc(currentUser.id)
                .collection('userCart')
                .doc(widget.productId)
                .set({
              "productId": widget.productId,
              "vendorId": productSnapshot.data!.get('vendorId'),
              "image": productSnapshot.data!.get('image'),
              "type": productSnapshot.data!.get('type'),
              "productTitle": productSnapshot.data!.get('productTitle'),
              "productPrice": productSnapshot.data!.get('productPrice'),
              "productDesc": productSnapshot.data!.get('productDesc'),
              "myQuantity": 1,
              "purchase":
                  double.parse(productSnapshot.data!.get('productPrice')),
            });
          } else {
            showDialog(
                context: context,
                builder: ((context) => AlertDialog(
                      backgroundColor: kdarkGreyColor,
                      title: const Text(
                        'Bir siparişte sadece bir satıcının ürününü sipariş edebilirisiniz',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Text(
                        'Diğer ürünü çıkartıp bu ürünü eklemek için Tamam\'a basın',
                        style: TextStyle(color: Colors.grey),
                      ),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  color: kThemeColor,
                                  child: const Text('Geri'),
                                  onPressed: () {
                                    Get.back();
                                  }),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  color: Colors.red,
                                  child: const Text('Tamam'),
                                  onPressed: () {
                                    cartsRef
                                        .doc(currentUser.id)
                                        .collection('userCart')
                                        .get()
                                        .then((value) async {
                                      for (var doc in value.docs) {
                                        await doc.reference.delete();
                                      }

                                      cartsRef
                                          .doc(currentUser.id)
                                          .collection('userCart')
                                          .doc(widget.productId)
                                          .set({
                                        "productId": widget.productId,
                                        "vendorId": productSnapshot.data!
                                            .get('vendorId'),
                                        "image":
                                            productSnapshot.data!.get('image'),
                                        "type":
                                            productSnapshot.data!.get("type"),
                                        "productTitle": productSnapshot.data!
                                            .get('productTitle'),
                                        "productPrice": productSnapshot.data!
                                            .get('productPrice'),
                                        "productDesc": productSnapshot.data!
                                            .get('productDesc'),
                                        "myQuantity": 1,
                                        "purchase": double.parse(productSnapshot
                                            .data!
                                            .get('productPrice')),
                                      });
                                      Get.back();
                                    });
                                  }),
                            ),
                          ],
                        ),
                      ],
                    )));
          }
        });
      }
    });
  }
}
