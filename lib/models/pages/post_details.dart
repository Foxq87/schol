import '/models/post_detail_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'root.dart';

class PostDetails extends StatelessWidget {
  final String userId;
  final String postId;
  const PostDetails({Key? key, required this.userId, required this.postId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: postsRef.doc(userId).collection('userPosts').doc(postId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CupertinoActivityIndicator();
          }
          PostDetail post = PostDetail(
            postId: snapshot.data!.get('postId'),
            ownerId: snapshot.data!.get('ownerId'),
            username: snapshot.data!.get('username'),
            postText: snapshot.data!.get('postText'),
            timeStamp: snapshot.data!.get('timeStamp'),
            likes: snapshot.data!.get('likes'),
            mediaUrl: snapshot.data!.get('mediaUrl'),
          );
          return post;
        });
  }
}
