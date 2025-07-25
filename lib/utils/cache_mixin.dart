import 'dart:async';
import 'package:flutter/foundation.dart';

/// Mixin providing common caching functionality for services
/// Servisler için ortak önbellekleme işlevselliği sağlayan mixin
mixin CacheMixin {
  // Cache storage
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, Timer> _cacheTimers = {};

  /// Default cache expiry duration
  Duration get defaultCacheExpiry => const Duration(minutes: 10);

  /// Store value in cache with optional expiry
  /// Değeri isteğe bağlı süre ile önbellekte sakla
  void cacheValue<T>(String key, T value, [Duration? expiry]) {
    final cacheExpiry = expiry ?? defaultCacheExpiry;
    
    // Store value and timestamp
    _cache[key] = value;
    _cacheTimestamps[key] = DateTime.now();

    // Cancel existing timer
    _cacheTimers[key]?.cancel();

    // Set new expiry timer
    _cacheTimers[key] = Timer(cacheExpiry, () {
      clearCacheKey(key);
    });

    debugPrint('📋 Cache: Stored $key for ${cacheExpiry.inMinutes}m');
  }

  /// Get value from cache if not expired
  /// Süresi dolmamışsa önbellekten değeri al
  T? getCachedValue<T>(String key) {
    if (!_cache.containsKey(key)) {
      return null;
    }

    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) {
      clearCacheKey(key);
      return null;
    }

    debugPrint('📋 Cache: Retrieved $key');
    return _cache[key] as T?;
  }

  /// Check if cache key exists and is valid
  /// Önbellek anahtarının var olduğunu ve geçerli olduğunu kontrol et
  bool isCached(String key) {
    return _cache.containsKey(key) && _cacheTimestamps.containsKey(key);
  }

  /// Clear specific cache key
  /// Belirli önbellek anahtarını temizle
  void clearCacheKey(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
    _cacheTimers[key]?.cancel();
    _cacheTimers.remove(key);
    debugPrint('🗑️ Cache: Cleared $key');
  }

  /// Clear all cache
  /// Tüm önbelleği temizle
  void clearAllCache() {
    // Cancel all timers
    for (var timer in _cacheTimers.values) {
      timer.cancel();
    }

    _cache.clear();
    _cacheTimestamps.clear();
    _cacheTimers.clear();
    debugPrint('🗑️ Cache: Cleared all cache');
  }

  /// Get cache statistics
  /// Önbellek istatistiklerini al
  Map<String, dynamic> getCacheStats() {
    return {
      'totalKeys': _cache.length,
      'keys': _cache.keys.toList(),
      'timestamps': _cacheTimestamps,
    };
  }

  /// Cache with async operation
  /// Async işlemle önbellekleme
  Future<T> cacheAsync<T>(
    String key, 
    Future<T> Function() operation, {
    Duration? expiry,
    bool forceRefresh = false,
  }) async {
    // Return cached value if available and not forcing refresh
    if (!forceRefresh) {
      final cached = getCachedValue<T>(key);
      if (cached != null) {
        return cached;
      }
    }

    // Execute operation and cache result
    try {
      final result = await operation();
      cacheValue(key, result, expiry);
      return result;
    } catch (error) {
      // Don't cache errors, just rethrow
      rethrow;
    }
  }

  /// Generate cache key from parameters
  /// Parametrelerden önbellek anahtarı oluştur
  String generateCacheKey(String prefix, Map<String, dynamic> params) {
    final sortedParams = Map.fromEntries(
      params.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );
    
    final paramsString = sortedParams.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    
    return '${prefix}_$paramsString';
  }

  /// Invalidate cache keys by prefix
  /// Önek ile önbellek anahtarlarını geçersiz kıl
  void invalidateCacheByPrefix(String prefix) {
    final keysToRemove = _cache.keys
        .where((key) => key.startsWith(prefix))
        .toList();
    
    for (final key in keysToRemove) {
      clearCacheKey(key);
    }
    
    debugPrint('🗑️ Cache: Invalidated ${keysToRemove.length} keys with prefix $prefix');
  }

  /// Dispose all cache timers (call in service dispose)
  /// Tüm önbellek zamanlayıcılarını temizle (service dispose'da çağır)
  void disposeCacheTimers() {
    for (var timer in _cacheTimers.values) {
      timer.cancel();
    }
    _cacheTimers.clear();
  }
}