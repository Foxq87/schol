// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { user } = require("firebase-functions/v1/auth");
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
exports.onCreateFollower = functions.firestore
    .document("/followers/{userId}/userFollowers/{followerId}")
    .onCreate(async (snapshot, context) => {
        console.log("Follower Created", snapshot.id);
        const userId = context.params.userId;
        const followerId = context.params.followerId;

        // 1) Create followed users posts ref
        const followedUserPostsRef = admin
            .firestore()
            .collection("posts")
            .doc(userId)
            .collection("userPosts");

        // 2) Create following user's timeline ref
        const timelinePostsRef = admin
            .firestore()
            .collection("timeline")
            .doc(followerId)
            .collection("timelinePosts");

        // 3) Get followed users posts
        const querySnapshot = await followedUserPostsRef.get();

        // 4) Add each user post to following user's timeline
        querySnapshot.forEach(doc => {
            if (doc.exists) {
                const postId = doc.id;
                const postData = doc.data();
                timelinePostsRef.doc(postId).set(postData);
            }
        });
    });


exports.onDeleteFollower = functions.firestore
    .document("/followers/{userId}/userFollowers/{followerId}")
    .onDelete(async (snapshot, context) => {
        console.log('Follower Deleted', snapshot.id);

        const userId = context.params.userId;
        const followerId = context.params.followerId;

        const timelinePostsRef = admin
            .firestore()
            .collection('timeline')
            .doc(followerId)
            .collection('timelinePosts')
            .where("ownerId", "==", userId);

        const querySnaphot = await timelinePostsRef.get();
        querySnaphot.forEach((doc) => {
            if (doc.exists) {
                doc.ref.delete();
            }
        });
    });


exports.onCreatePost = functions.firestore
    .document("/posts/{userId}/userPosts/{postId}")
    .onCreate(async (snapshot, context) => {
        const postCreated = snapshot.data();
        const userId = context.params.userId;
        const postId = context.params.postId;

        const userFollowersRef = admin
            .firestore()
            .collection('followers')
            .doc(userId)
            .collection('userFollowers');

        const querySnapshot = await userFollowersRef.get();

        querySnapshot.forEach(doc => {

            const followerId = doc.id;

            admin
                .firestore()
                .collection('timeline')
                .doc(followerId)
                .collection('timelinePosts')
                .doc(postId)
                .set(postCreated);

        });
    });

exports.onUpdatePost = functions.firestore
    .document("/posts/{userId}/userPosts/{postId}")
    .onUpdate(async (change, context) => {

        const postUpdated = change.after.data();
        const userId = context.params.userId;
        const postId = context.params.postId;

        const userFollowersRef = admin.firestore()
            .collection('followers')
            .doc(userId)
            .collection('userFollowers');

        const querySnapshot = await userFollowersRef.get();

        querySnapshot.forEach(doc => {
            const followerId = doc.id;

            admin
                .firestore()
                .collection('timeline')
                .doc(followerId)
                .collection('timelinePosts')
                .doc(postId)
                .get().then(doc => {
                    if (doc.exists) {
                        doc.ref.update(postUpdated);
                    }
                });

        });
    });

exports.onDeletePost = functions.firestore
    .document("/posts/{userId}/userPosts/{postId}")
    .onDelete(async (snapshot, context) => {
        console.log('trsting please mppy',snapshot.id,);
        const userId = context.params.userId;
        const postId = context.params.postId;

        const userFollowersRef = admin.firestore()
            .collection('followers')
            .doc(userId)
            .collection('userFollowers');
        const querySnapshot = await userFollowersRef.get();

        querySnapshot.forEach(doc => {
            const followerId = doc.id;

            admin
                .firestore()
                .collection('timeline')
                .doc(followerId)
                .collection('timelinePosts')
                .doc(postId)
                .get().then(doc => {
                    if (doc.exists) {
                        doc.ref.delete();
                    }
                });

        });
    });

    exports.onCreateActivityFeedItem = functions.firestore
        .document('/notifications/{userId}/userNotifications/{activityFeedItem}')
        .onCreate(async (snapshot,context)=>{
            console.log('Activity Feed Item Created',snapshot.data());

            const userId = context.params.userId;

            const userRef = admin.firestore().doc(`users/${userId}`);
            const doc = await userRef.get();

            const androidNotificationToken = doc.data()
            .androidNotificationToken;
            const createdActivityFeedItem = snapshot.data();

            if (androidNotificationToken) {
                //send notification
                sendNotification(androidNotificationToken,createdActivityFeedItem);
            }else {
                console.log("no token for user, cannot send notification");
            }

            function sendNotification(androidNotificationToken,activityFeedItem) {
                let body;
                let title;
                switch (activityFeedItem.type) {
                    case "comment":
                        title = `Yorum`
                        body = `${activityFeedItem.username} cevap verdi: ${activityFeedItem.subTitle}`    
                        break;  
                    case "like":
                        title = `Begeni`
                        body = `${activityFeedItem.username} paylaşımını beğendi`    
                        break;
                    case "follow":
                        title = `Takip`
                        body = `yeni bir takipcin var`    
                        break;
                    case "newOrder":
                        title = `Yeni siparis`
                        body = `Yeni bir siparişin var!`    
                        break;
                    case "productApproved":
                        title = `Urun kabul edildi`
                        body = `Ürünün kabul edildi ve artık satılmaya hazır!`    
                        break;
                    case "productRejected":
                        title = `Urun reddedildi`
                        body = `Ürünün uygulamamız için uygunsuz veya alakasız olduğu için reddedildi ama başka ürünler satabilirsin`    
                        break;
                    case "orderRejected":
                        title = `Siparis reddedildi`
                        body = `Siparişin reddedildi`    
                        break;
                    case "message":
                        title = `${activityFeedItem.senderName} size bir mesaj gonderdi`
                        body = `${activityFeedItem.message}`  
                        break;
                    case "accountApproved":
                        title = `Hesabın onaylandı`
                        body = `Hesabın onaylandı artık uygulamamızı kullanabilirsin!`
                        break;
                       
                    default:                       
                        // title = `Yeni bildirim`
                        // body = `Yeni bildirimlerin var!`    

                        break;
                }
                const message = {
                    notification: { title,body },
                    token: androidNotificationToken,
                    data: { recipient: userId }
                };

                admin
                    .messaging()
                    .send(message)
                    .then(response => {

                    console.log("Successfully sent message",response);
                })
                .catch(error=>{
                    console.log("Error sending message",error)
                });
            }
        });