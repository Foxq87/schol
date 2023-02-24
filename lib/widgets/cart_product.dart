import '/widgets/loading.dart';

import '/widgets/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/models/user_model.dart';
import '../pages/root.dart';

import 'app_bar.dart';

class CartProduct extends StatefulWidget {
  final CartProductModel? document;
  const CartProduct({Key? key, this.document}) : super(key: key);

  @override
  _CartProductState createState() => _CartProductState();
}

class _CartProductState extends State<CartProduct> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: usersRef.doc(widget.document!.vendor).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return loading();
          }
          User user = User.fromDocument(snapshot.data!);
          return Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey[600]!, width: 0.8),
            ),
            child: ListTile(
              leading: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.network(
                    widget.document!.imageUrl,
                    width: 55,
                    height: 55,
                    fit: BoxFit.cover,
                  )),
              title: SizedBox(
                width: 100,
                child: Text(
                  widget.document!.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontFamily: 'poppinsBold'),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              subtitle: Text('₺ ${widget.document!.price}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              trailing: updateQuantity(),
            ),
          );
        });
  }

  Row updateQuantity() {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
                      .doc(widget.document!.productId)
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
                                widget.document!.price,
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
                                                  .doc(widget
                                                      .document!.productId)
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
                  .doc(widget.document!.productId)
                  .snapshots(),
              builder: (context, qSnapshot) {
                if (!qSnapshot.hasData) {
                  return loading();
                }
                if (qSnapshot.data!.exists) {
                  if (qSnapshot.data!['myQuantity'] != null) {
                    return Text(
                      qSnapshot.data!['myQuantity'].toString(),
                      style: const TextStyle(color: Colors.white),
                    );
                  } else {
                    return const Text('1');
                  }
                } else {
                  return const Text('1');
                }
              }),
        ),
        StreamBuilder(
            stream: productRef.doc(widget.document!.productId).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return loading();
              }
              Product product = Product(
                productId: snapshot.data!.get('productId'),
                type: snapshot.data!.get('type'),
                isLoaded: snapshot.hasData,
                description: snapshot.data!.get('productDesc'),
                title: snapshot.data!.get('productTitle'),
                price: snapshot.data!.get('productPrice'),
                vendor: snapshot.data!.get('vendorId'),
                imageUrl: snapshot.data!.get('image'),
                quantity: snapshot.data!.get('quantity'),
                approve: snapshot.data!.get('approve'),
              );

              return SizedBox(
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
                            .doc(widget.document!.productId)
                            .get()
                            .then((doc) {
                          double purchaseData = doc.get("purchase");

                          int data = doc.get("myQuantity");
                          if (data < product.quantity) {
                            doc.reference.update(
                              {
                                "myQuantity": data + 1,
                                "purchase": purchaseData +
                                    double.parse(
                                      widget.document!.price,
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
                      }));
            }),
      ],
    );
  }
}

class ProductDetails extends StatefulWidget {
  String title;
  String price;
  String vendor;
  String imageUrl;
  String description;
  ProductDetails({
    super.key,
    required this.title,
    required this.price,
    required this.vendor,
    required this.imageUrl,
    required this.description,
  });

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(widget.title, true),
      body: FutureBuilder(
          future: usersRef.doc(widget.vendor).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return loading();
            }
            User user = User.fromDocument(snapshot.data!);
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: SizedBox(
                    height: 250,
                    width: 250,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        widget.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 25.0, bottom: 5, top: 10),
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
                          widget.title,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                        Divider(
                          color: Colors.grey[700],
                        ),
                        Text(
                          '${widget.price} ₺',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 25.0, bottom: 5, top: 10),
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
                      widget.description,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 25.0, bottom: 5, top: 10),
                  child: Text(
                    'Satıcı ',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                Padding(
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
              ],
            );
          }),
      bottomNavigationBar: Row(
        children: [
          const SizedBox(
            width: 20,
          ),
          Expanded(
              flex: 0,
              child: Text(
                '${widget.price} ₺',
                style: const TextStyle(color: Colors.white, fontSize: 22),
              )),
          const SizedBox(
            width: 20,
          ),
          Expanded(
              flex: 3,
              child: CupertinoButton(
                  borderRadius: BorderRadius.circular(200),
                  color: kThemeColor,
                  child: const Text('Sepete Ekle'),
                  onPressed: () {})),
          const SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }
}

class CartProductModel {
  int? index;
  String title;
  String price;
  String vendor;
  String imageUrl;
  String description;
  String productId;
  int? myQuantity;
  double purchase;
  CartProductModel({
    required this.purchase,
    required this.title,
    required this.productId,
    required this.price,
    required this.vendor,
    required this.imageUrl,
    required this.description,
    this.myQuantity,
  });

  // factory CartProductModel.fromDocument(DocumentSnapshot doc) {
  //   return CartProductModel(
  //     purchase: doc['purchase'],
  //     title: doc['productTitle'],
  //     price: doc['productPrice'],
  //     productId: doc['productId'],
  //     vendor: doc['vendorId'],
  //     description: doc['productDesc'],
  //     imageUrl: doc['image'],
  //     myQuantity: doc['myQuantity'],
  //   );
  // }
}
