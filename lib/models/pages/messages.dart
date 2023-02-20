import '/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/models/pages/root.dart';

import '../user_model.dart';
import 'chat_page.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  Future<QuerySnapshot>? searchResultsFuture;

  handleSearch(String query) {
    Future<QuerySnapshot> users = usersRef
        .where("username", isGreaterThanOrEqualTo: query.toUpperCase())
        .get();
    setState(() {
      searchResultsFuture = users;
    });
  }

  buildSearchResults() {
    return FutureBuilder<QuerySnapshot>(
        future: searchResultsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CupertinoActivityIndicator();
          }
          List<UserResult> searchResultsForUsers = [];
          for (var doc in snapshot.data!.docs) {
            User user = User.fromDocument(doc);
            UserResult searchResult = UserResult(user: user);
            searchResultsForUsers.add(searchResult);
          }
          return ListView(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            children: searchResultsForUsers,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Get.back(),
              child: const Text(
                'Geri',
                style: TextStyle(color: Colors.white),
              )),
          backgroundColor: const Color.fromARGB(255, 17, 17, 17),
          automaticallyImplyLeading: false,
          elevation: 0,
          title: CupertinoSearchTextField(
            style: const TextStyle(color: Colors.white),
            onChanged: (query) {
              handleSearch(query);
            },
          ),
        ),
        body: searchResultsFuture == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [])
            : buildSearchResults());
  }
}

class Messages extends StatefulWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: kThemeColor,
          child: const Icon(CupertinoIcons.mail),
          onPressed: () {
            Get.to(() => const Explore(), transition: Transition.downToUp);
          }),
      body: CupertinoPageScaffold(
          child: NestedScrollView(
              physics: const BouncingScrollPhysics(),
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    CupertinoSliverNavigationBar(
                      automaticallyImplyLeading: false,
                      border: innerBoxIsScrolled
                          ? const Border(
                              bottom: BorderSide(
                                  color: CupertinoColors.systemGrey,
                                  width: 0.5))
                          : const Border(bottom: BorderSide()),
                      backgroundColor: innerBoxIsScrolled
                          ? const Color.fromARGB(255, 42, 42, 42)
                              .withOpacity(0.5)
                          : const Color.fromARGB(255, 3, 3, 3),
                      largeTitle: const Text(
                        "Mesajlar",
                        style: TextStyle(color: Colors.white),
                      ),
                      // CupertinoButton(
                      //     padding: EdgeInsets.zero,
                      //     child: Icon(CupertinoIcons.bolt_horizontal),
                      //     onPressed: () {
                      //       Get.to(() => ChatPage(
                      //           userId: '100565833960449092342'));
                      //     })
                    )
                  ],
              body: StreamBuilder<QuerySnapshot>(
                  stream: messagesRef
                      .doc(currentUser.id)
                      .collection('contacts')
                      .where('userId', isNotEqualTo: currentUser.id)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return loading();
                    }
                    if (snapshot.data!.docs.isEmpty) {
                      return showExplore();
                    } else {
                      return ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.0),
                            child: CupertinoSearchTextField(
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              return FutureBuilder<DocumentSnapshot>(
                                  future: usersRef
                                      .doc(snapshot.data!.docs[index]['userId'])
                                      .get(),
                                  builder: (context, userSnapshot) {
                                    if (!userSnapshot.hasData) {
                                      return loading();
                                    }
                                    User user =
                                        User.fromDocument(userSnapshot.data!);
                                    return Container(
                                      decoration: const BoxDecoration(
                                          border: Border.symmetric(
                                              horizontal: BorderSide(
                                                  width: 0.2,
                                                  color: Colors.white))),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                            backgroundImage:
                                                NetworkImage(user.photoUrl)),
                                        onTap: () {
                                          Get.to(
                                              () => ChatPage(userId: user.id),
                                              transition: Transition.cupertino);
                                        },
                                        title: Text(
                                          user.username,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        subtitle: StreamBuilder(
                                            stream: messagesRef
                                                .doc(currentUser.id)
                                                .collection('contacts')
                                                .doc(user.id)
                                                .collection('messages')
                                                .snapshots(),
                                            builder:
                                                (context, lastMessageSnapshot) {
                                              if (!lastMessageSnapshot
                                                  .hasData) {
                                                return loading();
                                              }
                                              return Text(
                                                lastMessageSnapshot
                                                    .data!.docs.last
                                                    .get('message'),
                                                style: TextStyle(
                                                    color: Colors.grey),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              );
                                            }),
                                      ),
                                    );
                                  });
                            },
                          ),
                        ],
                      );
                    }
                  }))),
    );
  }

  Column showExplore() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 40.0, left: 20),
          child: Text(
            'Find People To Talk Or Ask',
            style: TextStyle(color: Colors.white, fontSize: 23),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 50, left: 30),
          child: SizedBox(
              height: 35,
              width: 110,
              child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: kThemeColor,
                  borderRadius: BorderRadius.circular(200),
                  child: const Text('Explore'),
                  onPressed: () {
                    Get.to(() => const Explore(),
                        transition: Transition.downToUp);
                  })),
        )
      ],
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;

  const UserResult({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          border: Border.symmetric(
              horizontal: BorderSide(width: 0.2, color: Colors.grey))),
      child: ListTile(
        onTap: () {
          Get.to(() => ChatPage(userId: user.id),
              transition: Transition.cupertino);
        },
        leading: CircleAvatar(
          backgroundImage: NetworkImage(user.photoUrl),
          radius: 18,
        ),
        title: SizedBox(
          width: 100,
          child: Text(
            user.username,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        subtitle: Text(
          user.username,
          style: const TextStyle(color: Colors.grey, fontSize: 15),
        ),
      ),
    );
  }
}
