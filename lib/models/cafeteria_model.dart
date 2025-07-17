import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

part 'cafeteria_model.g.dart';

/// Kafeterya menü modeli / Cafeteria menu model
@JsonSerializable()
class CafeteriaMenuModel {
  @JsonKey(name: 'id')
  final String? id;

  @JsonKey(name: 'date')
  final String date; // 'YYYY-MM-DD' format

  @JsonKey(name: 'meals')
  final MealPlanModel meals;

  @JsonKey(name: 'specialNotes')
  final String? specialNotes;

  @JsonKey(name: 'allergenWarnings')
  final List<String>? allergenWarnings;

  @JsonKey(name: 'isHoliday')
  final bool isHoliday;

  @JsonKey(name: 'lastUpdated')
  @TimestampConverter()
  final DateTime lastUpdated;

  @JsonKey(name: 'updatedBy')
  final String updatedBy;

  const CafeteriaMenuModel({
    this.id,
    required this.date,
    required this.meals,
    this.specialNotes,
    this.allergenWarnings,
    this.isHoliday = false,
    required this.lastUpdated,
    required this.updatedBy,
  });

  /// JSON'dan CafeteriaMenuModel oluştur / Create CafeteriaMenuModel from JSON
  factory CafeteriaMenuModel.fromJson(Map<String, dynamic> json) => _$CafeteriaMenuModelFromJson(json);

  /// CafeteriaMenuModel'i JSON'a çevir / Convert CafeteriaMenuModel to JSON
  Map<String, dynamic> toJson() => _$CafeteriaMenuModelToJson(this);

  /// Firestore verilerinden CafeteriaMenuModel oluştur / Create CafeteriaMenuModel from Firestore data
  factory CafeteriaMenuModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return CafeteriaMenuModel.fromJson(data);
  }

  /// Firebase'e uygun veri formatına çevir / Convert to Firebase-compatible format
  Map<String, dynamic> toFirestore() {
    final data = toJson();
    data.remove('id');
    return data;
  }

  /// Tarihi DateTime olarak getir / Get date as DateTime
  DateTime get dateTime => DateTime.parse(date);

  /// Bugünün menüsü mü kontrol et / Check if this is today's menu
  bool get isToday {
    final today = DateTime.now();
    final menuDate = dateTime;
    return today.year == menuDate.year &&
           today.month == menuDate.month &&
           today.day == menuDate.day;
  }

  /// Menünün geçerli olup olmadığını kontrol et / Check if menu is valid
  bool get isValid {
    // Geçmiş tarihler için menü geçerli değil / Menu not valid for past dates
    final now = DateTime.now();
    final menuDate = dateTime;
    
    // Bugün veya gelecekteki tarihler için geçerli / Valid for today or future dates
    return menuDate.isAfter(now.subtract(const Duration(days: 1)));
  }

  /// Toplam yemek sayısını getir / Get total number of meals
  int get totalMealCount {
    int count = 0;
    if (meals.breakfast?.available == true) count += meals.breakfast!.items.length;
    if (meals.lunch.available) count += meals.lunch.items.length;
    if (meals.dinner?.available == true) count += meals.dinner!.items.length;
    return count;
  }

  /// Vejetaryen yemek sayısını getir / Get vegetarian meal count
  int get vegetarianMealCount {
    int count = 0;
    if (meals.breakfast?.available == true) {
      count += meals.breakfast!.items.where((item) => item.dietary.isVegetarian).length;
    }
    if (meals.lunch.available) {
      count += meals.lunch.items.where((item) => item.dietary.isVegetarian).length;
    }
    if (meals.dinner?.available == true) {
      count += meals.dinner!.items.where((item) => item.dietary.isVegetarian).length;
    }
    return count;
  }

  /// Menü kopyala / Copy menu with new values
  CafeteriaMenuModel copyWith({
    String? id,
    String? date,
    MealPlanModel? meals,
    String? specialNotes,
    List<String>? allergenWarnings,
    bool? isHoliday,
    DateTime? lastUpdated,
    String? updatedBy,
  }) {
    return CafeteriaMenuModel(
      id: id ?? this.id,
      date: date ?? this.date,
      meals: meals ?? this.meals,
      specialNotes: specialNotes ?? this.specialNotes,
      allergenWarnings: allergenWarnings ?? this.allergenWarnings,
      isHoliday: isHoliday ?? this.isHoliday,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  String toString() {
    return 'CafeteriaMenuModel{date: $date, isHoliday: $isHoliday, totalMeals: $totalMealCount}';
  }
}

/// Öğün planı modeli / Meal plan model
@JsonSerializable()
class MealPlanModel {
  @JsonKey(name: 'breakfast')
  final MealModel? breakfast;

  @JsonKey(name: 'lunch')
  final MealModel lunch;

  @JsonKey(name: 'dinner')
  final MealModel? dinner;

  const MealPlanModel({
    this.breakfast,
    required this.lunch,
    this.dinner,
  });

  factory MealPlanModel.fromJson(Map<String, dynamic> json) => _$MealPlanModelFromJson(json);
  Map<String, dynamic> toJson() => _$MealPlanModelToJson(this);

  /// Mevcut öğünleri getir / Get available meals
  List<MealModel> get availableMeals {
    final meals = <MealModel>[];
    if (breakfast?.available == true) meals.add(breakfast!);
    if (lunch.available) meals.add(lunch);
    if (dinner?.available == true) meals.add(dinner!);
    return meals;
  }
}

/// Öğün modeli / Meal model
@JsonSerializable()
class MealModel {
  @JsonKey(name: 'available')
  final bool available;

  @JsonKey(name: 'servingTime')
  final ServingTimeModel servingTime;

  @JsonKey(name: 'items')
  final List<MenuItemModel> items;

  const MealModel({
    required this.available,
    required this.servingTime,
    required this.items,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) => _$MealModelFromJson(json);
  Map<String, dynamic> toJson() => _$MealModelToJson(this);

  /// Şu anda servis edilip edilmediğini kontrol et / Check if currently being served
  bool get isCurrentlyServing {
    if (!available) return false;
    
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);
    
    return _isTimeInRange(currentTime, servingTime.start, servingTime.end);
  }

  /// Servis saatine kaç dakika kaldığını hesapla / Calculate minutes until serving time
  int? get minutesUntilServing {
    if (!available) return null;
    
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);
    final startTime = _parseTimeOfDay(servingTime.start);
    
    if (isCurrentlyServing) return 0;
    
    // Servis saati geçmişse null döndür / Return null if serving time has passed
    if (_isTimeAfter(currentTime, _parseTimeOfDay(servingTime.end))) return null;
    
    return _calculateMinutesDifference(currentTime, startTime);
  }

  /// Mevcut yemekleri getir / Get available food items
  List<MenuItemModel> get availableItems {
    return items.where((item) => item.availability == FoodAvailability.available).toList();
  }

  /// Kategoriye göre yemekleri grupla / Group items by category
  Map<FoodCategory, List<MenuItemModel>> get itemsByCategory {
    final Map<FoodCategory, List<MenuItemModel>> grouped = {};
    
    for (final item in items) {
      if (!grouped.containsKey(item.category)) {
        grouped[item.category] = [];
      }
      grouped[item.category]!.add(item);
    }
    
    return grouped;
  }

  // Helper methods / Yardımcı metodlar
  bool _isTimeInRange(TimeOfDay current, String start, String end) {
    final startTime = _parseTimeOfDay(start);
    final endTime = _parseTimeOfDay(end);
    
    final currentMinutes = current.hour * 60 + current.minute;
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    
    return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
  }

  bool _isTimeAfter(TimeOfDay current, TimeOfDay target) {
    final currentMinutes = current.hour * 60 + current.minute;
    final targetMinutes = target.hour * 60 + target.minute;
    return currentMinutes > targetMinutes;
  }

  int _calculateMinutesDifference(TimeOfDay current, TimeOfDay target) {
    final currentMinutes = current.hour * 60 + current.minute;
    final targetMinutes = target.hour * 60 + target.minute;
    return targetMinutes - currentMinutes;
  }

  TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}

/// Servis saati modeli / Serving time model
@JsonSerializable()
class ServingTimeModel {
  @JsonKey(name: 'start')
  final String start; // 'HH:mm' format

  @JsonKey(name: 'end')
  final String end; // 'HH:mm' format

  const ServingTimeModel({
    required this.start,
    required this.end,
  });

  factory ServingTimeModel.fromJson(Map<String, dynamic> json) => _$ServingTimeModelFromJson(json);
  Map<String, dynamic> toJson() => _$ServingTimeModelToJson(this);

  /// Servis süresini dakika olarak getir / Get serving duration in minutes
  int get durationInMinutes {
    final startParts = start.split(':');
    final endParts = end.split(':');
    
    final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
    
    return endMinutes - startMinutes;
  }

  /// Formatlanmış servis saati / Formatted serving time
  String get formatted => '$start - $end';
}

/// Menü öğesi modeli / Menu item model
@JsonSerializable()
class MenuItemModel {
  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'nameEn')
  final String? nameEn;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'category')
  final FoodCategory category;

  @JsonKey(name: 'nutrition')
  final NutritionModel? nutrition;

  @JsonKey(name: 'dietary')
  final DietaryModel dietary;

  @JsonKey(name: 'allergens')
  final List<Allergen>? allergens;

  @JsonKey(name: 'imageUrl')
  final String? imageUrl;

  @JsonKey(name: 'price')
  final double? price;

  @JsonKey(name: 'availability')
  final FoodAvailability availability;

  @JsonKey(name: 'rating')
  final RatingModel? rating;

  const MenuItemModel({
    required this.name,
    this.nameEn,
    this.description,
    required this.category,
    this.nutrition,
    required this.dietary,
    this.allergens,
    this.imageUrl,
    this.price,
    this.availability = FoodAvailability.available,
    this.rating,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) => _$MenuItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$MenuItemModelToJson(this);

  /// Kategori simgesi / Category icon
  String get categoryIcon {
    switch (category) {
      case FoodCategory.soup:
        return '🍲';
      case FoodCategory.main:
        return '🍽️';
      case FoodCategory.side:
        return '🥗';
      case FoodCategory.salad:
        return '🥙';
      case FoodCategory.dessert:
        return '🍰';
      case FoodCategory.beverage:
        return '🥤';
    }
  }

  /// Kategori adı / Category name
  String get categoryName {
    switch (category) {
      case FoodCategory.soup:
        return 'Çorba';
      case FoodCategory.main:
        return 'Ana Yemek';
      case FoodCategory.side:
        return 'Garnitür';
      case FoodCategory.salad:
        return 'Salata';
      case FoodCategory.dessert:
        return 'Tatlı';
      case FoodCategory.beverage:
        return 'İçecek';
    }
  }

  /// Diyet etiketlerini getir / Get dietary labels
  List<String> get dietaryLabels {
    final labels = <String>[];
    if (dietary.isVegetarian) labels.add('Vejetaryen');
    if (dietary.isVegan) labels.add('Vegan');
    if (dietary.isGlutenFree) labels.add('Glutensiz');
    if (dietary.isLactoseFree) labels.add('Laktozsuz');
    if (dietary.isHalal) labels.add('Helal');
    return labels;
  }

  /// Alerjen uyarıları / Allergen warnings
  List<String> get allergenWarnings {
    if (allergens == null) return [];
    return allergens!.map((allergen) {
      switch (allergen) {
        case Allergen.gluten:
          return 'Gluten';
        case Allergen.dairy:
          return 'Süt Ürünleri';
        case Allergen.nuts:
          return 'Kuruyemiş';
        case Allergen.eggs:
          return 'Yumurta';
        case Allergen.soy:
          return 'Soya';
        case Allergen.fish:
          return 'Balık';
        case Allergen.shellfish:
          return 'Kabuklu Deniz Ürünleri';
      }
    }).toList();
  }

  /// Fiyat formatlanmış / Formatted price
  String? get formattedPrice {
    if (price == null) return null;
    return '₺${price!.toStringAsFixed(2)}';
  }

  /// Yemek mevcut mu / Is food available
  bool get isAvailable => availability == FoodAvailability.available;
}

/// Beslenme bilgileri modeli / Nutrition information model
@JsonSerializable()
class NutritionModel {
  @JsonKey(name: 'calories')
  final int? calories;

  @JsonKey(name: 'protein')
  final double? protein; // grams

  @JsonKey(name: 'carbs')
  final double? carbs; // grams

  @JsonKey(name: 'fat')
  final double? fat; // grams

  @JsonKey(name: 'fiber')
  final double? fiber; // grams

  @JsonKey(name: 'sodium')
  final double? sodium; // mg

  const NutritionModel({
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.fiber,
    this.sodium,
  });

  factory NutritionModel.fromJson(Map<String, dynamic> json) => _$NutritionModelFromJson(json);
  Map<String, dynamic> toJson() => _$NutritionModelToJson(this);

  /// Toplam makro besin ögesi / Total macronutrients
  double get totalMacros {
    return (protein ?? 0) + (carbs ?? 0) + (fat ?? 0);
  }

  /// Protein yüzdesi / Protein percentage
  double get proteinPercentage {
    if (totalMacros == 0) return 0;
    return ((protein ?? 0) / totalMacros) * 100;
  }

  /// Karbonhidrat yüzdesi / Carbohydrate percentage
  double get carbsPercentage {
    if (totalMacros == 0) return 0;
    return ((carbs ?? 0) / totalMacros) * 100;
  }

  /// Yağ yüzdesi / Fat percentage
  double get fatPercentage {
    if (totalMacros == 0) return 0;
    return ((fat ?? 0) / totalMacros) * 100;
  }
}

/// Diyet bilgileri modeli / Dietary information model
@JsonSerializable()
class DietaryModel {
  @JsonKey(name: 'isVegetarian')
  final bool isVegetarian;

  @JsonKey(name: 'isVegan')
  final bool isVegan;

  @JsonKey(name: 'isGlutenFree')
  final bool isGlutenFree;

  @JsonKey(name: 'isLactoseFree')
  final bool isLactoseFree;

  @JsonKey(name: 'isHalal')
  final bool isHalal;

  const DietaryModel({
    this.isVegetarian = false,
    this.isVegan = false,
    this.isGlutenFree = false,
    this.isLactoseFree = false,
    this.isHalal = true, // Default to halal
  });

  factory DietaryModel.fromJson(Map<String, dynamic> json) => _$DietaryModelFromJson(json);
  Map<String, dynamic> toJson() => _$DietaryModelToJson(this);
}

/// Değerlendirme modeli / Rating model
@JsonSerializable()
class RatingModel {
  @JsonKey(name: 'average')
  final double average; // 1-5 stars

  @JsonKey(name: 'count')
  final int count;

  const RatingModel({
    required this.average,
    required this.count,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) => _$RatingModelFromJson(json);
  Map<String, dynamic> toJson() => _$RatingModelToJson(this);

  /// Yıldız sayısını tam sayı olarak getir / Get star count as integer
  int get starCount => average.round();

  /// Değerlendirme metnini getir / Get rating text
  String get ratingText {
    if (average >= 4.5) return 'Mükemmel';
    if (average >= 4.0) return 'Çok İyi';
    if (average >= 3.5) return 'İyi';
    if (average >= 3.0) return 'Orta';
    if (average >= 2.0) return 'Kötü';
    return 'Çok Kötü';
  }
}

/// Yemek kategorileri / Food categories
enum FoodCategory {
  @JsonValue('soup')
  soup,
  @JsonValue('main')
  main,
  @JsonValue('side')
  side,
  @JsonValue('salad')
  salad,
  @JsonValue('dessert')
  dessert,
  @JsonValue('beverage')
  beverage,
}

/// Alerjenler / Allergens
enum Allergen {
  @JsonValue('gluten')
  gluten,
  @JsonValue('dairy')
  dairy,
  @JsonValue('nuts')
  nuts,
  @JsonValue('eggs')
  eggs,
  @JsonValue('soy')
  soy,
  @JsonValue('fish')
  fish,
  @JsonValue('shellfish')
  shellfish,
}

/// Yemek mevcudiyeti / Food availability
enum FoodAvailability {
  @JsonValue('available')
  available,
  @JsonValue('limited')
  limited,
  @JsonValue('unavailable')
  unavailable,
}

/// Firestore Timestamp converter for JSON serialization
/// Firestore Timestamp'i JSON serileştirme için dönüştürücü
class TimestampConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.tryParse(json);
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    return null;
  }

  @override
  Object? toJson(DateTime? dateTime) {
    if (dateTime == null) return null;
    return Timestamp.fromDate(dateTime);
  }
} 