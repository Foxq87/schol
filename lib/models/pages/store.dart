import '/widgets/loading.dart';

import '/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/models/pages/create.dart';
import '/models/pages/root.dart';

import '../../constants.dart';
import '../../widgets/product.dart';

class Store extends StatefulWidget {
  const Store({super.key});

  @override
  State<Store> createState() => _StoreState();
}

class _StoreState extends State<Store> {
  String type = 'Hepsi';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar('Market', true),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          SizedBox(
            height: 40,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: types.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    for (var i = 0; i < types.length; i++) {
                      setState(() {
                        types[i][1] = false;
                      });
                    }
                    setState(() {
                      types[index][1] = true;
                      type = types[index][0];
                    });
                  },
                  child: Container(
                      margin: const EdgeInsets.only(right: 7),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: types[index][1] ? kThemeColor : kdarkGreyColor,
                          borderRadius: BorderRadius.circular(500)),
                      child: Center(
                        child: Text(
                          types[index][0],
                          style: const TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontFamily: 'poppinsBold'),
                        ),
                      )),
                );
              },
            ),
          ),
          StreamBuilder(
              stream: type == "Hepsi"
                  ? productRef
                      .where('vendorId', isNotEqualTo: currentUser.id)
                      .where('approve', isEqualTo: 2)
                      .snapshots()
                  : productRef
                      .where('vendorId', isNotEqualTo: currentUser.id)
                      .where('type', isEqualTo: type)
                      .where('approve', isEqualTo: 2)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return loading();
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 20,
                    crossAxisCount: 2,
                    childAspectRatio: 0.69,
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    if (snapshot.data!.docs.isEmpty ||
                        !snapshot.hasData ||
                        snapshot.hasError ||
                        snapshot.isBlank == true) {
                      return const Center(
                        child: Text('Ürün Yok'),
                      );
                    }
                    final listOfDocumentSnapshot = snapshot.data!.docs[index];
                    return Product(
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
                  },
                );
              })
        ],
      ),
    );
  }
}
