import 'dart:io';

/// AdMob reklam birimi ID'leri, tek yerden yönetilir.
///
/// `useTestAds` açıkken Google'ın herkese açık TEST reklam ID'leri
/// kullanılır -- gerçek AdMob hesabı hazır olmadan da reklamlar görünür,
/// ama gerçek gelir üretmez. Gerçek AdMob hesabı açılıp reklam birimleri
/// oluşturulunca `useTestAds`'i false yapıp ID'leri değiştir.
class AdConfig {
  static const bool useTestAds = true;

  static const String _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIOS = 'ca-app-pub-3940256099942544/2934735716';

  static const String _realBannerAndroid = 'REPLACE_WITH_REAL_ANDROID_BANNER_ID';
  static const String _realBannerIOS = 'REPLACE_WITH_REAL_IOS_BANNER_ID';

  static String get bannerAdUnitId {
    if (useTestAds) {
      return Platform.isIOS ? _testBannerIOS : _testBannerAndroid;
    }
    return Platform.isIOS ? _realBannerIOS : _realBannerAndroid;
  }
}
