// ignore_for_file: unrelated_type_equality_checks, must_be_immutable

import 'package:feather_icons/feather_icons.dart';

import '/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdCupertinoButton extends StatelessWidget {
  Widget page;
  Widget child;
  EdgeInsetsGeometry? padding;
  BorderRadius? borderRadius;
  Color? color;
  VoidCallback onPressed;
  AdCupertinoButton(
      {super.key,
      required this.page,
      required this.child,
      required this.onPressed,
      this.padding,
      this.borderRadius,
      this.color}) {
    _initAd();
  }
  late InterstitialAd _interstitalAd;
  bool _isAdLoaded = false;
  _initAd() {
    InterstitialAd.load(
        adUnitId: TargetPlatform.iOS == true
            ? "ca-app-pub-9838840200304232/6313534084"
            : "ca-app-pub-9838840200304232/7144218268",
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: onAdLoaded, onAdFailedToLoad: (error) {}));
  }

  void onAdLoaded(InterstitialAd ad) {
    _interstitalAd = ad;
    _isAdLoaded = true;

    _interstitalAd.fullScreenContentCallback =
        FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
      Get.to(() => page);
      _interstitalAd.dispose();
    }, onAdFailedToShowFullScreenContent: (ad, error) {
      _interstitalAd.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
        padding: padding,
        borderRadius: borderRadius,
        color: color,
        child: child,
        onPressed: () {
          //print(_isAdLoaded);
          if (_isAdLoaded) {
            _interstitalAd.show();
            onPressed();
          }
        });
    // bottomNavigationBar: _isAdLoaded
    //     ? Container(
    //         height: _interstitalAd.size.height.toDouble(),
    //         width: _interstitalAd.size.width.toDouble(),
    //         child: AdWidget(ad: _interstitalAd),
    //       )
    //     : SizedBox(),
  }
}

class AdIconButton extends StatelessWidget {
  Widget page;
  Icon icon;

  AdIconButton({Key? key, required this.page, required this.icon})
      : super(key: key) {
    _initAd();
  }
  late InterstitialAd _interstitalAd;
  bool _isAdLoaded = false;
  _initAd() {
    InterstitialAd.load(
        adUnitId: "ca-app-pub-9838840200304232/7144218268",
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: onAdLoaded, onAdFailedToLoad: (error) {}));
  }

  void onAdLoaded(InterstitialAd ad) {
    _interstitalAd = ad;
    _isAdLoaded = true;

    _interstitalAd.fullScreenContentCallback =
        FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
      Get.to(() => page);
      _interstitalAd.dispose();
    }, onAdFailedToShowFullScreenContent: (ad, error) {
      _interstitalAd.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        color: kThemeColor,
        icon: icon,
        onPressed: () {
          if (_isAdLoaded) {
            _interstitalAd.show();
          }
        });
    // bottomNavigationBar: _isAdLoaded
    //     ? Container(
    //         height: _interstitalAd.size.height.toDouble(),
    //         width: _interstitalAd.size.width.toDouble(),
    //         child: AdWidget(ad: _interstitalAd),
    //       )
    //     : SizedBox(),
  }
}

class AdPage extends StatefulWidget {
  final int giftCoin;
  const AdPage({
    super.key,
    required this.giftCoin,
  });

  @override
  State<AdPage> createState() => _AdPageState();
}

class _AdPageState extends State<AdPage> {
  @override
  void initState() {
    _initAd();
    super.initState();
  }

  late BannerAd _bannerAd;
  late BannerAd _bannerAd2;

  // late InterstitialAd _interstitalAd;

  _initAd() {
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: "ca-app-pub-9838840200304232/5999523526",
      listener: BannerAdListener(
          onAdFailedToLoad: (ad, error) {},
          onAdLoaded: (ad) {
            setState(() {});
          }),
      request: const AdRequest(),
    );
    _bannerAd2 = BannerAd(
        size: AdSize.banner,
        adUnitId: "ca-app-pub-9838840200304232/3673383719",
        listener: BannerAdListener(
            onAdFailedToLoad: (ad, error) {},
            onAdLoaded: (ad) {
              setState(() {});
            }),
        request: const AdRequest());
    _bannerAd2.load();
    _bannerAd.load();

    // InterstitialAd.load(
    //     adUnitId: TargetPlatform.iOS == true
    //         ? "ca-app-pub-9838840200304232/6313534084"
    //         : "ca-app-pub-9838840200304232/7144218268",
    //     request: AdRequest(),
    //     adLoadCallback: InterstitialAdLoadCallback(
    //         onAdLoaded: onAdLoaded, onAdFailedToLoad: (error) {}));
  }

  // void onAdLoaded(InterstitialAd ad) {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: SizedBox(
                height: _bannerAd.size.height.toDouble(),
                width: _bannerAd.size.width.toDouble(),
                child: AdWidget(
                  ad: _bannerAd,
                )),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: Get.width - 40,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(width: 1.0, color: Colors.grey[700]!)),
                child: Column(
                  children: [
                    const Icon(
                      CupertinoIcons.check_mark_circled,
                      size: 70,
                      color: kThemeColor,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      'Siparişiniz Alındı!',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Center(
                      child: SizedBox(
                        width: Get.width - 170,
                        height: 40,
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          color: kThemeColor,
                          borderRadius: BorderRadius.circular(20),
                          child: const Text('Ana Sayfaya Dön'),
                          onPressed: () {
                            Get.back();
                            Get.back();
                            Get.back();
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Container(
                width: Get.width - 40,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(width: 1.0, color: Colors.grey[700]!)),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.gift,
                      size: 35,
                      color: kThemeColor,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Siparişin tamamlandığında ',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        Row(
                          children: [
                            Text(
                              widget.giftCoin.toString(),
                              style: const TextStyle(
                                  color: Colors.amber, fontSize: 20),
                            ),
                            const Icon(
                              CupertinoIcons.money_dollar_circle,
                              color: Colors.amber,
                            ),
                            const Text(
                              '\'i hesabında görebilirsin!',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: const [
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(height: 15),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [],
              ),
              const SizedBox(
                height: 6,
              ),
            ],
          ),
          bottomNavigationBar: SizedBox(
              height: _bannerAd2.size.height.toDouble(),
              width: _bannerAd2.size.width.toDouble(),
              child: AdWidget(
                ad: _bannerAd2,
              ))),
    );
    //  CupertinoButton(
    //     child: Text('Devam Et'),
    //     onPressed: () {
    //       //print(_isAdLoaded);
    //       if (_isAdLoaded) {
    //         _interstitalAd.show();
    //       }
    //     });
    // bottomNavigationBar: _isAdLoaded
    //     ? Container(
    //         height: _interstitalAd.size.height.toDouble(),
    //         width: _interstitalAd.size.width.toDouble(),
    //         child: AdWidget(ad: _interstitalAd),
    //       )
    //     : SizedBox(),
  }
}
