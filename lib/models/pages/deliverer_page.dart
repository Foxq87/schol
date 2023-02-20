import 'package:appbeyoglu/constants.dart';
import 'package:appbeyoglu/models/pages/account.dart';
import 'package:appbeyoglu/models/pages/home.dart';
import 'package:appbeyoglu/models/pages/root.dart';
import 'package:appbeyoglu/provider/data.dart';
import 'package:appbeyoglu/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../user_model.dart';

class Deliverers extends StatefulWidget {
  const Deliverers({super.key});

  @override
  State<Deliverers> createState() => _DeliverersState();
}

class _DeliverersState extends State<Deliverers> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: NestedScrollView(
        physics: const BouncingScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          CupertinoSliverNavigationBar(
            automaticallyImplyLeading: false,
            border: innerBoxIsScrolled
                ? const Border(
                    bottom: BorderSide(
                        color: CupertinoColors.systemGrey, width: 0.5))
                : const Border(bottom: BorderSide()),
            backgroundColor: innerBoxIsScrolled
                ? const Color.fromARGB(255, 42, 42, 42).withOpacity(0.5)
                : const Color.fromARGB(255, 3, 3, 3),
            largeTitle: const Text(
              'Siparişler',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
        body: ListView(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(20, 5, 20, 0),
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey[700]!),
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Eve dön",
                      style: TextStyle(color: Colors.white, fontSize: 19),
                    ),
                    CupertinoSwitch(
                        value: Provider.of<Data>(
                          context,
                        ).appType,
                        onChanged: (value) {
                          Provider.of<Data>(context, listen: false)
                              .updateAppType(value);
                        }),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            StreamBuilder(
                stream: ordersRef
                    .where('isAccepted', isEqualTo: true)
                    .where('isCompleted', isEqualTo: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return loading();
                  } else if (snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.check_mark_circled,
                            color: kThemeColor,
                            size: 70,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: kThemeColor),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Text(
                              'Harika! Su anda hicbir sipariş bulunmamakta',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return StreamBuilder(
                      stream: deliveriesRef.doc(currentUser.id).snapshots(),
                      builder: (context, delivererSnapshot) {
                        if (!delivererSnapshot.hasData) {
                          return loading();
                        }

                        return delivererSnapshot.data!.exists &&
                                delivererSnapshot.data!
                                        .data()!['isCompleted'] ==
                                    false
                            ? StreamBuilder(
                                stream: ordersRef
                                    .doc(delivererSnapshot.data!
                                        .data()!['orderId'])
                                    .snapshots(),
                                builder: (context, orderSnapshot) {
                                  if (!orderSnapshot.hasData) {
                                    return loading();
                                  }

                                  return StreamBuilder(
                                      stream: usersRef
                                          .doc(orderSnapshot.data!
                                              .data()!['buyerId'])
                                          .snapshots(),
                                      builder: (context, buyerSnapshot2) {
                                        if (!buyerSnapshot2.hasData) {
                                          return loading();
                                        }
                                        User buyer = User.fromDocument(
                                            buyerSnapshot2.data!);
                                        return StreamBuilder(
                                            stream: usersRef
                                                .doc(orderSnapshot.data!
                                                    .data()!['vendorId'])
                                                .snapshots(),
                                            builder:
                                                (context, vendorSnapshot2) {
                                              if (!vendorSnapshot2.hasData) {
                                                return loading();
                                              }
                                              User vendor = User.fromDocument(
                                                  vendorSnapshot2.data!);
                                              return ListView(
                                                shrinkWrap: true,
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                children: [
                                                  Container(
                                                    width: Get.width,
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 20),
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 8,
                                                        vertical: 5),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          width: 2,
                                                          color: kThemeColor),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Center(
                                                          child: Text(
                                                            'Aktif Teslimat',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 20),
                                                          ),
                                                        ),
                                                        const Divider(
                                                          thickness: 1,
                                                          color: kThemeColor,
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            Get.to(() => Account(
                                                                profileId:
                                                                    buyer.id,
                                                                previousPage:
                                                                    'Siparişler'));
                                                          },
                                                          child: Text(
                                                            'Alici : ' +
                                                                buyer.username,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            Get.to(() => Account(
                                                                profileId:
                                                                    vendor.id,
                                                                previousPage:
                                                                    'Siparişler'));
                                                          },
                                                          child: Text(
                                                            'Satıcı : ' +
                                                                vendor.username,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 7,
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 5),
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  width: 1.0,
                                                                  color:
                                                                      kThemeColor),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          child: const Text(
                                                            'Alicinin adresi',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 7,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      8.0),
                                                          child: Text(
                                                            orderSnapshot.data!
                                                                        .data()![
                                                                    'dormType'] +
                                                                '\t-\t' +
                                                                orderSnapshot
                                                                    .data!
                                                                    .data()![
                                                                        'dormNumber']
                                                                    .toString() +
                                                                '. Yatakhane',
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        18),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 7,
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 5),
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  width: 1.0,
                                                                  color:
                                                                      kThemeColor),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          child: const Text(
                                                            'Satıcınin adresi',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 7,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      8.0),
                                                          child: Text(
                                                            // ignore: prefer_interpolation_to_compose_strings
                                                            vendor.dormType +
                                                                '\t-\t' +
                                                                vendor
                                                                    .dormNumber
                                                                    .toString() +
                                                                '. Yatakhane',
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        18),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 5),
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  width: 1.0,
                                                                  color:
                                                                      kThemeColor),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          child: const Text(
                                                            'Fiyat',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 5,
                                                                  horizontal:
                                                                      10),
                                                          child: Text(
                                                            orderSnapshot.data!
                                                                    .data()![
                                                                        'purchase']
                                                                    .toString() +
                                                                ' ₺',
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontSize:
                                                                        18),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 20.0,
                                                        vertical: 10),
                                                    child: StreamBuilder(
                                                        stream: ordersRef
                                                            .doc(orderSnapshot
                                                                    .data!
                                                                    .data()![
                                                                'orderId'])
                                                            .snapshots(),
                                                        builder: (context,
                                                            approveSnapshot) {
                                                          if (!approveSnapshot
                                                              .hasData) {
                                                            return loading();
                                                          }
                                                          List approve =
                                                              approveSnapshot
                                                                      .data!
                                                                      .data()![
                                                                  'isApproved'];
                                                          return Column(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: CupertinoButton(
                                                                        borderRadius: BorderRadius.circular(13),
                                                                        padding: EdgeInsets.zero,
                                                                        color: kThemeColor,
                                                                        child: Text(
                                                                          approve.length == 1
                                                                              ? 'Satıcıdan siparişi aldim'
                                                                              : approve.length == 2
                                                                                  ? 'Teslim Ettim'
                                                                                  : 'Tamamlandı',
                                                                          style:
                                                                              const TextStyle(color: Colors.white),
                                                                        ),
                                                                        onPressed: () {
                                                                          if (approve.length ==
                                                                              1) {
                                                                            try {
                                                                              ordersRef.doc(orderSnapshot.data!.data()!['orderId']).update({
                                                                                "isApproved": FieldValue.arrayUnion([
                                                                                  currentUser.id
                                                                                ]),
                                                                              });
                                                                            } catch (e) {
                                                                              //print(e);
                                                                            }
                                                                          } else if (approve.length ==
                                                                              2) {
                                                                            showDialog(
                                                                                context: context,
                                                                                builder: (context) => AlertDialog(
                                                                                      backgroundColor: kdarkGreyColor,
                                                                                      title: const Text(
                                                                                        'Emin misin?',
                                                                                        style: TextStyle(color: Colors.white),
                                                                                      ),
                                                                                      content: const Text(
                                                                                        'Siparişi teslim ettiğini onaylıyorsun, bu işlemi geri alamazsın',
                                                                                        style: TextStyle(color: Colors.grey),
                                                                                      ),
                                                                                      actions: [
                                                                                        Row(
                                                                                          children: [
                                                                                            Expanded(
                                                                                              child: Container(
                                                                                                height: 50,
                                                                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                                                                                decoration: BoxDecoration(border: Border.all(width: 1.0, color: kThemeColor), borderRadius: BorderRadius.circular(10)),
                                                                                                child: CupertinoButton(
                                                                                                    padding: EdgeInsets.zero,
                                                                                                    child: const Text(
                                                                                                      'Geri don',
                                                                                                      style: TextStyle(color: Colors.white),
                                                                                                    ),
                                                                                                    onPressed: () {
                                                                                                      Get.back();
                                                                                                    }),
                                                                                              ),
                                                                                            ),
                                                                                            const SizedBox(
                                                                                              width: 10,
                                                                                            ),
                                                                                            Expanded(
                                                                                              child: Container(
                                                                                                height: 50,
                                                                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                                                                                decoration: BoxDecoration(border: Border.all(width: 1.0, color: kThemeColor), borderRadius: BorderRadius.circular(10)),
                                                                                                child: CupertinoButton(
                                                                                                    padding: EdgeInsets.zero,
                                                                                                    child: const Text(
                                                                                                      'Devam et',
                                                                                                      style: TextStyle(color: Colors.white),
                                                                                                    ),
                                                                                                    onPressed: () {
                                                                                                      try {
                                                                                                        ordersRef.doc(orderSnapshot.data!.data()!['orderId']).update({
                                                                                                          "isApproved": FieldValue.arrayUnion([currentUser.id]),
                                                                                                          "isCompleted": true,
                                                                                                        });
                                                                                                        increaseLeaderboard(vendor.id);

                                                                                                        Get.back();
                                                                                                      } catch (e) {
                                                                                                        //print(e);
                                                                                                      }
                                                                                                    }),
                                                                                              ),
                                                                                            )
                                                                                          ],
                                                                                        ),
                                                                                      ],
                                                                                    ));
                                                                          } else {}
                                                                        }),
                                                                    //  Container(
                                                                    //         decoration:
                                                                    //             BoxDecoration(
                                                                    //           border: Border.all(width: 0.8, color: kThemeColor),
                                                                    //           borderRadius: BorderRadius.circular(13),
                                                                    //         ),
                                                                    //         child: CupertinoButton(
                                                                    //             borderRadius: BorderRadius.circular(13),
                                                                    //             padding: EdgeInsets.zero,
                                                                    //             color: Colors.transparent,
                                                                    //             child: const Text(
                                                                    //               'Tamamlandi',
                                                                    //               style: TextStyle(color: Colors.white),
                                                                    //             ),
                                                                    //             onPressed: () {}),
                                                                    //       )
                                                                    //     : const SizedBox(),
                                                                  ),
                                                                ],
                                                              ),
                                                              approve.length ==
                                                                      3
                                                                  ? Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        const Text(
                                                                          'Buradaki işin bitti gibi görünüyor, Geri dönerek başka siparişleri teslim edebilirsin.',
                                                                          style:
                                                                              TextStyle(color: kThemeColor),
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              10,
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              45,
                                                                          child: CupertinoButton(
                                                                              borderRadius: BorderRadius.circular(15),
                                                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                                                              color: kThemeColor,
                                                                              child: const Text('Tamamla ve Geri don'),
                                                                              onPressed: () {
                                                                                deliveriesRef.doc(currentUser.id).update({
                                                                                  "isCompleted": true
                                                                                });
                                                                              }),
                                                                        )
                                                                      ],
                                                                    )
                                                                  : const Text(
                                                                      '')
                                                            ],
                                                          );
                                                        }),
                                                  )
                                                ],
                                              );
                                            });
                                      });
                                })
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: ((context, index) {
                                  return Container(
                                    margin: const EdgeInsets.fromLTRB(
                                        20.0, 0, 20.0, 10.0),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                            width: 0.5, color: Colors.white)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0,
                                        vertical: 15.0,
                                      ),
                                      child: StreamBuilder(
                                          stream: usersRef
                                              .doc(snapshot.data!.docs[index]
                                                  ['buyerId'])
                                              .snapshots(),
                                          builder: (context, buyerSnapshot) {
                                            if (!buyerSnapshot.hasData) {
                                              return loading();
                                            }
                                            User buyer = User.fromDocument(
                                                buyerSnapshot.data!);
                                            return StreamBuilder(
                                                stream: usersRef
                                                    .doc(snapshot
                                                            .data!.docs[index]
                                                        ['vendorId'])
                                                    .snapshots(),
                                                builder:
                                                    (context, vendorSnapshot) {
                                                  if (!vendorSnapshot.hasData) {
                                                    return loading();
                                                  }
                                                  User vendor =
                                                      User.fromDocument(
                                                          vendorSnapshot.data!);
                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          Get.to(() => Account(
                                                              profileId:
                                                                  buyer.id,
                                                              previousPage:
                                                                  'Siparişler'));
                                                        },
                                                        child: Text(
                                                          'Alici : ' +
                                                              buyer.username,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 18),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          Get.to(() => Account(
                                                              profileId:
                                                                  vendor.id,
                                                              previousPage:
                                                                  'Siparişler'));
                                                        },
                                                        child: Text(
                                                          'Satıcı : ' +
                                                              vendor.username,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 18),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 7,
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 8,
                                                                vertical: 5),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                width: 1.0,
                                                                color:
                                                                    kThemeColor),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        child: const Text(
                                                          'Alicinin adresi',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 18),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 7,
                                                      ),
                                                      Text(
                                                        snapshot.data!
                                                                    .docs[index]
                                                                ['dormType'] +
                                                            '\t' +
                                                            snapshot
                                                                .data!
                                                                .docs[index][
                                                                    'dormNumber']
                                                                .toString() +
                                                            '. Yatakhane',
                                                        style: const TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 18),
                                                      ),
                                                      const SizedBox(
                                                        height: 7,
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 8,
                                                                vertical: 5),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                width: 1.0,
                                                                color:
                                                                    kThemeColor),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        child: const Text(
                                                          'Satıcının adresi',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 18),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 7,
                                                      ),
                                                      Text(
                                                        vendor.dormType +
                                                            '\t' +
                                                            vendor.dormNumber
                                                                .toString() +
                                                            '. Yatakhane',
                                                        style: const TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 18),
                                                      ),
                                                      snapshot
                                                              .data!
                                                              .docs[index]
                                                                  ['note']
                                                              .toString()
                                                              .isEmpty
                                                          ? const SizedBox()
                                                          : Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const SizedBox(
                                                                  height: 7,
                                                                ),
                                                                Container(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          8,
                                                                      vertical:
                                                                          5),
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          width:
                                                                              1.0,
                                                                          color:
                                                                              kThemeColor),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10)),
                                                                  child:
                                                                      const Text(
                                                                    'Alicinin Notu',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            18),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 7,
                                                                ),
                                                              ],
                                                            ),
                                                      snapshot
                                                              .data!
                                                              .docs[index][
                                                                  'vendorsNote']
                                                              .toString()
                                                              .isEmpty
                                                          ? const SizedBox()
                                                          : Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  snapshot.data!
                                                                              .docs[
                                                                          index]
                                                                      ['note'],
                                                                  style: const TextStyle(
                                                                      color:
                                                                          kThemeColor),
                                                                ),
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                                const SizedBox(
                                                                  height: 7,
                                                                ),
                                                                Container(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          8,
                                                                      vertical:
                                                                          5),
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          width:
                                                                              1.0,
                                                                          color:
                                                                              kThemeColor),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10)),
                                                                  child:
                                                                      const Text(
                                                                    'Satıcının Notu',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            18),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 7,
                                                                ),
                                                                Text(
                                                                  snapshot.data!
                                                                              .docs[
                                                                          index]
                                                                      [
                                                                      'vendorsNote'],
                                                                  style: const TextStyle(
                                                                      color:
                                                                          kThemeColor),
                                                                ),
                                                                const SizedBox(
                                                                  height: 5,
                                                                ),
                                                              ],
                                                            ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 8,
                                                                vertical: 5),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                width: 1.0,
                                                                color:
                                                                    kThemeColor),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        child: const Text(
                                                          'Fiyat',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 18),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          vertical: 5,
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              (snapshot.data!.docs[index]
                                                                              [
                                                                              'purchase'] -
                                                                          5)
                                                                      .toString() +
                                                                  ' ₺',
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 18),
                                                            ),
                                                            const Text(
                                                              '5 ₺ kazanc',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .amber,
                                                                  fontSize: 18),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
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
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            15),
                                                                    child: const Text(
                                                                        'Bana salin beyler'),
                                                                    onPressed:
                                                                        () {
                                                                      showDialog(
                                                                          context:
                                                                              context,
                                                                          builder: (context) =>
                                                                              AlertDialog(
                                                                                backgroundColor: kdarkGreyColor,
                                                                                title: const Text(
                                                                                  'Emin misin?',
                                                                                  style: TextStyle(color: Colors.white),
                                                                                ),
                                                                                content: const Text(
                                                                                  'Isi kabul ettikten sonra iptal edemezsin',
                                                                                  style: TextStyle(color: Colors.grey),
                                                                                ),
                                                                                actions: [
                                                                                  Row(
                                                                                    children: [
                                                                                      Expanded(
                                                                                        child: Container(
                                                                                          height: 50,
                                                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                                                                          decoration: BoxDecoration(border: Border.all(width: 1.0, color: kThemeColor), borderRadius: BorderRadius.circular(10)),
                                                                                          child: CupertinoButton(
                                                                                              padding: EdgeInsets.zero,
                                                                                              child: const Text(
                                                                                                'Geri don',
                                                                                                style: TextStyle(color: Colors.white),
                                                                                              ),
                                                                                              onPressed: () {
                                                                                                Get.back();
                                                                                              }),
                                                                                        ),
                                                                                      ),
                                                                                      const SizedBox(
                                                                                        width: 10,
                                                                                      ),
                                                                                      Expanded(
                                                                                        child: Container(
                                                                                          height: 50,
                                                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                                                                          decoration: BoxDecoration(border: Border.all(width: 1.0, color: kThemeColor), borderRadius: BorderRadius.circular(10)),
                                                                                          child: CupertinoButton(
                                                                                              padding: EdgeInsets.zero,
                                                                                              child: const Text(
                                                                                                'Devam et',
                                                                                                style: TextStyle(color: Colors.white),
                                                                                              ),
                                                                                              onPressed: () {
                                                                                                try {
                                                                                                  ordersRef.doc(snapshot.data!.docs[index]['orderId']).get().then((doc) {
                                                                                                    if (doc.exists && doc.get('delivererId').toString().isEmpty) {
                                                                                                      doc.reference.update({
                                                                                                        "delivererId": currentUser.id
                                                                                                      });
                                                                                                    }
                                                                                                  });
                                                                                                  deliveriesRef.doc(currentUser.id).set({
                                                                                                    "delivererId": currentUser.id,
                                                                                                    "orderId": snapshot.data!.docs[index]['orderId'],
                                                                                                    "approvalTime": DateTime.now(),
                                                                                                    "isCompleted": false,
                                                                                                  });
                                                                                                  Get.back();
                                                                                                } catch (e) {}
                                                                                              }),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ));
                                                                    }),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  );
                                                });
                                          }),
                                    ),
                                  );
                                }),
                              );
                      });
                }),
          ],
        ),
      ),
    );
  }

  increaseLeaderboard(String vendor) {
    leaderboardRef.doc(vendor).get().then((doc) {
      if (doc.exists) {
        doc.reference.update({
          "soldGoods": doc.get('soldGoods') + 1,
        });
      } else {
        doc.reference.set({
          "soldGoods": 1,
          "userId": vendor,
        });
      }
    });
  }
}
