// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cafeteria_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CafeteriaMenuModel _$CafeteriaMenuModelFromJson(Map<String, dynamic> json) =>
    CafeteriaMenuModel(
      id: json['id'] as String?,
      date: json['date'] as String,
      meals: MealPlanModel.fromJson(json['meals'] as Map<String, dynamic>),
      specialNotes: json['specialNotes'] as String?,
      allergenWarnings: (json['allergenWarnings'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isHoliday: json['isHoliday'] as bool? ?? false,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      updatedBy: json['updatedBy'] as String,
    );

Map<String, dynamic> _$CafeteriaMenuModelToJson(CafeteriaMenuModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'meals': instance.meals,
      'specialNotes': instance.specialNotes,
      'allergenWarnings': instance.allergenWarnings,
      'isHoliday': instance.isHoliday,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'updatedBy': instance.updatedBy,
    };

MealPlanModel _$MealPlanModelFromJson(Map<String, dynamic> json) =>
    MealPlanModel(
      breakfast: json['breakfast'] == null
          ? null
          : MealModel.fromJson(json['breakfast'] as Map<String, dynamic>),
      lunch: MealModel.fromJson(json['lunch'] as Map<String, dynamic>),
      dinner: json['dinner'] == null
          ? null
          : MealModel.fromJson(json['dinner'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MealPlanModelToJson(MealPlanModel instance) =>
    <String, dynamic>{
      'breakfast': instance.breakfast,
      'lunch': instance.lunch,
      'dinner': instance.dinner,
    };

MealModel _$MealModelFromJson(Map<String, dynamic> json) => MealModel(
  available: json['available'] as bool,
  servingTime: ServingTimeModel.fromJson(
    json['servingTime'] as Map<String, dynamic>,
  ),
  items: (json['items'] as List<dynamic>)
      .map((e) => MenuItemModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MealModelToJson(MealModel instance) => <String, dynamic>{
  'available': instance.available,
  'servingTime': instance.servingTime,
  'items': instance.items,
};

ServingTimeModel _$ServingTimeModelFromJson(Map<String, dynamic> json) =>
    ServingTimeModel(
      start: json['start'] as String,
      end: json['end'] as String,
    );

Map<String, dynamic> _$ServingTimeModelToJson(ServingTimeModel instance) =>
    <String, dynamic>{'start': instance.start, 'end': instance.end};

MenuItemModel _$MenuItemModelFromJson(Map<String, dynamic> json) =>
    MenuItemModel(
      name: json['name'] as String,
      nameEn: json['nameEn'] as String?,
      description: json['description'] as String?,
      category: $enumDecode(_$FoodCategoryEnumMap, json['category']),
      nutrition: json['nutrition'] == null
          ? null
          : NutritionModel.fromJson(json['nutrition'] as Map<String, dynamic>),
      dietary: DietaryModel.fromJson(json['dietary'] as Map<String, dynamic>),
      allergens: (json['allergens'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$AllergenEnumMap, e))
          .toList(),
      imageUrl: json['imageUrl'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      availability:
          $enumDecodeNullable(
            _$FoodAvailabilityEnumMap,
            json['availability'],
          ) ??
          FoodAvailability.available,
      rating: json['rating'] == null
          ? null
          : RatingModel.fromJson(json['rating'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MenuItemModelToJson(
  MenuItemModel instance,
) => <String, dynamic>{
  'name': instance.name,
  'nameEn': instance.nameEn,
  'description': instance.description,
  'category': _$FoodCategoryEnumMap[instance.category]!,
  'nutrition': instance.nutrition,
  'dietary': instance.dietary,
  'allergens': instance.allergens?.map((e) => _$AllergenEnumMap[e]!).toList(),
  'imageUrl': instance.imageUrl,
  'price': instance.price,
  'availability': _$FoodAvailabilityEnumMap[instance.availability]!,
  'rating': instance.rating,
};

const _$FoodCategoryEnumMap = {
  FoodCategory.soup: 'soup',
  FoodCategory.main: 'main',
  FoodCategory.side: 'side',
  FoodCategory.salad: 'salad',
  FoodCategory.dessert: 'dessert',
  FoodCategory.beverage: 'beverage',
};

const _$AllergenEnumMap = {
  Allergen.gluten: 'gluten',
  Allergen.dairy: 'dairy',
  Allergen.nuts: 'nuts',
  Allergen.eggs: 'eggs',
  Allergen.soy: 'soy',
  Allergen.fish: 'fish',
  Allergen.shellfish: 'shellfish',
};

const _$FoodAvailabilityEnumMap = {
  FoodAvailability.available: 'available',
  FoodAvailability.limited: 'limited',
  FoodAvailability.unavailable: 'unavailable',
};

NutritionModel _$NutritionModelFromJson(Map<String, dynamic> json) =>
    NutritionModel(
      calories: (json['calories'] as num?)?.toInt(),
      protein: (json['protein'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
      fiber: (json['fiber'] as num?)?.toDouble(),
      sodium: (json['sodium'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$NutritionModelToJson(NutritionModel instance) =>
    <String, dynamic>{
      'calories': instance.calories,
      'protein': instance.protein,
      'carbs': instance.carbs,
      'fat': instance.fat,
      'fiber': instance.fiber,
      'sodium': instance.sodium,
    };

DietaryModel _$DietaryModelFromJson(Map<String, dynamic> json) => DietaryModel(
  isVegetarian: json['isVegetarian'] as bool? ?? false,
  isVegan: json['isVegan'] as bool? ?? false,
  isGlutenFree: json['isGlutenFree'] as bool? ?? false,
  isLactoseFree: json['isLactoseFree'] as bool? ?? false,
  isHalal: json['isHalal'] as bool? ?? true,
);

Map<String, dynamic> _$DietaryModelToJson(DietaryModel instance) =>
    <String, dynamic>{
      'isVegetarian': instance.isVegetarian,
      'isVegan': instance.isVegan,
      'isGlutenFree': instance.isGlutenFree,
      'isLactoseFree': instance.isLactoseFree,
      'isHalal': instance.isHalal,
    };

RatingModel _$RatingModelFromJson(Map<String, dynamic> json) => RatingModel(
  average: (json['average'] as num).toDouble(),
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$RatingModelToJson(RatingModel instance) =>
    <String, dynamic>{'average': instance.average, 'count': instance.count};
