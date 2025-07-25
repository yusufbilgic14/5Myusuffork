// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_calculator_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamScore _$ExamScoreFromJson(Map<String, dynamic> json) => ExamScore(
  id: json['id'] as String,
  name: json['name'] as String,
  score: (json['score'] as num?)?.toDouble(),
  weight: (json['weight'] as num).toDouble(),
  maxScore: (json['maxScore'] as num?)?.toDouble() ?? 100.0,
  isRequired: json['isRequired'] as bool? ?? true,
  examDate: json['examDate'] == null
      ? null
      : DateTime.parse(json['examDate'] as String),
  description: json['description'] as String?,
);

Map<String, dynamic> _$ExamScoreToJson(ExamScore instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'score': instance.score,
  'weight': instance.weight,
  'maxScore': instance.maxScore,
  'isRequired': instance.isRequired,
  'examDate': instance.examDate?.toIso8601String(),
  'description': instance.description,
};

CourseCalculation _$CourseCalculationFromJson(Map<String, dynamic> json) =>
    CourseCalculation(
      id: json['id'] as String,
      courseName: json['courseName'] as String,
      courseCode: json['courseCode'] as String? ?? '',
      exams: (json['exams'] as List<dynamic>)
          .map((e) => ExamScore.fromJson(e as Map<String, dynamic>))
          .toList(),
      passingGrade: (json['passingGrade'] as num?)?.toDouble() ?? 60.0,
      targetGrade: (json['targetGrade'] as num?)?.toDouble() ?? 85.0,
      maxGrade: (json['maxGrade'] as num?)?.toDouble() ?? 100.0,
      mode:
          $enumDecodeNullable(_$CalculationModeEnumMap, json['mode']) ??
          CalculationMode.calculateRequired,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CourseCalculationToJson(CourseCalculation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'courseName': instance.courseName,
      'courseCode': instance.courseCode,
      'exams': instance.exams,
      'passingGrade': instance.passingGrade,
      'targetGrade': instance.targetGrade,
      'maxGrade': instance.maxGrade,
      'mode': _$CalculationModeEnumMap[instance.mode]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$CalculationModeEnumMap = {
  CalculationMode.calculateRequired: 'calculate_required',
  CalculationMode.calculateCurrent: 'calculate_current',
};

CalculationResult _$CalculationResultFromJson(Map<String, dynamic> json) =>
    CalculationResult(
      isAchievable: json['isAchievable'] as bool,
      requiredScore: (json['requiredScore'] as num).toDouble(),
      currentAverage: (json['currentAverage'] as num).toDouble(),
      projectedFinalGrade: (json['projectedFinalGrade'] as num).toDouble(),
      message: json['message'] as String,
      remainingExams: (json['remainingExams'] as List<dynamic>?)
          ?.map((e) => ExamScore.fromJson(e as Map<String, dynamic>))
          .toList(),
      completedExams: (json['completedExams'] as List<dynamic>?)
          ?.map((e) => ExamScore.fromJson(e as Map<String, dynamic>))
          .toList(),
      breakdown: (json['breakdown'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      isAllExamsCompleted: json['isAllExamsCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$CalculationResultToJson(CalculationResult instance) =>
    <String, dynamic>{
      'isAchievable': instance.isAchievable,
      'requiredScore': instance.requiredScore,
      'currentAverage': instance.currentAverage,
      'projectedFinalGrade': instance.projectedFinalGrade,
      'message': instance.message,
      'remainingExams': instance.remainingExams,
      'completedExams': instance.completedExams,
      'breakdown': instance.breakdown,
      'isAllExamsCompleted': instance.isAllExamsCompleted,
    };
