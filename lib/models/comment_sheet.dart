// ignore_for_file: no_logic_in_create_state

import '/widgets/loading.dart';

import '/constants.dart';
import '/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'pages/root.dart';

class Comments extends StatefulWidget {
  final String postId;
  final String postText;
  final String postOwnerId;
  final String postOwnerUsername;
  const Comments(
      {Key? key,
      required this.postId,
      required this.postOwnerId,
      required this.postText,
      required this.postOwnerUsername})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CommentsState createState() => _CommentsState(
        postId: postId,
        postOwnerId: postOwnerId,
      );
}

TextEditingController commentTextController = TextEditingController();

class _CommentsState extends State<Comments> {
  final String postId;
  final String postOwnerId;
  _CommentsState({required this.postId, required this.postOwnerId});
  bool isActive = false;
  @override
  Widget build(BuildContext context) {
    final systemHeight = Get.height;
    final keyboardPadding = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: keyboardPadding,
      child: SizedBox(
        height: systemHeight * 0.8,
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: buildComments(),
              ),
              buildWriteComment()
            ],
          ),
        ),
      ),
    );
  }

  addComment() {
    if (commentTextController.text != "") {
      commentsRef.doc(postId).collection('comments').add({
        "comment": commentTextController.text,
        "timeStamp": DateTime.now(),
        "commenterId": currentUser.id,
        "ownerId": postOwnerId,
      });

      bool isNotPostOwner = postOwnerId != currentUser.id;

      if (isNotPostOwner) {
        notificationsRef.doc(postOwnerId).collection('userNotifications').add({
          "type": "comment",
          "title": "${currentUser.username} yorum yazdı:",
          "subTitle": commentTextController.text,
          "userId": currentUser.id,
          "userProfilePicture": currentUser.photoUrl,
          "postId": postId,
          "timestamp": DateTime.now(),
          "username":currentUser.username,
        });
      }

      commentTextController.clear();
    }
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
        return ListView(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          children: comments,
        );
      }),
    );
  }

  buildWriteComment() {
    return Container(
      color: const Color.fromARGB(255, 8, 8, 8),
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CupertinoTextField(
                        controller: commentTextController,
                        onChanged: (input) {
                          if (commentTextController.text.isNotEmpty) {
                            setState(() {
                              isActive = true;
                            });
                          } else {
                            setState(() {
                              isActive = false;
                            });
                          }
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: BoxDecoration(
                            color: kdarkGreyColor,
                            borderRadius: BorderRadius.circular(8)),
                        placeholder: 'Yorum yaz',
                        placeholderStyle:
                            const TextStyle(color: Colors.white70),
                      ),
                    ),
                    Expanded(
                        flex: 0,
                        child: TextButton(
                            onPressed: addComment,
                            child: Text(
                              'Post',
                              style: TextStyle(
                                  color: isActive == false
                                      ? kThemeColor.withOpacity(0.6)
                                      : kThemeColor,
                                  fontFamily: 'poppinsBold'),
                            )))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String commenterId;
  final String ownerId;
  final String comment;
  final Timestamp timeStamp;
  const Comment({
    Key? key,
    required this.commenterId,
    required this.ownerId,
    required this.comment,
    required this.timeStamp,
  }) : super(key: key);

  // factory Comment.fromDocument(DocumentSnapshot doc) {
  //   return Comment(
  //     ownerId: doc['ownerId'],
  //     commenterId: doc['commenterId'],
  //     comment: doc['comment'],
  //     timeStamp: doc['timeStamp'],
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: usersRef.doc(commenterId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return loading();
          }
          User user = User.fromDocument(snapshot.data!);

          return CupertinoContextMenu(
            previewBuilder: (BuildContext context, Animation<double> animation,
                Widget child) {
              return FittedBox(
                fit: BoxFit.fill,
                child: SingleChildScrollView(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.symmetric(
                              horizontal: BorderSide(
                                  width: 0.25, color: Colors.grey[700]!))),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, top: 10, right: 15, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  radius: 18,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(200),
                                      child: Image.network(
                                        user.photoUrl,
                                        fit: BoxFit.cover,
                                      )),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          user.username,
                                          style: const TextStyle(
                                              inherit: false,
                                              fontFamily: 'poppinsBold'),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                          child: Text(
                                            comment,
                                            style:
                                                const TextStyle(inherit: false),
                                            maxLines: 4,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      timeago.format(timeStamp.toDate()),
                                      style: const TextStyle(
                                          inherit: false, color: Colors.grey),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            actions: [
              commenterId == currentUser.id
                  ? CupertinoTheme(
                      data:
                          const CupertinoThemeData(brightness: Brightness.dark),
                      child: CupertinoContextMenuAction(
                          onPressed: () {
                            commentsRef
                                .doc()
                                .collection('comments')
                                .doc()
                                .delete();
                          },
                          trailingIcon: CupertinoIcons.delete,
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          )),
                    )
                  : const SizedBox(),
              CupertinoTheme(
                data: const CupertinoThemeData(brightness: Brightness.dark),
                child: CupertinoContextMenuAction(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text('Cancel')),
              ),
            ],
            child: SingleChildScrollView(
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.transparent,
                    border: Border.symmetric(
                        horizontal:
                            BorderSide(width: 0.25, color: Colors.grey))),
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 15.0, top: 10, bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.transparent,
                                radius: 18,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(200),
                                    child: Image.network(
                                      user.photoUrl,
                                      fit: BoxFit.cover,
                                    )),
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        user.username,
                                        style: const TextStyle(
                                            inherit: false,
                                            fontFamily: 'poppinsBold'),
                                      ),
                                      Text(
                                        ' · ${timeago.format(timeStamp.toDate())}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          inherit: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Row(
                                    children: [
                                      const Text(
                                        'Replying to',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          inherit: false,
                                        ),
                                      ),
                                      StreamBuilder(
                                          stream:
                                              usersRef.doc(ownerId).snapshots(),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return loading();
                                            }
                                            User owner = User.fromDocument(
                                                snapshot.data!);
                                            return Text(
                                              ' @${owner.username}',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  inherit: false,
                                                  fontFamily: 'poppinsBold'),
                                            );
                                          }),
                                    ],
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    child: Text(
                                      comment,
                                      style: const TextStyle(inherit: false),
                                      maxLines: 4,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}

// Future createComment() async {
//   final doc =
//       FirebaseFirestore.instance.collection('Questions').doc('Question-1');

//   final comment = Comment(comments: [commentTextController.text,],commenters: ['eeoxq']);

//   final json = comment.toJson();

//   await doc.set(json);
// }
