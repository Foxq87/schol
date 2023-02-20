import '/constants.dart';
import '/models/pages/root.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/loading.dart';

class CoinStore extends StatefulWidget {
  const CoinStore({super.key});

  @override
  State<CoinStore> createState() => _CoinStoreState();
}

class _CoinStoreState extends State<CoinStore> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                child: const Icon(
                  Icons.close,
                  color: kThemeColor,
                ),
                onPressed: () {
                  Get.back();
                },
              ),
              const Text(
                'BeyogluStore',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Row(
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  const Icon(
                    CupertinoIcons.money_dollar_circle,
                    color: Colors.amber,
                  ),
                  StreamBuilder(
                      stream: coinsRef.doc(currentUser.id).snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return loading();
                        }
                        if (!snapshot.data!.exists) {
                          return const Text(
                            '\t0',
                            style: TextStyle(color: Colors.amber, fontSize: 16),
                          );
                        }
                        return Text(
                          '\t${snapshot.data!.get('coins').toString()}',
                          style: const TextStyle(
                              color: Colors.amber, fontSize: 16),
                        );
                      }),
                  const SizedBox(
                    width: 20,
                  )
                ],
              ),
            ],
          ),
          Divider(
            color: Colors.grey[700],
            thickness: 0.4,
            height: 5,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            child: Text(
              'Rozetler',
              style: TextStyle(
                  color: Colors.white, fontSize: 18, fontFamily: 'poppinsMed'),
            ),
          ),
          Divider(
            color: Colors.grey[700],
            thickness: 0.4,
            height: 5,
            indent: 15,
            endIndent: 15,
          ),
          tileItem(
              Image.asset(
                "assets/cat_badge.png",
                height: 50,
                width: 50,
              ),
              "Cool",
              "Rozeti alarak sayfana ekleyebilirsin",
              50),
          Divider(
            color: Colors.grey[700],
            thickness: 0.5,
          ),
          tileItem(
              Image.asset(
                "assets/cat_badge.png",
                height: 50,
                width: 50,
              ),
              "Cool",
              "Rozeti alarak sayfana ekleyebilirsin",
              50),
          Divider(
            color: Colors.grey[700],
            thickness: 0.5,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            child: Text(
              'Daha fazla ürün',
              style: TextStyle(
                  color: Colors.white, fontSize: 18, fontFamily: 'poppinsMed'),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(
                width: 15,
              ),
              item(
                  const Icon(
                    CupertinoIcons.cube_box,
                    color: kThemeColor,
                    size: 50,
                  ),
                  '+5 ürün',
                  "Sayfana 5 ürün daha eklemeni sağlar.",
                  20),
              const SizedBox(
                width: 10,
              ),
              item(
                  const Icon(
                    CupertinoIcons.cube_box,
                    color: kThemeColor,
                    size: 50,
                  ),
                  '+10 ürün',
                  "Sayfana 5 ürün daha eklemeni sağlar.",
                  35),
              const SizedBox(
                width: 10,
              ),
              item(
                  const Icon(
                    CupertinoIcons.cube_box,
                    color: kThemeColor,
                    size: 50,
                  ),
                  '+15 ürün',
                  "Sayfana 5 ürün daha eklemeni sağlar.",
                  45),
              const SizedBox(
                width: 15,
              ),
            ],
          ),
        ],
      ),
    );
  }

  item(Icon leading, String title, String subtitle, int cost) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: Colors.grey[700]!,
            ),
            borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            const SizedBox(
              height: 5,
            ),
            leading,
            const SizedBox(
              height: 5,
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  cost.toString(),
                  style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 17,
                      fontFamily: 'poppinsBold'),
                ),
                const SizedBox(
                  width: 2,
                ),
                const Icon(
                  CupertinoIcons.money_dollar_circle,
                  color: Colors.amber,
                )
              ],
            ),
            const SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }

  tileItem(Image leading, String title, String subtitle, int cost) {
    return ListTile(
      leading:
          ClipRRect(borderRadius: BorderRadius.circular(7), child: leading),
      title: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontFamily: 'poppinsMed', fontSize: 17),
          ),
        ],
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            cost.toString(),
            style: const TextStyle(
                color: Colors.amber, fontSize: 15, fontFamily: 'poppinsBold'),
          ),
          const SizedBox(
            width: 2,
          ),
          const Icon(
            CupertinoIcons.money_dollar_circle,
            color: Colors.amber,
          )
        ],
      ),
    );
  }
}
