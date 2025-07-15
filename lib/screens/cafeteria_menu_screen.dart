import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../themes/app_themes.dart';
import '../widgets/common/app_drawer_widget.dart';
import '../widgets/common/bottom_navigation_widget.dart';

/// Yemekhane Menü Sayfası / Cafeteria Menu Screen
class CafeteriaMenuScreen extends StatefulWidget {
  const CafeteriaMenuScreen({super.key});

  @override
  State<CafeteriaMenuScreen> createState() => _CafeteriaMenuScreenState();
}

class _CafeteriaMenuScreenState extends State<CafeteriaMenuScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  // Filtreleme ve arama / Filtering and search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<DietaryFilter> _selectedFilters = {};
  final Set<String> _favoriteItems = {'Mantı', 'Izgara Tavuk', 'Çorba'};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Bugünün menüsü / Today's menu
  final Map<MealType, List<MenuItem>> _todayMenu = {
    MealType.breakfast: [
      MenuItem(
        name: 'Menemen',
        description: 'Domates, biber ve yumurta ile yapılan geleneksel kahvaltı',
        price: 15.50,
        calories: 220,
        ingredients: ['Yumurta', 'Domates', 'Biber', 'Soğan', 'Zeytinyağı'],
        allergens: ['Yumurta'],
        dietaryInfo: [DietaryFilter.vegetarian],
        image: 'assets/images/menemen.jpeg',
      ),
      MenuItem(
        name: 'Peynirli Börek',
        description: 'El açması börek, beyaz peynir ve maydanoz',
        price: 12.00,
        calories: 280,
        ingredients: ['Yufka', 'Beyaz Peynir', 'Maydanoz', 'Yumurta'],
        allergens: ['Gluten', 'Süt Ürünleri', 'Yumurta'],
        dietaryInfo: [DietaryFilter.vegetarian],
        image: 'assets/images/borek.jpg',
      ),
      MenuItem(
        name: 'Simit',
        description: 'Taze pişmiş geleneksel İstanbul simidi',
        price: 3.50,
        calories: 165,
        ingredients: ['Un', 'Su', 'Maya', 'Tuz', 'Susam'],
        allergens: ['Gluten'],
        dietaryInfo: [DietaryFilter.vegan],
        image: 'assets/images/simit.jpg',
      ),
    ],
    MealType.lunch: [
      MenuItem(
        name: 'Mantı',
        description: 'Ev yapımı mantı, yoğurt ve sarımsaklı sos',
        price: 25.00,
        calories: 420,
        ingredients: ['Un', 'Kıyma', 'Soğan', 'Yoğurt', 'Sarımsak'],
        allergens: ['Gluten', 'Süt Ürünleri'],
        dietaryInfo: [],
        image: 'assets/images/manti.jpeg',
      ),
      MenuItem(
        name: 'Izgara Tavuk',
        description: 'Baharatlı izgara tavuk göğsü, pilav ve salata',
        price: 28.50,
        calories: 380,
        ingredients: ['Tavuk', 'Pirinç', 'Sebze', 'Baharat'],
        allergens: [],
        dietaryInfo: [DietaryFilter.glutenFree, DietaryFilter.highProtein],
        image: 'assets/images/grilled_chicken.jpg',
      ),
      MenuItem(
        name: 'Mercimek Çorbası',
        description: 'Kırmızı mercimek çorbası, limon ile servis',
        price: 8.00,
        calories: 140,
        ingredients: ['Kırmızı Mercimek', 'Soğan', 'Havuç', 'Baharat'],
        allergens: [],
        dietaryInfo: [DietaryFilter.vegan, DietaryFilter.glutenFree],
        image: 'assets/images/lentil_soup.jpg',
      ),
      MenuItem(
        name: 'Veggie Burger',
        description: 'Sebze köftesi, avokado ve tam buğday ekmeği',
        price: 22.00,
        calories: 320,
        ingredients: ['Tam Buğday Ekmeği', 'Sebze Köftesi', 'Avokado', 'Marul'],
        allergens: ['Gluten'],
        dietaryInfo: [DietaryFilter.vegetarian],
        image: 'assets/images/veggie_burger.jpg',
      ),
    ],
    MealType.dinner: [
      MenuItem(
        name: 'Balık Izgara',
        description: 'Taze deniz balığı, sebze garnitür ile',
        price: 32.00,
        calories: 295,
        ingredients: ['Deniz Balığı', 'Sebze', 'Zeytinyağı', 'Limon'],
        allergens: ['Balık'],
        dietaryInfo: [DietaryFilter.glutenFree, DietaryFilter.highProtein],
        image: 'assets/images/grilled_fish.jpg',
      ),
      MenuItem(
        name: 'Karnıyarık',
        description: 'Patlıcan, kıyma ve domates sosu ile',
        price: 24.00,
        calories: 340,
        ingredients: ['Patlıcan', 'Kıyma', 'Domates', 'Soğan'],
        allergens: [],
        dietaryInfo: [],
        image: 'assets/images/karniyarik.jpg',
      ),
      MenuItem(
        name: 'Vegan Salata',
        description: 'Mevsim yeşillikleri, avokado ve chia tohumu',
        price: 18.50,
        calories: 185,
        ingredients: ['Marul', 'Roka', 'Avokado', 'Chia Tohumu', 'Zeytinyağı'],
        allergens: [],
        dietaryInfo: [DietaryFilter.vegan, DietaryFilter.glutenFree, DietaryFilter.lowCalorie],
        image: 'assets/images/vegan_salad.jpg',
      ),
    ],
  };

  // Filtrelenmiş menü öğeleri / Filtered menu items
  List<MenuItem> _getFilteredItems(MealType mealType) {
    List<MenuItem> items = _todayMenu[mealType] ?? [];

    // Arama filtresi / Search filter
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) {
        return item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.ingredients.any((ingredient) =>
                ingredient.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    // Diyet filtresi / Dietary filter
    if (_selectedFilters.isNotEmpty) {
      items = items.where((item) {
        return _selectedFilters.every((filter) => item.dietaryInfo.contains(filter));
      }).toList();
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppThemes.getBackgroundColor(context),
      // Navy renkli AppBar / Navy colored AppBar
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: AppConstants.textColorLight,
        elevation: 0,
        title: const Text(
          'Cafeteria Menu',
          style: TextStyle(
            fontSize: AppConstants.fontSizeXLarge,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              child: const Icon(Icons.menu, color: Colors.white, size: 24),
            );
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          labelStyle: const TextStyle(
            fontSize: AppConstants.fontSizeMedium,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Kahvaltı', icon: Icon(Icons.free_breakfast, size: 20)),
            Tab(text: 'Öğle', icon: Icon(Icons.lunch_dining, size: 20)),
            Tab(text: 'Akşam', icon: Icon(Icons.dinner_dining, size: 20)),
          ],
        ),
      ),

      // Ana sayfa drawer'ı / Main drawer
      drawer: const AppDrawerWidget(
        currentPageIndex: AppConstants.navIndexHome, // Cafeteria Menu için özel indeks yok, home kullanıyoruz
      ),

      body: Column(
        children: [
          // Arama ve filtre çubuğu / Search and filter bar
          _buildSearchAndFilterBar(),

          // Tab view içeriği / Tab view content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMealList(MealType.breakfast),
                _buildMealList(MealType.lunch),
                _buildMealList(MealType.dinner),
              ],
            ),
          ),
        ],
      ),

      // Alt navigasyon çubuğu / Bottom navigation bar
      bottomNavigationBar: const BottomNavigationWidget(
        currentIndex: AppConstants.navIndexHome, // Cafeteria Menu için özel indeks yok
      ),
    );
  }

  // Arama ve filtre çubuğu widget'ı / Search and filter bar widget
  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppThemes.getSurfaceColor(context),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          // Arama kutusu / Search box
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Yemek ara... / Search food...',
              prefixIcon: Icon(
                Icons.search,
                color: AppThemes.getSecondaryTextColor(context),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                borderSide: BorderSide(
                  color: AppThemes.getSecondaryTextColor(context).withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                borderSide: BorderSide(
                  color: AppThemes.getSecondaryTextColor(context).withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                borderSide: BorderSide(
                  color: AppThemes.getPrimaryColor(context),
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),

          const SizedBox(height: AppConstants.paddingSmall),

          // Diyet filtre butonları / Dietary filter buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: DietaryFilter.values.map((filter) {
                final isSelected = _selectedFilters.contains(filter);
                return Padding(
                  padding: const EdgeInsets.only(right: AppConstants.paddingSmall),
                  child: FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          filter.icon,
                          size: 16,
                          color: isSelected ? Colors.white : AppThemes.getTextColor(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          filter.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppThemes.getTextColor(context),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: AppConstants.fontSizeSmall,
                          ),
                        ),
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: filter.color,
                    backgroundColor: AppThemes.getSurfaceColor(context),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedFilters.add(filter);
                        } else {
                          _selectedFilters.remove(filter);
                        }
                      });
                    },
                    side: BorderSide(
                      color: isSelected
                          ? filter.color
                          : AppThemes.getSecondaryTextColor(context).withValues(alpha: 0.3),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Yemek listesi widget'ı / Meal list widget
  Widget _buildMealList(MealType mealType) {
    final filteredItems = _getFilteredItems(mealType);

    if (filteredItems.isEmpty) {
      return _buildEmptyState(mealType);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return _buildMenuItem(item);
      },
    );
  }

  // Menü öğesi kartı widget'ı / Menu item card widget
  Widget _buildMenuItem(MenuItem item) {
    final isFavorite = _favoriteItems.contains(item.name);

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppThemes.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst satır: Resim ve favori butonu / Top row: Image and favorite button
          Stack(
            children: [
              // Yemek resmi / Food image
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.radiusMedium),
                    topRight: Radius.circular(AppConstants.radiusMedium),
                  ),
                  color: Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.radiusMedium),
                    topRight: Radius.circular(AppConstants.radiusMedium),
                  ),
                  child: Image.asset(
                    item.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant,
                              size: 40,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.name,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Favori butonu / Favorite button
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isFavorite) {
                        _favoriteItems.remove(item.name);
                      } else {
                        _favoriteItems.add(item.name);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Kalori badge / Calorie badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${item.calories} kcal',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppConstants.fontSizeSmall,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // İçerik bölümü / Content section
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık ve fiyat / Title and price
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeLarge,
                          fontWeight: FontWeight.bold,
                          color: AppThemes.getTextColor(context),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppThemes.getPrimaryColor(context),
                        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                      ),
                      child: Text(
                        '₺${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: AppConstants.fontSizeMedium,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.paddingSmall),

                // Açıklama / Description
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    color: AppThemes.getSecondaryTextColor(context),
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: AppConstants.paddingSmall),

                // Diyet bilgileri / Dietary information
                if (item.dietaryInfo.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: item.dietaryInfo.map((filter) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: filter.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                          border: Border.all(
                            color: filter.color.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              filter.icon,
                              size: 12,
                              color: filter.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              filter.name,
                              style: TextStyle(
                                fontSize: AppConstants.fontSizeSmall,
                                fontWeight: FontWeight.w600,
                                color: filter.color,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                const SizedBox(height: AppConstants.paddingSmall),

                // Malzemeler / Ingredients
                ExpansionTile(
                  title: Text(
                    'Malzemeler',
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeMedium,
                      fontWeight: FontWeight.w600,
                      color: AppThemes.getTextColor(context),
                    ),
                  ),
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 8),
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: item.ingredients.map((ingredient) {
                        return Chip(
                          label: Text(
                            ingredient,
                            style: const TextStyle(
                              fontSize: AppConstants.fontSizeSmall,
                            ),
                          ),
                          backgroundColor: AppThemes.getSecondaryTextColor(context).withValues(alpha: 0.1),
                          side: BorderSide.none,
                        );
                      }).toList(),
                    ),
                  ],
                ),

                // Alerjenler / Allergens
                if (item.allergens.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.paddingSmall),
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        size: 16,
                        color: Colors.orange[700],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Alerjenler: ${item.allergens.join(', ')}',
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeSmall,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Boş durum widget'ı / Empty state widget
  Widget _buildEmptyState(MealType mealType) {
    String mealName = '';
    IconData icon = Icons.restaurant;

    switch (mealType) {
      case MealType.breakfast:
        mealName = 'kahvaltı';
        icon = Icons.free_breakfast;
        break;
      case MealType.lunch:
        mealName = 'öğle yemeği';
        icon = Icons.lunch_dining;
        break;
      case MealType.dinner:
        mealName = 'akşam yemeği';
        icon = Icons.dinner_dining;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppThemes.getSecondaryTextColor(context),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'Menü Bulunamadı',
              style: TextStyle(
                fontSize: AppConstants.fontSizeXLarge,
                fontWeight: FontWeight.bold,
                color: AppThemes.getTextColor(context),
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              'Seçili filtrelere uygun $mealName menüsü bulunamadı.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                color: AppThemes.getSecondaryTextColor(context),
              ),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedFilters.clear();
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemes.getPrimaryColor(context),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge,
                  vertical: AppConstants.paddingMedium,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
              ),
              child: const Text(
                'Filtreleri Temizle',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Menü öğesi veri modeli / Menu item data model
class MenuItem {
  final String name;
  final String description;
  final double price;
  final int calories;
  final List<String> ingredients;
  final List<String> allergens;
  final List<DietaryFilter> dietaryInfo;
  final String image;

  const MenuItem({
    required this.name,
    required this.description,
    required this.price,
    required this.calories,
    required this.ingredients,
    required this.allergens,
    required this.dietaryInfo,
    required this.image,
  });
}

// Öğün türleri / Meal types
enum MealType {
  breakfast,
  lunch,
  dinner,
}

// Diyet filtre seçenekleri / Dietary filter options
enum DietaryFilter {
  vegetarian('Vejetaryen', Icons.eco, Color(0xFF4CAF50)),
  vegan('Vegan', Icons.spa, Color(0xFF8BC34A)),
  glutenFree('Gluten-Free', Icons.no_food, Color(0xFFFF9800)),
  lowCalorie('Düşük Kalori', Icons.monitor_weight, Color(0xFF2196F3)),
  highProtein('Yüksek Protein', Icons.fitness_center, Color(0xFF9C27B0));

  const DietaryFilter(this.name, this.icon, this.color);
  final String name;
  final IconData icon;
  final Color color;
} 