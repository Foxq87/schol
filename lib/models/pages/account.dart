import 'dart:io';

import 'package:appbeyoglu/models/pages/search.dart';
import 'package:lottie/lottie.dart';

import '/services/ad_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '/widgets/loading.dart';

import '/widgets/snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '/constants.dart';
import '/models/user_model.dart';
import '/models/pages/create.dart';
import '/models/pages/root.dart';
import '/models/pages/settings.dart';
import '/provider/data.dart';
import '/widgets/product.dart';
import 'package:uuid/uuid.dart';

import '../post_model.dart';
import 'coin_store.dart';

class Account extends StatefulWidget {
  final String profileId;
  final String previousPage;
  Account({Key? key, required this.profileId, required this.previousPage})
      : super(key: key) {
    adManager.loadRewardedAd();
  }

  @override
  State<Account> createState() => _AccountState();
}

final adManager = AdManager();

class _AccountState extends State<Account> {
  String type = 'Hepsi';
  int productCount = 0;
  List<Product> products = [];
  List<DateTime?> date = [
    DateTime.now(),
  ];
  int state = 0;
  int postCount = 0;
  bool isLoading = false;
  bool isFollowing = false;
  @override
  void initState() {
    super.initState();
    checkIfFollowing();
    adManager.loadRewardedAd();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUser.id)
        .get();
    isFollowing = doc.exists;
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
                'Ürünler',
                style: TextStyle(color: CupertinoColors.white),
              ),
            ),
            1: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Paylaşımlar',
                style: TextStyle(color: CupertinoColors.white),
              ),
            ),
          },
        ),
      ),
    );
  }

  buildProfileHeader(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        earnCoin(),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(color: Colors.grey[700]!, width: 0.7))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.to(() => Photo(mediaUrl: user.photoUrl));
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              user.photoUrl,
                              height: 90,
                              width: 90,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Expanded(child: Container()),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            // showAd(),

                            Text(
                              user.username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            widget.profileId == currentUser.id
                                ? editProfileButton(user)
                                : followUnfollow(),

                            widget.profileId == currentUser.id
                                ? const SizedBox(
                                    height: 65,
                                  )
                                : const SizedBox(height: 55.0),
                          ],
                        ),
                        Expanded(child: Container()),
                      ]),
                ),
              ),
            ),
            widget.profileId == currentUser.id
                ? const SizedBox(
                    height: 10,
                  )
                : const SizedBox(),
            Positioned(bottom: 30, child: followersFollowing()),
            widget.profileId == currentUser.id
                ? user.isVendor
                    ? user.id == currentUser.id
                        ? Positioned(
                            bottom: -22,
                            left: 20,
                            right: 20,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: Get.width - 40,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 15),
                                  decoration: BoxDecoration(
                                      color: kdarkGreyColor,
                                      borderRadius: BorderRadius.circular(13)),
                                  child: Column(
                                    children: [updateStatus()],
                                  ),
                                ),
                              ],
                            ))
                        : const SizedBox()
                    : const SizedBox()
                : const SizedBox(),
          ],
        ),
        widget.profileId == currentUser.id
            ? const SizedBox(
                height: 30,
              )
            : const SizedBox(
                height: 10,
              ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            user.bio,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StreamBuilder(
                  stream: productRef
                      .where("approve", isEqualTo: 2)
                      .where("vendorId", isEqualTo: widget.profileId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return loading();
                    }
                    return accountDetail(
                        "Ürünler",
                        snapshot.data!.docs.length.toString(),
                        const Icon(
                          CupertinoIcons.cube_box,
                          color: kThemeColor,
                          size: 40,
                        ));
                  }),
              const SizedBox(
                width: 10,
              ),
              StreamBuilder(
                  stream: ordersRef
                      .where('vendorId', isEqualTo: widget.profileId)
                      .where('isCompleted', isEqualTo: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return loading();
                    }
                    return accountDetail(
                        'Satışlar',
                        snapshot.data!.docs.length.toString(),
                        const Icon(
                          CupertinoIcons.money_dollar,
                          color: kThemeColor,
                          size: 40,
                        ));
                  }),
              const SizedBox(
                width: 10,
              ),
              StreamBuilder(
                  stream: coinsRef.doc(widget.profileId).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return loading();
                    }
                    if (!snapshot.data!.exists) {
                      return accountDetail(
                          'Coinler',
                          '\t0',
                          const Icon(
                            CupertinoIcons.money_dollar_circle,
                            color: kThemeColor,
                            size: 40,
                          ));
                    }
                    return accountDetail(
                        'Coinler',
                        '\t${snapshot.data!.get('coins').toString()}',
                        const Icon(
                          CupertinoIcons.money_dollar_circle,
                          color: kThemeColor,
                          size: 40,
                        ));
                  }),
            ],
          ),
        ),
        widget.profileId == currentUser.id
            ? Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const SearchForUsers(),
                          transition: Transition.downToUp);
                    },
                    child: Container(
                      height: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      decoration: BoxDecoration(
                          border:
                              Border.all(width: 2, color: Colors.grey[700]!),
                          borderRadius: BorderRadius.circular(15)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            CupertinoIcons.person_add,
                            color: kThemeColor,
                          ),
                          SizedBox(
                            width: 7,
                          ),
                          Text(
                            "Arkadaş bul",
                            style: TextStyle(color: Colors.white, fontSize: 19),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox(),
        const SizedBox(
          height: 15,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(
              color: Colors.grey,
              thickness: 0.5,
            ),
            user.isVendor == false
                ? const SizedBox()
                : state == 0
                    ? Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Filtrele",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () async {
                                  type = await showDialog(
                                      context: context,
                                      builder: (context) => const Filter());

                                  //print(type);
                                },
                                child: const Icon(
                                  CupertinoIcons.slider_horizontal_3,
                                  color: kThemeColor,
                                  size: 20,
                                ))
                          ],
                        ),
                      )
                    : const SizedBox(),
            user.isVendor == false ? const SizedBox() : buildSegmentedControl(),
          ],
        ),
      ],
    );
  }

  Container earnCoin() {
    return Container(
      decoration: const BoxDecoration(color: kdarkGreyColor),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Coin kazan",
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'poppinsBold',
                      fontSize: 18),
                ),
                Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(8)),
                  height: 35,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          width: 1,
                          color: Colors.grey[700]!,
                        )),
                    child: CupertinoButton(
                      borderRadius: BorderRadius.circular(15),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.transparent,
                      child: const Text(
                        "Reklam",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        try {
                          adManager.loadRewardedAd();
                          adManager.showRewardedAd();
                        } catch (e) {
                          snackbar(
                              "Zaman Aşımı",
                              "Bir hata oluştu lütfen birkaç saniye içinde tekrar deneyin.",
                              true);
                        }
                      },
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showCupertinoModalBottomSheet(
                        backgroundColor: kdarkGreyColor,
                        context: context,
                        builder: (context) => const CoinStore());
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                        borderRadius: kCircleBorderRadius,
                        border: Border.all(width: 0.9, color: Colors.amber)),
                    child: Row(
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        const Icon(
                          CupertinoIcons.money_dollar_circle,
                          color: Colors.amber,
                          size: 20,
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
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                );
                              }
                              return Text(
                                '\t${snapshot.data!.get('coins').toString()}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 15),
                              );
                            }),
                        const SizedBox(
                          width: 5,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 0,
            color: Colors.grey[700],
            thickness: 0.6,
          ),
        ],
      ),
    );
  }

  Center sellerMode() {
    return Center(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Satma modu',
          style: TextStyle(color: Colors.white, fontSize: 19),
        ),
        const SizedBox(
          width: 6,
        ),
        //satma modu
        CupertinoSwitch(
            value: Provider.of<Data>(context).appType,
            onChanged: (val) {
              Provider.of<Data>(context, listen: false).updateAppType(val);
            }),
      ],
    ));
  }

  updateStatus() {
    return StreamBuilder<DocumentSnapshot>(
        stream: usersRef.doc(currentUser.id).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return loading();
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tatil modu',
                style: TextStyle(color: Colors.white, fontSize: 19),
              ),
              const SizedBox(
                width: 6,
              ),
              //update status
              CupertinoSwitch(
                  value: snapshot.data!.get('tripMode'),
                  onChanged: (val) {
                    setState(() {
                      usersRef.doc(currentUser.id).update({"tripMode": val});
                    });
                  }),
            ],
          );
        });
  }

  editProfileButton(User user) {
    return SizedBox(
      height: 35,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
        borderRadius: BorderRadius.circular(230),
        color: Colors.grey[200],
        child: const Text(
          'Profilini Düzenle',
          style: TextStyle(color: Colors.black, fontFamily: 'poppinsBold'),
        ),
        onPressed: () {
          editProfile(context, user);
        },
      ),
    );
  }

  Center followUnfollow() {
    return Center(
      child: SizedBox(
        height: 35,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(200),
              border: isFollowing
                  ? Border.all(color: Colors.grey[600]!)
                  : Border.all()),
          child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
              borderRadius: BorderRadius.circular(230),
              color: isFollowing ? Colors.transparent : Colors.grey[200],
              child: Text(
                isFollowing ? 'Takipten çık' : 'Takip et',
                style: TextStyle(
                    color: isFollowing ? Colors.grey[300] : Colors.black,
                    fontFamily: 'poppinsBold'),
              ),
              onPressed: () {
                if (isFollowing) {
                  handleUnfollow();
                } else {
                  handleFollow();
                }
              }),
        ),
      ),
    );
  }

  Row followersFollowing() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 10,
        ),
        const Text(
          'Takipçiler\t\t',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
        StreamBuilder<QuerySnapshot>(
            stream: followersRef
                .doc(widget.profileId)
                .collection('userFollowers')
                .snapshots(),
            builder: (context, followerCountSnapshot) {
              if (!followerCountSnapshot.hasData) {
                return loading();
              }
              return Text(
                followerCountSnapshot.data!.docs.length.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              );
            }),
        const SizedBox(
          width: 15,
        ),
        const Text(
          'Takip edilen\t\t',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
        StreamBuilder<QuerySnapshot>(
            stream: followingRef
                .doc(widget.profileId)
                .collection('userFollowing')
                .snapshots(),
            builder: (context, followingCountSnapshot) {
              if (!followingCountSnapshot.hasData) {
                return loading();
              }
              return Text(
                followingCountSnapshot.data!.docs.length.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              );
            }),
      ],
    );
  }

  Future? editProfile(BuildContext context, User user) {
    return Get.to(
        () => EditProfile(
              user: user,
            ),
        transition: Transition.downToUp);
  }

  accountDetail(String title, String other, Icon icon) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
              border: Border.all(width: 2, color: Colors.grey[700]!),
              borderRadius: BorderRadius.circular(15)),
          child: Column(
            children: [
              const SizedBox(
                height: 5,
              ),
              icon,
              const SizedBox(
                height: 5,
              ),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 19),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                other,
                style: TextStyle(
                    color: other == 'Online' ? Colors.green : Colors.grey,
                    fontSize: 19,
                    fontFamily: 'poppinsBols'),
              ),
              const SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  StreamBuilder buildProfileProducts() {
    return StreamBuilder<QuerySnapshot>(
        stream: productRef
            .where("approve", isEqualTo: 2)
            .where("vendorId", isEqualTo: widget.profileId)
            .snapshots(),
        builder: (context, snapsshot) {
          if (!snapsshot.hasData) {
            return loading();
          }

          return GridView.builder(
              itemCount: snapsshot.data!.docs.length,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.68,
                  mainAxisSpacing: 20),
              itemBuilder: (context, index) {
                final listOfDocumentSnapshot = snapsshot.data!.docs[index];
                return Product(
                  productId: listOfDocumentSnapshot['productId'],
                  type: listOfDocumentSnapshot['type'],
                  isLoaded: snapsshot.hasData,
                  description: listOfDocumentSnapshot['productDesc'],
                  title: listOfDocumentSnapshot['productTitle'],
                  price: listOfDocumentSnapshot['productPrice'],
                  vendor: listOfDocumentSnapshot['vendorId'],
                  imageUrl: listOfDocumentSnapshot['image'],
                  quantity: listOfDocumentSnapshot['quantity'],
                  approve: listOfDocumentSnapshot['approve'],
                );
              });
        });
  }

  buildProfilePosts() {
    return StreamBuilder(
      stream: postsRef
          .doc(widget.profileId)
          .collection('userPosts')
          .orderBy('timeStamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return loading();
        } else if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 150,
                  child: Lottie.network(
                      "https://assets2.lottiefiles.com/packages/lf20_D6OHyBy8aY.json"),
                ),
                Text(
                  'Henuz post yok',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return Post(
              postId: snapshot.data!.docs[index]['postId'],
              ownerId: snapshot.data!.docs[index]['ownerId'],
              postText: snapshot.data!.docs[index]['postText'],
              mediaUrl: snapshot.data!.docs[index]['mediaUrl'],
              timeStamp: snapshot.data!.docs[index]['timeStamp'],
              likes: snapshot.data!.docs[index]['likes'],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: usersRef.doc(widget.profileId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return loading();
          }
          User user = User.fromDocument(snapshot.data!);

          return CupertinoPageScaffold(
            navigationBar: appBar(user, widget.previousPage),
            child: Center(
              child: Scaffold(
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                floatingActionButton: widget.profileId == currentUser.id
                    ? currentUser.isVendor
                        ? state != 0
                            ? const SizedBox()
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 40,
                                    child: CupertinoButton(
                                      borderRadius: kCircleBorderRadius,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      color: kThemeColor,
                                      child: Row(
                                        children: const [
                                          Icon(Icons
                                              .add_circle_outline_outlined),
                                          SizedBox(
                                            width: 6,
                                          ),
                                          Text(
                                            'Ürün ekle',
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        ],
                                      ),
                                      onPressed: () {
                                        Get.to(
                                            () => CreatePage(
                                                  productId: "",
                                                  imageUrl: "",
                                                  type: "",
                                                  title: "",
                                                  price: "",
                                                  desc: "",
                                                  quantity: -1,
                                                  editing: false,
                                                ),
                                            transition: Transition.downToUp);
                                      },
                                    ),
                                  ),
                                ],
                              )
                        : const SizedBox()
                    : const SizedBox(),
                body: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: buildProfileHeader(user),
                    ),
                    StreamBuilder(
                      stream: usersRef.doc(widget.profileId).snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return loading();
                        }
                        User user = User.fromDocument(snapshot.data!);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            user.isVendor == false
                                ? const Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(20.0, 0, 20, 10),
                                    child: Text(
                                      'Paylaşımlar',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                  )
                                : const SizedBox(),
                            user.isVendor == false
                                ? buildProfilePosts()
                                : const SizedBox(),
                            user.isVendor == false
                                ? const SizedBox()
                                : state == 0
                                    ? buildProfileProducts()
                                    : buildProfilePosts()
                          ],
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  CupertinoNavigationBar appBar(User user, String previousPage) {
    return CupertinoNavigationBar(
      border: Border(bottom: BorderSide(color: Colors.grey[700]!, width: 0.25)),
      trailing: widget.profileId == currentUser.id
          ? CupertinoButton(
              onPressed: () {
                Get.to(() => const SettingsPage(),
                    transition: Transition.cupertino);
              },
              child: const Icon(
                CupertinoIcons.settings,
                color: kThemeColor,
              ))
          : CupertinoButton(
              onPressed: () {
                Get.to(
                    () => ReportPage(
                          user: user,
                        ),
                    transition: Transition.cupertino);
              },
              child: const Icon(
                Icons.report_gmailerrorred_rounded,
                color: kThemeColor,
              )),
      backgroundColor: const Color.fromARGB(255, 16, 16, 16).withOpacity(0.9),
      previousPageTitle: previousPage,
      middle: Text(
        user.username,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  handleFollow() {
    setState(() {
      isFollowing = true;
    });

    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUser.id)
        .set({});
    followingRef
        .doc(currentUser.id)
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});

    notificationsRef
        .doc(widget.profileId)
        .collection('userNotifications')
        .doc(currentUser.id)
        .set({
      "type": 'follow',
      "title": "Yeni Takip",
      "subTitle": '${currentUser.username} seni takip ediyor!',
      "userId": currentUser.id,
      "userProfilePicture": currentUser.photoUrl,
      "timestamp": DateTime.now(),
    });
  }

  handleUnfollow() {
    setState(() {
      isFollowing = false;
    });

    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUser.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    followingRef
        .doc(currentUser.id)
        .collection('userFollowing')
        .doc(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    notificationsRef
        .doc(widget.profileId)
        .collection('userNotifications')
        .doc(currentUser.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }
}

class EditProfile extends StatefulWidget {
  User user;
  EditProfile({
    required this.user,
    super.key,
  });

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  @override
  void initState() {
    usernameController = TextEditingController(text: widget.user.username);
    bioController = TextEditingController(text: widget.user.bio);
    super.initState();
  }

  File? image;
  String url = '';

  Future pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final imageTemporary = File(image.path);
    setState(() => this.image = imageTemporary);
  }

  Future<void> handleDatabase() async {
    final storageImage = FirebaseStorage.instance
        .ref()
        .child('userImages')
        .child('${widget.user.id}.jpg');
    var task = storageImage.putFile(image!);
    url = await (await task.whenComplete(() => null)).ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: CupertinoButton(
          borderRadius: BorderRadius.circular(100),
          color: kThemeColor,
          child: const Text('Kaydet'),
          onPressed: () async {
            try {
              if (image != null) {
                await handleDatabase();
              }

              if (image != null) {
                usersRef.doc(currentUser.id).update({
                  "username": usernameController.text,
                  "bio": bioController.text,
                  "photoUrl": url.toString(),
                });
              } else {
                usersRef.doc(currentUser.id).update({
                  "username": usernameController.text,
                  "bio": bioController.text,
                });
              }
              Get.back();
            } catch (e) {
              snackbar('Hata',
                  'Bir hata oluştu. lütfen daha sonra tekrar deneyin', true);
            }
          }),
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          Container(
            color: const Color.fromARGB(255, 13, 13, 13),
            height: 55,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Icon(
                      CupertinoIcons.back,
                      color: kThemeColor,
                      size: 29,
                    )),
                const Center(
                  child: Text(
                    'Profilini Düzenle',
                    style: TextStyle(color: Colors.white, fontSize: 19),
                    textAlign: TextAlign.center,
                  ),
                ),
                const CupertinoButton(
                    onPressed: null,
                    child: Icon(
                      CupertinoIcons.back,
                      color: Colors.transparent,
                      size: 29,
                    )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: () {
                      pickImage();
                    },
                    // onTap: pickImage,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: image != null
                          ? Image.file(
                              image!,
                              fit: BoxFit.cover,
                              height: 120,
                              width: 120,
                            )
                          : Image.network(
                              widget.user.photoUrl,
                              fit: BoxFit.cover,
                              height: 120,
                              width: 120,
                            ),
                    ),
                  ),
                  Positioned(
                      bottom: -5,
                      right: -5,
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.grey[900],
                        child: const Icon(
                          CupertinoIcons.camera,
                          color: kThemeColor,
                          size: 29,
                        ),
                      ))
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            child: Column(
              children: [
                CupertinoTextFormFieldRow(
                  maxLength: 15,
                  style: const TextStyle(color: Colors.white),
                  controller: usernameController,
                  placeholder: 'Kullanıcı Adı',
                  placeholderStyle: const TextStyle(color: Colors.grey),
                  prefix: const Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Icon(
                      CupertinoIcons.profile_circled,
                      color: kThemeColor,
                    ),
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: kdarkGreyColor),
                ),
                CupertinoTextFormFieldRow(
                  maxLength: 50,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  controller: bioController,
                  placeholder: 'Bio',
                  placeholderStyle: const TextStyle(color: Colors.grey),
                  prefix: const Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Icon(
                      CupertinoIcons.bookmark,
                      color: kThemeColor,
                    ),
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: kdarkGreyColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Filter extends StatefulWidget {
  const Filter({super.key});

  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  String type = 'Hepsi';
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kdarkGreyColor,
      actions: [
        Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            CupertinoButton(
                color: kThemeColor,
                borderRadius: BorderRadius.circular(100),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: const Text('Tamam'),
                onPressed: () {
                  Navigator.of(context).pop(type);
                }),
          ],
        )
      ],
      title: const Text(
        'Sırala',
        style: TextStyle(color: Colors.white),
      ),
      content: Padding(
        padding: const EdgeInsets.only(left: 2.0),
        child: Wrap(
          runSpacing: 0,
          clipBehavior: Clip.none,
          alignment: WrapAlignment.start,
          children: types.map((e) => typeItem(e)).toList(),
        ),
      ),
    );
  }

  Padding typeItem(List e) {
    return Padding(
      padding: const EdgeInsets.only(right: 5.0),
      child: FilterChip(
          onSelected: (val) {
            for (var i = 0; i < types.length; i++) {
              setState(() {
                types[i][1] = false;
              });

              setState(() {
                type = e[0];
                e[1] = val;
              });
            }
          },
          backgroundColor: e[1] ? kThemeColor : Colors.grey[800],
          label: Text(
            e[0],
            style: const TextStyle(color: Colors.white),
          )),
    );
  }
}

class ReportPage extends StatefulWidget {
  User user;
  ReportPage({super.key, required this.user});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  TextEditingController descController = TextEditingController();
  String cause = "";
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: kBackgroundColor,
      navigationBar: appBar(),
      child: Material(
        color: Colors.transparent,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 35,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: crimes.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            for (var i = 0; i < crimes.length; i++) {
                              setState(() {
                                crimes[i][1] = false;
                              });
                            }
                            setState(() {
                              crimes[index][1] = true;
                              cause = crimes[index][0];
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            margin: const EdgeInsets.only(right: 5),
                            decoration: BoxDecoration(
                                color: crimes[index][1]
                                    ? kThemeColor
                                    : kdarkGreyColor,
                                borderRadius: kCircleBorderRadius),
                            child: Center(
                                child: Text(
                              crimes[index][0],
                              style: const TextStyle(color: Colors.white),
                            )),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  CupertinoTextField(
                    style: const TextStyle(color: Colors.white),
                    controller: descController,
                    maxLines: 5,
                    placeholder: 'Açıklama',
                    placeholderStyle: const TextStyle(color: Colors.grey),
                    decoration: BoxDecoration(
                      color: kdarkGreyColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 48,
                    child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        borderRadius: BorderRadius.circular(14),
                        color: kThemeColor,
                        child: const Text(
                          'Şikayet Et',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          try {
                            String reportId = const Uuid().v4();
                            if (descController.text.isNotEmpty && cause != "") {
                              reportsRef.doc(reportId).set({
                                "reportId": reportId,
                                "cause": cause,
                                "reportDesc": descController.text,
                                "guiltyId": widget.user.id,
                              });
                              Get.back();

                              snackbar(
                                  'Başarı',
                                  'Şikayetiniz için teşekkürler. İlgileneceğiz...',
                                  false);
                            } else {
                              snackbar(
                                  'Hata', 'Lütfen açıklamayı doldurun.', true);
                            }
                          } catch (e) {
                            snackbar(
                                'Hata',
                                'Bir hata oluştu. Lütfen daha sonra tekrar deneyin',
                                true);
                          }
                        }),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  CupertinoNavigationBar appBar() {
    return CupertinoNavigationBar(
      border: const Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey, width: 0.25)),
      backgroundColor: const Color.fromARGB(255, 19, 19, 19).withOpacity(0.9),
      middle: Text(
        widget.user.username,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

List crimes = [
  ['Uygunsuz hesap', false],
  ['Uygunsuz ürünler', false],
  ['Uygunsuz postlar', false],
];
