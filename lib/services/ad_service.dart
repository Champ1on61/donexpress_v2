import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // 🔹 ТЕСТОВЫЕ ID AdMob (работают сразу!)
  static const String _appId = 'ca-app-pub-3940256099942544~3347511713';
  static const String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoaded = false;

  Future<void> init() async {
    await MobileAds.instance.initialize();
    _loadInterstitial();
    print('✅ Google Ads готовы!');
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
        },
        onAdFailedToLoad: (error) {
          print('❌ Ошибка: $error');
          _isInterstitialLoaded = false;
        },
      ),
    );
  }

  void showInterstitial() {
    if (_isInterstitialLoaded && _interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitial();
        },
      );
      _isInterstitialLoaded = false;
    }
  }

  Widget? createBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => print('✅ Баннер загружен'),
        onAdFailedToLoad: (ad, error) {
          print('❌ Баннер: $error');
          ad.dispose();
        },
      ),
    );
    return AdWidget(ad: _bannerAd!);
  }

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }
}