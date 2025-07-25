import 'package:json_annotation/json_annotation.dart';

part 'exam_calculator_models.g.dart';

/// Sınav notu modeli / Exam score model
@JsonSerializable()
class ExamScore {
  final String id;
  final String name; // Exam name (e.g., "Midterm 1", "Quiz 1", "Final")
  final double? score; // Score value (null if not taken yet)
  final double weight; // Weight percentage (0.0 - 1.0)
  final double maxScore; // Maximum possible score (usually 100)
  final bool isRequired; // Whether this exam is required
  final DateTime? examDate; // Optional exam date
  final String? description; // Optional description

  ExamScore({
    required this.id,
    required this.name,
    this.score,
    required this.weight,
    this.maxScore = 100.0,
    this.isRequired = true,
    this.examDate,
    this.description,
  });

  /// Create from JSON
  factory ExamScore.fromJson(Map<String, dynamic> json) =>
      _$ExamScoreFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$ExamScoreToJson(this);

  /// Create a copy with updated values
  ExamScore copyWith({
    String? id,
    String? name,
    double? score,
    double? weight,
    double? maxScore,
    bool? isRequired,
    DateTime? examDate,
    String? description,
    bool? clearScore, // Add flag to explicitly clear score
  }) {
    return ExamScore(
      id: id ?? this.id,
      name: name ?? this.name,
      score: clearScore == true ? null : (score ?? this.score),
      weight: weight ?? this.weight,
      maxScore: maxScore ?? this.maxScore,
      isRequired: isRequired ?? this.isRequired,
      examDate: examDate ?? this.examDate,
      description: description ?? this.description,
    );
  }

  /// Check if this exam has been taken
  bool get isTaken => score != null;

  /// Get score as percentage (0.0 - 1.0)
  double get scorePercentage => score != null ? score! / maxScore : 0.0;

  /// Get weighted score contribution
  double get weightedScore => isTaken ? scorePercentage * weight : 0.0;

  @override
  String toString() {
    return 'ExamScore(id: $id, name: $name, score: $score, weight: $weight)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamScore && 
      runtimeType == other.runtimeType &&
      id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Ders hesaplama konfigürasyonu / Course calculation configuration
@JsonSerializable()
class CourseCalculation {
  final String id;
  final String courseName;
  final String courseCode;
  final List<ExamScore> exams;
  final double passingGrade; // Minimum grade to pass (e.g., 60.0)
  final double targetGrade; // Target grade to achieve (e.g., 85.0)
  final double maxGrade; // Maximum possible grade (usually 100.0)
  final CalculationMode mode;
  final DateTime createdAt;
  final DateTime updatedAt;

  CourseCalculation({
    required this.id,
    required this.courseName,
    this.courseCode = '',
    required this.exams,
    this.passingGrade = 60.0,
    this.targetGrade = 85.0,
    this.maxGrade = 100.0,
    this.mode = CalculationMode.calculateRequired,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create from JSON
  factory CourseCalculation.fromJson(Map<String, dynamic> json) =>
      _$CourseCalculationFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$CourseCalculationToJson(this);

  /// Create a copy with updated values
  CourseCalculation copyWith({
    String? id,
    String? courseName,
    String? courseCode,
    List<ExamScore>? exams,
    double? passingGrade,
    double? targetGrade,
    double? maxGrade,
    CalculationMode? mode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseCalculation(
      id: id ?? this.id,
      courseName: courseName ?? this.courseName,
      courseCode: courseCode ?? this.courseCode,
      exams: exams ?? this.exams,
      passingGrade: passingGrade ?? this.passingGrade,
      targetGrade: targetGrade ?? this.targetGrade,
      maxGrade: maxGrade ?? this.maxGrade,
      mode: mode ?? this.mode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Get total weight of all exams
  double get totalWeight => exams.fold(0.0, (sum, exam) => sum + exam.weight);

  /// Check if weights are valid (should sum to 1.0)
  bool get hasValidWeights => (totalWeight - 1.0).abs() < 0.001;

  /// Get taken exams (exams with scores)
  List<ExamScore> get takenExams => exams.where((exam) => exam.isTaken).toList();

  /// Get remaining exams (exams without scores)
  List<ExamScore> get remainingExams => exams.where((exam) => !exam.isTaken).toList();

  /// Get current course average from taken exams
  double get currentAverage {
    if (takenExams.isEmpty) return 0.0;
    
    double weightedSum = takenExams.fold(0.0, (sum, exam) => sum + exam.weightedScore);
    double takenWeight = takenExams.fold(0.0, (sum, exam) => sum + exam.weight);
    
    if (takenWeight == 0.0) return 0.0;
    
    return (weightedSum / takenWeight) * maxGrade;
  }

  /// Calculate required score for remaining exams to pass the course
  CalculationResult calculateRequiredScore() {
    if (remainingExams.isEmpty) {
      // All exams completed - show only course average
      return CalculationResult(
        isAchievable: true,
        requiredScore: 0.0,
        currentAverage: currentAverage,
        projectedFinalGrade: currentAverage,
        message: 'Course Average',
        isAllExamsCompleted: true,
      );
    }

    // Calculate current weighted score from taken exams
    double currentWeightedScore = takenExams.fold(0.0, (sum, exam) => sum + exam.weightedScore);
    
    // Calculate total weight of remaining exams
    double remainingWeight = remainingExams.fold(0.0, (sum, exam) => sum + exam.weight);
    
    if (remainingWeight == 0.0) {
      return CalculationResult(
        isAchievable: true,
        requiredScore: 0.0,
        currentAverage: currentAverage,
        projectedFinalGrade: currentAverage,
        message: 'Kalan sınav ağırlığı 0 / No remaining exam weight',
      );
    }

    // Calculate required weighted score to reach passing grade (not target grade)
    double passingWeightedScore = passingGrade / maxGrade;
    double requiredWeightedScore = passingWeightedScore - currentWeightedScore;
    
    // Calculate required average score for remaining exams
    double requiredAverageScore = (requiredWeightedScore / remainingWeight) * maxGrade;
    
    bool isAchievable = requiredAverageScore <= maxGrade && requiredAverageScore >= 0;
    
    String message = '';
    if (!isAchievable) {
      if (requiredAverageScore > maxGrade) {
        message = 'Dersi geçmek imkansız / Impossible to pass the course';
      } else {
        message = 'Dersi geçmek için yeterli not alındı / Sufficient score to pass already achieved';
      }
    } else {
      message = 'Dersi geçmek mümkün / Passing the course is achievable';
    }

    return CalculationResult(
      isAchievable: isAchievable,
      requiredScore: requiredAverageScore.clamp(0.0, maxGrade),
      currentAverage: currentAverage,
      projectedFinalGrade: isAchievable ? passingGrade : currentAverage,
      message: message,
      remainingExams: remainingExams,
    );
  }

  @override
  String toString() {
    return 'CourseCalculation(courseName: $courseName, mode: $mode, exams: ${exams.length})';
  }
}

/// Hesaplama sonucu modeli / Calculation result model
@JsonSerializable()
class CalculationResult {
  final bool isAchievable;
  final double requiredScore;
  final double currentAverage;
  final double projectedFinalGrade;
  final String message;
  final List<ExamScore>? remainingExams;
  final List<ExamScore>? completedExams;
  final Map<String, double>? breakdown; // Detailed breakdown of calculations
  final bool isAllExamsCompleted; // Flag to indicate all exams are completed

  CalculationResult({
    required this.isAchievable,
    required this.requiredScore,
    required this.currentAverage,
    required this.projectedFinalGrade,
    required this.message,
    this.remainingExams,
    this.completedExams,
    this.breakdown,
    this.isAllExamsCompleted = false,
  });

  /// Create from JSON
  factory CalculationResult.fromJson(Map<String, dynamic> json) =>
      _$CalculationResultFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$CalculationResultToJson(this);

  /// Get success status based on achievability and current performance
  ResultStatus get status {
    if (isAchievable && requiredScore <= 100.0) {
      if (requiredScore <= 70.0) return ResultStatus.excellent;
      if (requiredScore <= 85.0) return ResultStatus.good;
      return ResultStatus.challenging;
    } else {
      return ResultStatus.impossible;
    }
  }

  /// Get localized status message
  String getStatusMessage(bool isTurkish) {
    switch (status) {
      case ResultStatus.excellent:
        return isTurkish ? 'Mükemmel durum!' : 'Excellent situation!';
      case ResultStatus.good:
        return isTurkish ? 'İyi durum' : 'Good situation';
      case ResultStatus.challenging:
        return isTurkish ? 'Zorlu ama mümkün' : 'Challenging but possible';
      case ResultStatus.impossible:
        return isTurkish ? 'Hedef ulaşılamaz' : 'Target unreachable';
    }
  }
}

/// Hesaplama modu enum / Calculation mode enum
enum CalculationMode {
  @JsonValue('calculate_required')
  calculateRequired, // Calculate required score for remaining exams
  
  @JsonValue('calculate_current')
  calculateCurrent,  // Calculate current course average
}

/// Sonuç durumu enum / Result status enum
enum ResultStatus {
  excellent,   // Required score <= 70%
  good,        // Required score <= 85%
  challenging, // Required score <= 100%
  impossible,  // Required score > 100%
}

/// Sınav türü enum / Exam type enum
enum ExamType {
  @JsonValue('midterm')
  midterm,
  
  @JsonValue('final')
  final_,
  
  @JsonValue('quiz')
  quiz,
  
  @JsonValue('homework')
  homework,
  
  @JsonValue('project')
  project,
  
  @JsonValue('lab')
  lab,
  
  @JsonValue('presentation')
  presentation,
  
  @JsonValue('other')
  other,
}

/// Form doğrulama sonucu modeli / Form validation result model
class ValidationResult {
  final bool isValid;
  final String message;

  ValidationResult({required this.isValid, required this.message});
}

/// Sınav türü uzantı / Exam type extension
extension ExamTypeExtension on ExamType {
  String getDisplayName(bool isTurkish) {
    switch (this) {
      case ExamType.midterm:
        return isTurkish ? 'Vize' : 'Midterm';
      case ExamType.final_:
        return isTurkish ? 'Final' : 'Final';
      case ExamType.quiz:
        return isTurkish ? 'Quiz' : 'Quiz';
      case ExamType.homework:
        return isTurkish ? 'Ödev' : 'Homework';
      case ExamType.project:
        return isTurkish ? 'Proje' : 'Project';
      case ExamType.lab:
        return isTurkish ? 'Lab' : 'Lab';
      case ExamType.presentation:
        return isTurkish ? 'Sunum' : 'Presentation';
      case ExamType.other:
        return isTurkish ? 'Diğer' : 'Other';
    }
  }

  /// Get default weight for exam type
  double get defaultWeight {
    switch (this) {
      case ExamType.midterm:
        return 0.3; // 30%
      case ExamType.final_:
        return 0.4; // 40%
      case ExamType.quiz:
        return 0.1; // 10%
      case ExamType.homework:
        return 0.1; // 10%
      case ExamType.project:
        return 0.15; // 15%
      case ExamType.lab:
        return 0.1; // 10%
      case ExamType.presentation:
        return 0.1; // 10%
      case ExamType.other:
        return 0.1; // 10%
    }
  }
}