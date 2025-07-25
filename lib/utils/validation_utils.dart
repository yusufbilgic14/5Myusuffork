import 'package:flutter/material.dart';

/// Validation utility class for common form validations
/// Yaygın form doğrulamaları için doğrulama yardımcı sınıfı
class ValidationUtils {
  
  /// Email validation
  /// E-posta doğrulaması
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresi gerekli';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    
    return null;
  }

  /// Password validation
  /// Şifre doğrulaması
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    
    if (value.length < minLength) {
      return 'Şifre en az $minLength karakter olmalı';
    }
    
    return null;
  }

  /// Required field validation
  /// Zorunlu alan doğrulaması
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Bu alan'} gerekli';
    }
    return null;
  }

  /// Phone number validation (Turkish format)
  /// Telefon numarası doğrulaması (Türk formatı)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon numarası gerekli';
    }
    
    // Remove spaces and special characters
    final cleanNumber = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Turkish mobile number format
    final phoneRegex = RegExp(r'^(\+90|0)?5[0-9]{9}$');
    if (!phoneRegex.hasMatch(cleanNumber)) {
      return 'Geçerli bir telefon numarası girin (05XXXXXXXXX)';
    }
    
    return null;
  }

  /// Name validation
  /// İsim doğrulaması
  static String? validateName(String? value, {int minLength = 2}) {
    if (value == null || value.trim().isEmpty) {
      return 'İsim gerekli';
    }
    
    if (value.trim().length < minLength) {
      return 'İsim en az $minLength karakter olmalı';
    }
    
    // Only letters and spaces allowed
    final nameRegex = RegExp(r'^[a-zA-ZğüşıöçĞÜŞİÖÇ\s]+$');
    if (!nameRegex.hasMatch(value.trim())) {
      return 'İsim sadece harf ve boşluk içerebilir';
    }
    
    return null;
  }

  /// Student ID validation (Turkish universities)
  /// Öğrenci numarası doğrulaması (Türk üniversiteleri)
  static String? validateStudentId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Öğrenci numarası gerekli';
    }
    
    // Typically 9-10 digits
    final studentIdRegex = RegExp(r'^\d{9,10}$');
    if (!studentIdRegex.hasMatch(value)) {
      return 'Geçerli bir öğrenci numarası girin (9-10 rakam)';
    }
    
    return null;
  }

  /// URL validation
  /// URL doğrulaması
  static String? validateUrl(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      return required ? 'URL gerekli' : null;
    }
    
    final urlRegex = RegExp(
        r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$');
    
    if (!urlRegex.hasMatch(value)) {
      return 'Geçerli bir URL girin (http:// veya https:// ile başlamalı)';
    }
    
    return null;
  }

  /// Date validation
  /// Tarih doğrulaması
  static String? validateDate(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      return required ? 'Tarih gerekli' : null;
    }
    
    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Geçerli bir tarih formatı girin (YYYY-MM-DD)';
    }
  }

  /// Future date validation
  /// Gelecek tarih doğrulaması
  static String? validateFutureDate(DateTime? value, {bool required = false}) {
    if (value == null) {
      return required ? 'Tarih gerekli' : null;
    }
    
    if (value.isBefore(DateTime.now())) {
      return 'Tarih gelecekte olmalı';
    }
    
    return null;
  }

  /// Number validation
  /// Sayı doğrulaması
  static String? validateNumber(String? value, {
    bool required = false,
    double? min,
    double? max,
  }) {
    if (value == null || value.isEmpty) {
      return required ? 'Sayı gerekli' : null;
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Geçerli bir sayı girin';
    }
    
    if (min != null && number < min) {
      return 'Sayı $min\'den küçük olamaz';
    }
    
    if (max != null && number > max) {
      return 'Sayı $max\'den büyük olamaz';
    }
    
    return null;
  }

  /// Integer validation
  /// Tam sayı doğrulaması
  static String? validateInteger(String? value, {
    bool required = false,
    int? min,
    int? max,
  }) {
    if (value == null || value.isEmpty) {
      return required ? 'Sayı gerekli' : null;
    }
    
    final number = int.tryParse(value);
    if (number == null) {
      return 'Geçerli bir tam sayı girin';
    }
    
    if (min != null && number < min) {
      return 'Sayı $min\'den küçük olamaz';
    }
    
    if (max != null && number > max) {
      return 'Sayı $max\'den büyük olamaz';
    }
    
    return null;
  }

  /// Text length validation
  /// Metin uzunluğu doğrulaması
  static String? validateLength(String? value, {
    bool required = false,
    int? minLength,
    int? maxLength,
    String? fieldName,
  }) {
    if (value == null || value.isEmpty) {
      return required ? '${fieldName ?? 'Bu alan'} gerekli' : null;
    }
    
    if (minLength != null && value.length < minLength) {
      return '${fieldName ?? 'Alan'} en az $minLength karakter olmalı';
    }
    
    if (maxLength != null && value.length > maxLength) {
      return '${fieldName ?? 'Alan'} en fazla $maxLength karakter olabilir';
    }
    
    return null;
  }

  /// Password confirmation validation
  /// Şifre onayı doğrulaması
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Şifre onayı gerekli';
    }
    
    if (value != password) {
      return 'Şifreler eşleşmiyor';
    }
    
    return null;
  }

  /// Create validator function for TextFormField
  /// TextFormField için doğrulayıcı fonksiyonu oluştur
  static String? Function(String?) createValidator({
    bool required = false,
    int? minLength,
    int? maxLength,
    String? pattern,
    String? fieldName,
    List<String? Function(String?)>? customValidators,
  }) {
    return (String? value) {
      // Required validation
      if (required && (value == null || value.trim().isEmpty)) {
        return '${fieldName ?? 'Bu alan'} gerekli';
      }
      
      // Skip other validations if value is empty and not required
      if (value == null || value.isEmpty) {
        return null;
      }
      
      // Length validations
      if (minLength != null && value.length < minLength) {
        return '${fieldName ?? 'Alan'} en az $minLength karakter olmalı';
      }
      
      if (maxLength != null && value.length > maxLength) {
        return '${fieldName ?? 'Alan'} en fazla $maxLength karakter olabilir';
      }
      
      // Pattern validation
      if (pattern != null) {
        final regex = RegExp(pattern);
        if (!regex.hasMatch(value)) {
          return '${fieldName ?? 'Alan'} geçersiz format';
        }
      }
      
      // Custom validations
      if (customValidators != null) {
        for (final validator in customValidators) {
          final result = validator(value);
          if (result != null) {
            return result;
          }
        }
      }
      
      return null;
    };
  }

  /// Validate grade (0-100)
  /// Not doğrulaması (0-100)
  static String? validateGrade(String? value, {bool required = false}) {
    return validateNumber(
      value,
      required: required,
      min: 0,
      max: 100,
    );
  }

  /// Validate percentage (0-100)
  /// Yüzde doğrulaması (0-100)
  static String? validatePercentage(String? value, {bool required = false}) {
    return validateNumber(
      value,
      required: required,
      min: 0,
      max: 100,
    );
  }

  /// Validate capacity (positive integer)
  /// Kapasite doğrulaması (pozitif tam sayı)
  static String? validateCapacity(String? value, {bool required = false}) {
    return validateInteger(
      value,
      required: required,
      min: 1,
    );
  }
}