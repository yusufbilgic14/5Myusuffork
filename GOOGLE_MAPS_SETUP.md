# Google Maps API Kurulumu / Google Maps API Setup

MedipolApp'te Campus Map özelliğini kullanabilmek için Google Maps API anahtarı yapılandırmanız gerekir.

## Adımlar / Steps:

### 1. Google Cloud Console'a Girin
- [Google Cloud Console](https://console.cloud.google.com/) adresine gidin
- Google hesabınızla giriş yapın

### 2. Proje Oluşturun veya Seçin
- Yeni bir proje oluşturun veya mevcut bir projeyi seçin

### 3. Maps SDK for Android'i Etkinleştirin
- Sol menüden "APIs & Services" > "Library" seçin
- "Maps SDK for Android" aratın ve etkinleştirin

### 4. API Anahtarı Oluşturun
- Sol menüden "APIs & Services" > "Credentials" seçin
- "Create Credentials" > "API Key" tıklayın
- API anahtarınızı kopyalayın

### 5. API Anahtarını Yapılandırın
`android/app/src/main/AndroidManifest.xml` dosyasını açın ve şu satırı bulun:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE" />
```

`YOUR_GOOGLE_MAPS_API_KEY_HERE` yerine gerçek API anahtarınızı yazın:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyB..." />
```

### 6. Uygulamayı Yeniden Başlatın
```bash
flutter clean
flutter pub get
flutter run
```

## Önemli Notlar:
- API anahtarınızı güvenli tutun
- Gereksiz kullanımları önlemek için API kısıtlamaları ekleyin
- Geliştirme için günlük $200 ücretsiz kredi bulunur

## Sorun Giderme:
- API anahtarı çalışmıyorsa, Android paket adının (com.example.medipolapp) doğru olduğundan emin olun
- API kısıtlamalarını kontrol edin
- Billing hesabının etkin olduğundan emin olun 