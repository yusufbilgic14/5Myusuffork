import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/exam_calculator_models.dart';
import '../services/secure_storage_service.dart';

/// Sınav hesaplayıcı servisi / Exam calculator service
/// Handles all exam calculation logic, validation, and persistence
class ExamCalculatorService {
  static final ExamCalculatorService _instance = ExamCalculatorService._internal();
  factory ExamCalculatorService() => _instance;
  ExamCalculatorService._internal();

  final SecureStorageService _storageService = SecureStorageService();
  
  // Cache for calculations
  final Map<String, CourseCalculation> _calculationsCache = {};
  final StreamController<List<CourseCalculation>> _calculationsController = 
      StreamController<List<CourseCalculation>>.broadcast();

  // Storage keys
  static const String _calculationsKey = 'exam_calculations';
  static const String _templatesKey = 'exam_templates';

  /// Get stream of all calculations
  Stream<List<CourseCalculation>> get calculationsStream => _calculationsController.stream;

  /// Initialize the service
  Future<void> initialize() async {
    try {
      await _loadCalculationsFromStorage();
      debugPrint('✅ ExamCalculatorService: Initialized successfully');
    } catch (e) {
      debugPrint('❌ ExamCalculatorService: Error initializing - $e');
    }
  }

  /// Create a new course calculation
  Future<CourseCalculation> createCalculation({
    required String courseName,
    String courseCode = '',
    double passingGrade = 60.0,
    CalculationMode mode = CalculationMode.calculateRequired,
  }) async {
    try {
      final calculation = CourseCalculation(
        id: _generateId(),
        courseName: courseName,
        courseCode: courseCode,
        exams: [],
        passingGrade: passingGrade,
        targetGrade: passingGrade, // Target grade is now the same as passing grade
        mode: mode,
      );

      _calculationsCache[calculation.id] = calculation;
      await _saveCalculationsToStorage();
      _notifyCalculationsChanged();

      debugPrint('✅ ExamCalculatorService: Created calculation for $courseName');
      return calculation;
    } catch (e) {
      debugPrint('❌ ExamCalculatorService: Error creating calculation - $e');
      rethrow;
    }
  }

  /// Update an existing calculation
  Future<CourseCalculation> updateCalculation(CourseCalculation calculation) async {
    try {
      final updatedCalculation = calculation.copyWith(updatedAt: DateTime.now());
      _calculationsCache[updatedCalculation.id] = updatedCalculation;
      await _saveCalculationsToStorage();
      _notifyCalculationsChanged();

      debugPrint('✅ ExamCalculatorService: Updated calculation ${calculation.id}');
      return updatedCalculation;
    } catch (e) {
      debugPrint('❌ ExamCalculatorService: Error updating calculation - $e');
      rethrow;
    }
  }

  /// Delete a calculation
  Future<void> deleteCalculation(String calculationId) async {
    try {
      _calculationsCache.remove(calculationId);
      await _saveCalculationsToStorage();
      _notifyCalculationsChanged();

      debugPrint('✅ ExamCalculatorService: Deleted calculation $calculationId');
    } catch (e) {
      debugPrint('❌ ExamCalculatorService: Error deleting calculation - $e');
      rethrow;
    }
  }

  /// Get a specific calculation by ID
  CourseCalculation? getCalculation(String calculationId) {
    return _calculationsCache[calculationId];
  }

  /// Get all calculations
  List<CourseCalculation> getAllCalculations() {
    return _calculationsCache.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  /// Add an exam to a calculation
  Future<CourseCalculation> addExam(String calculationId, ExamScore exam) async {
    final calculation = _calculationsCache[calculationId];
    if (calculation == null) {
      throw Exception('Calculation not found');
    }

    final updatedExams = List<ExamScore>.from(calculation.exams)..add(exam);
    final updatedCalculation = calculation.copyWith(exams: updatedExams);
    
    return await updateCalculation(updatedCalculation);
  }

  /// Update an exam in a calculation
  Future<CourseCalculation> updateExam(String calculationId, ExamScore exam) async {
    final calculation = _calculationsCache[calculationId];
    if (calculation == null) {
      throw Exception('Calculation not found');
    }

    final updatedExams = calculation.exams.map((e) => e.id == exam.id ? exam : e).toList();
    final updatedCalculation = calculation.copyWith(exams: updatedExams);
    
    return await updateCalculation(updatedCalculation);
  }

  /// Remove an exam from a calculation
  Future<CourseCalculation> removeExam(String calculationId, String examId) async {
    final calculation = _calculationsCache[calculationId];
    if (calculation == null) {
      throw Exception('Calculation not found');
    }

    final updatedExams = calculation.exams.where((e) => e.id != examId).toList();
    final updatedCalculation = calculation.copyWith(exams: updatedExams);
    
    return await updateCalculation(updatedCalculation);
  }

  /// Calculate minimum required score for remaining exams
  CalculationResult calculateRequiredScore(CourseCalculation calculation) {
    try {
      return calculation.calculateRequiredScore();
    } catch (e) {
      debugPrint('❌ ExamCalculatorService: Error calculating required score - $e');
      return CalculationResult(
        isAchievable: false,
        requiredScore: 0.0,
        currentAverage: calculation.currentAverage,
        projectedFinalGrade: calculation.currentAverage,
        message: 'Hesaplama hatası: $e',
        isAllExamsCompleted: false,
      );
    }
  }

  /// Calculate current course average
  double calculateCurrentAverage(CourseCalculation calculation) {
    return calculation.currentAverage;
  }

  /// Validate calculation weights
  ValidationResult validateWeights(List<ExamScore> exams) {
    if (exams.isEmpty) {
      return ValidationResult(
        isValid: false,
        message: 'En az bir sınav eklenmeli / At least one exam must be added',
      );
    }

    final totalWeight = exams.fold(0.0, (sum, exam) => sum + exam.weight);
    
    if ((totalWeight - 1.0).abs() > 0.001) {
      return ValidationResult(
        isValid: false,
        message: 'Toplam ağırlık %100 olmalı (Şu an: %${(totalWeight * 100).toStringAsFixed(1)}) / Total weight must be 100% (Currently: ${(totalWeight * 100).toStringAsFixed(1)}%)',
      );
    }

    // Check for negative weights
    final hasNegativeWeight = exams.any((exam) => exam.weight < 0);
    if (hasNegativeWeight) {
      return ValidationResult(
        isValid: false,
        message: 'Ağırlık değerleri negatif olamaz / Weight values cannot be negative',
      );
    }

    return ValidationResult(isValid: true, message: 'Ağırlıklar geçerli / Weights are valid');
  }

  /// Validate exam scores
  ValidationResult validateScores(List<ExamScore> exams) {
    for (final exam in exams) {
      if (exam.score != null) {
        if (exam.score! < 0 || exam.score! > exam.maxScore) {
          return ValidationResult(
            isValid: false,
            message: '${exam.name} notu 0 ile ${exam.maxScore} arasında olmalı / ${exam.name} score must be between 0 and ${exam.maxScore}',
          );
        }
      }
    }

    return ValidationResult(isValid: true, message: 'Notlar geçerli / Scores are valid');
  }

  /// Get exam templates for quick setup
  List<ExamTemplate> getExamTemplates() {
    return [
      ExamTemplate(
        name: 'Standart Ders / Standard Course',
        description: 'Vize (%40) + Final (%60)',
        exams: [
          ExamScore(
            id: _generateId(),
            name: 'Vize',
            weight: 0.4,
            maxScore: 100.0,
          ),
          ExamScore(
            id: _generateId(),
            name: 'Final',
            weight: 0.6,
            maxScore: 100.0,
          ),
        ],
      ),
      ExamTemplate(
        name: 'İki Vize Sistemi / Two Midterm System',
        description: 'Vize 1 (%25) + Vize 2 (%25) + Final (%40) + Ödev (%10)',
        exams: [
          ExamScore(
            id: _generateId(),
            name: 'Vize 1',
            weight: 0.25,
            maxScore: 100.0,
          ),
          ExamScore(
            id: _generateId(),
            name: 'Vize 2',
            weight: 0.25,
            maxScore: 100.0,
          ),
          ExamScore(
            id: _generateId(),
            name: 'Final',
            weight: 0.4,
            maxScore: 100.0,
          ),
          ExamScore(
            id: _generateId(),
            name: 'Ödev Ortalaması',
            weight: 0.1,
            maxScore: 100.0,
          ),
        ],
      ),
      ExamTemplate(
        name: 'Proje Odaklı / Project Focused',
        description: 'Vize (%20) + Final (%30) + Proje (%40) + Quiz (%10)',
        exams: [
          ExamScore(
            id: _generateId(),
            name: 'Vize',
            weight: 0.2,
            maxScore: 100.0,
          ),
          ExamScore(
            id: _generateId(),
            name: 'Final',
            weight: 0.3,
            maxScore: 100.0,
          ),
          ExamScore(
            id: _generateId(),
            name: 'Proje',
            weight: 0.4,
            maxScore: 100.0,
          ),
          ExamScore(
            id: _generateId(),
            name: 'Quiz Ortalaması',
            weight: 0.1,
            maxScore: 100.0,
          ),
        ],
      ),
    ];
  }

  /// Apply a template to a calculation
  Future<CourseCalculation> applyTemplate(String calculationId, ExamTemplate template) async {
    final calculation = _calculationsCache[calculationId];
    if (calculation == null) {
      throw Exception('Calculation not found');
    }

    final updatedCalculation = calculation.copyWith(exams: template.exams);
    return await updateCalculation(updatedCalculation);
  }

  /// Get statistics for all calculations
  CalculationStatistics getStatistics() {
    final calculations = getAllCalculations();
    
    return CalculationStatistics(
      totalCalculations: calculations.length,
      averageTargetGrade: calculations.isEmpty 
        ? 0.0 
        : calculations.fold(0.0, (sum, calc) => sum + calc.targetGrade) / calculations.length,
      successRate: calculations.isEmpty 
        ? 0.0 
        : calculations.where((calc) => calc.calculateRequiredScore().isAchievable).length / calculations.length,
      mostUsedMode: calculations.isEmpty 
        ? CalculationMode.calculateRequired 
        : _getMostUsedMode(calculations),
    );
  }

  /// Export calculation to shareable format
  Map<String, dynamic> exportCalculation(String calculationId) {
    final calculation = _calculationsCache[calculationId];
    if (calculation == null) {
      throw Exception('Calculation not found');
    }

    final result = calculation.calculateRequiredScore();
    
    return {
      'calculation': calculation.toJson(),
      'result': result.toJson(),
      'exportDate': DateTime.now().toIso8601String(),
      'appVersion': '1.0.0',
    };
  }

  /// Import calculation from exported data
  Future<CourseCalculation> importCalculation(Map<String, dynamic> data) async {
    try {
      final calculationData = data['calculation'] as Map<String, dynamic>;
      final calculation = CourseCalculation.fromJson(calculationData);
      
      // Generate new ID to avoid conflicts
      final newCalculation = calculation.copyWith(
        id: _generateId(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _calculationsCache[newCalculation.id] = newCalculation;
      await _saveCalculationsToStorage();
      _notifyCalculationsChanged();

      debugPrint('✅ ExamCalculatorService: Imported calculation ${newCalculation.courseName}');
      return newCalculation;
    } catch (e) {
      debugPrint('❌ ExamCalculatorService: Error importing calculation - $e');
      rethrow;
    }
  }

  /// Clear all calculations
  Future<void> clearAllCalculations() async {
    try {
      _calculationsCache.clear();
      await _saveCalculationsToStorage();
      _notifyCalculationsChanged();

      debugPrint('✅ ExamCalculatorService: Cleared all calculations');
    } catch (e) {
      debugPrint('❌ ExamCalculatorService: Error clearing calculations - $e');
      rethrow;
    }
  }

  /// Private: Load calculations from storage
  Future<void> _loadCalculationsFromStorage() async {
    try {
      // For now, use local cache only - can be extended to use secure storage later
      _calculationsCache.clear();
      _notifyCalculationsChanged();
      
      debugPrint('✅ ExamCalculatorService: Initialized empty calculations cache');
    } catch (e) {
      debugPrint('❌ ExamCalculatorService: Error loading from storage - $e');
      _calculationsCache.clear();
    }
  }

  /// Private: Save calculations to storage
  Future<void> _saveCalculationsToStorage() async {
    try {
      // For now, calculations are stored in memory only
      // This can be extended to use secure storage or SharedPreferences later
      debugPrint('✅ ExamCalculatorService: Calculations cached in memory');
    } catch (e) {
      debugPrint('❌ ExamCalculatorService: Error saving to storage - $e');
    }
  }

  /// Private: Notify calculations changed
  void _notifyCalculationsChanged() {
    final calculations = getAllCalculations();
    _calculationsController.add(calculations);
  }

  /// Private: Generate unique ID
  String _generateId() {
    return 'calc_${DateTime.now().millisecondsSinceEpoch}_${UniqueKey().toString()}';
  }

  /// Private: Get most used calculation mode
  CalculationMode _getMostUsedMode(List<CourseCalculation> calculations) {
    final modeCount = <CalculationMode, int>{};
    
    for (final calc in calculations) {
      modeCount[calc.mode] = (modeCount[calc.mode] ?? 0) + 1;
    }
    
    return modeCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Dispose the service
  void dispose() {
    _calculationsController.close();
  }
}

/// Exam template model for quick setup
class ExamTemplate {
  final String name;
  final String description;
  final List<ExamScore> exams;

  ExamTemplate({
    required this.name,
    required this.description,
    required this.exams,
  });
}

/// Statistics model for calculations
class CalculationStatistics {
  final int totalCalculations;
  final double averageTargetGrade;
  final double successRate;
  final CalculationMode mostUsedMode;

  CalculationStatistics({
    required this.totalCalculations,
    required this.averageTargetGrade,
    required this.successRate,
    required this.mostUsedMode,
  });
}