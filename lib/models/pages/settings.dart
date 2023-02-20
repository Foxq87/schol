import 'dart:ui';
import 'package:appbeyoglu/models/pages/account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:appbeyoglu/widgets/loading.dart';
import 'package:appbeyoglu/widgets/snackbar.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../provider/data.dart';
import '/models/pages/approve.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/constants.dart';
import '/models/pages/root.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GoogleSignIn googleSignIn = GoogleSignIn(
      
      //clientId: "256943613795-61ikmuh7kmplsj0cm3lplbqrjgo32kdb.apps.googleusercontent.com"
          );
  
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 22,
            )),
      ),
      body: ListView(
        children: [
          settingItem('Kod gir', const EnterCode()),
          const SizedBox(
            height: 10,
          ),
          settingItem('Satıcı ol', const BeVendor()),
          const SizedBox(
            height: 10,
          ),
          settingItem('Kurye ol', const BeShipper()),
          const SizedBox(
            height: 10,
          ),
          currentUser.email == 'ibrhm.oid@gmail.com' ||
                  currentUser.email == 'ardaask54@gmail.com' ||
                  currentUser.email == 'ramadankeremucar@gmail.com'
              ? settingItem('Kontrol et', const Approve())
              : const SizedBox(),
          const SizedBox(
            height: 10,
          ),
          currentUser.email == 'ibrhm.oid@gmail.com' ||
                  currentUser.email == 'ardaask54@gmail.com' ||
                  currentUser.email == 'ramadankeremucar@gmail.com'
              ? settingItem('Kullanıcı izinleri', const UserApprove())
              : const SizedBox(),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: CupertinoButton(
                borderRadius: BorderRadius.circular(100),
                color: kThemeColor,
                child: const Text('Log Out'),
                onPressed: () {
                  user.signOut();
                  setState(() {
                    googleSignIn.signOut();

                    Get.to(() => const Root());
                  });
                }),
          )
        ],
      ),
    );
  }

  GestureDetector settingItem(String title, Widget destination) {
    return GestureDetector(
      onTap: () {
        Get.to(() => destination, transition: Transition.cupertino);
      },
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: kdarkGreyColor,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 13,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const Row(
                children: [
                  Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

buildBackButton() {
  return GestureDetector(
    onTap: () {
      Get.back();
    },
    child: const CircleAvatar(
      radius: 15,
      backgroundColor: kdarkGreyColor,
      child: Center(
          child: Icon(
        FeatherIcons.arrowLeft,
        color: Colors.white,
        size: 18,
      )),
    ),
  );
}

class Page1 extends StatefulWidget {
  Page1({super.key});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  TextEditingController nameController =
      TextEditingController(text: currentUser.username);
  TextEditingController lastNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: kThemeColor,
          child: Icon(Icons.arrow_forward),
          onPressed: () {
            Provider.of<Data>(context, listen: false).increaseBeVendorIndex(1);
          }),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 0),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromARGB(255, 0, 43, 79)),
              child: const Center(
                child: Text(
                  'Satıcı olmak için başvur (1)',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'poppinsBold'),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20),
            child: Text(
              'Kişisel bilgiler',
              style: TextStyle(
                  color: Colors.white, fontSize: 19, fontFamily: 'poppinsBold'),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 45,
            child: CupertinoTextField(
              controller: nameController,
              placeholder: 'İsim',
              placeholderStyle: TextStyle(color: Colors.grey),
              style: TextStyle(color: Colors.white),
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey),
                  borderRadius: BorderRadius.circular(15),
                  color: kdarkGreyColor),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 45,
            child: CupertinoTextField(
              controller: lastNameController,
              placeholder: 'Soyisim',
              placeholderStyle: TextStyle(color: Colors.grey),
              style: TextStyle(color: Colors.white),
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey),
                  borderRadius: BorderRadius.circular(15),
                  color: kdarkGreyColor),
            ),
          ),
        ],
      ),
    );
  }
}

class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: kThemeColor,
          child: Icon(Icons.arrow_forward),
          onPressed: () {
            Provider.of<Data>(context, listen: false).increaseBeVendorIndex(1);
          }),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 0),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromARGB(255, 0, 43, 79)),
              child: const Center(
                child: Text(
                  'Satıcı olmak için başvur (2/2)',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'poppinsBold'),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20),
            child: Text(
              'Anlaşmalar',
              style: TextStyle(
                  color: Colors.white, fontSize: 19, fontFamily: 'poppinsBold'),
              textAlign: TextAlign.center,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: agreements.length,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return agreementItem(index + 1, agreements[index]);
            },
          ),
        ],
      ),
    );
  }
}

List<String> agreements = ['Sigara vb. gibi ürünler satmak','Siparişi onayladığın halde ürünlerini hazırlamamak',''];

agreementItem(int number, String agreement) {
  return Row(
    children: [
      Text(
        number.toString(),
        style: TextStyle(color: kThemeColor),
      ),
      Text(
        agreement,
        style: TextStyle(color: Colors.white),
      ),
    ],
  );
}

class EnterCode extends StatefulWidget {
  const EnterCode({super.key});

  @override
  State<EnterCode> createState() => _EnterCodeState();
}

class _EnterCodeState extends State<EnterCode> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: CupertinoButton(
          color: kThemeColor,
          borderRadius: BorderRadius.circular(15),
          child: const Text(
            'Tamam',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {}),
      appBar: AppBar(
        title: const Text(
          'Kod gir',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OTPTextField(
            length: 5,
            width: MediaQuery.of(context).size.width,
            fieldWidth: 50,
            otpFieldStyle: OtpFieldStyle(
              borderColor: Colors.grey,
              focusBorderColor: Colors.grey,
              disabledBorderColor: Colors.grey,
              enabledBorderColor: Colors.grey,
              errorBorderColor: Colors.grey,
            ),
            style: const TextStyle(fontSize: 17, color: Colors.white),
            textFieldAlignment: MainAxisAlignment.spaceAround,
            fieldStyle: FieldStyle.box,
            onCompleted: (pin) {
              print("Completed: " + pin);
              codesRef.get().then((doc) {
                doc.docs.every((element) {
                  if (element.get('code') == pin) {
                    switch (element.id) {
                      case 'isAdmin':
                        usersRef.doc(currentUser.id).update({
                          "isAdmin": true,
                        });
                        break;
                      case 'isDeliverer':
                        if (element.get('maxUsers').length <= 5) {
                          usersRef.doc(currentUser.id).update({
                            "isDeliverer": true,
                          });

                          codesRef.doc(element.id).update({
                            "maxUsers": FieldValue.arrayUnion([currentUser.id]),
                          });
                        } else {
                          snackbar('Hata', 'Bu kod artik aktif degil', true);
                        }
                        break;

                      case 'isController':
                        if (element.get('maxUsers').length <= 5) {
                          usersRef.doc(currentUser.id).update({
                            "isController": true,
                          });

                          codesRef.doc(element.id).update({
                            "maxUsers": FieldValue.arrayUnion([currentUser.id]),
                          });
                        } else {
                          snackbar('Hata', 'Bu kod artik aktif degil', true);
                        }
                        break;
                      default:
                        snackbar('Hata', 'boyle bir kod bulunmuyor', true);
                        break;
                    }
                  }
                  return true;
                });
              });
            },
          ),
        ],
      ),
    );
  }
}

class BeVendor extends StatefulWidget {
  const BeVendor({super.key});

  @override
  State<BeVendor> createState() => _BeVendorState();
}

class _BeVendorState extends State<BeVendor> {
  TextEditingController nameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController schoolNumController = TextEditingController();
  String grade = '';

  List beVendor = [
    Page1(),
    Page2(),
  ];
  PageController pageController = PageController(initialPage: 0);
  @override
  Widget build(BuildContext context) {
    int i = Provider.of<Data>(context).beVendorIndex;

    return StreamBuilder(
        stream: vendorAppliesRef.doc(currentUser.id).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return loading();
          }
          return snapshot.data!.exists == false
              ? PageView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  controller: pageController,
                  itemBuilder: (BuildContext context, int index) {
                    return beVendor[i];
                  },
                )
              : Scaffold(
                  appBar: AppBar(
                    leading: IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: buildBackButton()),
                    title: Text(
                      snapshot.data!.exists
                          ? 'Değerlendiriliyor...'
                          : "Satıcı ol",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  body: snapshot.data!.exists
                      ? Column(
                          children: [
                            Lottie.network(
                              "https://assets2.lottiefiles.com/packages/lf20_ab0pxvgc.json",
                            ),
                            CupertinoButton(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.red,
                                child: const Text(
                                  'Başvuruyu iptal et',
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            backgroundColor: kdarkGreyColor,
                                            title: const Text(
                                              "Başvuru iptali",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            content: Text(
                                              "Başvurunuzu iptal etmek istediğinize emin misiniz?",
                                              style: TextStyle(
                                                  color: Colors.grey[400]),
                                            ),
                                            actions: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                      child: CupertinoButton(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          color: kThemeColor,
                                                          child: const Text(
                                                            'Hayır',
                                                          ),
                                                          onPressed: () {
                                                            Get.back();
                                                          })),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                      child: CupertinoButton(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          color: Colors.red,
                                                          child: const Text(
                                                            'Evet',
                                                          ),
                                                          onPressed: () {
                                                            vendorAppliesRef
                                                                .doc(currentUser
                                                                    .id)
                                                                .delete();
                                                            Get.back();
                                                          })),
                                                ],
                                              ),
                                            ],
                                          ));
                                })
                          ],
                        )
                      : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0, vertical: 15),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 40,
                                    child: CupertinoTextField(
                                      style:
                                          const TextStyle(color: Colors.white),
                                      controller: nameController,
                                      decoration: BoxDecoration(
                                          color: kdarkGreyColor,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      placeholder: 'İsim',
                                      placeholderStyle:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    height: 40,
                                    child: CupertinoTextField(
                                      style:
                                          const TextStyle(color: Colors.white),
                                      controller: lastnameController,
                                      decoration: BoxDecoration(
                                          color: kdarkGreyColor,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      placeholder: 'Soyisim',
                                      placeholderStyle:
                                          const TextStyle(color: Colors.grey),
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
                                            style: const TextStyle(
                                                color: Colors.white),
                                            controller: schoolNumController,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            decoration: BoxDecoration(
                                                color: kdarkGreyColor,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            placeholder: 'Okul Numarası',
                                            placeholderStyle: const TextStyle(
                                                color: Colors.grey),
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
                                              grade =
                                                  await showCupertinoModalPopup(
                                                      context: context,
                                                      builder: (context) =>
                                                          Signing(
                                                            adultExists: false,
                                                          ));
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: kdarkGreyColor,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  Provider.of<Data>(context)
                                                      .grade,
                                                  style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 18,
                                                      fontFamily:
                                                          'poppinsBold'),
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
                            Expanded(child: Container()),
                            Center(
                              child: CupertinoButton(
                                  borderRadius: BorderRadius.circular(20),
                                  color: kThemeColor,
                                  child: const Text('Başvur'),
                                  onPressed: () {
                                    print(nameController.text +
                                        lastnameController.text +
                                        schoolNumController.text +
                                        Provider.of<Data>(context,
                                                listen: false)
                                            .grade);
                                    if (nameController.text.length > 2 &&
                                        nameController.text.length < 50 &&
                                        lastnameController.text.isNotEmpty &&
                                        lastnameController.text.length < 25 &&
                                        schoolNumController.text.length == 4 &&
                                        Provider.of<Data>(context,
                                                listen: false)
                                            .grade
                                            .isNotEmpty) {
                                      try {
                                        vendorAppliesRef
                                            .doc(currentUser.id)
                                            .set({
                                          "userId": currentUser.id,
                                          "name": nameController.text,
                                          "lastName": lastnameController.text,
                                          "schoolNum": schoolNumController.text,
                                          "grade": Provider.of<Data>(context,
                                                  listen: false)
                                              .grade,
                                        });
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                backgroundColor: kdarkGreyColor,
                                                title: const Text(
                                                  "Başvurunuz alındı",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                content: Text(
                                                  "Size geri dönüş sağlayacağız",
                                                  style: TextStyle(
                                                      color: Colors.grey[400]),
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
                                              );
                                            });
                                      } catch (e) {
                                        print(e);
                                      }
                                    } else {
                                      snackbar(
                                          'Hata',
                                          'Lütfen bilgilerinizi doğru bir şekilde doldurduğunuza emin olun',
                                          true);
                                    }
                                  }),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                );
        });
  }
}

class BeShipper extends StatefulWidget {
  const BeShipper({super.key});

  @override
  State<BeShipper> createState() => _BeShipperState();
}

class _BeShipperState extends State<BeShipper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: const [],
      ),
    );
  }
}
