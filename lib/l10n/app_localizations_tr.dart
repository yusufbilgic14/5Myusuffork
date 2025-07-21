// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Medipol Üniversitesi';

  @override
  String get loginTitle => 'Giriş Yap';

  @override
  String get signUpTitle => 'Hesap Oluştur';

  @override
  String get loginSubtitle => 'Öğrenci bilgilerinizle giriş yapın';

  @override
  String get studentId => 'Öğrenci Numarası';

  @override
  String get password => 'Şifre';

  @override
  String get forgotPassword => 'Şifremi Unuttum';

  @override
  String get loginButton => 'Giriş Yap';

  @override
  String get or => 'veya';

  @override
  String get loginWithMicrosoft => 'Microsoft ile Giriş Yap';

  @override
  String get invalidStudentId => 'Lütfen öğrenci numaranızı girin';

  @override
  String get invalidPassword => 'Lütfen şifrenizi girin';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageEnglish => 'İngilizce';

  @override
  String get language => 'Dil';

  @override
  String get languageDesc => 'Uygulama dilini değiştirin.';

  @override
  String get homeWelcome => 'Hoş geldin,';

  @override
  String get announcements => 'Duyurular';

  @override
  String get seeAll => 'Tümünü Gör';

  @override
  String get todaysCourses => 'Bugünün Dersleri';

  @override
  String get todayDate => 'Cuma, 24 Mayıs';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get markAllRead => 'Tümünü Okundu İşaretle';

  @override
  String get navigation => 'Navigasyon';

  @override
  String get calendar => 'Takvim';

  @override
  String get mondayShort => 'Pzt';

  @override
  String get tuesdayShort => 'Sal';

  @override
  String get wednesdayShort => 'Çar';

  @override
  String get thursdayShort => 'Per';

  @override
  String get fridayShort => 'Cum';

  @override
  String get saturdayShort => 'Cmt';

  @override
  String get sundayShort => 'Paz';

  @override
  String get home => 'Anasayfa';

  @override
  String get scan => 'Tara';

  @override
  String get profile => 'Profil';

  @override
  String get userName => 'Elif Yılmaz';

  @override
  String get userDepartment => 'YBS';

  @override
  String get userGrade => '3. Sınıf';

  @override
  String get settings => 'Ayarlar';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get logoutConfirm =>
      'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?';

  @override
  String get cancel => 'İptal';

  @override
  String get messageBox => 'Gelen Kutusu';

  @override
  String get feedbacks => 'Geri Bildirimler';

  @override
  String get cafeteriaMenu => 'Yemekhane Menüsü';

  @override
  String get breakfast => 'Kahvaltı';

  @override
  String get lunch => 'Öğle';

  @override
  String get dinner => 'Akşam';

  @override
  String get academicCalendar => 'Akademik Takvim';

  @override
  String get courseGrades => 'Ders Notları';

  @override
  String get upcomingEvents => 'Yaklaşan Etkinlikler';

  @override
  String get events => 'Etkinlikler';

  @override
  String get clubs => 'Kulüpler';

  @override
  String get myEvents => 'Etkinliklerim';

  @override
  String get helpSupport => 'Yardım ve Destek';

  @override
  String get inbox => 'Gelen Kutusu';

  @override
  String get feedback => 'Geri Bildirim ve Talep';

  @override
  String get feedbackOnly => 'Geri Bildirim';

  @override
  String get quickStats => 'Hızlı İstatistikler';

  @override
  String get accountSettings => 'Hesap Ayarları';

  @override
  String get qrAccess => 'QR Erişim';

  @override
  String get campusTransport => 'Kampüse Ulaşım';

  @override
  String get statsEvents => 'Katılınan Etkinlik';

  @override
  String get statsGpa => 'GNO';

  @override
  String get statsComplaints => 'Şikayet Sayısı';

  @override
  String get statsAssignments => 'Tamamlanan Ödev';

  @override
  String get notificationSettings => 'Bildirim Ayarları';

  @override
  String get eventNotifications => 'Etkinlik Bildirimleri';

  @override
  String get gradeNotifications => 'Sınav Bildirimleri';

  @override
  String get messageNotifications => 'Mesaj Bildirimleri';

  @override
  String get clubNotifications => 'Kulüp ve Topluluk Duyuruları';

  @override
  String get save => 'Kaydet';

  @override
  String get notificationSettingsSaved => 'Bildirim ayarları kaydedildi.';

  @override
  String get notificationSettingsDesc => 'Hangi bildirimleri alacağınızı seçin';

  @override
  String get helpSupportDesc => 'SSS ve iletişim bilgileri';

  @override
  String get campusTransportDesc =>
      'Aşağıdaki hat ve güzergahlar, İstanbul Medipol Üniversitesi Kavacık Güney ve Kuzey Kampüsleri’ne ulaşım içindir.';

  @override
  String get europeanSide => 'Avrupa Yakası';

  @override
  String get anatolianSide => 'Anadolu Yakası';

  @override
  String get ingredients => 'Malzemeler';

  @override
  String allergens(Object allergens) {
    return 'Alerjenler: $allergens';
  }

  @override
  String get menuNotFound => 'Menü Bulunamadı';

  @override
  String menuNotFoundFilter(Object mealName) {
    return 'Seçili filtrelere uygun $mealName menüsü bulunamadı.';
  }

  @override
  String get noEventsFound => 'Etkinlik Bulunamadı';

  @override
  String get noEventsFilter =>
      'Seçili filtrelere uygun akademik takvim etkinliği bulunamadı.';

  @override
  String get clearFilters => 'Filtreleri Temizle';

  @override
  String get startDate => 'Başlangıç';

  @override
  String get endDate => 'Bitiş';

  @override
  String get logoutDesc => 'Hesabınızdan güvenli şekilde çıkış yapın';

  @override
  String get theme => 'Tema';

  @override
  String get themeDesc => 'Uygulama temasını değiştir (açık/koyu)';

  @override
  String get contact => 'İletişim';

  @override
  String get contactDesc =>
      'Her türlü soru, görüş ve destek talepleriniz için aşağıdaki iletişim kanallarını kullanabilirsiniz.';

  @override
  String get kavacikNorth => 'Kavacık Kuzey Yerleşkesi';

  @override
  String get kavacikNorthDesc =>
      'Yerleşke; Medipol Üniversitesi Kavacık (Ana Yerleşke Rektörlük)';

  @override
  String get feedbackTitle => 'Görüşleriniz Bizim İçin Değerli';

  @override
  String get feedbackDesc =>
      'Medipol uygulamasını daha iyi hale getirmek için görüşlerinizi ve önerilerinizi bizimle paylaşın.';

  @override
  String get feedbackDetail => 'Detaylı Açıklama';

  @override
  String get feedbackDetailHint =>
      'Geri bildiriminizi detaylı olarak açıklayın...';

  @override
  String get feedbackRequired => 'Açıklama gerekli';

  @override
  String get feedbackMinLength => 'Açıklama en az 20 karakter olmalı';

  @override
  String get clear => 'Temizle';

  @override
  String get sendFeedback => 'Geri Bildirim Gönder';

  @override
  String get sending => 'Gönderiliyor...';

  @override
  String get clearForm => 'Formu Temizle';

  @override
  String get rateApp => 'Uygulamayı puanlamak ve yorum yapmak için tıklayınız';

  @override
  String get what_do_you_want_to_do => 'Ne yapmak istiyorsunuz?';

  @override
  String get request => 'Talep';

  @override
  String get select_request_category => 'Talep Kategorisi Seçin';

  @override
  String get select_feedback_category => 'Geri Bildirim Kategorisi Seçin';

  @override
  String get rate_and_comment_app =>
      'Uygulamayı puanlamak ve yorum yapmak için tıklayınız';

  @override
  String get redirect_to_app_store =>
      'Uygulama mağazasına yönlendirileceksiniz...';

  @override
  String get anonymous_feedback => 'Anonim Geri Bildirim';

  @override
  String get keep_my_identity_private =>
      'Kimliğim gizli kalsın, anonim olarak geri bildirim göndermek istiyorum.';

  @override
  String get relevant_department => 'İlgili Departman';

  @override
  String get select_department => 'Departman seçin';

  @override
  String get please_select_department => 'Lütfen bir departman seçin';

  @override
  String get priority_level => 'Öncelik Seviyesi';

  @override
  String get email_address => 'E-posta Adresi';

  @override
  String get example_email => 'ornek@medipol.edu.tr';

  @override
  String get email_address_required => 'E-posta adresi gerekli';

  @override
  String get valid_email_address => 'Geçerli bir e-posta adresi girin';

  @override
  String get subject => 'Konu';

  @override
  String get feedback_subject => 'Geri bildirim konusu';

  @override
  String get subject_required => 'Konu gerekli';

  @override
  String get subject_min_length => 'Konu en az 5 karakter olmalı';

  @override
  String get detailed_description => 'Detaylı Açıklama';

  @override
  String get describe_your_feedback =>
      'Geri bildiriminizi detaylı olarak açıklayın...';

  @override
  String get description_required => 'Açıklama gerekli';

  @override
  String get description_min_length => 'Açıklama en az 20 karakter olmalı';

  @override
  String get add_photo_or_document => 'Fotoğraf veya Belge Ekle';

  @override
  String get click_to_select_file => 'Dosya seçmek için tıklayın';

  @override
  String get file_types_max_size => 'JPG, PNG, PDF (Maksimum 10MB)';

  @override
  String get selected_files => 'Seçilen Dosyalar:';

  @override
  String get file_added => 'Dosya eklendi:';

  @override
  String get file_removed => 'Dosya kaldırıldı:';

  @override
  String get please_select_feedback_or_request_type =>
      'Lütfen talep veya geri bildirim türünü seçin';

  @override
  String get please_select_request_category =>
      'Lütfen bir talep kategorisi seçin';

  @override
  String get please_select_feedback_category =>
      'Lütfen bir geri bildirim kategorisi seçin';

  @override
  String get your_feedback_submitted_successfully =>
      'Geri bildiriminiz başarıyla gönderildi! Teşekkür ederiz.';

  @override
  String get clear_form => 'Formu Temizle';

  @override
  String get your_feedback_is_valuable => 'Görüşleriniz Bizim İçin Değerli';

  @override
  String get share_your_opinions_and_suggestions_for_better_app =>
      'Medipol uygulamasını daha iyi hale getirmek için görüşlerinizi ve önerilerinizi bizimle paylaşın.';

  @override
  String get submitting => 'Gönderiliyor...';

  @override
  String get send_feedback => 'Geri Bildirim Gönder';

  @override
  String get messages => 'mesaj';

  @override
  String get unread => 'okunmamış';

  @override
  String get back => 'Geri';

  @override
  String get attachments => 'Ek Dosyalar';

  @override
  String get reply => 'Yanıtla';

  @override
  String get forward => 'İlet';

  @override
  String get delete => 'Sil';

  @override
  String get pointPDF => 'Point PDF';

  @override
  String get transcript => 'Transcript';

  @override
  String get semesterGPA => 'Dönem GPA';

  @override
  String get cumulativeGPA => 'Genel GPA';

  @override
  String get totalCourses => 'Toplam Ders';

  @override
  String get completedCourses => 'Tamamlanan';

  @override
  String get waitingGrades => 'Beklemede';

  @override
  String get credits => 'Kredi';

  @override
  String get searchCourseNameOrCode => 'Ders adı veya kodu ara...';

  @override
  String get status => 'Durum';

  @override
  String get sortBy => 'Sırala';

  @override
  String get noCoursesFound => 'Arama kriterlerinize uygun ders bulunamadı.';

  @override
  String get gpa => 'GPA';

  @override
  String get detailedGrades => 'Detaylı Notlar';

  @override
  String get waiting => 'Beklemede...';

  @override
  String get semester => 'Dönem';

  @override
  String get semesterGpa => 'Dönem GPA';

  @override
  String get cumulativeGpa => 'Genel GPA';

  @override
  String get pdfReportWillBeGenerated =>
      'Bu dönem için PDF raporu oluşturulacak...';

  @override
  String get pdfFeatureWillBeAddedSoon => 'PDF özelliği yakında eklenecektir.';

  @override
  String get ok => 'Tamam';

  @override
  String get overallTranscriptForAllSemestersWillBePrepared =>
      'Tüm dönemler için genel transcript hazırlanacak...';

  @override
  String get totalGpa => 'Toplam GPA';

  @override
  String get totalCredits => 'Toplam Kredi';

  @override
  String get content => 'İçerik';

  @override
  String get courses => 'ders';

  @override
  String get transcriptFeatureWillBeAddedSoon =>
      'Transcript özelliği yakında eklenecektir.';

  @override
  String get refreshingGrades => 'Notlar yenileniyor...';

  @override
  String get gradesUpdatedSuccessfully => 'Notlar başarıyla güncellendi!';

  @override
  String get qrScanner => 'QR Kod Tarayıcısı';

  @override
  String get cameraPermissionPermanentlyDenied =>
      'Kamera izni kalıcı olarak reddedildi. Ayarlardan izin verin.';

  @override
  String get cameraPermissionRequired => 'Kamera İzni Gerekli';

  @override
  String get enableCameraPermissionInSettings =>
      'Ayarlardan kamera iznini etkinleştirin.';

  @override
  String get needCameraPermissionToScan =>
      'QR kod taramak için kamera iznine ihtiyacımız var.';

  @override
  String get startingCamera => 'Kamera başlatılıyor...';

  @override
  String get filterBuildingTypes => 'Bina Türlerini Filtrele';

  @override
  String get all => 'Tümü';

  @override
  String get academicBuildings => 'Akademik Binalar';

  @override
  String get administrativeBuildings => 'İdari Binalar';

  @override
  String get socialAreas => 'Sosyal Alanlar';

  @override
  String get sportsFacilities => 'Spor Tesisleri';

  @override
  String get shuttleStops => 'Servis Durakları';

  @override
  String get close => 'Kapat';

  @override
  String get mapNotLoaded => 'Harita Yüklenemedi';

  @override
  String get googleMapsNotLoaded => 'Google Maps yüklenemedi.';

  @override
  String get checkApiKeyOrInternet =>
      'API anahtarı yapılandırmasını kontrol edin veya internet bağlantınızı doğrulayın.';

  @override
  String get tryAgain => 'Tekrar Dene';

  @override
  String get courseVisualProgramming => 'Görsel Programlama';

  @override
  String get courseDataStructures => 'Veri Yapıları';

  @override
  String get courseDiscreteMathematics => 'Ayrık Matematik';

  @override
  String get courseTechnicalEnglish => 'Teknik İngilizce';

  @override
  String get instructorAhmetYilmaz => 'Dr. Ahmet Yılmaz';

  @override
  String get instructorFatmaKaya => 'Prof. Fatma Kaya';

  @override
  String get instructorMehmetOzkan => 'Dr. Mehmet Özkan';

  @override
  String get instructorSarahJohnson => 'Ms. Sarah Johnson';

  @override
  String get noCoursesToday => 'Bugün için ders bulunamadı.';

  @override
  String get timelineView => 'Zaman Çizelgesi Görünümü';

  @override
  String get monthView => 'Ay Görünümü';

  @override
  String get monthlyCalendar => 'Aylık Takvim';

  @override
  String get campusQrTitle => 'Kampüs Giriş QR Kodu';

  @override
  String get validTime => 'Geçerli süre';

  @override
  String get refresh => 'Yenile';

  @override
  String get scanQr => 'QR Kodu Tarat';

  @override
  String get qrInfo =>
      'Bu QR kodu kampüs giriş tarayıcılarında kullanın. Güvenlik için kod otomatik olarak yenilenir.';

  @override
  String get secureCampusAccess => 'Güvenli kampüs erişimi';

  @override
  String get urlCouldNotOpen => 'URL açılamadı';

  @override
  String get anErrorOccurred => 'Bir hata oluştu';

  @override
  String get studentIdHint => '2024520001';

  @override
  String get inboxSubject1 => 'Öğrenci Belgesi Talebiniz Hakkında';

  @override
  String get inboxSender1 => 'Öğrenci İşleri';

  @override
  String get inboxContent1 =>
      'Sayın Elif Yılmaz,\n\n24.06.2025 tarihinde talepte bulunduğunuz öğrenci belgesi hazırlanmıştır. \n\nBelgenizi aşağıdaki şekillerde temin edebilirsiniz:\n• Öğrenci İşleri ofisimizden şahsen teslim alabilirsiniz\n• Kargo ile adresinize göndermek için ek ücret karşılığında başvurabilirsiniz\n\nOfis saatleri: Pazartesi-Cuma 09:00-17:00\n\nSaygılarımızla,\nÖğrenci İşleri Müdürlüğü';

  @override
  String get inboxSubject2 => 'Burs Başvuru Sonucu';

  @override
  String get inboxSender2 => 'Burs ve Yardım İşleri';

  @override
  String get inboxContent2 =>
      'Sayın Elif Yılmaz,\n\n2024-2025 Akademik Yılı Başarı Bursu başvurunuz değerlendirilmiş olup, başvurunuzun KABUL edildiğini bildiririz.\n\nBurs Detayları:\n• Burs Türü: Başarı Bursu (%25)\n• Geçerli Dönem: 2025-2026 Güz Dönemi\n• Ödeme Tarihi: Kayıt yenileme sonrası\n\nSaygılarımızla,\nBurs ve Yardım İşleri';

  @override
  String get requestCategoryAcademicSupport => 'Akademik Destek';

  @override
  String get requestCategoryTechnicalHelp => 'Teknik Yardım';

  @override
  String get requestCategoryLibrary => 'Kütüphane Hizmetleri';

  @override
  String get requestCategoryCafeteria => 'Yemekhane Hizmetleri';

  @override
  String get requestCategoryTransport => 'Ulaşım Talebi';

  @override
  String get requestCategorySecurity => 'Güvenlik Desteği';

  @override
  String get requestCategoryFinance => 'Mali İşler';

  @override
  String get requestCategoryGeneral => 'Genel Talep';

  @override
  String get feedbackCategoryBugReport => 'Hata Bildirimi';

  @override
  String get feedbackCategorySuggestion => 'Öneri';

  @override
  String get feedbackCategoryComplaint => 'Şikayet';

  @override
  String get feedbackCategoryAppreciation => 'Takdir';

  @override
  String get feedbackCategoryFeatureRequest => 'Özellik İsteği';

  @override
  String get feedbackCategoryAppReview => 'Uygulama Yorumu';

  @override
  String get feedbackCategoryGeneral => 'Genel Geri Bildirim';

  @override
  String get searchBuildingOrLocation => 'Bina veya konum ara...';

  @override
  String get routeInfo => 'Rota Bilgisi';

  @override
  String get yourCurrentLocation => 'Mevcut Konumunuz';

  @override
  String get engineeringFaculty => 'Mühendislik Fakültesi';

  @override
  String get walking => 'Yürüyüş';

  @override
  String get shuttle => 'Servis';

  @override
  String get bike => 'Bisiklet';

  @override
  String get startNavigation => 'Navigasyonu Başlat';

  @override
  String get mainBuilding => 'Ana Bina';

  @override
  String get northCampus => 'Kuzey Kampüs';

  @override
  String get kavacikBridgeBusStop => 'Kavacık Köprüsü Otobüs Durağı';

  @override
  String get asiaRoad => 'Asya Yolu';

  @override
  String get europeRoad => 'Avrupa Yolu';

  @override
  String get kavacikBusStop => 'Kavacık Otobüs Durağı';

  @override
  String get ataturkStreetBeykoz => 'Atatürk Caddesi/Beykoz';

  @override
  String get kavacikJunctionBusStop => 'Kavacık Sapağı Otobüs Durağı';

  @override
  String get kavacikJunctionBeykoz => 'Kavacık Sapağı/Beykoz';

  @override
  String get yeniRivaYoluBusStop => 'Yeni Riva Yolu Otobüs Durağı';

  @override
  String get mapLoading => 'Harita yükleniyor...';

  @override
  String get monShort => 'Pzt';

  @override
  String get tueShort => 'Sal';

  @override
  String get wedShort => 'Çar';

  @override
  String get thuShort => 'Per';

  @override
  String get friShort => 'Cum';

  @override
  String get satShort => 'Cmt';

  @override
  String get sunShort => 'Paz';

  @override
  String get monday => 'Pazartesi';

  @override
  String get tuesday => 'Salı';

  @override
  String get wednesday => 'Çarşamba';

  @override
  String get thursday => 'Perşembe';

  @override
  String get friday => 'Cuma';

  @override
  String get saturday => 'Cumartesi';

  @override
  String get sunday => 'Pazar';

  @override
  String get halicCampus => 'Haliç Yerleşkesi';
  @override
  String get halicCampusDesc =>
      'Yerleşke; Medipol Üniversitesi Haliç Yerleşkesi';
  @override
  String get bagcilarCampus => 'Bağcılar Yerleşkesi';
  @override
  String get bagcilarCampusDesc =>
      'Yerleşke; Üniversite Hastanesi (Bağcılar Yerleşkesi)';
  @override
  String get healthResearchCenters => 'Sağlık Uygulama Araştırma Merkezleri';
  @override
  String get healthResearchCentersDent => 'Sağlık UA Merkezi Diş Hastanesi';
  @override
  String get healthResearchCentersVatan => 'Sağlık UA Merkezi Vatan Kliniği';
  @override
  String get healthResearchCentersEsenler =>
      'Sağlık UA Merkezi Esenler Hastanesi';
  @override
  String get fax => 'Faks:';
  @override
  String get faxRectorate => 'Faks (Rektörlük):';
  @override
  String get faxAccounting => 'Faks (Muhasebe):';
  @override
  String get faxFaculties => 'Faks (Fakülteler):';
  @override
  String get phoneInternal => 'Telefon (Dahili):';
  @override
  String get website => 'İnternet Sitesi:';
  @override
  String get address => 'Adres:';

  // Sign up related translations

  @override
  String get signUpSubtitle => 'Yeni hesabınızı oluşturun';

  @override
  String get fullName => 'Ad Soyad';

  @override
  String get fullNameHint => 'Adınızı ve soyadınızı girin';

  @override
  String get fullNameRequired => 'Ad soyad gerekli';

  @override
  String get fullNameInvalid => 'Lütfen ad ve soyadınızı girin';

  @override
  String get emailAddress => 'Email Adresi';

  @override
  String get emailHint => 'ornek@email.com';

  @override
  String get emailRequired => 'Email adresi gerekli';

  @override
  String get emailInvalid => 'Geçerli bir email adresi girin';

  @override
  String get createPassword => 'Şifre Oluştur';

  @override
  String get createPasswordHint => 'Güçlü bir şifre oluşturun';

  @override
  String get passwordRequired => 'Şifre gerekli';

  @override
  String get passwordTooShort => 'Şifre en az 8 karakter olmalı';

  @override
  String get passwordTooWeak => 'Şifre büyük harf, küçük harf ve rakam içermeli';

  @override
  String get confirmPassword => 'Şifre Tekrar';

  @override
  String get confirmPasswordHint => 'Şifrenizi tekrar girin';

  @override
  String get confirmPasswordRequired => 'Şifre tekrarı gerekli';

  @override
  String get passwordsDoNotMatch => 'Şifreler eşleşmiyor';

  @override
  String get departmentOptional => 'Bölüm (Opsiyonel)';

  @override
  String get selectDepartment => 'Bölümünüzü seçin';

  @override
  String get phoneOptional => 'Telefon (İsteğe Bağlı)';

  @override
  String get phoneHint => '+90 5xx xxx xx xx';

  @override
  String get phoneInvalid => 'Geçerli bir telefon numarası girin';

  @override
  String get studentIdOptional => 'Öğrenci No (İsteğe Bağlı)';

  @override
  String get studentIdHintSignup => '2024520001';

  @override
  String get yearOfStudyOptional => 'Sınıf (İsteğe Bağlı)';

  @override
  String get selectYearOfStudy => 'Sınıfınızı seçin';

  @override
  String get birthDateOptional => 'Doğum Tarihi (İsteğe Bağlı)';

  @override
  String get selectBirthDate => 'Doğum tarihinizi seçin';

  @override
  String get genderOptional => 'Cinsiyet (İsteğe Bağlı)';

  @override
  String get selectGender => 'Cinsiyetinizi seçin';

  @override
  String get male => 'Erkek';

  @override
  String get female => 'Kadın';

  @override
  String get preferNotToSay => 'Belirtmek istemiyorum';

  @override
  String get termsAndConditions => 'Kullanım Şartları';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get agreeToTerms => 'Medipol Uygulaması Kullanım Şartları ve Gizlilik Politikasını okuduğumu ve kabul ettiğimi onaylarım.';

  @override
  String get pleaseAcceptTerms => 'Lütfen kullanım şartlarını kabul edin';

  @override
  String get createAccount => 'Hesap Oluştur';

  @override
  String get alreadyHaveAccount => 'Zaten hesabınız var mı?';

  @override
  String get signInHere => 'Giriş Yap';

  @override
  String get dontHaveAccount => 'Hesabınız yok mu?';

  @override
  String get signUpHere => 'Kayıt Ol';

  @override
  String get accountCreatedSuccessfully => 'Hesap başarıyla oluşturuldu! Lütfen email adresinizi doğrulayın.';

  @override
  String get firstYear => '1. Sınıf';

  @override
  String get secondYear => '2. Sınıf';

  @override
  String get thirdYear => '3. Sınıf';

  @override
  String get fourthYear => '4. Sınıf';

  @override
  String get graduateStudent => 'Yüksek Lisans';

  @override
  String get phdStudent => 'Doktora';
}
