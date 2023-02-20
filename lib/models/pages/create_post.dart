import 'dart:io';
import '/widgets/snackbar.dart';

import '/constants.dart';
import '/models/pages/root.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:firebase_storage/firebase_storage.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({Key? key}) : super(key: key);

  @override
  State<CreatePost> createState() => _CreatePostState();
}

TextEditingController tweetController = TextEditingController();
List<File> images = [];

class _CreatePostState extends State<CreatePost> {
  String audienceTxt = 'herkes';
  List audience = [
    [0, true], //everyone
    [1, false], //school
    [2, false] //students
  ];
  String url = "";
  File? image;
  bool isActive = false;

  Future pickImage() async {
    final imageFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (imageFile == null) return;

    final imageTemporary = File(imageFile.path);
    setState(() {
      image = imageTemporary;
    });
  }

  // buildPickImage(context) async {
  //   final storageImage =
  //       FirebaseStorage.instance.ref().child('postImages').child('$postId.jpg');
  //   var task = storageImage.putFile(image!);
  //   setState(() async {
  //     url = await (await task.whenComplete(() => null)).ref.getDownloadURL();
  //     if (url == "") {
  //       setState(() {
  //         url == 'error';
  //       });
  //     }
  //   });
  // }
  Future<void> handleImage(String postId) async {
    final storageImage =
        FirebaseStorage.instance.ref().child('postImages').child('$postId.jpg');
    var task = storageImage.putFile(image!);
    url = await (await task.whenComplete(() => null)).ref.getDownloadURL();
    postsRef.doc(currentUser.id).collection('userPosts').doc(postId).update({
      "mediaUrl": url.toString(),
    });
  }

  createPost({
    required String tweet,
    required String postId,
  }) async {
    if (image != null) {
      postsRef.doc(currentUser.id).collection('userPosts').doc(postId).set({
        'postId': postId,
        'ownerId': currentUser.id,
        'username': currentUser.username,
        'postText': tweet,
        'mediaUrl': '',
        'timeStamp': DateTime.now(),
        'likes': {},
      });
      await handleImage(postId);
    } else {
      postsRef.doc(currentUser.id).collection('userPosts').doc(postId).set({
        'postId': postId,
        'ownerId': currentUser.id,
        'username': currentUser.username,
        'postText': tweet,
        'timeStamp': DateTime.now(),
        'mediaUrl': '',
        'likes': {},
      });
    }
  }

  Future<String> uploadImage(File image, String postId) async {
    UploadTask uploadTask =
        storageRefc.child("post_$postId.jpg").putFile(image);
    TaskSnapshot storageSnap = await uploadTask;
    url = await storageSnap.ref.getDownloadURL();
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white, fontSize: 17),
                    )),
                SizedBox(
                  height: 32,
                  child: CupertinoButton(
                      color: isActive == true
                          ? kThemeColor
                          : kThemeColor.withOpacity(0.4),
                      // shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                      // ),
                      padding: const EdgeInsets.symmetric(horizontal: 17),
                      onPressed: () {
                        String postId = const Uuid().v4();
                        try {
                          if (isActive == true) {
                            createPost(
                              tweet: tweetController.text,
                              postId: postId,
                            );

                            tweetController.clear();
                            images.clear();
                            setState(() {
                              image = null;
                            });

                            Get.back();
                            Get.back();
                          }
                        } catch (e) {
                          snackbar(
                              "Hata",
                              "Beklenmeyen bir hata oluştu. Daha sonra tekrar deneyin",
                              true);
                        }
                      },
                      child: Text(
                        'Done',
                        style: TextStyle(
                            color: isActive == true
                                ? Colors.white
                                : kThemeColor.withOpacity(0.5),
                            fontSize: 17),
                      )),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(200),
                  child: Image.network(
                    currentUser.photoUrl,
                    fit: BoxFit.fill,
                    height: 40,
                    width: 40,
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                GestureDetector(
                  onTap: () {
                    showCupertinoModalBottomSheet(
                        backgroundColor: kdarkGreyColor,
                        context: context,
                        builder: (context) => Material(
                              color: Colors.transparent,
                              child: StatefulBuilder(
                                  builder: (context, setModalState) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Audience(
                                      title: 'Herkes',
                                      subTitle:
                                          'Uygulamada kayitli herkes gorebilir',
                                      color: Colors.blue,
                                      icon: const Icon(
                                        FeatherIcons.globe,
                                        color: Colors.white,
                                      ),
                                      isActive: audience[0][1],
                                      onTap: () {
                                        setModalState(() {
                                          audience[2][1] = false;
                                          audience[1][1] = false;
                                          audience[0][1] = true;
                                        });
                                        audienceText();
                                        Get.back();
                                      },
                                    ),
                                    Audience(
                                      title: 'Okul',
                                      subTitle:
                                          'Sadece senin okulunda kayitli kisiler gorebilir (ogretmenler dahil)',
                                      color: Colors.amber,
                                      icon: const Icon(
                                        CupertinoIcons.book,
                                        color: Colors.white,
                                      ),
                                      isActive: audience[1][1],
                                      onTap: () {
                                        setModalState(() {
                                          audience[0][1] = false;
                                          audience[2][1] = false;
                                          audience[1][1] = true;
                                        });
                                        audienceText();

                                        Get.back();
                                      },
                                    ),
                                    Audience(
                                      title: 'Ogrenciler',
                                      subTitle: 'Sadece ogrenciler gorebilir',
                                      color: Colors.green,
                                      icon: const Icon(
                                        Icons.school_outlined,
                                        color: Colors.white,
                                      ),
                                      isActive: audience[2][1],
                                      onTap: () {
                                        setModalState(() {
                                          audience[0][1] = false;
                                          audience[1][1] = false;
                                          audience[2][1] = true;
                                        });
                                        audienceText();
                                        Get.back();
                                      },
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                );
                              }),
                            ));
                  },
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: kThemeColor),
                        borderRadius: BorderRadius.circular(200)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          audienceTxt,
                          style: const TextStyle(
                              color: kThemeColor,
                              fontFamily: 'poppinsBold',
                              fontSize: 16),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: kThemeColor,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: CupertinoTextField(
              controller: tweetController,
              onChanged: (input) {
                if (tweetController.text != '') {
                  setState(() {
                    isActive = true;
                  });
                } else {
                  setState(() {
                    isActive = false;
                  });
                }
              },
              inputFormatters: [
                FilteringTextInputFormatter.singleLineFormatter
              ],
              minLines: 1,
              maxLines: 12,
              maxLength: 400,
              style: const TextStyle(color: Colors.white),
              decoration: const BoxDecoration(color: Colors.transparent),
              placeholder: 'Aklından ne geçiyor?',
              placeholderStyle: const TextStyle(color: Colors.white70),
            ),
          ),
          image == null
              ? const SizedBox()
              : Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.35, color: Colors.grey[600]!),
                      borderRadius: BorderRadius.circular(5)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.file(
                      image!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
          const SizedBox(
            height: 60,
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: Get.width,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0),
            color: kdarkGreyColor,
          ),
          child: Row(children: [
            IconButton(
                onPressed: () {
                  if (image == null) {
                    pickImage();
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              backgroundColor: kdarkGreyColor,
                              title: const Text(
                                'Yalnızca bir resim ekleyebilirsiniz',
                                style: TextStyle(color: Colors.white),
                              ),
                              actions: [
                                CupertinoButton(
                                    color: kThemeColor,
                                    child: const Text('Geri'),
                                    onPressed: () {
                                      Get.back();
                                    })
                              ],
                            ));
                  }
                },
                icon: const Icon(
                  FeatherIcons.image,
                  color: Colors.grey,
                )),
          ]),
        ),
      ),
    );
  }

  audienceText() {
    if (audience[0][1]) {
      setState(() {
        audienceTxt = 'herkes';
      });
    } else if (audience[1][1]) {
      setState(() {
        audienceTxt = 'okul';
      });
    } else if (audience[2][1]) {
      setState(() {
        audienceTxt = 'ogrenciler';
      });
    } else {
      setState(() {
        audienceTxt = 'hata';
      });
    }
  }
}

class Audience extends StatefulWidget {
  String title;
  String? subTitle;
  Color color;
  Icon icon;
  VoidCallback onTap;
  bool isActive;
  Audience(
      {super.key,
      required this.title,
      required this.color,
      required this.icon,
      required this.onTap,
      required this.isActive,
      this.subTitle});

  @override
  State<Audience> createState() => _AudienceState();
}

class _AudienceState extends State<Audience> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(15),
                    // image: DecorationImage(image: Image.)
                  ),
                  child: Center(child: widget.icon),
                ),
                widget.isActive
                    ? const Positioned(
                        bottom: -7,
                        right: -7,
                        child: CircleAvatar(
                          backgroundColor: kdarkGreyColor,
                          radius: 13,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: kThemeColor,
                            child: Icon(
                              CupertinoIcons.check_mark,
                              size: 14,
                            ),
                          ),
                        ))
                    : const SizedBox()
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  maxLines: 2,
                ),
                SizedBox(
                  width: Get.width - 30 - 10 - 50,
                  child: Text(
                    widget.subTitle!,
                    style: const TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
