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
  bool _bannerLoadFailed = false; // 🔥 Новый флаг
  DateTime? _lastInterstitialShow;
  static const _minInterval = Duration(minutes: 3);
  static const _bannerLoadTimeout = Duration(seconds: 10); // 🔥 Таймаут 10 сек

  Future<void> init() async {
    try {
      await MobileAds.instance.initialize();
      _loadBanner();
      _loadInterstitial();
      print('✅ Google Ads инициализированы');
    } catch (e) {
      print('❌ Ошибка инициализации: $e');
      _bannerLoadFailed = true;
    }
  }

  // 🔥 ЗАГРУЗКА БАННЕРА С ТАЙМАУТОМ
  void _loadBanner() {
    _bannerLoadFailed = false;
    
    // Таймаут: если за 10 сек не загрузилось — помечаем как ошибку
    Future.delayed(_bannerLoadTimeout, () {
      if (!_isBannerLoaded && _bannerAd == null) {
        _bannerLoadFailed = true;
        print('⏰ Таймаут загрузки баннера');
      }
    });

    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isBannerLoaded = true;
          _bannerLoadFailed = false;
          print('✅ Баннер загружен');
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerLoaded = false;
          _bannerLoadFailed = true;
          print('❌ Ошибка баннера: $error');
          ad.dispose();
          // Пробуем еще раз через 30 сек
          Future.delayed(const Duration(seconds: 30), _loadBanner);
        },
        onAdOpened: (_) => print('👆 Баннер открыт'),
        onAdClosed: (_) => print('❌ Баннер закрыт'),
        onAdImpression: (_) => print('👁 Баннер показан'),
      ),
    );
    _bannerAd!.load();
  }

  bool get isBannerReady => _isBannerLoaded && _bannerAd != null && !_bannerLoadFailed;
  bool get shouldShowFallback => _bannerLoadFailed || (!_isBannerLoaded && _bannerAd == null);

  BannerAd? getBannerAd() => _bannerAd;
  Widget? getBannerWidget() {
    if (!isBannerReady) return null;
    return AdWidget(ad: _bannerAd!);
  }

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
          print('❌ Ошибка показа: $error');
          ad.dispose();
          _loadInterstitial();
        },
      );
      _interstitialAd!.show();
      _isInterstitialLoaded = false;
      _lastInterstitialShow = now;
      print('📊 Интерстициал показан');
    }
  }

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }
}