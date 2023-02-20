import 'dart:math';
import '/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/constants.dart';
import '/models/pages/root.dart';

class VendorPage extends StatefulWidget {
  const VendorPage({super.key});

  @override
  State<VendorPage> createState() => _VendorPageState();
}

class _VendorPageState extends State<VendorPage> {
  double angle = pi / 4;

  bool turned = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentUser.username,
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
                color: kdarkGreyColor,
                border: Border.symmetric(
                    horizontal:
                        BorderSide(color: Colors.grey[800]!, width: 0.5))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Burada nasıl gittiğini görebilirsin',
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Satıcı seviyesi',
                      style: TextStyle(color: Colors.grey[100], fontSize: 15),
                    ),
                    const Text(
                      'Çömez',
                      style: TextStyle(
                          color: Colors.green, fontFamily: 'poppinsBold'),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: const [
                            SizedBox(
                              height: 50,
                              width: 50,
                              child: CircularProgressIndicator(
                                semanticsLabel: '100',
                                value: 1,
                                strokeWidth: 2.5,
                                color: Colors.green,
                                backgroundColor: kdarkGreyColor,
                              ),
                            ),
                            Text(
                              '100%',
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        const Text(
                          'Mesajlara dönme hızı',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: const [
                            SizedBox(
                              height: 50,
                              width: 50,
                              child: CircularProgressIndicator(
                                semanticsLabel: '100',
                                value: 1,
                                strokeWidth: 2.5,
                                color: Colors.green,
                                backgroundColor: kdarkGreyColor,
                              ),
                            ),
                            Text(
                              '100%',
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 7,
                        ),
                        const Text(
                          'Müşteri memnuniyeti',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            height: 0,
            color: Colors.grey[300],
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                turned = !turned;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 14, 14, 14),
                  border: Border.symmetric(
                      horizontal:
                          BorderSide(color: Colors.grey[700]!, width: 0.5))),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sonraki seviye için',
                        style: TextStyle(color: Colors.grey[300]),
                      ),
                      Transform.rotate(
                        angle: turned ? pi / 90 : pi / 1,
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey,
                          size: 29,
                        ),
                      )
                    ],
                  ),
                  turned
                      ? Column(
                          children: [
                            StreamBuilder(
                                stream:
                                    usersRef.doc(currentUser.id).snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return loading();
                                  }
                                  Timestamp creation =
                                      snapshot.data!['creation'];
                                  return ListTile(
                                    title: const Text(
                                      'Tecrübe',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                    subtitle: Text(
                                      'Satıcı olarak 30 gün tamamla',
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14),
                                    ),
                                    trailing: Text(
                                      '${DateTime.now().difference(creation.toDate()).inDays} / 30',
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontFamily: 'poppinsBold'),
                                    ),
                                  );
                                }),
                            Divider(
                              color: Colors.grey[400],
                            ),
                            StreamBuilder(
                                stream: ordersRef
                                    .where('vendorId',
                                        isEqualTo: currentUser.id)
                                    .where('isCompleted', isEqualTo: true)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return loading();
                                  }
                                  double sum = 0;
                                  for (var i = 0;
                                      i < snapshot.data!.docs.length;
                                      i++) {
                                    sum += snapshot.data!.docs[i]['purchase'];
                                  }
                                  return ListTile(
                                    title: const Text(
                                      'Kazançlar',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                    subtitle: Text(
                                      'En az 300 ₺ kazan',
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14),
                                    ),
                                    trailing: Text(
                                      '${sum.toStringAsFixed(2)} ₺ / 300 ₺',
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontFamily: 'poppinsBold'),
                                    ),
                                  );
                                }),
                            Divider(
                              color: Colors.grey[400],
                            ),
                            StreamBuilder(
                                stream: ordersRef
                                    .where('vendorId',
                                        isEqualTo: currentUser.id)
                                    .where('isCompleted', isEqualTo: true)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return loading();
                                  }
                                  return ListTile(
                                    title: const Text(
                                      'Siparişler',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                    subtitle: Text(
                                      'En az 15 sipariş tamamla',
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14),
                                    ),
                                    trailing: Text(
                                      '${snapshot.data!.docs.length} / 15',
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontFamily: 'poppinsBold'),
                                    ),
                                  );
                                }),
                          ],
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Gelirler',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Text(
                  'Detaylar',
                  style: TextStyle(
                    color: kThemeColor,
                    fontSize: 13,
                  ),
                )
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: kdarkGreyColor,
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StreamBuilder(
                        stream: ordersRef
                            .where('vendorId', isEqualTo: currentUser.id)
                            .where('isCompleted', isEqualTo: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return loading();
                          }
                          num sum = 0;
                          for (var i = 0; i < snapshot.data!.docs.length; i++) {
                            sum += snapshot.data!.docs[i]['purchase'];
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${dateFormatter(DateTime.now().month + 1)}'de kazançlar",
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                              Text(
                                '${sum.toStringAsFixed(2)} ₺',
                                style: const TextStyle(
                                    color: kThemeColor,
                                    fontFamily: 'poppinsBold',
                                    fontSize: 17),
                              ),
                            ],
                          );
                        }),
                    StreamBuilder(
                        stream: ordersRef
                            .where('vendorId', isEqualTo: currentUser.id)
                            .where('isCompleted', isEqualTo: false)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return loading();
                          }
                          num sum = 0;
                          for (var i = 0; i < snapshot.data!.docs.length; i++) {
                            sum += snapshot.data!.docs[i]['purchase'];
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Aktif siparişler",
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                              Text(
                                '${sum.toStringAsFixed(2)} ₺',
                                style: const TextStyle(
                                    color: kThemeColor,
                                    fontFamily: 'poppinsBold',
                                    fontSize: 17),
                              ),
                            ],
                          );
                        }),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 23.0),
            child: Text(
              'Ürünlerim',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: kdarkGreyColor,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "İstatistikler",
                      style: TextStyle(color: Colors.grey[400], fontSize: 18),
                    ),
                    const Text(
                      'son 7 gün',
                      style: TextStyle(
                          color: kThemeColor,
                          fontFamily: 'poppinsBold',
                          fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tıklanmalar",
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    Row(
                      children: [
                        const Text(
                          '534',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'poppinsBold',
                              fontSize: 17),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          String.fromCharCode(
                              CupertinoIcons.arrow_up.codePoint),
                          style: TextStyle(
                            inherit: false,
                            color: Colors.green,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w900,
                            fontFamily: CupertinoIcons
                                .exclamationmark_circle.fontFamily,
                            package: CupertinoIcons
                                .exclamationmark_circle.fontPackage,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String dateFormatter(int month) {
  String result = 'error';
  switch (month) {
    case 2:
      result = 'Ocak';

      break;
    case 3:
      result = 'Şubat';

      break;
    case 4:
      result = 'Mart';

      break;
    case 5:
      result = 'Nisan';

      break;
    case 6:
      result = 'Mayıs';

      break;
    case 7:
      result = 'Haziran';

      break;
    case 8:
      result = 'Temmuz';

      break;
    case 9:
      result = 'Ağustos';

      break;
    case 10:
      result = 'Eylül';

      break;
    case 11:
      result = 'Ekim';

      break;
    case 12:
      result = 'Kasım';

      break;
    case 13:
      result = 'Aralık';

      break;

    default:
      result = 'error';
  }
  return result;
}
