import 'dart:io';

import 'package:flutter/services.dart';

import '/services/notification_service.dart';
import '/widgets/snackbar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:uuid/uuid.dart';
import '/constants.dart';
import '/models/pages/root.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CreatePage extends StatefulWidget {
  String productId;
  String imageUrl;
  String type;
  String title;
  String desc;
  String price;
  int quantity;
  bool editing;

  CreatePage({
    super.key,
    required this.productId,
    required this.imageUrl,
    required this.type,
    required this.title,
    required this.price,
    required this.desc,
    required this.quantity,
    required this.editing,
  });

  @override
  State<CreatePage> createState() => _CreatePageState();
}

List types = [
  ['Hepsi', true],
  ['Çikolata', false],
  ['Cips', false],
  ['İçecek', false],
  ['Süt', false],
  ['Bisküvi', false],
  ['Kıyafet', false],
  ['Elektronik', false],
  ['Diğer', false]
];

class _CreatePageState extends State<CreatePage> {
  int quantity = 0;
  String imageUrl = "";

  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descController = TextEditingController();
  File? image;

  late FixedExtentScrollController scrollController =
      FixedExtentScrollController(initialItem: quantity + 1);

  String type = '';

  @override
  void initState() {
    if (widget.editing) {
      imageUrl = widget.imageUrl;
      titleController = TextEditingController(text: widget.title);
      priceController = TextEditingController(text: widget.price.toString());
      descController = TextEditingController(text: widget.desc);
      type = widget.type;
      quantity = widget.quantity;
    }
    super.initState();
  }

  Future pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final imageTemporary = File(image.path);
    setState(() => this.image = imageTemporary);
  }

  Future<void> handleDatabase(String productId) async {
    final storageImage = FirebaseStorage.instance
        .ref()
        .child('productImages')
        .child('$productId.jpg');
    var task = storageImage.putFile(image!);
    url = await (await task.whenComplete(() => null)).ref.getDownloadURL();
    productRef.doc(productId).update({
      "image": url.toString(),
    });
  }

  createProductInFirebase() async {
    String productId = const Uuid().v4();
    try {
      productRef.doc(productId).set({
        "quantity": quantity,
        "productId": productId,
        "vendorId": currentUser.id,
        "image": '',
        "type": type,
        "productTitle": titleController.text,
        "productPrice": priceController.text,
        "productDesc": descController.text,
        "approve": 1,
        "carts": [],
      });
      await handleDatabase(productId);
      clearFields();
    } catch (e) {
      snackbar('Hata', 'Lutfen butun alanlari doldurun', true);
      //print(e);
    }
  }

  String url = '';

  clearFields() {
    titleController.clear();
    priceController.clear();
    descController.clear();
    image = null;
    type = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(CupertinoIcons.clear)),
            title: Text(
              widget.editing ? 'Düzenle' : 'Ekle',
              style: const TextStyle(fontFamily: 'poppinsBold'),
            )),
        body: ListView(physics: const BouncingScrollPhysics(), children: [
          Center(
            child: GestureDetector(
              onTap: () {
                pickImage();
              },
              child: Container(
                height: 250,
                width: Get.width - 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: kdarkGreyColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: widget.editing && image == null
                            ? Image.network(
                                widget.imageUrl,
                                height: 250,
                                width: Get.width - 40,
                                fit: BoxFit.cover,
                              )
                            : image != null
                                ? Image.file(
                                    image!,
                                    height: 250,
                                    width: Get.width - 40,
                                    fit: BoxFit.cover,
                                  )
                                : const Center(
                                    child: Icon(
                                      CupertinoIcons.camera,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                                  )),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    height: 35,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: types.length,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return index != 0
                            ? GestureDetector(
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
                                        color: types[index][1]
                                            ? kThemeColor
                                            : kdarkGreyColor,
                                        borderRadius:
                                            BorderRadius.circular(500)),
                                    child: Center(
                                      child: Text(
                                        types[index][0],
                                        style: TextStyle(
                                            fontSize: 17,
                                            color: types[index][1]
                                                ? Colors.grey[900]
                                                : Colors.grey,
                                            fontFamily: 'poppinsBold'),
                                      ),
                                    )),
                              )
                            : const SizedBox();
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 10.0, bottom: 5, top: 10),
                  child: Text(
                    'Bilgiler',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: kdarkGreyColor,
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CupertinoTextField(
                        style: const TextStyle(color: Colors.white),
                        controller: titleController,
                        placeholderStyle: const TextStyle(color: Colors.grey),
                        placeholder: 'Ürün İsmi',
                        textAlignVertical: TextAlignVertical.center,
                        decoration: BoxDecoration(
                            color: kdarkGreyColor,
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      Divider(
                        color: Colors.grey[700],
                      ),
                      CupertinoTextField(
                        maxLength: 5,
                        inputFormatters: [
                          FilteringTextInputFormatter.singleLineFormatter,
                          FilteringTextInputFormatter.deny(','),
                          FilteringTextInputFormatter.deny('-'),
                          FilteringTextInputFormatter.deny(' '),
                        ],
                        style: const TextStyle(color: Colors.white),
                        controller: priceController,
                        placeholderStyle: const TextStyle(color: Colors.grey),
                        placeholder: 'Ürün Fiyatı',
                        textAlignVertical: TextAlignVertical.center,
                        decoration: BoxDecoration(
                            color: kdarkGreyColor,
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      Divider(
                        color: Colors.grey[700],
                      ),
                      setQuantity(context),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 10.0, bottom: 5, top: 10),
                  child: Text(
                    'Açıklama',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                      color: kdarkGreyColor,
                      borderRadius: BorderRadius.circular(15)),
                  child: CupertinoTextField(
                    minLines: 1,
                    maxLines: 12,
                    maxLength: 120,
                    style: const TextStyle(color: Colors.white),
                    controller: descController,
                    placeholderStyle: const TextStyle(color: Colors.grey),
                    placeholder: 'Ürün Açıklaması',
                    textAlignVertical: TextAlignVertical.center,
                    decoration: BoxDecoration(
                        color: kdarkGreyColor,
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                saveButton(context),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ))
        ]));
  }

  Row saveButton(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
              height: 50,
              child: CupertinoButton(
                color: Colors.green,
                borderRadius: BorderRadius.circular(17),
                child: const Text('Kaydet'),
                onPressed: () {
                  try {
                    if (widget.editing) {
                      productRef.doc(widget.productId).update({
                        "quantity": quantity,
                        "vendorId": currentUser.id,
                        "type": type,
                        "productTitle": titleController.text,
                        "productPrice": priceController.text,
                        "productDesc": descController.text,
                        "carts": [],
                      });
                      if (image != null) {
                        handleDatabase(widget.productId);
                        productRef.doc(widget.productId).update({
                          "image": url.toString(),
                        });
                      }
                      Get.back();
                    } else {
                      if (quantity != 0 &&
                          image != null &&
                          type.isNotEmpty &&
                          titleController.text.isNotEmpty &&
                          priceController.text.isNotEmpty &&
                          descController.text.isNotEmpty) {
                        try {
                          createProductInFirebase();
                          Get.back();
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: const Text(
                                      "Ürün Kontrol Ediliyor",
                                      style: TextStyle(),
                                    ),
                                    content: const Text(
                                      "Bu işlem zaman alabilir",
                                      style: TextStyle(),
                                    ),
                                    actions: [
                                      Row(
                                        children: [
                                          Expanded(
                                              child: CupertinoButton(
                                                  color: kThemeColor,
                                                  child: const Text(
                                                    'Tamam',
                                                  ),
                                                  onPressed: () {
                                                    Get.back();
                                                  }))
                                        ],
                                      ),
                                    ],
                                  ));
                        } catch (e) {
                          snackbar(
                              'Hata', 'Lutfen butun alanlari doldurun', true);
                          //print(e);
                        }
                      } else {
                        snackbar(
                            'Hata', 'Lutfen butun alanlari doldurun', true);
                      }
                    }
                  } catch (e) {
                    snackbar('Hata', 'Lutfen butun alanlari doldurun', true);
                    //print(e);
                  }
                },
              )),
        ),
      ],
    );
  }

  Row setQuantity(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 5,
        ),
        const Text(
          'Stok',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        const SizedBox(
          width: 15,
        ),
        GestureDetector(
          onTap: () {
            List<Center> quantities = [];
            for (var i = 0; i < 51; i++) {
              quantities.add(Center(
                child: Text(
                  i.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ));
            }

            showCupertinoModalPopup(
                context: context,
                builder: (context) => CupertinoTheme(
                      data: const CupertinoThemeData(
                          brightness: Brightness.dark,
                          primaryColor: kdarkGreyColor),
                      child: CupertinoActionSheet(
                          cancelButton: CupertinoActionSheetAction(
                              onPressed: () {
                                Get.back();
                              },
                              child: const Text(
                                'Tamam',
                                style: TextStyle(color: Colors.white70),
                              )),
                          actions: [
                            SizedBox(
                              height: Get.height / 3,
                              child: CupertinoPicker(
                                backgroundColor: kdarkGreyColor,
                                scrollController: FixedExtentScrollController(
                                    initialItem: quantity),
                                itemExtent: 64,
                                onSelectedItemChanged: (val) {
                                  setState(() {
                                    quantity = val;
                                  });
                                },
                                children: quantities,
                              ),
                            ),
                          ]),
                    ));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
            decoration: BoxDecoration(
                color: kThemeColor, borderRadius: BorderRadius.circular(7)),
            child: Text(
              (quantity).toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
