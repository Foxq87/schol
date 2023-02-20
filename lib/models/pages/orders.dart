import '/widgets/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/models/order_model.dart';

import '/models/pages/root.dart';

import '../../constants.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  final ScrollController _scrollController = ScrollController();
  int state = 0;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: state == 1
            ? ordersRef
                .where('theList', arrayContains: currentUser.id)
                .where('isCompleted', isNotEqualTo: true)
                .snapshots()
            : ordersRef
                .where('theList', arrayContains: currentUser.id)
                .where('isCompleted', isEqualTo: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return loading();
          }
          return CupertinoPageScaffold(
              child: NestedScrollView(
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
                  "Siparişler",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
            body: Material(
              color: Colors.transparent,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  buildSegmentedControl(),
                  ListView.builder(
                    controller: _scrollController,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return Order(
                        orderId: snapshot.data!.docs[index]['orderId'],
                        purchase: snapshot.data!.docs[index]['purchase'],
                        vendorId: snapshot.data!.docs[index]['vendorId'],
                        buyerId: snapshot.data!.docs[index]['buyerId'],
                        note: snapshot.data!.docs[index]['note'],
                        dormNumber: snapshot.data!.docs[index]['dormNumber'],
                        dormType: snapshot.data!.docs[index]['dormType'],
                        paymentMethod: snapshot.data!.docs[index]
                            ['paymentMethod'],
                        isApproved: snapshot.data!.docs[index]['isApproved'],
                        isCompleted: snapshot.data!.docs[index]['isCompleted'],
                        theList: snapshot.data!.docs[index]['theList'],
                        delivererId: snapshot.data!.docs[index]['delivererId'],
                        isAccepted: snapshot.data!.docs[index]['isAccepted'],
                        isCanceled: snapshot.data!.docs[index]['isCanceled'],
                      );
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ));
        });
  }

  buildSegmentedControl() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 15, right: 15),
        child: CupertinoSlidingSegmentedControl<int>(
          backgroundColor: kdarkGreyColor,
          thumbColor: kMyGreyColor,
          // This represents the currently selected segmented control.
          groupValue: state,
          // Callback that sets the selected segmented control.
          onValueChanged: (value) {
            if (value != null) {
              setState(() {
                state = value;
              });
            }
          },
          children: const {
            0: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Aktif',
                style: TextStyle(color: CupertinoColors.white),
              ),
            ),
            1: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Tamamlanmış',
                style: TextStyle(color: CupertinoColors.white),
              ),
            ),
          },
        ),
      ),
    );
  }
}
