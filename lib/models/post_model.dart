import 'dart:collection';

import '/widgets/loading.dart';

import '/constants.dart';
import '/models/pages/post_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicons/unicons.dart';
import 'pages/account.dart';
import 'pages/root.dart';
import 'comment_sheet.dart';
import 'user_model.dart';
import 'dart:math';
import 'package:timeago/timeago.dart' as timeago;

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String postText;
  final String mediaUrl;
  final Timestamp timeStamp;
  final dynamic likes;

  const Post({
    super.key,
    required this.postId,
    required this.ownerId,
    required this.postText,
    required this.mediaUrl,
    required this.timeStamp,
    required this.likes,
  });

  // factory Post.fromDocument(DocumentSnapshot doc) {
  //   return Post(
  //     postId: doc['postId'],
  //     ownerId: doc['ownerId'],
  //     username: doc['username'],
  //     postText: doc['postText'],
  //     timeStamp: doc['timeStamp'],
  //     likes: doc['likes'],
  //     mediaUrl: doc['mediaUrl'],
  //   );
  // }

  int getLikeCount(likes) {
    // if no likes, return 0
    if (likes == null) {
      return 0;
    }
    int count = 0;
    // if the key is explicitly set to true, add a like
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
        postId: postId,
        ownerId: ownerId,
        postText: postText,
        timeStamp: timeStamp,
        likes: likes,
        likeCount: getLikeCount(likes),
        mediaUrl: mediaUrl,
      );
}

deletePosts(String postId) async {
  try {
    postsRef
        .doc(currentUser.id)
        .collection('userPosts')
        .doc(postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  } catch (e) {
    //print(e);
  }

  QuerySnapshot notificationsSnapshot = await notificationsRef
      .doc(currentUser.id)
      .collection('userNotifications')
      .where('postId', isEqualTo: postId)
      .get();

  for (var doc in notificationsSnapshot.docs) {
    if (doc.exists) {
      doc.reference.delete();
    }
  }

  QuerySnapshot commentsSnaphot =
      await commentsRef.doc(postId).collection('comments').get();
  for (var doc in commentsSnaphot.docs) {
    if (doc.exists) {
      doc.reference.delete();
    }
  }
}

class _PostState extends State<Post> {
  final String currentUserId = currentUser.id;
  final String postId;
  final String ownerId;
  final String postText;
  final String mediaUrl;
  final Timestamp timeStamp;
  int likeCount;
  Map likes;
  bool? isLiked;

  bool isTapped = false;

  _PostState({
    required this.postId,
    required this.ownerId,
    required this.postText,
    required this.timeStamp,
    required this.likes,
    required this.likeCount,
    required this.mediaUrl,
  });

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);
    return buildPostText();
  }

  List<DropdownMenuItem<String>>? items() {
    return [
      DropdownMenuItem(
        onTap: () async {
          await deletePosts(postId);
        },
        value: 'Delete',
        child: const Text(
          'Delete',
          style: TextStyle(color: Colors.red),
        ),
      ),
      const DropdownMenuItem(
        value: 'Cancel',
        child: Text(
          'Cancel',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    ];
  }

  handleLikePost() {
    bool isliked = likes[currentUserId] == true;
    if (isliked) {
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({"likes.$currentUserId": false});
      removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!isliked) {
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({"likes.$currentUserId": true});
      // addLikeToActivityFeed();
      bool isNotPostOwner = ownerId != currentUserId;
      if (isNotPostOwner) {
        notificationsRef
            .doc(ownerId)
            .collection('userNotifications')
            .doc(postId)
            .set({
          "type": "like",
          "username": currentUser.username,
          "userId": currentUser.id,
          "subTitle": "${currentUser.username} postunu begendi!",
          "title": "Yeni begeni",
          "userProfilePicture": currentUser.photoUrl,
          "postId": postId,
          "timestamp": DateTime.now(),
        });
      }
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotOwner = currentUserId != ownerId;
    if (isNotOwner) {
      notificationsRef
          .doc(ownerId)
          .collection('userNotifications')
          .doc(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

//   String formatter = DateFormat('dd MMM yyyy').format(timeStamp.toDate());

// DateTime.fromMicrosecondsSinceEpoch(timeStamp.microsecondsSinceEpoch);

  buildPostText() {
    String? value;
    return FutureBuilder<DocumentSnapshot>(
        future: usersRef.doc(ownerId).get(),
        builder: ((context, snapshot) {
          if (!snapshot.hasData) {
            return loading();
          }
          User user = User.fromDocument(snapshot.data!);
          return GestureDetector(
              onTap: () {
                Get.to(
                    () => PostDetails(
                          postId: postId,
                          userId: user.id,
                        ),
                    transition: Transition.cupertino);
              },
              child: Container(
                decoration: const BoxDecoration(
                    border: Border.symmetric(
                        horizontal:
                            BorderSide(color: Colors.grey, width: 0.25))),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 15, top: 15, bottom: 15, right: 15),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showProfile(profileId: ownerId);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(7),
                                      child: Image.network(
                                        user.photoUrl,
                                        height: 45,
                                        width: 45,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.username,
                                          style: const TextStyle(
                                              fontSize: 17,
                                              color: Colors.white,
                                              fontFamily: 'poppinsBold'),
                                        ),
                                        Text(timeago.format(timeStamp.toDate()),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              ownerId == currentUserId
                                  ? DropdownButton<String>(
                                      onTap: () {},
                                      underline: const SizedBox(),
                                      dropdownColor: Colors.grey[900],
                                      borderRadius: BorderRadius.circular(10),
                                      icon: const Icon(
                                        Icons.more_horiz,
                                        color: Colors.grey,
                                      ),
                                      items: items(),
                                      onChanged: (val) => setState(() {
                                            if (val == 'Delete') {
                                              deletePosts(postId);
                                            }
                                            val = value;
                                          }))
                                  : const SizedBox(),
                              // const Icon(
                              //   Icons.more_horiz,
                              //   color: Colors.grey,
                              // )
                            ]),
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 20,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                              width: Get.width - 80,
                              child: Text(
                                postText,
                                style: const TextStyle(color: Colors.white),
                                maxLines: 15,
                              ),
                            ),
                          ],
                        ),
                        mediaUrl == ""
                            ? const SizedBox()
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    radius: 20,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Get.to(() => Photo(mediaUrl: mediaUrl));
                                      },
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(7),
                                          child: Image.network(
                                            mediaUrl,
                                            fit: BoxFit.cover,
                                            height: 150,
                                          )),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                ],
                              ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 20,
                            ),
                            SizedBox(
                              width: Get.width - 150,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  StreamBuilder(
                                      stream: postsRef
                                          .doc(widget.ownerId)
                                          .collection('userPosts')
                                          .doc(widget.postId)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          Map likes =
                                              snapshot.data!.data()!['likes'];
                                          bool isLikedFunc() {
                                            if (likes.containsKey(
                                                    currentUser.id) &&
                                                likes[currentUser.id] == true) {
                                              return true;
                                            } else {
                                              return false;
                                            }
                                          }

                                          return GestureDetector(
                                            onTap: () {
                                              handleLikePost();
                                            },
                                            child: Row(
                                              children: [
                                                Icon(
                                                    isLikedFunc()
                                                        ? CupertinoIcons
                                                            .heart_fill
                                                        : CupertinoIcons.heart,
                                                    color: isLikedFunc()
                                                        ? Colors.pink
                                                        : Colors.grey,
                                                    size: 21),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                    widget
                                                        .getLikeCount(likes)
                                                        .toString(),
                                                    style: TextStyle(
                                                      color: isLikedFunc()
                                                          ? Colors.pink
                                                          : Colors.white,
                                                    )),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return loading();
                                        }
                                      }),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            showModalBottomSheet(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 15, 15, 15),
                                                isScrollControlled: true,
                                                context: context,
                                                builder: (context) => Comments(
                                                      postId: postId,
                                                      postOwnerId: ownerId,
                                                      postText: postText,
                                                      postOwnerUsername:
                                                          user.username,
                                                    ));
                                          },
                                          child: Transform(
                                            alignment: Alignment.center,
                                            transform: Matrix4.rotationY(pi),
                                            child: const Icon(
                                              UniconsLine.comment,
                                              color: Colors.grey,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        StreamBuilder<QuerySnapshot>(
                                            stream: commentsRef
                                                .doc(postId)
                                                .collection('comments')
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) {
                                                return loading();
                                              }
                                              return Text(
                                                  snapshot.data!.docs.length
                                                      .toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ));
                                            })
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  GestureDetector(
                                      onTap: () {},
                                      child: const Icon(FeatherIcons.share,
                                          color: Colors.white70, size: 19)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ]),
                ),
              ));
        }));
  }

  buildMenuItem<String>(String item) {
    DropdownMenuItem(
      value: item,
      child: Row(
        children: [
          Text(
            item.toString(),
            style: TextStyle(
                color: item == 'Delete' ? Colors.red : Colors.white70),
          ),
          Icon(
            item == 'Delete' ? CupertinoIcons.delete : CupertinoIcons.clear,
            color: item == 'Delete' ? Colors.red : Colors.white70,
          )
        ],
      ),
    );
  }
}

showProfile({profileId}) {
  Get.to(() => Account(
        profileId: profileId,
        previousPage: 'Post',
      ));
}

buildButton(String type) {
  return GestureDetector(
    onTap: () {
      if (type == "back") {
        Get.back();
      }
    },
    child: CircleAvatar(
      radius: 15,
      backgroundColor: kdarkGreyColor,
      child: Center(
          child: Icon(
        type == "back" ? FeatherIcons.arrowLeft : FeatherIcons.share2,
        color: Colors.white,
        size: 16,
      )),
    ),
  );
}

class Photo extends StatelessWidget {
  String mediaUrl;
  Photo({super.key, required this.mediaUrl});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Image.network(
              mediaUrl,
              width: Get.width,
              height: Get.height,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 15,
              left: 15,
              child: buildButton("back"),
            ),
            Positioned(
              top: 15,
              right: 15,
              child: buildButton("share"),
            )
          ],
        ),
      ),
    );
  }
}
