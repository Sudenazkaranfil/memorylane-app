# MemoryLane — Mobile App

Flutter ile geliştirilmiş dijital seyahat ajandası uygulaması. Kullanıcılar gezilerini sayfa sayfa, scrapbook tarzında kaydedebilir, haritada görebilir ve keşfedebilir.

## Teknolojiler

- Flutter (Dart)
- REST API entegrasyonu (http paketi)
- OpenStreetMap + flutter_map (harita)
- Nominatim API (geocoding)
- image_picker (fotoğraf seçimi)
- shared_preferences (token saklama)
- Custom canvas editör (drag-drop, çizim, emoji, konum)

## Özellikler

- Kullanıcı kayıt / giriş (JWT)
- Ajanda oluşturma ve yönetimi
- Canvas/scrapbook sayfa editörü
  - Fotoğraf ekleme ve sürükleme
  - Yazı kutusu
  - Emoji seçici (7 kategori, 100+ emoji)
  - Parmakla serbest çizim (renk ve boyut seçimi)
  - Konum etiketi (Nominatim geocoding)
- Defter görünümü (PageView + thumbnail)
- Harita ekranı (kendi konumların + public konumlar)
- Keşfet ekranı (public ajandalar, arama)
- Profil düzenleme
- Ajanda gizlilik yönetimi (public/private)

## Kurulum

### Gereksinimler
- Flutter 3.x
- Android Studio / VS Code
- Android emülatör veya fiziksel cihaz

### Adımlar

1. Repoyu klonla
```bash
git clone https://github.com/Sudenazkaranfil/memorylane-app.git
cd memorylane_app
```

2. Bağımlılıkları yükle
```bash
flutter pub get
```

3. Backend URL'ini güncelle
`lib/services/` klasöründeki tüm service dosyalarında `baseUrl`'i kendi backend adresinle değiştir.

4. Uygulamayı çalıştır
```bash
flutter run
```

## Ekran Görüntüleri

_Yakında eklenecek_

## Backend

Bu uygulama [MemoryLane Backend](https://github.com/Sudenazkaranfil/memorylane) ile çalışır.
