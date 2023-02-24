import 'dart:io';

import '../pages/root.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  RewardedAd? _rewardedAd;

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: Platform.isIOS
          ? "ca-app-pub-9838840200304232/6011816918"
          : "ca-app-pub-9838840200304232/2948402474",
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
        },
      ),
    );
  }

  void showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (RewardedAd ad) {
        coinsRef.doc(currentUser.id).get().then((doc) {
          if (doc.exists) {
            doc.reference.update({
              "coins": doc.get('coins') + 1,
              "userId": currentUser.id,
            });
          } else {
            doc.reference.set({
              "coins": 1,
              "userId": currentUser.id,
            });
          }
        });
        //print("Ad onAdShowed ");
      }, onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        loadRewardedAd();
      }, onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        loadRewardedAd();
      });
      _rewardedAd!.setImmersiveMode(true);
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {},
      );
    }
  }
}
