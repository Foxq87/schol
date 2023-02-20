import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants.dart';
import '../widgets/cart_product.dart';

class Data with ChangeNotifier {
  bool isSocialMedia = false;
  String type = 'all';
  bool appType = false;
  int index = 0;
  List cartProducts = [];
  double price = 0;
  int i = 0;
  String grade = '';
  int beVendorIndex = 0;

  void updateIsSocialMedia(val) {
    isSocialMedia = val;
    notifyListeners();
  }

  void updateType(String myType) {
    type = myType;
    notifyListeners();
  }

  void updateAppType(bool val) {
    appType = val;
    notifyListeners();
  }

  void getPrice(double productPrice) {
    price = productPrice;
    notifyListeners();
  }

  void increaseBeVendorIndex(int index) {
    beVendorIndex = index;
    notifyListeners();
  }
  // void addToCart(DocumentSnapshot doc, double pPrice, int index) {
  //   // createProductInCart();
  //   getPrice(pPrice);
  //   i = index;
  //   if (cartProducts.contains(CartProductModel.fromDocument(doc)) == false) {
  //     // purchase += price;
  //     cartProducts.add([CartProductModel.fromDocument(doc), 0, index]);
  //     //print(cartProducts);
  //     notifyListeners();
  //   }
  //   notifyListeners();
  // }

  void increaseIndex() {
    index++;
    notifyListeners();
  }

  void increasemyQuantity(index) {
    cartProducts[index][1]++;
    notifyListeners();
  }

  void decreasemyQuantity(index, context) {
    if (cartProducts[index][1] > 1) {
      cartProducts[index][1]--;
      notifyListeners();
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Emin Misin?'),
                content: const Text('Ürün Sepetinden kaldırılacak'),
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
                              Get.back();
                            }),
                      ),
                    ],
                  ),
                ],
              ));
    }
    notifyListeners();
  }

  void decreasePurchase(double price) {
    // purchase -= price;
    notifyListeners();
  }

  void updateGrade(String mygrade) {
    grade = mygrade;
    notifyListeners();
  }
}
