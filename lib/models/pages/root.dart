import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '/widgets/loading.dart';
import '/widgets/snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
// import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';
import '/constants.dart';
import '/models/pages/account.dart';
import '/models/pages/home.dart';
import '/models/pages/messages.dart';
import '/models/pages/orders.dart';
import '/models/pages/search.dart';
import '/models/pages/vendor_page.dart';
import '../user_model.dart';
import '../../provider/data.dart';
import 'approve.dart';
import 'create.dart';
import 'deliverer_page.dart';
class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

final checkForUpdateRef = FirebaseFirestore.instance.collection('updates');
final vendorAppliesRef = FirebaseFirestore.instance.collection('vendorApplies');
final suggestionsRef = FirebaseFirestore.instance.collection('suggestions');
final coinsRef = FirebaseFirestore.instance.collection('coins');
final timelineRef = FirebaseFirestore.instance.collection('timeline');
final reportsRef = FirebaseFirestore.instance.collection('reports');
final Reference storageRefc = FirebaseStorage.instance.ref();
final postsRef = FirebaseFirestore.instance.collection('posts');
final productRef = FirebaseFirestore.instance.collection('products');
final usersRef = FirebaseFirestore.instance.collection('users');
final cartsRef = FirebaseFirestore.instance.collection('carts');
final ordersRef = FirebaseFirestore.instance.collection('orders');
final orderContentsRef = FirebaseFirestore.instance.collection('orderContents');
final messagesRef = FirebaseFirestore.instance.collection('messages');
final notificationsRef = FirebaseFirestore.instance.collection('notifications');
final leaderboardRef = FirebaseFirestore.instance.collection('leaderboard');
final bimRef = FirebaseFirestore.instance.collection('bim');
final followersRef = FirebaseFirestore.instance.collection('followers');
final followingRef = FirebaseFirestore.instance.collection('following');
final commentsRef = FirebaseFirestore.instance.collection('comments');
final deliveriesRef = FirebaseFirestore.instance.collection('deliveries');
final codesRef = FirebaseFirestore.instance.collection('code');
final deliveryFeeRef = FirebaseFirestore.instance.collection('deliveryFee');

final GoogleSignIn googleSignIn = GoogleSignIn(
    // clientId: "256943613795-61ikmuh7kmplsj0cm3lplbqrjgo32kdb.apps.googleusercontent.com"
    );
User currentUser = User(
    id: '',
    username: 'username',
    email: 'email',
    photoUrl: 'photoUrl',
    displayName: 'displayName',
    bio: 'bio',
    rating: 0.0,
    isVendor: false,
    grade: '',
    approve: 1,
    tripMode: false,
    password: '',
    phoneNumber: '',
    schoolNumber: '',
    creation: Timestamp.fromDate(DateTime.now()),
    isDeliverer: false,
    dormNumber: 0,
    dormType: '');

class _RootState extends State<Root> {
  final Connectivity _connectivity = Connectivity();
  bool noInternet = true;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool isAuth = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // _checkNewVersion();
    _connectivity.onConnectivityChanged.listen((event) {
      if (event == ConnectivityResult.none) {
        setState(() {
          noInternet = true;
        });
      } else {
        setState(() {
          noInternet = false;
        });
      }
    });
    googleSignIn.onCurrentUserChanged.listen(
      (account) {
        handleSignIn(account);
      },
      onError: (err) {
        //print('error signing : ' + err);
      },
    );
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      //print('error signing : ' + err);
    });
  }

  handleSignIn(account) async {
    if (account != null) {
      await createUserInFirestore();
      //print('user signed in $account');
      setState(() {
        isAuth = true;
      });
      configurePushNotifications();
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  configurePushNotifications() {
    final GoogleSignInAccount user = googleSignIn.currentUser!;
    if (Platform.isIOS) getiOSPermission();

    _firebaseMessaging.getToken().then((token) {
      print("Firebase Messaging Token: $token\n");
      usersRef.doc(user.id).update({"androidNotificationToken": token});
    });

    // FirebaseMessaging.instance.getInitialMessage().then((remoteMessage) {
    //   final String recipientId = remoteMessage!.senderId!;
    //   if (recipientId == user.id) {
    //     //print('Notification shown');
    //     //print('smrttthhhhheddfpwefns.df shown');

    //     // Get.snackbar("Bildirim",
    //     //     "${remoteMessage.notification!.body}",
    //     //     snackPosition: SnackPosition.TOP,
    //     //     icon: const Icon(
    //     //       CupertinoIcons.bell,
    //     //       color: kThemeColor,
    //     //       size: 28,
    //     //     ),
    //     //     borderWidth: 1.2,
    //     //     borderColor: kThemeColor,
    //     //     colorText: Colors.white,
    //     //     backgroundColor: Colors.black.withOpacity(0.8));
    //   } else {
    //     //print("Notification not shown");
    //   }
    // });
    // FirebaseMessaging.onMessage.listen((remoteMessage) {
    //   final String recipientId = remoteMessage.senderId!;
    //   if (recipientId == user.id) {
    //     //print('Notification shown');
    //     //print('smrttthhhhheddfpwefns.df shown');

    //     // Get.snackbar("${remoteMessage.notification!.title}",
    //     //     "${remoteMessage.notification!.body}",
    //     //     snackPosition: SnackPosition.TOP,
    //     //     icon: const Icon(
    //     //       CupertinoIcons.cube_box,
    //     //       color: kThemeColor,
    //     //       size: 28,
    //     //     ),
    //     //     borderWidth: 1.2,
    //     //     borderColor: kThemeColor,
    //     //     colorText: Colors.white,
    //     //     backgroundColor: Colors.black.withOpacity(0.8));
    //   } else {
    //     //print("Notification not shown");
    //   }
    // });
    // FirebaseMessaging.onBackgroundMessage((remoteMessage) async {
    //   await Firebase.initializeApp();
    // });
  }

  getiOSPermission() {
    _firebaseMessaging.requestPermission(alert: true, badge: true, sound: true);
  }

  createUserInFirestore() async {
    final GoogleSignInAccount user = googleSignIn.currentUser!;
    final DocumentSnapshot doc = await usersRef.doc(user.id).get();

    if (!doc.exists) {
      final List<String> userData = await Navigator.push(
          context, MaterialPageRoute(builder: ((context) => const SignUp())));
      usersRef.doc(user.id).set({
        "id": user.id,
        "username": userData[0],
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "rating": 0.0,
        "grade": userData[4],
        "isVendor": false,
        "approve": 1,
        "tripMode": false,
        "password": 'list[1],',
        "phoneNumber": 'list[2]',
        "schoolNumber": userData[3],
        "creation": Timestamp.fromDate(DateTime.now()),
        "isDeliverer": false,
        "dormNumber": 0,
        "dormType": ''
      });
    }
    setState(() {
      currentUser = User.fromDocument(doc);
    });
    //print(currentUser.username);
  }

  login() async {
    await googleSignIn.signIn();
  }

  Scaffold buildSignUp() {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          child:
              Image.asset('assets/icon-png-one.png', height: 250, width: 250),
        ),
        const Text(
          'Hoşgeldiniz',
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        const SizedBox(
          height: 30,
        ),
        GestureDetector(
          onTap: login,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/google.png',
                  height: 50,
                  width: 50,
                ),
                const SizedBox(
                  width: 5,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: kThemeColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                      child: Text(
                    'Giriş izni iste',
                    style: TextStyle(color: Colors.white),
                  )),
                ),
              ],
            ),
          ),
        ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    bool isDelivererApp = Provider.of<Data>(context).appType;
    List<Widget> screens = [
      const Home(),
      const Search(),
      const Orders(),
      const Messages(),
      Account(
        profileId: currentUser.id,
        previousPage: '',
      ),
    ];

    List<Widget> admin = [
      const Home(),
      const Search(),
      const Approve(),
      const Messages(),
      Account(
        profileId: currentUser.id,
        previousPage: '',
      ),
    ];
    List<Widget> delivererScreens = [
      isDelivererApp ? const Deliverers() : const Home(),
      const Search(),
      const Orders(),
      const Messages(),
      Account(
        profileId: currentUser.id,
        previousPage: '',
      ),
    ];
    return Scaffold(
      body: noInternet
          ? buildNoInternet()
          : isAuth
              ? StreamBuilder(
                  stream: usersRef.doc(currentUser.id).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return loading();
                    } else {
                      if (snapshot.data!.get('approve') == 2) {
                        if (snapshot.data!.get('isDeliverer')) {
                          return delivererScreens[_currentIndex];
                        } else {
                          return screens[_currentIndex];
                        }
                      } else if (snapshot.data!.get('approve') == 1) {
                        return const UnderReview();
                      } else {
                        return buildRejectedAccount();
                      }
                    }
                  })
              : buildSignUp(),
      bottomNavigationBar: isAuth
          ? currentUser.approve != 2
              ? null
              : currentUser.email == "kazdal@gmail." || currentUser.email == ""
                  ? adminBottomNavBar()
                  : currentUser.isDeliverer
                      ? delivererBottomNavBar()
                      : buyerBottomNavBar()
          : null,
    );
  }

  buildRejectedAccount() {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Lottie.network(
              "https://assets2.lottiefiles.com/packages/lf20_ab0pxvgc.json",
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Hesabiniz uygulama erisimine reddedildi. Lutfen gercek bilgilerinizi girdiginize emin olun.',
                style: TextStyle(color: Colors.red, fontSize: 24),
                textAlign: TextAlign.center,
              ),
            ),
            GestureDetector(
              onTap: () {
                usersRef.doc(currentUser.id).delete();
                login();
              },
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/google.png',
                      height: 50,
                      width: 50,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: kThemeColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                          child: Text(
                        'Tekrar izin iste',
                        style: TextStyle(color: Colors.white),
                      )),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding buildNoInternet() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Container()),
          SizedBox(
              height: 270,
              child: Lottie.asset('assets/no-internet-error.json')),
          Expanded(child: Container()),
          const Text(
            "Lütfen internet bağlantınızı kontrol edin...",
            style: TextStyle(color: Colors.white, fontSize: 22),
            textAlign: TextAlign.center,
          ),
          Expanded(child: Container()),
          CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              color: kThemeColor,
              borderRadius: BorderRadius.circular(19),
              child: const Text('Yenile'),
              onPressed: () {
                initState();
              }),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  buyerBottomNavBar() {
    return Material(
      color: Colors.black,
      child: Container(
        decoration: BoxDecoration(
            border:
                Border(top: BorderSide(color: Colors.grey[600]!, width: 0.65))),
        child: CustomNavigationBar(
          blurEffect: false,
          bubbleCurve: Curves.easeInOutQuad,

          // elevation: 2.0,
          iconSize: 30.0,
          isFloating: false,
          selectedColor: Colors.white,
          unSelectedColor: Colors.grey,
          backgroundColor: Colors.black,
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
              icon: const Icon(CupertinoIcons.doc_on_clipboard),
            ),
            CustomNavigationBarItem(
              icon: const Icon(
                Icons.mail_outline,
              ),
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

  vendorBottomNavBar() {
    return Material(
      color: Colors.black,
      child: Container(
        decoration: BoxDecoration(
            border:
                Border(top: BorderSide(color: Colors.grey[600]!, width: 0.65))),
        child: CustomNavigationBar(
          blurEffect: false,
          bubbleCurve: Curves.easeInOutQuad,

          // elevation: 2.0,
          iconSize: 30.0,
          isFloating: false,
          selectedColor: Colors.white,
          unSelectedColor: Colors.grey,
          backgroundColor: Colors.black,
          strokeColor: Colors.transparent,

          items: [
            CustomNavigationBarItem(
              icon: const Icon(UniconsLine.home_alt),
            ),
            CustomNavigationBarItem(
              icon: const Icon(
                CupertinoIcons.cube_box,
              ),
            ),
            CustomNavigationBarItem(
              icon: const Icon(CupertinoIcons.doc_on_clipboard),
            ),
            CustomNavigationBarItem(
              icon: const Icon(
                Icons.mail_outline,
              ),
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

  delivererBottomNavBar() {
    return Material(
      color: Colors.black,
      child: Container(
        decoration: BoxDecoration(
            border:
                Border(top: BorderSide(color: Colors.grey[600]!, width: 0.65))),
        child: CustomNavigationBar(
          blurEffect: false,
          bubbleCurve: Curves.easeInOutQuad,

          // elevation: 2.0,
          iconSize: 30.0,
          isFloating: false,
          selectedColor: Colors.white,
          unSelectedColor: Colors.grey,
          backgroundColor: Colors.black,
          strokeColor: Colors.transparent,

          items: [
            CustomNavigationBarItem(
              icon: const Icon(
                CupertinoIcons.cube_box,
              ),
            ),
            CustomNavigationBarItem(
              icon: const Icon(
                CupertinoIcons.search,
              ),
            ),
            CustomNavigationBarItem(
              icon: const Icon(CupertinoIcons.doc_on_clipboard),
            ),
            CustomNavigationBarItem(
              icon: const Icon(
                Icons.mail_outline,
              ),
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

  adminBottomNavBar() {
    Material(
      color: Colors.black,
      child: Container(
        decoration: BoxDecoration(
            border:
                Border(top: BorderSide(color: Colors.grey[600]!, width: 0.65))),
        child: CustomNavigationBar(
          blurEffect: false,
          bubbleCurve: Curves.easeInOutQuad,
          // elevation: 2.0,
          iconSize: 30.0,
          isFloating: false,
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
                CupertinoIcons.cube_box,
              ),
            ),
            CustomNavigationBarItem(
              icon: const Icon(
                CupertinoIcons.checkmark,
              ),
            ),
            CustomNavigationBarItem(
              icon: const Icon(
                Icons.mail_outline,
              ),
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

// class Authanticate extends StatefulWidget {
//   const Authanticate({super.key});

//   @override
//   State<Authanticate> createState() => _AuthanticateState();
// }

// class _AuthanticateState extends State<Authanticate> {
//   List userData = [
//     'Kullanıcı Adı',
//     'Şifre',
//     'Telefon Numarası',
//     'Okul numarası'
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           actions: [
//             CupertinoButton(
//                 child: Text('Kaydet'),
//                 onPressed: () {
//                   Navigator.of(context).pop(userData);
//                 })
//           ],
//         ),
//         body: ListView.builder(
//           itemCount: userData.length,
//           itemBuilder: (context, index) {
//             return Padding(
//               padding: const EdgeInsets.only(top: 8.0),
//               child: CupertinoTextField(
//                 placeholder: userData[index],
//                 placeholderStyle: TextStyle(color: Colors.grey),
//                 style: TextStyle(color: Colors.white),
//                 onChanged: (val) {
//                   userData[index] = val;
//                 },
//               ),
//             );
//           },
//         ));
//   }
// }

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // String grade(val) {
  //   switch (val) {
  //     case val:
  //       break;
  //     default:
  //   }
  // }

  List<String> userData = [
    'Kullanıcı Adı',
    'İsim',
    'Soyisim',
    'Okul Numarası',
    'Sınıf'
  ];
  TextEditingController name = TextEditingController();
  TextEditingController surname = TextEditingController();
  TextEditingController schoolNum = TextEditingController();
  String grade = '';
  bool isAdult = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Hesap Oluştur'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: CupertinoButton(
                onPressed: () {
                  // //print(userData);

                  if (name.text.isNotEmpty && surname.text.isNotEmpty) {
                    //print(userData);

                    if (isAdult) {
                      //print(userData);
                      setState(() {
                        userData[0] = name.text.toString();
                        userData[1] = surname.text.toString();
                        userData[3] = schoolNum.text.toString();
                        userData[4] =
                            Provider.of<Data>(context).grade.toString();
                        //print(userData);
                      });

                      Navigator.of(context).pop(userData);
                      //success
                    } else {
                      //print(userData);

                      if (schoolNum.text.isNotEmpty) {
                        setState(() {
                          userData[0] = name.text.toString();
                          userData[1] = surname.text.toString();
                          userData[3] = schoolNum.text.toString();
                          userData[4] =
                              Provider.of<Data>(context, listen: false).grade;
                          //print(userData);
                        });

                        Navigator.of(context).pop(userData);

                        //success
                      } else {
                        // //print(userData);
                        snackbar('Hata',
                            'Lütfen giriş bilgilerinizi gözden geçirin', true);

                        //fail
                      }
                    }
                  }
                },
                child: const Text(
                  'Kaydet',
                  style: TextStyle(fontFamily: 'poppinsBold', fontSize: 16),
                )),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                    child: CupertinoTextField(
                      style: const TextStyle(color: Colors.white),
                      controller: name,
                      decoration: BoxDecoration(
                          color: kdarkGreyColor,
                          borderRadius: BorderRadius.circular(10)),
                      placeholder: 'İsim',
                      placeholderStyle: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 40,
                    child: CupertinoTextField(
                      style: const TextStyle(color: Colors.white),
                      controller: surname,
                      decoration: BoxDecoration(
                          color: kdarkGreyColor,
                          borderRadius: BorderRadius.circular(10)),
                      placeholder: 'Soyisim',
                      placeholderStyle: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: CupertinoTextField(
                            style: const TextStyle(color: Colors.white),
                            controller: schoolNum,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: BoxDecoration(
                                color: kdarkGreyColor,
                                borderRadius: BorderRadius.circular(10)),
                            placeholder: 'Okul Numarası',
                            placeholderStyle:
                                const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: SizedBox(
                        height: 40,
                        child: SizedBox(
                          height: 40,
                          child: GestureDetector(
                            onTap: () async {
                              grade = await showCupertinoModalPopup(
                                  context: context,
                                  builder: (context) => Signing(
                                        adultExists: true,
                                      ));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: kdarkGreyColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  Provider.of<Data>(context).grade,
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 18,
                                      fontFamily: 'poppinsBold'),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ))
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Signing extends StatefulWidget {
  bool adultExists;
  Signing({super.key, required this.adultExists});

  @override
  State<Signing> createState() => _SigningState();
}

class _SigningState extends State<Signing> {
  String sinif = 'Hazırlık';
  String sube = 'A';
  String grade(int? grade, int? subee) {
    setState(() {
      switch (grade) {
        case 0:
          sinif = '5';
          break;
        case 1:
          sinif = '6';
          break;
        case 2:
          sinif = '7';
          break;
        case 3:
          sinif = '8';
          break;
        case 4:
          sinif = 'Hazırlık';
          break;
        case 5:
          sinif = '9';
          break;
        case 6:
          sinif = '10';
          break;
        case 7:
          sinif = '11';
          break;
        case 8:
          sinif = '12';
          break;

        case 9:
          sinif = 'Öğretmen';
          break;
        case 10:
          sinif = 'Öğretmen';
          break;
        default:
          break;
      }
    });

    if (isAdult) {
      return sinif;
    } else {
      return '$sinif-$sube';
    }
  }

  int gradeee = 0;
  int subeee = 0;

  bool isAdult = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kdarkGreyColor,
      height: Get.height / 2,
      child: Row(
        children: [
          Expanded(
            child: CupertinoPicker(
                itemExtent: 64,
                onSelectedItemChanged: (val) {
                  if (val == 9 || val == 10) {
                    setState(() {
                      isAdult = true;
                    });
                  } else {
                    setState(() {
                      isAdult = false;
                    });
                  }
                  setState(() {
                    gradeee = val;
                  });
                  Provider.of<Data>(context, listen: false)
                      .updateGrade(grade(gradeee, subeee));
                },
                children: widget.adultExists ? listForSignUp : listForBecome),
          ),
          isAdult
              ? const SizedBox()
              : Expanded(
                  child: CupertinoPicker(
                    itemExtent: 64,
                    onSelectedItemChanged: (val) {
                      setState(() {
                        switch (val) {
                          case 0:
                            sube = 'A';
                            break;
                          case 1:
                            sube = 'B';
                            break;
                          case 2:
                            sube = 'C';
                            break;
                          case 3:
                            sube = 'D';
                            break;
                          case 4:
                            sube = 'Hafızlık A';
                            break;
                          case 5:
                            sube = 'Hafızlık B';
                            break;

                          default:
                        }
                        setState(() {
                          subeee = val;
                        });
                        Provider.of<Data>(context, listen: false)
                            .updateGrade(grade(gradeee, subeee));
                      });
                    },
                    children: const [
                      Center(
                        child: Text(
                          "A",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Center(
                        child: Text(
                          "B",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Center(
                        child: Text(
                          "C",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Center(
                        child: Text(
                          "D",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Center(
                        child: Text(
                          "Hafızlık A",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Center(
                        child: Text(
                          "Hafızlık B",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}

List<Widget> listForSignUp = [
  const Center(
    child: Center(
        child: Text(
      "5",
      style: TextStyle(color: Colors.white),
    )),
  ),
  const Center(
      child: Text(
    "6",
    style: TextStyle(color: Colors.white),
  )),
  const Center(
      child: Text(
    "7",
    style: TextStyle(color: Colors.white),
  )),
  const Center(
      child: Text(
    "8",
    style: TextStyle(color: Colors.white),
  )),
  const Center(
    child: Center(
        child: Text(
      "Hazırlık",
      style: TextStyle(color: Colors.white),
    )),
  ),
  const Center(
      child: Text(
    "9",
    style: TextStyle(color: Colors.white),
  )),
  const Center(
      child: Text(
    "10",
    style: TextStyle(color: Colors.white),
  )),
  const Center(
      child: Text(
    "11",
    style: TextStyle(color: Colors.white),
  )),
  const Center(
      child: Text(
    "12",
    style: TextStyle(color: Colors.white),
  )),
  const Center(
    child: Text(
      "Belletmen",
      style: TextStyle(color: Colors.white),
    ),
  ),
  const Center(
    child: Text(
      "Öğretmen",
      style: TextStyle(color: Colors.white),
    ),
  ),
];
List<Widget> listForBecome = [
  const Center(
    child: Center(
        child: Text(
      "Hazırlık",
      style: TextStyle(color: Colors.white),
    )),
  ),
  const Center(
      child: Text(
    "9",
    style: TextStyle(color: Colors.white),
  )),
  const Center(
      child: Text(
    "10",
    style: TextStyle(color: Colors.white),
  )),
  const Center(
      child: Text(
    "11",
    style: TextStyle(color: Colors.white),
  )),
  const Center(
      child: Text(
    "12",
    style: TextStyle(color: Colors.white),
  )),
];

class UnderReview extends StatefulWidget {
  const UnderReview({super.key});

  @override
  State<UnderReview> createState() => _UnderReviewState();
}

class _UnderReviewState extends State<UnderReview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Lottie.network(
            "https://assets2.lottiefiles.com/packages/lf20_ab0pxvgc.json",
          ),
          const Text(
            'Hesap bilgileriniz gözden geçiriliyor... (bu işlem uzun süre alabilir)',
            style: TextStyle(color: Colors.white, fontSize: 17),
          ),
        ],
      ),
    );
  }
}
