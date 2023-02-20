import '/models/pages/create.dart';

import '/widgets/loading.dart';

import '/models/pages/account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/constants.dart';
import '/models/pages/root.dart';
import '/widgets/product.dart';

import '../user_model.dart';
import 'cart.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search> {
  int state = 0;
  String myQuery = '';

  Future<QuerySnapshot>? searchResultsFuture;

  handleSearch(String query) {
    Future<QuerySnapshot> products = productRef
        .where("productTitle", isGreaterThanOrEqualTo: myQuery.toUpperCase())
        .where("approve", isEqualTo: 2)
        .get();
    setState(() {
      searchResultsFuture = products;
    });
  }

  buildSearchResults() {
    // return StreamBuilder<QuerySnapshot>(
    //     stream: searchResultsFuture,
    //     builder: (context, snapshot) {
    //       if (!snapshot.hasData) {
    //         return const CupertinoActivityIndicator();
    //       }
    //       List<ProductResult> searchResultsForProducts = [];

    //       for (var doc in snapshot.data!.docs) {
    //         Product product = Product.fromDocument(doc);

    //         ProductResult searchResultForTutors = ProductResult(
    //           product: product,
    //         );
    //         searchResultsForProducts.add(searchResultForTutors);
    //       }
    //       return Column(children: searchResultsForProducts);
    //     });
    return FutureBuilder<QuerySnapshot>(
        future: searchResultsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return loading();
          }
          List<ProductResult> searchResults = [];
          for (var doc in snapshot.data!.docs) {
            Product product = Product(
              productId: doc['productId'],
              type: doc['type'],
              isLoaded: snapshot.hasData,
              description: doc['productDesc'],
              title: doc['productTitle'],
              price: doc['productPrice'],
              vendor: doc['vendorId'],
              imageUrl: doc['image'],
              quantity: doc['quantity'],
              approve: doc['approve'],
            );

            ProductResult searchResult = ProductResult(
              product: product,
            );
            searchResults.add(searchResult);
          }
          return ListView(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              children: searchResults);
        });
  }

  // buildSearchResults0() {
  //   return StreamBuilder<QuerySnapshot>(
  //       stream: productRef
  //           .where("vendorId", isNotEqualTo: currentUser.id)
  //           .where("productTitle",
  //               isGreaterThanOrEqualTo: myQuery.toUpperCase())
  //           .snapshots(),
  //       builder: (context, snapshot) {
  //         if (!snapshot.hasData) {
  //           return const CupertinoActivityIndicator();
  //         }
  //         List<ProductResult> searchResultsForProducts = [];

  //         for (var doc in snapshot.data!.docs) {
  //           Product product = Product.fromDocument(doc);

  //           ProductResult searchResultForTutors = ProductResult(
  //             product: product,
  //           );
  //           searchResultsForProducts.add(searchResultForTutors);
  //         }
  //         return Column(children: searchResultsForProducts);
  //       });
  // }

  // buildSearchResults1() {
  //   return StreamBuilder<QuerySnapshot>(
  //       stream: usersRef
  //           .where("username", isGreaterThanOrEqualTo: myQuery.toUpperCase())
  //           .snapshots(),
  //       builder: (context, snapshot) {
  //         if (!snapshot.hasData) {
  //           return const CupertinoActivityIndicator();
  //         }
  //         List<UserResult> searchResultsForUsers = [];

  //         for (var doc in snapshot.data!.docs) {
  //           User user = User.fromDocument(doc);

  //           UserResult searchResult = UserResult(user: user);

  //           searchResultsForUsers.add(searchResult);
  //         }
  //         return Column(children: searchResultsForUsers);
  //       });
  // }

  // buildSegmentedControl() {
  //   return Center(
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(vertical: 10),
  //       child: CupertinoSlidingSegmentedControl<int>(
  //         backgroundColor: const Color.fromARGB(255, 10, 10, 10),
  //         thumbColor: kdarkGreyColor,
  //         // This represents the currently selected segmented control.
  //         groupValue: state,
  //         // Callback that sets the selected segmented control.
  //         onValueChanged: (value) {
  //           if (value != null) {
  //             setState(() {
  //               if (value == 0) {
  //                 searchResultsFuture = productRef
  //                     .where("productTitle",
  //                         isGreaterThanOrEqualTo: myQuery.toUpperCase())
  //                     .snapshots();
  //               } else if (value == 1) {
  //                 searchResultsFuture = usersRef
  //                     .where("username",
  //                         isGreaterThanOrEqualTo: myQuery.toUpperCase())
  //                     .snapshots();
  //               }
  //               state = value;
  //             });
  //           }
  //         },
  //         children: const {
  //           0: Padding(
  //             padding: EdgeInsets.symmetric(horizontal: 20),
  //             child: Text(
  //               'Ürünler',
  //               style: TextStyle(color: CupertinoColors.white),
  //             ),
  //           ),
  //           1: Padding(
  //             padding: EdgeInsets.symmetric(horizontal: 20),
  //             child: Text(
  //               'Kullanıcılar',
  //               style: TextStyle(color: CupertinoColors.white),
  //             ),
  //           ),
  //         },
  //       ),
  //     ),
  //   );
  // }
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: CupertinoNavigationBar(
        border:
            Border(bottom: BorderSide(color: Colors.grey[600]!, width: 0.30)),
        backgroundColor: kdarkGreyColor.withOpacity(0.8),
        automaticallyImplyLeading: false,
        middle: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: CupertinoSearchTextField(
                  style: const TextStyle(color: Colors.white),
                  onChanged: (query) {
                    handleSearch(query);
                    setState(() {
                      myQuery = query;
                    });
                  },
                ),
              ),
              Expanded(
                flex: 0,
                child: StreamBuilder(
                    stream: cartsRef
                        .doc(currentUser.id)
                        .collection('userCart')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return loading();
                      }
                      return Badge(
                        alignment: AlignmentDirectional.topEnd,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        label: Text(
                          snapshot.data!.docs.length.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                        child: CupertinoButton(
                          onPressed: () {
                            Get.to(() => const Cart(),
                                transition: Transition.cupertino);
                          },
                          child: const Icon(
                            CupertinoIcons.bag,
                            color: kThemeColor,
                          ),
                        ),
                      );
                    }),
              )
            ],
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // Center(
          //   child: buildSegmentedControl(),
          // ),
          searchResultsFuture == null ? buildExplore() : buildSearchResults(),
          // state == 0
          //     ? buildSearchResults0()
          //     : buildSearchResults1()
        ],
      ),
    );
  }

  StreamBuilder buildExplore() {
    return StreamBuilder<QuerySnapshot>(
        stream: productRef
            .where("productTitle",
                isGreaterThanOrEqualTo: myQuery.toUpperCase())
            .where("approve", isEqualTo: 2)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return loading();
          }
          return buildProducts(snapshot);
        });
  }

  // ListView users(AsyncSnapshot snapshot) {
  //   return ListView.builder(
  //     physics: const NeverScrollableScrollPhysics(),
  //     padding: const EdgeInsets.symmetric(
  //       vertical: 15,
  //     ),
  //     shrinkWrap: true,
  //     itemCount: snapshot.data!.docs.length,
  //     itemBuilder: (context, index) {
  //       User user = User.fromDocument(snapshot.data!.docs[index]);
  //       if (snapshot.data!.docs.isEmpty ||
  //           !snapshot.hasData ||
  //           snapshot.hasError ||
  //           snapshot.isBlank == true) {
  //         return const Center(
  //           child: Text('Ürün Yok'),
  //         );
  //       }
  //       return UserResult(
  //         user: user,
  //       );
  //     },
  //   );
  // }

  GridView buildProducts(AsyncSnapshot snapshot) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          crossAxisCount: 2,
          childAspectRatio: 3.04 / 4),
      shrinkWrap: true,
      itemCount: snapshot.data!.docs.length,
      itemBuilder: (context, index) {
        if (snapshot.data!.docs.isEmpty || snapshot.isBlank == true) {
          return const Center(
            child: Text('Ürün Yok'),
          );
        }
        final listOfDocumentSnapshot = snapshot.data!.docs[index];
        return Product(
          productId: listOfDocumentSnapshot['productId'],
          type: listOfDocumentSnapshot['type'],
          isLoaded: snapshot.hasData,
          description: listOfDocumentSnapshot['productDesc'],
          title: listOfDocumentSnapshot['productTitle'],
          price: listOfDocumentSnapshot['productPrice'],
          vendor: listOfDocumentSnapshot['vendorId'],
          imageUrl: listOfDocumentSnapshot['image'],
          quantity: listOfDocumentSnapshot['quantity'],
          approve: listOfDocumentSnapshot['approve'],
        );
      },
    );
  }
}

class ProductResult extends StatelessWidget {
  final Product product;

  const ProductResult({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: usersRef.doc(product.vendor).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CupertinoActivityIndicator();
          }
          User user = User.fromDocument(snapshot.data!);
          return Container(
            decoration: const BoxDecoration(
                border: Border.symmetric(
                    horizontal: BorderSide(width: 0.2, color: Colors.grey))),
            child: ListTile(
              onTap: () {
                showProduct(
                  product.title,
                  product.price,
                  product.vendor,
                  product.imageUrl,
                  product.description,
                  product.productId,
                  product.type,
                  product.quantity,
                );
              },
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  product.imageUrl,
                  height: 70,
                  width: 70,
                  fit: BoxFit.cover,
                ),
              ),
              title: Row(
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "@${user.username}",
                    style: const TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${product.price}',
                    style: const TextStyle(color: Colors.white, fontSize: 17),
                  ),
                  const Text(
                    '\t₺',
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class UserResult extends StatelessWidget {
  final User user;

  const UserResult({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: usersRef.doc(user.id).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return loading();
          }
          User user = User.fromDocument(snapshot.data!);
          return Container(
            margin: const EdgeInsets.fromLTRB(15, 10, 15, 0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(width: 0.8, color: Colors.grey)),
            child: ListTile(
              onTap: () {
                Get.to(() => Account(
                      profileId: user.id,
                      previousPage: 'Ara',
                    ));
              },
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  user.photoUrl,
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                user.username,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              subtitle: Text(
                "@${user.username}",
                style: const TextStyle(color: Colors.grey, fontSize: 15),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  user.isVendor && user.rating != 0
                      ? const Icon(
                          Icons.star_rate_rounded,
                          color: Colors.yellow,
                        )
                      : const SizedBox(),
                  Text(
                    user.isVendor && user.rating != 0
                        ? user.rating.toString()
                        : 'no reviews',
                    style: TextStyle(
                        color: user.rating == 0 ? Colors.grey : Colors.yellow,
                        fontSize: 15),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

showProduct(
  String title,
  String price,
  String vendor,
  String imageUrl,
  String description,
  String productId,
  String type,
  int quantity,
) {
  return Get.to(
      () => ProductDetails(
            productId: productId,
          ),
      transition: Transition.cupertino);
}

// class Search extends StatefulWidget {
//   const Search({Key? key}) : super(key: key);

//   @override
//   State<Search> createState() => _SearchState();
// }

// class _SearchState extends State<Search> {
//   int state = 0;

//   Future<QuerySnapshot>? searchResultsFuture;

//   handleSearch(query) {
//     if (state == 0) {
//       Future<QuerySnapshot> users = productRef
//           .where("productTitle", isGreaterThanOrEqualTo: query)
//           .where("vendorId", isNotEqualTo: currentUser.id)
//           .get();
//       setState(() {
//         searchResultsFuture = users;
//       });
//     } else if (state == 1) {
//       setState(() {
//         Future<QuerySnapshot> users = usersRef
//             .where("username", isGreaterThanOrEqualTo: query)
//             .where("id", isNotEqualTo: currentUser.id)
//             .get();
//         setState(() {
//           searchResultsFuture = users;
//         });
//       });
//     }
//   }

//   buildSearchResults() {
//     return FutureBuilder<QuerySnapshot>(
//         future: searchResultsFuture,
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const CupertinoActivityIndicator();
//           }
//           List<UserResult> searchResultsForUsers = [];
//           List<TutorResult> searchResultsForTutors = [];
//           snapshot.data!.docs.forEach((doc) {
//             User user = User.fromDocument(doc);
//             UserResult searchResult = UserResult(user: user);
//             TutorResult searchResultForTutors = TutorResult(user: user);
//             state == 1
//                 ? searchResultsForUsers.add(searchResult)
//                 : searchResultsForTutors.add(searchResultForTutors);
//           });
//           return ListView(children: [
//             Center(child: buildSegmentedControl()),
//             const SizedBox(
//               height: 10,
//             ),
//             ListView(
//               shrinkWrap: true,
//               children:
//                   state == 0 ? searchResultsForTutors : searchResultsForUsers,
//             )
//           ]);
//         });
//   }

//   buildSegmentedControl() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20.0),
//       child: CupertinoSlidingSegmentedControl<int>(
//         backgroundColor: kdarkGreyColor,
//         thumbColor: kBackgroundColor,
//         // This represents the currently selected segmented control.
//         groupValue: state,
//         // Callback that sets the selected segmented control.
//         onValueChanged: (value) {
//           if (value != null) {
//             setState(() {
//               state = value;
//             });
//           }
//         },
//         children: {
//           0: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 20),
//             child: const Text(
//               'Tutors',
//               style: TextStyle(color: CupertinoColors.white),
//             ),
//           ),
//           1: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 20),
//             child: Text(
//               'Users',
//               style: TextStyle(color: CupertinoColors.white),
//             ),
//           ),
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           elevation: 0,
//           title: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//             child: CupertinoSearchTextField(
//               style: const TextStyle(color: Colors.white),
//               onChanged: (query) {
//                 handleSearch(query);
//               },
//             ),
//           ),
//         ),
//         body: searchResultsFuture == null
//             ? Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Center(
//                     child: buildSegmentedControl(),
//                   )
//                 ],
//               )
//             : buildSearchResults());
//   }
// }

// class UserResult extends StatelessWidget {
//   final User user;

//   const UserResult({Key? key, required this.user}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//           border: Border.symmetric(
//               horizontal: BorderSide(width: 0.2, color: Colors.grey))),
//       child: ListTile(
//         onTap: () {
//           showProfile(profileId: user.id);
//         },
//         leading: CircleAvatar(
//           backgroundImage: NetworkImage(user.photoUrl),
//           radius: 18,
//         ),
//         title: Text(
//           user.displayName,
//           style: const TextStyle(color: Colors.white, fontSize: 18),
//         ),
//         subtitle: Text(
//           user.username,
//           style: const TextStyle(color: Colors.grey, fontSize: 15),
//         ),
//       ),
//     );
//   }
// }

// class TutorResult extends StatelessWidget {
//   final User user;

//   const TutorResult({Key? key, required this.user}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//           border: Border.symmetric(
//               horizontal: BorderSide(width: 0.2, color: Colors.grey))),
//       child: ListTile(
//         onTap: () {
//           showProfile(profileId: user.id);
//         },
//         leading: CircleAvatar(
//           backgroundImage: NetworkImage(user.photoUrl),
//           radius: 18,
//         ),
//         title: Text(
//           user.username,
//           style: const TextStyle(color: Colors.white, fontSize: 18),
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             user.rating != 0
//                 ? const Icon(
//                     Icons.star_rate_rounded,
//                     color: Colors.yellow,
//                   )
//                 : const SizedBox(),
//             Text(
//               user.rating != 0 ? user.rating.toString() : 'no reviews',
//               style: TextStyle(
//                   color: user.rating == 0 ? Colors.grey : Colors.yellow,
//                   fontSize: 15),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class SearchForUsers extends StatefulWidget {
  const SearchForUsers({super.key});

  @override
  State<SearchForUsers> createState() => _SearchForUsersState();
}

class _SearchForUsersState extends State<SearchForUsers> {
  int state = 0;
  String myQuery = '';

  Future<QuerySnapshot>? searchResultsFuture;

  handleSearch(String query) {
    Future<QuerySnapshot> users = usersRef
        .where("username", isGreaterThanOrEqualTo: query.toUpperCase())
        .where("approve", isEqualTo: 2)
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
            return loading();
          }
          List<UserResult> searchResults = [];
          for (var doc in snapshot.data!.docs) {
            User user = User.fromDocument(doc);

            UserResult searchResult = UserResult(
              user: user,
            );
            searchResults.add(searchResult);
          }
          return ListView(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              children: searchResults);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        leading: GestureDetector(
            child: const Icon(
              CupertinoIcons.clear,
              color: Colors.white,
              size: 22,
            ),
            onTap: () {
              Get.back();
            }),
        border:
            Border(bottom: BorderSide(color: Colors.grey[600]!, width: 0.30)),
        backgroundColor: kdarkGreyColor.withOpacity(0.8),
        automaticallyImplyLeading: false,
        middle: Padding(
          padding: const EdgeInsets.only(
            left: 10,
            right: 20,
          ),
          child: CupertinoSearchTextField(
            style: const TextStyle(color: Colors.white),
            onChanged: (query) {
              handleSearch(query);
              setState(() {
                myQuery = query;
              });
            },
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // Center(
          //   child: buildSegmentedControl(),
          // ),
          searchResultsFuture == null ? buildExplore() : buildSearchResults(),
          // state == 0
          //     ? buildSearchResults0()
          //     : buildSearchResults1()
        ],
      ),
    );
  }

  StreamBuilder buildExplore() {
    return StreamBuilder<QuerySnapshot>(
        stream: usersRef
            .where("approve", isEqualTo: 2)
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
              if (snapshot.data!.docs.isEmpty || snapshot.isBlank == true) {
                return const Center(
                  child: Text('Ürün Yok'),
                );
              }
              User user = User.fromDocument(snapshot.data!.docs[index]);
              return UserResult(user: user);
            },
          );
        });
  }
}
