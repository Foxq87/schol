import 'dart:io';

import 'package:provider/provider.dart';

import '../../provider/data.dart';
import '/widgets/loading.dart';

import '/models/pages/root.dart';
import '/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:svg_icon/svg_icon.dart';
import 'package:unicons/unicons.dart';
import '/constants.dart';
import '/models/user_model.dart';
import '/models/pages/account.dart';
import '/models/pages/cart.dart';
import '/models/pages/store.dart';

import '../post_model.dart';
import '../../widgets/product.dart';
import 'bim.dart';
import 'create_post.dart';
import 'notifications.dart';
import 'suggest.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _service = FirebaseNotificationService();
  List<Post> posts = [];
  List<Post> explorePosts = [];
  @override
  void initState() {
    _service.connectNotification();
    getTimeLine();
    initAd();
    super.initState();
  }

  getTimeLine() async {
    QuerySnapshot snapshot = await timelineRef
        .doc(currentUser.id)
        .collection('timelinePosts')
        .orderBy('timeStamp', descending: true)
        .get();

    List<Post> posts = snapshot.docs
        .map((doc) => Post(
              postId: doc['postId'],
              ownerId: doc['ownerId'],
              postText: doc['postText'],
              timeStamp: doc['timeStamp'],
              likes: doc['likes'],
              mediaUrl: doc['mediaUrl'],
            ))
        .toList();
    setState(() {
      this.posts = posts;
    });
  }

  buildSegmentedControl() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
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
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Market',
                style: TextStyle(color: CupertinoColors.white),
              ),
            ),
            1: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Sosyal Medya',
                style: TextStyle(color: CupertinoColors.white),
              ),
            ),
          },
        ),
      ),
    );
  }

  bool isExpanded = false;
  late BannerAd _bannerAd1;
  late BannerAd _bannerAd2;

  void initAd() {
    _bannerAd2 = BannerAd(
        size: AdSize.banner,
        adUnitId: Platform.isIOS
            ? "ca-app-pub-9838840200304232/1855566594"
            : "ca-app-pub-9838840200304232/4719036684",
        listener: BannerAdListener(
          onAdFailedToLoad: (ad, error) {},
          onAdLoaded: (ad) {},
        ),
        request: const AdRequest());
    _bannerAd1 = BannerAd(
        size: AdSize.banner,
        adUnitId: Platform.isIOS
            ? "ca-app-pub-9838840200304232/8166388724"
            : "ca-app-pub-9838840200304232/1172400349",
        listener: BannerAdListener(
          onAdFailedToLoad: (ad, error) {},
          onAdLoaded: (ad) {},
        ),
        request: const AdRequest());
    _bannerAd2.load();
    _bannerAd1.load();
  }

  int _currentIndex = 0;
  int state = 0;
  bool isExplore = false;
  // buildSegmentedControl() {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 10),
  //     child: CupertinoSlidingSegmentedControl<int>(
  //       backgroundColor: kdarkGreyColor,
  //       thumbColor: kMyGreyColor,
  //       // This represents the currently selected segmented control.
  //       groupValue: state,
  //       // Callback that sets the selected segmented control.
  //       onValueChanged: (value) {
  //         if (value != null) {
  //           setState(() {
  //             state = value;
  //           });
  //         }
  //       },
  //       children: {
  //         0: const Padding(
  //           padding: EdgeInsets.symmetric(horizontal: 20),
  //           child: Text(
  //             'Market',
  //             style: TextStyle(color: CupertinoColors.white),
  //           ),
  //         ),
  //         1: const Padding(
  //           padding: EdgeInsets.symmetric(horizontal: 20),
  //           child: Text(
  //             'Sosyal Medya',
  //             style: TextStyle(color: CupertinoColors.white),
  //           ),
  //         ),
  //       },
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Scaffold(
        body: CupertinoPageScaffold(
          backgroundColor: Colors.black,
          navigationBar: modernNavBar(),

          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(
                height: 15,
              ),
              buildSegmentedControl(),
              currentUser.isDeliverer
                  ? buildBackToOrders(context)
                  : const SizedBox(),
              state == 1
                  ? RefreshIndicator(
                      child: buildTimeLine(),
                      onRefresh: () => getTimeLine(),
                    )
                  : storeView(),
            ],
          ),

          // bottomNavigationBar: bottomNavBar(),
        ),
        floatingActionButton: state != 1
            ? const SizedBox()
            : FloatingActionButton(
                backgroundColor: kThemeColor,
                child: const Icon(Icons.add),
                onPressed: () {
                  Get.to(() => const CreatePost(),
                      transition: Transition.downToUp);
                },
              ),
      ),
    );
  }

  Container buildBackToOrders(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 5, 20, 0),
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.grey[700]!),
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Siparişlere dön",
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
    );
  }

  buildTimeLine() {
    if (posts == null) {
      return const CupertinoActivityIndicator();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () async {
              List userIds = [];
              int index = 0;
              int length = 0;
              usersRef.get().then((value) {
                setState(() {
                  userIds.add(value.docs[index]['id']);
                  length = value.docs.length;
                });
              });

              for (var i = 0; i < length; i++) {
                await postsRef
                    .doc(userIds[index])
                    .collection('userPosts')
                    .get()
                    .then((value) {
                  setState(() {
                    explorePosts.add(value.docs[i] as Post);
                  });
                });
              }
              setState(() {
                isExplore = !isExplore;
              });
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    isExplore ? 'Takip ettiklerim' : 'Tüm postlar',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: kThemeColor,
                    size: 35,
                  )
                ],
              ),
            ),
          ),
          ListView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: isExplore ? posts : explorePosts)
        ],
      );
    }
  }

  GestureDetector suggest() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 5, 20, 0),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey[700]!),
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Öner',
                    style: TextStyle(color: Colors.white, fontSize: 19),
                  ),
                  isExpanded
                      ? const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: kThemeColor,
                        )
                      : const Icon(
                          Icons.keyboard_arrow_up_rounded,
                          color: kThemeColor,
                        ),
                ],
              ),
              isExpanded == false
                  ? const SizedBox()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          'Uygulama hala çok yeni, eklememizi istediğin özellikleri yazabilirsin veya başkalarının önerilerini puanlayabilirsin!',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 35,
                          child: CupertinoButton(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              color: kThemeColor,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text('Devam et'),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Icon(
                                    CupertinoIcons.forward,
                                    size: 20,
                                  )
                                ],
                              ),
                              onPressed: () {
                                Get.to(() => const Suggest());
                              }),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Column storeView() {
    return Column(
      children: [
        //   suggest(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sizin İçin',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              TextButton(
                  onPressed: () {
                    Get.to(() => const Store());
                  },
                  child: const Text('hepsi',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 17,
                      ))),
            ],
          ),
        ),
        SizedBox(
          height: 214,
          child: StreamBuilder(
              stream: productRef
                  .where('vendorId', isNotEqualTo: currentUser.id)
                  .where("approve", isEqualTo: 2)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
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
              }),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Market',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    CupertinoIcons.slider_horizontal_3,
                    color: Colors.grey,
                  )),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      backgroundColor: kdarkGreyColor,
                      title: const Text(
                        "Demo surecinde bim'e gidenler calismayacak",
                        style: TextStyle(color: Colors.white),
                      ),
                      actions: [
                        CupertinoButton(
                            color: kThemeColor,
                            child: const Text('Tamam'),
                            onPressed: () {
                              Get.back();
                            })
                      ],
                    ));
            // Get.to(() => const Bim(), transition: Transition.cupertino);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[700]!, width: 1),
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/bim.png',
                    height: 45,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  "Bim'e Gidenler",
                  style: TextStyle(color: Colors.white, fontSize: 19),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Haftanın Satıcıları',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    CupertinoIcons.slider_horizontal_3,
                    color: Colors.grey,
                  )),
            ],
          ),
        ),
        StreamBuilder(
            stream: leaderboardRef
                .orderBy('soldGoods', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return loading();
              }
              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return StreamBuilder(
                      stream: usersRef
                          .doc(snapshot.data!.docs[index]['userId'])
                          .snapshots(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return loading();
                        }
                        User user = User.fromDocument(userSnapshot.data!);
                        return GestureDetector(
                          onTap: () {
                            Get.to(
                                () => Account(
                                      profileId: user.id,
                                      previousPage: 'AppBeyoglu',
                                    ),
                                transition: Transition.cupertino,
                                preventDuplicates: true);
                          },
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                    width: 2, color: Colors.grey[700]!),
                                borderRadius: BorderRadius.circular(15)),
                            child: ListTile(
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SvgIcon(
                                    'assets/trophy-solid.svg',
                                    height: 22,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(user.photoUrl),
                                  ),
                                ],
                              ),
                              title: Text(
                                user.username,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                  '${snapshot.data!.docs[index]['soldGoods'].toString()} ürün sattı!'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.star_rate_rounded,
                                    color: Colors.amber,
                                  ),
                                  Text(
                                    '\t4.9',
                                    style: TextStyle(color: Colors.amber),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                },
              );
            }),
        SizedBox(
            height: _bannerAd2.size.height.toDouble(),
            width: _bannerAd2.size.width.toDouble(),
            child: AdWidget(ad: _bannerAd2)),
      ],
    );
  }

  CupertinoNavigationBar modernNavBar() {
    return CupertinoNavigationBar(
      border: const Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey, width: 0.25)),
      middle: const Text(
        'AppBeyoğlu',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: const Color.fromARGB(255, 19, 19, 19).withOpacity(0.9),
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          Get.to(const Notifications());
        },
        child: const Icon(
          CupertinoIcons.bell,
          color: kThemeColor,
          size: 22,
        ),
      ),
      trailing: StreamBuilder(
          stream:
              cartsRef.doc(currentUser.id).collection('userCart').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return loading();
            }
            return Badge(
              alignment: AlignmentDirectional.topEnd,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              label: Text(
                snapshot.data!.docs.length.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              child: CupertinoButton(
                onPressed: () {
                  Get.to(() => const Cart(), transition: Transition.cupertino);
                },
                child: const Icon(
                  CupertinoIcons.bag,
                  color: kThemeColor,
                ),
              ),
            );
          }),
    );
  }

  loadingSkeleton() {
    return Container(
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
                child: Container(
                  height: 120,
                  width: 250,
                  color: kdarkGreyColor,
                )),
          ),
          const SizedBox(
            height: 7,
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: kdarkGreyColor),
                    height: 40,
                    width: 40,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    height: 20,
                    width: 250,
                    decoration: BoxDecoration(
                        color: kdarkGreyColor,
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  Container(
                    color: kdarkGreyColor,
                    width: 53,
                    height: 40,
                  )
                ],
              )),
        ],
      ),
    );
  }

  bottomNavBar() {
    return Material(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: CustomNavigationBar(
          borderRadius: const Radius.circular(12),
          blurEffect: false,
          bubbleCurve: Curves.easeInOutQuad,

          // elevation: 2.0,
          iconSize: 30.0,
          isFloating: true,
          selectedColor: Colors.white,
          unSelectedColor: Colors.grey,
          backgroundColor: const Color.fromARGB(255, 23, 23, 23),
          strokeColor: Colors.transparent,

          items: [
            CustomNavigationBarItem(
              icon: const Icon(UniconsLine.home_alt),
            ),
            CustomNavigationBarItem(
              icon: const Icon(
                CupertinoIcons.search,
              ),
            ),
            CustomNavigationBarItem(
              icon: const Icon(
                CupertinoIcons.add_circled,
              ),
            ),
            CustomNavigationBarItem(
              icon: const Icon(Icons.mail_outline_rounded),
            ),
            CustomNavigationBarItem(
              icon: const Icon(CupertinoIcons.person_crop_circle),
            ),
          ],
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
