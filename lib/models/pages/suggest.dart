import 'package:appbeyoglu/widgets/loading.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '/constants.dart';
import '/models/pages/root.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Suggest extends StatefulWidget {
  const Suggest({super.key});

  @override
  State<Suggest> createState() => _SuggestState();
}

class _SuggestState extends State<Suggest> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          previousPageTitle: "AppBeyoglu",
          border: const Border(
              bottom:
                  BorderSide(color: CupertinoColors.systemGrey, width: 0.5)),
          backgroundColor:
              const Color.fromARGB(255, 42, 42, 42).withOpacity(0.5),
          middle: const Text(
            "Öner",
            style: TextStyle(color: Colors.white),
          ),
        ),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 40,
                    child: CupertinoTextField(
                      controller: titleController,
                      maxLength: 40,
                      placeholder: 'Başlık',
                      placeholderStyle: const TextStyle(color: Colors.grey),
                      style: const TextStyle(color: Colors.white),
                      decoration: const BoxDecoration(
                          color: kdarkGreyColor,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10))),
                    ),
                  ),
                  Divider(
                    color: Colors.grey[700],
                    thickness: 0.3,
                    height: 0,
                  ),
                  CupertinoTextField(
                    controller: descController,
                    maxLines: 4,
                    placeholder: 'Açıklama',
                    placeholderStyle: const TextStyle(color: Colors.grey),
                    style: const TextStyle(color: Colors.white),
                    decoration: const BoxDecoration(
                        color: kdarkGreyColor,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10))),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 40,
                    child: CupertinoButton(
                        borderRadius: BorderRadius.circular(15),
                        color: kThemeColor,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Text('Paylaş'),
                        onPressed: () {
                          String suggestionId = const Uuid().v4();
                          //share suggestion
                          suggestionsRef.doc(suggestionId).set({
                            "userId": currentUser.id,
                            "title": titleController.text,
                            "desc": descController.text,
                            "points": 0,
                          });
                          titleController.clear();
                          descController.clear();
                        }),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Öneriler',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    'en yüksek puan',
                    style: TextStyle(color: kThemeColor, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            StreamBuilder(
                stream: suggestionsRef
                    .orderBy('points', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return loading();
                  }
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      return suggestion(
                          snapshot.data!.docs[index]['userId'],
                          snapshot.data!.docs[index]['title'],
                          snapshot.data!.docs[index]['desc'],
                          snapshot.data!.docs[index]['points']);
                    },
                  );
                })
          ],
        ),
      ),
    );
  }

  Container suggestion(String userId, String title, String desc, int points) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
          border: Border.symmetric(
              horizontal: BorderSide(color: Colors.grey[600]!, width: 0.25))),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.up_arrow,
              color: kThemeColor,
              size: 15,
            ),
            Text(
              points.toString(),
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(
              width: 10,
            ),
            StreamBuilder(
                stream: usersRef.doc(userId).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return loading();
                  }
                  return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        snapshot.data!.get('photoUrl'),
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                      ));
                }),
          ],
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        subtitle: Text(
          desc,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        trailing: Column(mainAxisSize: MainAxisSize.min, children: [
          Expanded(
            child: CupertinoButton(
                color: kdarkGreyColor,
                padding: EdgeInsets.zero,
                child: const Icon(
                  CupertinoIcons.up_arrow,
                  color: kThemeColor,
                ),
                onPressed: () {
                  //upvote
                }),
          ),
          const SizedBox(
            height: 3,
          ),
          Expanded(
            child: CupertinoButton(
                color: kdarkGreyColor,
                padding: EdgeInsets.zero,
                child: const Icon(
                  CupertinoIcons.down_arrow,
                  color: Colors.red,
                ),
                onPressed: () {
                  //downvote
                }),
          ),
        ]),
      ),
    );
  }
}
