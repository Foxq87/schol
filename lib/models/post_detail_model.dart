import 'package:appbeyoglu/models/post_model.dart';

import '/widgets/loading.dart';

import '/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../pages/account.dart';
import '../pages/root.dart';
import 'comment_sheet.dart';
import 'user_model.dart';

class PostDetail extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String postText;
  final String mediaUrl;
  final Timestamp timeStamp;
  final dynamic likes;

  const PostDetail({
    super.key,
    required this.postId,
    required this.mediaUrl,
    required this.ownerId,
    required this.username,
    required this.postText,
    required this.timeStamp,
    required this.likes,
  });

  // factory PostDetail.fromDocument(DocumentSnapshot doc) {
  //   return PostDetail(
  //     postId: doc['postId'],
  //     ownerId: doc['ownerId'],
  //     username: doc['username'],
  //     postText: doc['postText'],
  //     timeStamp: doc['timeStamp'],
  //     likes: doc['likes'],
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
  // ignore: no_logic_in_create_state
  _PostDetailState createState() => _PostDetailState(
        postId: postId,
        ownerId: ownerId,
        postText: postText,
        timeStamp: timeStamp,
        likes: likes,
        likeCount: getLikeCount(likes),
        mediaUrl: mediaUrl,
      );
}

class _PostDetailState extends State<PostDetail> {
  final String postId;
  final String mediaUrl;
  final String ownerId;
  final String postText;
  final Timestamp timeStamp;
  int likeCount;
  Map likes;
  bool? isLiked;

  FocusNode focusNode = FocusNode();

  bool isActive = false;

  bool isKeyboardActive = false;

  _PostDetailState({
    required this.postId,
    required this.mediaUrl,
    required this.ownerId,
    required this.postText,
    required this.timeStamp,
    required this.likes,
    required this.likeCount,
  });
  @override
  void initState() {
    formatTimestamp();
    super.initState();
  }

  String formatted = 'error';
  formatTimestamp() {
    formatted = DateFormat('HH:mm · dd.MM.yyyy').format(timeStamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUser.id] == true);
    return Scaffold(
      body: buildPostText(),
    );
  }

  handleLikePost() {
    bool isliked = likes[currentUser.id] == true;
    if (isliked) {
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({"likes.${currentUser.id}": false});
      exploreRef.doc(postId).update({"likes.${currentUser.id}": false});

      removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUser.id] = false;
      });
    } else if (!isliked) {
      postsRef
          .doc(ownerId)
          .collection('userPosts')
          .doc(postId)
          .update({"likes.${currentUser.id}": true});
      exploreRef.doc(postId).update({"likes.${currentUser.id}": true});

      // addLikeToActivityFeed();
      bool isNotPostOwner = ownerId != currentUser.id;
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
        likes[currentUser.id] = true;
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotOwner = currentUser.id != ownerId;
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
  buildBackButton() {
    return GestureDetector(
      onTap: () {
        Get.back();
      },
      child: const Center(
          child: Icon(
        FeatherIcons.arrowLeft,
        color: Colors.white,
        size: 18,
      )),
    );
  }

  buildComments() {
    return StreamBuilder<QuerySnapshot>(
      stream: commentsRef
          .doc(postId)
          .collection('comments')
          .orderBy("timeStamp", descending: false)
          .snapshots(),
      builder: ((context, snapshot) {
        if (!snapshot.hasData) {
          return loading();
        }
        List<Comment> comments = [];
        for (var doc in snapshot.data!.docs) {
          comments.add(Comment(
            commenterId: doc['commenterId'],
            ownerId: doc['ownerId'],
            comment: doc['comment'],
            timeStamp: doc['timeStamp'],
          ));
        }
        return Column(
          children: comments,
        );
      }),
    );
  }

  addComment() {
    commentsRef.doc(postId).collection('comments').add({
      "ownerId": ownerId,
      "comment": commentTextController.text,
      "timeStamp": DateTime.now(),
      "commenterId": currentUser.id
    });
    bool isNotPostOwner = ownerId != currentUser.id;
    if (isNotPostOwner) {
      notificationsRef.doc(ownerId).collection('userNotifications').add({
        "type": "comment",
        "title": "${currentUser.username} yorum yazdı:",
        "subTitle": commentTextController.text,
        "userId": currentUser.id,
        "userProfilePicture": currentUser.photoUrl,
        "postId": postId,
        "timestamp": DateTime.now(),
        "username": currentUser.username,
      });
    }

    commentTextController.clear();
  }

  buildPostText() {
    return FutureBuilder<DocumentSnapshot>(
        future: usersRef.doc(ownerId).get(),
        builder: ((context, snapshot) {
          if (!snapshot.hasData) {
            return loading();
          }
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: buildBackButton(),
              ),
              title: const Text(
                'Post',
                style: TextStyle(fontFamily: 'poppinsBold', fontSize: 17),
              ),
              centerTitle: true,
              elevation: 0,
            ),
            body: FutureBuilder<DocumentSnapshot>(
                future: usersRef.doc(ownerId).get(),
                builder: ((context, snapshot) {
                  if (!snapshot.hasData) {
                    return loading();
                  }
                  User user = User.fromDocument(snapshot.data!);

                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Stack(
                      children: [
                        ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      showProfile(profileId: ownerId);
                                    },
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundImage:
                                              NetworkImage(user.photoUrl),
                                        ),
                                        const SizedBox(
                                          width: 7,
                                        ),
                                        Text(
                                          user.username,
                                          style: const TextStyle(
                                              fontFamily: 'poppinsBold',
                                              fontSize: 19,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.more_horiz,
                                        color: Colors.grey,
                                      ))
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10),
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      postText,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 19),
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    mediaUrl == ""
                                        ? const SizedBox()
                                        : Column(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Get.to(() => Photo(
                                                      mediaUrl: mediaUrl));
                                                },
                                                child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7),
                                                    child: Image.network(
                                                      mediaUrl,
                                                      fit: BoxFit.cover,
                                                      height: 180,
                                                      width: Get.width,
                                                    )),
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              )
                                            ],
                                          ),
                                    Text(
                                      formatted,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                decoration: const BoxDecoration(
                                    border: Border.symmetric(
                                        horizontal: BorderSide(
                                            width: 0.25, color: Colors.grey))),
                                height: 40,
                                child: Row(children: [
                                  Text(
                                      widget
                                          .getLikeCount(widget.likes)
                                          .toString(),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'poppinsBold',
                                          fontSize: 18)),
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  const Text(
                                    'Likes',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(
                                    width: 15,
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
                                                fontSize: 18,
                                                fontFamily: 'poppinsBold'));
                                      }),
                                  const SizedBox(
                                    width: 7,
                                  ),
                                  const Text(
                                    'Comments',
                                    style: TextStyle(color: Colors.grey),
                                  )
                                ]),
                              ),
                            ),
                            SizedBox(
                              height: 50,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 9),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            handleLikePost();
                                          },
                                          child: Icon(
                                              isLiked!
                                                  ? CupertinoIcons.heart_fill
                                                  : CupertinoIcons.heart,
                                              color: isLiked!
                                                  ? Colors.pink
                                                  : Colors.grey,
                                              size: 27),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        focusNode.requestFocus();
                                        // showModalBottomSheet(
                                        //     backgroundColor: kBackgroundColor,
                                        //     isScrollControlled: true,
                                        //     context: context,
                                        //     builder: (context) => Comments(
                                        //           postId: postId,
                                        //           postOwnerId: ownerId,
                                        //           postText: postText,
                                        //           postOwnerUsername:
                                        //               user.username,
                                        //         ));
                                      },
                                      child: Image.asset(
                                        'assets/comment_big.png',
                                        color: Colors.white,
                                        height: 60,
                                      ),
                                    ),
                                    GestureDetector(
                                        onTap: () {},
                                        child: const Icon(FeatherIcons.share,
                                            color: Colors.white70, size: 22)),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 55),
                              child: buildComments(),
                            )
                          ],
                        ),
                        buildWriteComment()
                      ],
                    ),
                  );
                })),
          );
        }));
  }

  buildWriteComment() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: kBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: SizedBox(
            height: 35,
            // decoration: BoxDecoration(
            //   color: kCardColor,
            //     borderRadius: BorderRadius.circular(10),
            //     border: Border.all(width: 0.5, color: Colors.white54)),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Material(
                          color: Colors.transparent,
                          child: CupertinoSearchTextField(
                            focusNode: focusNode,
                            onSuffixTap: addComment,
                            controller: commentTextController,
                            style: const TextStyle(color: Colors.white),
                            prefixIcon: const SizedBox(),
                            placeholder: 'Write your reply',
                            suffixIcon: const Icon(
                              Icons.send_rounded,
                              color: Colors.grey,
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
//  TextField(

//                           controller: commentTextController,
//                           onTap: () {},
//                           onChanged: (input) {
//                             if (commentTextController.text.isNotEmpty) {
//                               setState(() {
//                                 isActive = true;
//                               });
//                             } else {
//                               setState(() {
//                                 isActive = false;
//                               });
//                             }
//                           },
//                           style: const TextStyle(color: Colors.white),
//                           decoration: const InputDecoration(
//                             fillColor: kCardColor,
//                             hintText: 'Write your comment',
//                             hintStyle: TextStyle(color: Colors.white70),
//                             border: InputBorder.none,
//                             enabledBorder: InputBorder.none,
//                             errorBorder: InputBorder.none,
//                             focusedBorder: InputBorder.none,
//                           ),
//                         ),
showProfile({profileId}) {
  Get.to(() => Account(profileId: profileId, previousPage: 'Post'));
}
