/// String utility functions for common text operations
/// Yaygın metin işlemleri için string yardımcı fonksiyonları
class StringUtils {
  
  /// Capitalize first letter of each word
  /// Her kelimenin ilk harfini büyük yap
  static String toTitleCase(String text) {
    if (text.isEmpty) return text;
    
    return text.split(' ')
        .map((word) => word.isEmpty ? word : 
             '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  /// Capitalize only first letter
  /// Sadece ilk harfi büyük yap
  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  /// Remove Turkish characters and convert to ASCII
  /// Türkçe karakterleri kaldır ve ASCII'ye dönüştür
  static String removeTurkishChars(String text) {
    final turkishToAscii = {
      'ç': 'c', 'Ç': 'C',
      'ğ': 'g', 'Ğ': 'G',
      'ı': 'i', 'İ': 'I',
      'ö': 'o', 'Ö': 'O',
      'ş': 's', 'Ş': 'S',
      'ü': 'u', 'Ü': 'U',
    };
    
    String result = text;
    turkishToAscii.forEach((turkish, ascii) {
      result = result.replaceAll(turkish, ascii);
    });
    
    return result;
  }

  /// Create URL-friendly slug from text
  /// Metinden URL dostu slug oluştur
  static String createSlug(String text) {
    return removeTurkishChars(text)
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  /// Truncate text with ellipsis
  /// Metni üç nokta ile kısalt
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - suffix.length)}$suffix';
  }

  /// Extract initials from full name
  /// Tam isimden baş harfleri çıkar
  static String getInitials(String fullName, {int maxInitials = 2}) {
    final words = fullName.trim().split(RegExp(r'\s+'));
    final initials = words
        .take(maxInitials)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .where((initial) => initial.isNotEmpty)
        .join();
    
    return initials.isEmpty ? '?' : initials;
  }

  /// Format phone number to Turkish format
  /// Telefon numarasını Türk formatına dönüştür
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    // Handle different formats
    if (digits.length == 10 && digits.startsWith('5')) {
      // 5xxxxxxxxx -> 0 5xx xxx xx xx
      return '0 ${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6, 8)} ${digits.substring(8)}';
    } else if (digits.length == 11 && digits.startsWith('05')) {
      // 05xxxxxxxxx -> 0 5xx xxx xx xx
      return '0 ${digits.substring(1, 4)} ${digits.substring(4, 7)} ${digits.substring(7, 9)} ${digits.substring(9)}';
    } else if (digits.length == 12 && digits.startsWith('905')) {
      // 905xxxxxxxxx -> 0 5xx xxx xx xx
      return '0 ${digits.substring(2, 5)} ${digits.substring(5, 8)} ${digits.substring(8, 10)} ${digits.substring(10)}';
    } else if (digits.length == 13 && digits.startsWith('+905')) {
      // +905xxxxxxxxx -> 0 5xx xxx xx xx
      return '0 ${digits.substring(3, 6)} ${digits.substring(6, 9)} ${digits.substring(9, 11)} ${digits.substring(11)}';
    }
    
    // Return original if no pattern matches
    return phoneNumber;
  }

  /// Check if string is null or empty
  /// String'in null veya boş olup olmadığını kontrol et
  static bool isNullOrEmpty(String? str) {
    return str == null || str.isEmpty;
  }

  /// Check if string is null, empty, or only whitespace
  /// String'in null, boş veya sadece boşluk olup olmadığını kontrol et
  static bool isNullOrWhitespace(String? str) {
    return str == null || str.trim().isEmpty;
  }

  /// Remove extra whitespaces and normalize text
  /// Fazla boşlukları kaldır ve metni normalize et
  static String normalizeWhitespace(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Convert string to snake_case
  /// String'i snake_case'e dönüştür
  static String toSnakeCase(String text) {
    return text
        .replaceAllMapped(RegExp(r'[A-Z]'), (Match match) => '_${match.group(0)!.toLowerCase()}')
        .replaceAll(RegExp(r'^_'), '')
        .replaceAll(RegExp(r'[\s-]+'), '_')
        .toLowerCase();
  }

  /// Convert string to camelCase
  /// String'i camelCase'e dönüştür
  static String toCamelCase(String text) {
    final words = text.split(RegExp(r'[\s_-]+'));
    if (words.isEmpty) return text;
    
    return words.first.toLowerCase() + 
           words.skip(1).map((word) => capitalizeFirst(word.toLowerCase())).join('');
  }

  /// Generate random string
  /// Rastgele string oluştur
  static String generateRandomString(int length, {bool includeNumbers = true}) {
    const letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    final chars = letters + (includeNumbers ? numbers : '');
    
    return List.generate(length, 
        (index) => chars[(DateTime.now().millisecondsSinceEpoch + index) % chars.length]
    ).join();
  }

  /// Check if string contains only alphabetic characters
  /// String'in sadece alfabetik karakter içerip içermediğini kontrol et
  static bool isAlphabetic(String text) {
    return RegExp(r'^[a-zA-ZğüşıöçĞÜŞİÖÇ]+$').hasMatch(text);
  }

  /// Check if string contains only numeric characters
  /// String'in sadece sayısal karakter içerip içermediğini kontrol et
  static bool isNumeric(String text) {
    return RegExp(r'^\d+$').hasMatch(text);
  }

  /// Check if string contains only alphanumeric characters
  /// String'in sadece alfanümerik karakter içerip içermediğini kontrol et
  static bool isAlphaNumeric(String text) {
    return RegExp(r'^[a-zA-Z0-9ğüşıöçĞÜŞİÖÇ]+$').hasMatch(text);
  }

  /// Format text as currency (Turkish Lira)
  /// Metni para birimi olarak formatla (Türk Lirası)
  static String formatCurrency(double amount, {String symbol = '₺'}) {
    return '${amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )} $symbol';
  }

  /// Format large numbers with K, M, B suffixes
  /// Büyük sayıları K, M, B ekleriyle formatla
  static String formatLargeNumber(int number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  /// Extract hashtags from text
  /// Metinden hashtag'leri çıkar
  static List<String> extractHashtags(String text) {
    final regex = RegExp(r'#(\w+)');
    return regex.allMatches(text)
        .map((match) => match.group(1)!)
        .toList();
  }

  /// Extract mentions from text
  /// Metinden mention'ları çıkar
  static List<String> extractMentions(String text) {
    final regex = RegExp(r'@(\w+)');
    return regex.allMatches(text)
        .map((match) => match.group(1)!)
        .toList();
  }

  /// Remove HTML tags from text
  /// Metinden HTML etiketlerini kaldır
  static String removeHtmlTags(String htmlText) {
    return htmlText.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// Escape special characters for RegExp
  /// RegExp için özel karakterleri kaçır
  static String escapeRegExp(String text) {
    return text.replaceAll(RegExp(r'[.*+?^${}()|[\]\\]'), r'\$&');
  }

  /// Calculate Levenshtein distance between two strings
  /// İki string arasındaki Levenshtein mesafesini hesapla
  static int levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    final matrix = List.generate(
      s1.length + 1,
      (i) => List.filled(s2.length + 1, 0),
    );

    for (int i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,      // deletion
          matrix[i][j - 1] + 1,      // insertion
          matrix[i - 1][j - 1] + cost // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[s1.length][s2.length];
  }

  /// Calculate string similarity (0.0 to 1.0)
  /// String benzerliğini hesapla (0.0 - 1.0)
  static double calculateSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    final maxLength = s1.length > s2.length ? s1.length : s2.length;
    if (maxLength == 0) return 1.0;
    
    final distance = levenshteinDistance(s1, s2);
    return 1.0 - (distance / maxLength);
  }
}