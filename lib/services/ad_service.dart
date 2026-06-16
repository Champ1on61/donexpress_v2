import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  static const String _appId = 'ca-app-pub-3940256099942544~3347511713';
  static const String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoaded = false;
  bool _isBannerLoaded = false;
  DateTime? _lastInterstitialShow;
  static const _minInterval = Duration(minutes: 3);

  Future<void> init() async {
    try {
      await MobileAds.instance.initialize();
      _loadBanner();
      _loadInterstitial();
      print('✅ Google Ads инициализированы');
    } catch (e) {
      print('❌ Ошибка инициализации: $e');
    }
  }

  // 🔥 ЗАГРУЗКА БАННЕРА
  void _loadBanner() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isBannerLoaded = true;
          print('✅ Баннер загружен');
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerLoaded = false;
          print('❌ Ошибка баннера: $error');
          ad.dispose();
          Future.delayed(const Duration(seconds: 5), _loadBanner);
        },
        onAdOpened: (_) => print('👆 Баннер открыт'),
        onAdClosed: (_) => print('❌ Баннер закрыт'),
        onAdImpression: (_) => print('👁 Баннер показан'),
      ),
    );
    _bannerAd!.load();
  }

  // 🔥 ПРОВЕРКА: баннер готов?
  bool get isBannerReady => _isBannerLoaded && _bannerAd != null;

  // 🔥 ПОЛУЧИТЬ БАННЕР
  BannerAd? getBannerAd() => _bannerAd;

  // 🔥 ВОЗВРАЩАЕМ ВИДЖЕТ БАННЕРА
  Widget? getBannerWidget() {
    if (!isBannerReady) return null;
    return AdWidget(ad: _bannerAd!);
  }

  // 🔥 ЗАГРУЗКА ИНТЕРСТИЦИАЛА
  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
          print('✅ Интерстициал загружен');
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoaded = false;
          print('❌ Ошибка интерстициала: $error');
        },
      ),
    );
  }

  // 🔥 ПОКАЗ ИНТЕРСТИЦИАЛА
  void showInterstitial() {
    final now = DateTime.now();
    if (_lastInterstitialShow != null && 
        now.difference(_lastInterstitialShow!) < _minInterval) {
      print('⏳ Слишком рано для рекламы');
      return;
    }
    
    if (_isInterstitialLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitial();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('❌ Ошибка показа интерстициала: $error');
          ad.dispose();
          _loadInterstitial();
        },
      );
      _interstitialAd!.show();
      _isInterstitialLoaded = false;
      _lastInterstitialShow = now;
      print('📊 Интерстициал показан');
    } else {
      print('⚠️ Интерстициал ещё не загружен');
    }
  }

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }
}