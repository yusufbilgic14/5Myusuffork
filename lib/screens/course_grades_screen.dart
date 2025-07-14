import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../themes/app_themes.dart';
import '../widgets/common/app_bar_widget.dart';
import '../widgets/common/app_drawer_widget.dart';
import '../widgets/common/bottom_navigation_widget.dart';

// Veri modelleri / Data models
class CourseGrade {
  final String type; // Midterm, Quiz, Final, etc.
  final String value; // Numerical score or "waiting"
  final String letterGrade; // AA, BB, CC, etc.
  final bool isWaiting; // True if grade is not yet available

  CourseGrade({
    required this.type,
    required this.value,
    required this.letterGrade,
    this.isWaiting = false,
  });
}

class Course {
  final String id;
  final String name;
  final String code;
  final String professor;
  final List<CourseGrade> grades;
  final double gpa;
  final String letterGrade;
  final int credit;

  Course({
    required this.id,
    required this.name,
    required this.code,
    required this.professor,
    required this.grades,
    required this.gpa,
    required this.letterGrade,
    required this.credit,
  });
}

class Semester {
  final String id;
  final String name;
  final String period;
  final List<Course> courses;
  final double semesterGPA;
  final double cumulativeGPA;

  Semester({
    required this.id,
    required this.name,
    required this.period,
    required this.courses,
    required this.semesterGPA,
    required this.cumulativeGPA,
  });
}

class CourseGradesScreen extends StatefulWidget {
  const CourseGradesScreen({super.key});

  @override
  State<CourseGradesScreen> createState() => _CourseGradesScreenState();
}

class _CourseGradesScreenState extends State<CourseGradesScreen> {
  int _selectedSemesterIndex = 0;
  final Set<String> _expandedCourses =
      {}; // Açık kursları takip etmek için / Track expanded courses
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, waiting, completed
  String _sortBy = 'name'; // name, grade, gpa

  // Örnek veri / Sample data
  final List<Semester> _semesters = [
    Semester(
      id: 'spring_2024_2025',
      name: '2024-2025 Bahar',
      period: 'Spring',
      semesterGPA: 3.25,
      cumulativeGPA: 3.18,
      courses: [
        Course(
          id: 'cse304',
          name: 'Nesne Tabanlı Programlama',
          code: 'CSE 304',
          professor: 'Prof. Dr. Ahmet Yılmaz',
          credit: 4,
          gpa: 3.5,
          letterGrade: 'BB',
          grades: [
            CourseGrade(type: 'Vize 1', value: '10', letterGrade: 'FF'),
            CourseGrade(type: 'Quiz 1', value: '10', letterGrade: 'FF'),
            CourseGrade(type: 'Ödev 1', value: '25', letterGrade: 'FF'),
            CourseGrade(
              type: 'Final',
              value: 'waiting',
              letterGrade: '',
              isWaiting: true,
            ),
          ],
        ),
        Course(
          id: 'cse302',
          name: 'Algoritma ve Veri Yapıları',
          code: 'CSE 302',
          professor: 'Doç. Dr. Yusuf Bircan',
          credit: 4,
          gpa: 3.0,
          letterGrade: 'BB',
          grades: [
            CourseGrade(type: 'Vize 1', value: '78', letterGrade: 'BB'),
            CourseGrade(type: 'Vize 2', value: '82', letterGrade: 'BB'),
            CourseGrade(type: 'Quiz 1', value: '70', letterGrade: 'BB'),
            CourseGrade(type: 'Quiz 2', value: '88', letterGrade: 'AA'),
            CourseGrade(
              type: 'Final',
              value: 'waiting',
              letterGrade: '',
              isWaiting: true,
            ),
          ],
        ),
        Course(
          id: 'mat205',
          name: 'Matematik III',
          code: 'MAT 205',
          professor: 'Prof. Dr. Mehmet Özkan',
          credit: 3,
          gpa: 2.5,
          letterGrade: 'CC',
          grades: [
            CourseGrade(type: 'Vize 1', value: '65', letterGrade: 'CB'),
            CourseGrade(type: 'Vize 2', value: '70', letterGrade: 'CB'),
            CourseGrade(type: 'Final', value: '68', letterGrade: 'CC'),
          ],
        ),
        Course(
          id: 'eng301',
          name: 'Technical English',
          code: 'ENG 301',
          professor: 'Dr. Sarah Johnson',
          credit: 2,
          gpa: 4.0,
          letterGrade: 'AA',
          grades: [
            CourseGrade(type: 'Vize 1', value: '92', letterGrade: 'AA'),
            CourseGrade(type: 'Vize 2', value: '88', letterGrade: 'AA'),
            CourseGrade(type: 'Proje', value: '95', letterGrade: 'AA'),
            CourseGrade(type: 'Final', value: '90', letterGrade: 'AA'),
          ],
        ),
      ],
    ),
    Semester(
      id: 'fall_2024_2025',
      name: '2024-2025 Güz',
      period: 'Fall',
      semesterGPA: 3.10,
      cumulativeGPA: 3.15,
      courses: [
        Course(
          id: 'cse301',
          name: 'Veritabanı Yönetim Sistemleri',
          code: 'CSE 301',
          professor: 'Prof. Dr. Fatma Kara',
          credit: 4,
          gpa: 3.5,
          letterGrade: 'BB',
          grades: [
            CourseGrade(type: 'Vize 1', value: '85', letterGrade: 'AA'),
            CourseGrade(type: 'Vize 2', value: '78', letterGrade: 'BB'),
            CourseGrade(type: 'Proje', value: '92', letterGrade: 'AA'),
            CourseGrade(type: 'Final', value: '80', letterGrade: 'BB'),
          ],
        ),
        Course(
          id: 'cse303',
          name: 'Bilgisayar Ağları',
          code: 'CSE 303',
          professor: 'Doç. Dr. Ali Demir',
          credit: 3,
          gpa: 2.5,
          letterGrade: 'CC',
          grades: [
            CourseGrade(type: 'Vize 1', value: '72', letterGrade: 'CB'),
            CourseGrade(type: 'Vize 2', value: '68', letterGrade: 'CC'),
            CourseGrade(type: 'Final', value: '75', letterGrade: 'CB'),
          ],
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.getBackgroundColor(context),
      appBar: const CommonAppBar(title: 'Ders Notları'),
      drawer: const AppDrawerWidget(currentPageIndex: -1), // Ders notları sayfası navigasyon dışında / Course grades page is outside navigation
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Dönem seçici ve üst butonlar / Semester selector and top buttons
            _buildTopSection(context),

            // GPA bilgisi / GPA information
            _buildGPASection(context),

            // Arama ve filtreler / Search and filters
            _buildSearchAndFilters(context),

            // Ders kartları / Course cards
            _buildCoursesList(context),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 2),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _refreshGrades(context),
        backgroundColor: AppThemes.getPrimaryColor(context),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  /// Üst bölüm - dönem seçici ve butonlar / Top section - semester selector and buttons
  Widget _buildTopSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppThemes.getSurfaceColor(context),
        boxShadow: AppThemes.getCardShadow(context),
      ),
      child: Column(
        children: [
          // Dönem seçici / Semester selector
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingSmall,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppThemes.getPrimaryColor(context)),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: DropdownButton<int>(
              value: _selectedSemesterIndex,
              isExpanded: true,
              underline: const SizedBox(),
              icon: Icon(
                Icons.arrow_drop_down,
                color: AppThemes.getPrimaryColor(context),
              ),
              items: _semesters.asMap().entries.map((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(
                    entry.value.name,
                    style: TextStyle(
                      color: AppThemes.getTextColor(context),
                      fontSize: AppConstants.fontSizeMedium,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSemesterIndex = value;
                    _expandedCourses
                        .clear(); // Dönem değiştirince genişletilen kartları kapat / Close expanded cards when semester changes
                  });
                }
              },
            ),
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          // Üst butonlar / Top buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showPointPDF(context),
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text('Point PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemes.getPrimaryColor(context),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSmall,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showTranscript(context),
                  icon: const Icon(Icons.description, size: 18),
                  label: const Text('Transcript'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemes.getPrimaryColor(context),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSmall,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// GPA bilgi bölümü / GPA information section
  Widget _buildGPASection(BuildContext context) {
    final semester = _semesters[_selectedSemesterIndex];
    final waitingGrades = semester.courses
        .where((course) => course.grades.any((grade) => grade.isWaiting))
        .length;
    final completedCourses = semester.courses.length - waitingGrades;

    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppThemes.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: AppThemes.getCardShadow(context),
      ),
      child: Column(
        children: [
          // GPA bilgileri / GPA information
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dönem GPA / Semester GPA',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        color: AppThemes.getSecondaryTextColor(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      semester.semesterGPA.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeXLarge,
                        color: AppThemes.getPrimaryColor(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppThemes.getSecondaryTextColor(
                  context,
                ).withValues(alpha: 0.3),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Genel GPA / Cumulative GPA',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        color: AppThemes.getSecondaryTextColor(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      semester.cumulativeGPA.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeXLarge,
                        color: AppThemes.getPrimaryColor(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          // İstatistikler / Statistics
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingSmall),
            decoration: BoxDecoration(
              color: AppThemes.getBackgroundColor(context),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${semester.courses.length}',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeMedium,
                        fontWeight: FontWeight.bold,
                        color: AppThemes.getPrimaryColor(context),
                      ),
                    ),
                    Text(
                      'Toplam Ders',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        color: AppThemes.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '$completedCourses',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeMedium,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[600],
                      ),
                    ),
                    Text(
                      'Tamamlanan',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        color: AppThemes.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '$waitingGrades',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeMedium,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[600],
                      ),
                    ),
                    Text(
                      'Beklemede',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        color: AppThemes.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${semester.courses.fold(0, (sum, course) => sum + course.credit)}',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeMedium,
                        fontWeight: FontWeight.bold,
                        color: AppThemes.getPrimaryColor(context),
                      ),
                    ),
                    Text(
                      'Kredi',
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        color: AppThemes.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Arama ve filtreler / Search and filters
  Widget _buildSearchAndFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        children: [
          // Arama kutusu / Search box
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Ders adı veya kodu ara...',
              prefixIcon: const Icon(Icons.search),
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
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),

          const SizedBox(height: AppConstants.paddingSmall),

          // Filtreler ve sıralama / Filters and sorting
          Row(
            children: [
              // Durum filtresi / Status filter
              Expanded(
                child: DropdownButton<String>(
                  value: _filterStatus,
                  isExpanded: true,
                  hint: const Text('Durum'),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Tümü')),
                    DropdownMenuItem(
                      value: 'waiting',
                      child: Text('Beklemede'),
                    ),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Text('Tamamlanan'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _filterStatus = value;
                      });
                    }
                  },
                ),
              ),

              const SizedBox(width: AppConstants.paddingSmall),

              // Sıralama / Sorting
              Expanded(
                child: DropdownButton<String>(
                  value: _sortBy,
                  isExpanded: true,
                  hint: const Text('Sırala'),
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('Ada göre')),
                    DropdownMenuItem(value: 'grade', child: Text('Nota göre')),
                    DropdownMenuItem(value: 'gpa', child: Text('GPA\'ya göre')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sortBy = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Ders listesi / Courses list
  Widget _buildCoursesList(BuildContext context) {
    final semester = _semesters[_selectedSemesterIndex];

    // Filtreleme ve sıralama uygula / Apply filtering and sorting
    List<Course> filteredCourses = semester.courses.where((course) {
      // Arama filtresi / Search filter
      bool matchesSearch =
          _searchQuery.isEmpty ||
          course.name.toLowerCase().contains(_searchQuery) ||
          course.code.toLowerCase().contains(_searchQuery) ||
          course.professor.toLowerCase().contains(_searchQuery);

      // Durum filtresi / Status filter
      bool matchesStatus =
          _filterStatus == 'all' ||
          (_filterStatus == 'waiting' &&
              course.grades.any((grade) => grade.isWaiting)) ||
          (_filterStatus == 'completed' &&
              course.grades.every((grade) => !grade.isWaiting));

      return matchesSearch && matchesStatus;
    }).toList();

    // Sıralama / Sorting
    filteredCourses.sort((a, b) {
      switch (_sortBy) {
        case 'name':
          return a.name.compareTo(b.name);
        case 'grade':
          return a.letterGrade.compareTo(b.letterGrade);
        case 'gpa':
          return b.gpa.compareTo(a.gpa); // Büyükten küçüğe / High to low
        default:
          return 0;
      }
    });

    if (filteredCourses.isEmpty) {
      return Container(
        height: 200,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Arama kriterlerinize uygun ders bulunamadı.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true, // ListView boyutunu içerik kadar sınırla / Limit ListView size to content
      physics: const NeverScrollableScrollPhysics(), // Ana SingleChildScrollView kullanacağız / Use main SingleChildScrollView
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
      ),
      itemCount: filteredCourses.length,
      itemBuilder: (context, index) {
        final course = filteredCourses[index];
        return _buildCourseCard(context, course);
      },
    );
  }

  /// Ders kartı / Course card
  Widget _buildCourseCard(BuildContext context, Course course) {
    final isExpanded = _expandedCourses.contains(course.id);

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppThemes.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: AppThemes.getCardShadow(context),
      ),
      child: Column(
        children: [
          // Ders başlığı / Course header
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedCourses.remove(course.id);
                } else {
                  _expandedCourses.add(course.id);
                }
              });
            },
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            child: Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Row(
                children: [
                  // Ders bilgisi / Course info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${course.code} - ${course.name}',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeMedium,
                            fontWeight: FontWeight.w600,
                            color: AppThemes.getTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          course.professor,
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeSmall,
                            color: AppThemes.getSecondaryTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kredi: ${course.credit} | GPA: ${course.gpa.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeSmall,
                            color: AppThemes.getSecondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Harf notu / Letter grade
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getGradeColor(course.letterGrade),
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSmall,
                      ),
                    ),
                    child: Text(
                      course.letterGrade,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: AppConstants.fontSizeMedium,
                      ),
                    ),
                  ),

                  const SizedBox(width: AppConstants.paddingSmall),

                  // Genişletme ikonu / Expand icon
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppThemes.getPrimaryColor(context),
                  ),
                ],
              ),
            ),
          ),

          // Genişletilen içerik / Expanded content
          if (isExpanded) ...[
            const Divider(height: 1),
            _buildExpandedContent(context, course),
          ],
        ],
      ),
    );
  }

  /// Genişletilen içerik / Expanded content
  Widget _buildExpandedContent(BuildContext context, Course course) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detaylı Notlar / Detailed Grades',
            style: TextStyle(
              fontSize: AppConstants.fontSizeMedium,
              fontWeight: FontWeight.w600,
              color: AppThemes.getTextColor(context),
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),

          // Notlar listesi / Grades list
          ...course.grades.map((grade) => _buildGradeRow(context, grade)),
        ],
      ),
    );
  }

  /// Not satırı / Grade row
  Widget _buildGradeRow(BuildContext context, CourseGrade grade) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      padding: const EdgeInsets.all(AppConstants.paddingSmall),
      decoration: BoxDecoration(
        color: AppThemes.getBackgroundColor(context),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        border: Border.all(
          color: AppThemes.getSecondaryTextColor(
            context,
          ).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Sınav türü / Exam type
          Expanded(
            flex: 2,
            child: Text(
              grade.type,
              style: TextStyle(
                fontSize: AppConstants.fontSizeSmall,
                fontWeight: FontWeight.w500,
                color: AppThemes.getTextColor(context),
              ),
            ),
          ),

          // Sayısal not / Numerical grade
          Expanded(
            child: Text(
              grade.isWaiting ? 'Beklemede...' : grade.value,
              style: TextStyle(
                fontSize: AppConstants.fontSizeSmall,
                color: grade.isWaiting
                    ? AppThemes.getSecondaryTextColor(context)
                    : AppThemes.getTextColor(context),
                fontStyle: grade.isWaiting
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ),

          // Harf notu / Letter grade
          if (!grade.isWaiting)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getGradeColor(grade.letterGrade),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                grade.letterGrade,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppConstants.fontSizeSmall,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Harf notuna göre renk belirle / Determine color based on letter grade
  Color _getGradeColor(String letterGrade) {
    switch (letterGrade) {
      case 'AA':
        return Colors.green[600]!;
      case 'BA':
        return Colors.green[500]!;
      case 'BB':
        return Colors.blue[600]!;
      case 'CB':
        return Colors.orange[600]!;
      case 'CC':
        return Colors.orange[700]!;
      case 'DC':
        return Colors.red[600]!;
      case 'DD':
        return Colors.red[700]!;
      case 'FF':
        return Colors.red[800]!;
      default:
        return Colors.grey[600]!;
    }
  }

  /// Point PDF göster / Show point PDF
  void _showPointPDF(BuildContext context) {
    final semester = _semesters[_selectedSemesterIndex];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Point PDF'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dönem: ${semester.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Dönem GPA: ${semester.semesterGPA.toStringAsFixed(2)}'),
              Text('Genel GPA: ${semester.cumulativeGPA.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              const Text(
                'Bu dönem için PDF raporu oluşturulacak...',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'PDF özelliği yakında eklenecektir.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  /// Transcript göster / Show transcript
  void _showTranscript(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transcript'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tüm dönemler için genel transcript hazırlanacak...',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('Toplam GPA: ${_calculateOverallGPA().toStringAsFixed(2)}'),
              Text('Toplam Kredi: ${_calculateTotalCredits()}'),
              const SizedBox(height: 16),
              const Text(
                'İçerik:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...List.generate(_semesters.length, (index) {
                final semester = _semesters[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Text('• '),
                      Expanded(
                        child: Text(
                          '${semester.name} - ${semester.courses.length} ders',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Transcript özelliği yakında eklenecektir.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  /// Genel GPA hesapla / Calculate overall GPA
  double _calculateOverallGPA() {
    if (_semesters.isEmpty) return 0.0;

    double totalWeightedGPA = 0.0;
    int totalCredits = 0;

    for (final semester in _semesters) {
      for (final course in semester.courses) {
        totalWeightedGPA += course.gpa * course.credit;
        totalCredits += course.credit;
      }
    }

    return totalCredits > 0 ? totalWeightedGPA / totalCredits : 0.0;
  }

  /// Toplam kredi hesapla / Calculate total credits
  int _calculateTotalCredits() {
    int totalCredits = 0;
    for (final semester in _semesters) {
      for (final course in semester.courses) {
        totalCredits += course.credit;
      }
    }
    return totalCredits;
  }



  /// Notları yenile / Refresh grades
  void _refreshGrades(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            const Text('Notlar yenileniyor...'),
          ],
        ),
      ),
    );

    // Simülasyon için 2 saniye bekle / Wait 2 seconds for simulation
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Notlar başarıyla güncellendi!'),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );

      // Gerçek uygulamada burada API çağrısı yapılır / In real app, API call would be made here
      setState(() {
        // Örnek olarak bekleyen notları güncelle / Update waiting grades as example
        // Bu kısım gerçek API entegrasyonunda dinamik olur / This part would be dynamic in real API integration
      });
    });
  }
}
