import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../themes/app_themes.dart';
import '../widgets/common/app_bar_widget.dart';
import '../widgets/common/app_drawer_widget.dart';
import '../widgets/common/bottom_navigation_widget.dart';
import '../l10n/app_localizations.dart';
import '../models/exam_calculator_models.dart';
import '../services/exam_calculator_service.dart';

class ExamCalculatorScreen extends StatefulWidget {
  const ExamCalculatorScreen({super.key});

  @override
  State<ExamCalculatorScreen> createState() => _ExamCalculatorScreenState();
}

class _ExamCalculatorScreenState extends State<ExamCalculatorScreen> with TickerProviderStateMixin {
  final ExamCalculatorService _calculatorService = ExamCalculatorService();
  
  // Form controllers
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _courseCodeController = TextEditingController();
  final TextEditingController _passingGradeController = TextEditingController(text: '60');
  
  // State variables - Fixed to Required Score mode only
  final CalculationMode _calculationMode = CalculationMode.calculateRequired;
  List<ExamScore> _exams = [];
  CalculationResult? _calculationResult;
  bool _isCalculating = false;
  
  // Animation controllers
  late AnimationController _resultAnimationController;
  late Animation<double> _resultAnimation;
  late AnimationController _examListAnimationController;
  late Animation<double> _examListAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDefaultTemplate();
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseCodeController.dispose();
    _passingGradeController.dispose();
    _resultAnimationController.dispose();
    _examListAnimationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _resultAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _resultAnimation = CurvedAnimation(
      parent: _resultAnimationController,
      curve: Curves.elasticOut,
    );

    _examListAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _examListAnimation = CurvedAnimation(
      parent: _examListAnimationController,
      curve: Curves.easeInOut,
    );
  }

  void _loadDefaultTemplate() {
    final templates = _calculatorService.getExamTemplates();
    if (templates.isNotEmpty) {
      setState(() {
        _exams = List.from(templates.first.exams);
      });
      _examListAnimationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.getBackgroundColor(context),
      appBar: ModernAppBar(
        title: AppLocalizations.of(context)!.examCalculator,
        subtitle: AppLocalizations.of(context)!.examCalculatorSubtitle,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
              tooltip: 'Menü',
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () => _showHelpDialog(),
            tooltip: AppLocalizations.of(context)!.help,
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => _showCalculationHistory(),
            tooltip: AppLocalizations.of(context)!.history,
          ),
        ],
      ),
      drawer: const AppDrawerWidget(currentPageIndex: -1),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // Course information
            _buildCourseInfoSection(),
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Exams section
            _buildExamsSection(),
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Calculate button
            _buildCalculateButton(),
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Results section
            if (_calculationResult != null)
              _buildResultsSection(),
            
            const SizedBox(height: 100), // Bottom padding for FAB
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: -1),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }



  Widget _buildCourseInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.school_outlined,
                  color: AppThemes.getPrimaryColor(context),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.courseInfo,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: AppThemes.getTextColor(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Course name and code
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: _courseNameController,
                    label: AppLocalizations.of(context)!.courseName,
                    hint: AppLocalizations.of(context)!.courseNameHint,
                    icon: Icons.book_outlined,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Expanded(
                  child: _buildTextField(
                    controller: _courseCodeController,
                    label: AppLocalizations.of(context)!.courseCode,
                    hint: AppLocalizations.of(context)!.courseCodeHint,
                    icon: Icons.code,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Passing grade only
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    controller: _passingGradeController,
                    label: AppLocalizations.of(context)!.passingGrade,
                    hint: '60',
                    icon: Icons.check_circle_outline,
                    suffix: '%',
                  ),
                ),
                // Removed target grade field completely
                const Expanded(flex: 1, child: SizedBox()), // Spacer to maintain layout
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment_outlined,
                  color: AppThemes.getPrimaryColor(context),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.examsAndWeights,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                    color: AppThemes.getTextColor(context),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _showTemplateDialog,
                  icon: Icon(
                    Icons.description_outlined,
                    color: AppThemes.getPrimaryColor(context),
                    size: 20,
                  ),
                  tooltip: AppLocalizations.of(context)!.selectTemplate,
                ),
              ],
            ),
            
            const SizedBox(height: AppConstants.paddingSmall),
            
            // Weight validation indicator
            _buildWeightIndicator(),
            
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Exams list
            AnimatedBuilder(
              animation: _examListAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _examListAnimation.value,
                  child: Opacity(
                    opacity: _examListAnimation.value,
                    child: Column(
                      children: [
                        ..._exams.asMap().entries.map((entry) {
                          return _buildExamCard(entry.key, entry.value);
                        }),
                        
                        // Add exam button
                        _buildAddExamButton(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightIndicator() {
    final totalWeight = _exams.fold(0.0, (sum, exam) => sum + exam.weight);
    final isValid = (totalWeight - 1.0).abs() < 0.001;
    final percentage = (totalWeight * 100);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isValid 
          ? Colors.green.withValues(alpha: 0.1)
          : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isValid ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.warning,
            color: isValid ? Colors.green : Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            '${AppLocalizations.of(context)!.totalWeight}: %${percentage.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isValid ? Colors.green : Colors.orange,
            ),
          ),
          if (!isValid) ...[
            const Spacer(),
            Text(
              AppLocalizations.of(context)!.mustBe100,
              style: TextStyle(
                fontSize: 11,
                color: Colors.orange.withValues(alpha: 0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExamCard(int index, ExamScore exam) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      decoration: BoxDecoration(
        color: AppThemes.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppThemes.getSecondaryTextColor(context).withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: exam.name,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.examName,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (value) => _updateExam(index, exam.copyWith(name: value)),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    initialValue: (exam.weight * 100).toStringAsFixed(0),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.weight,
                      suffix: const Text('%'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      final weight = (double.tryParse(value) ?? 0) / 100;
                      _updateExam(index, exam.copyWith(weight: weight));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _removeExam(index),
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.withValues(alpha: 0.7),
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: exam.score?.toString() ?? '',
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.score,
                      hintText: exam.score == null ? AppLocalizations.of(context)!.notEnteredYet : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    onChanged: (value) {
                      final trimmedValue = value.trim();
                      if (trimmedValue.isEmpty) {
                        // Explicitly clear the score when text is empty
                        _updateExam(index, exam.copyWith(clearScore: true));
                      } else {
                        final score = double.tryParse(trimmedValue);
                        _updateExam(index, exam.copyWith(score: score));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    initialValue: exam.maxScore.toStringAsFixed(0),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.maxScore,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      final maxScore = double.tryParse(value) ?? 100;
                      _updateExam(index, exam.copyWith(maxScore: maxScore));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddExamButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: AppConstants.paddingSmall),
      child: OutlinedButton.icon(
        onPressed: _addExam,
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.addExam),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildCalculateButton() {
    final validation = _validateForm();
    final isValid = validation.isValid;
    
    return Column(
      children: [
        // Validation message
        if (!isValid)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    validation.message,
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // Calculate button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isValid && !_isCalculating ? _calculateResults : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isValid 
                ? AppThemes.getPrimaryColor(context)
                : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: isValid ? 4 : 0,
            ),
            child: _isCalculating
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.trending_up),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.calculateRequiredScore,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsSection() {
    return AnimatedBuilder(
      animation: _resultAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _resultAnimation.value,
          child: Opacity(
            opacity: _resultAnimation.value,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          color: AppThemes.getPrimaryColor(context),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.results,
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeMedium,
                            fontWeight: FontWeight.w600,
                            color: AppThemes.getTextColor(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    
                    _buildResultCards(),
                    
                    if (_calculationResult!.message.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.paddingMedium),
                      _buildResultMessage(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultCards() {
    final result = _calculationResult!;
    
    // If all exams are completed, show only Course Average
    if (result.isAllExamsCompleted) {
      return _buildResultCard(
        title: result.message, // "Course Average"
        value: result.currentAverage.toStringAsFixed(1),
        suffix: '/${_exams.isNotEmpty ? _exams.first.maxScore.toStringAsFixed(0) : "100"}',
        color: _getScoreColor(result.currentAverage),
        icon: Icons.school,
      );
    }
    
    // Otherwise show only required score calculation
    return _buildResultCard(
      title: AppLocalizations.of(context)!.requiredScoreToPass,
      value: result.requiredScore.toStringAsFixed(1),
      suffix: '/${_exams.isNotEmpty ? _exams.first.maxScore.toStringAsFixed(0) : "100"}',
      color: _getScoreColor(result.requiredScore),
      icon: Icons.trending_up,
    );
  }

  Widget _buildResultCard({
    required String title,
    required String value,
    required String suffix,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppThemes.getSecondaryTextColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      suffix,
                      style: TextStyle(
                        fontSize: 14,
                        color: color.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
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

  Widget _buildResultMessage() {
    final result = _calculationResult!;
    final status = result.status;
    
    Color messageColor;
    IconData messageIcon;
    
    switch (status) {
      case ResultStatus.excellent:
        messageColor = Colors.green;
        messageIcon = Icons.check_circle;
        break;
      case ResultStatus.good:
        messageColor = Colors.blue;
        messageIcon = Icons.thumb_up;
        break;
      case ResultStatus.challenging:
        messageColor = Colors.orange;
        messageIcon = Icons.warning;
        break;
      case ResultStatus.impossible:
        messageColor = Colors.red;
        messageIcon = Icons.error;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: messageColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: messageColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(messageIcon, color: messageColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              result.message,
              style: TextStyle(
                color: messageColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        suffix: suffix != null ? Text(suffix) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showActionsBottomSheet,
      backgroundColor: AppThemes.getPrimaryColor(context),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.more_horiz),
      label: Text(AppLocalizations.of(context)!.actions),
    );
  }

  // Helper methods
  Color _getScoreColor(double score) {
    if (score >= 85) return Colors.green;
    if (score >= 70) return Colors.blue;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }


  ValidationResult _validateForm() {
    // Check if there are any exams
    if (_exams.isEmpty) {
      return ValidationResult(
        isValid: false,
        message: AppLocalizations.of(context)!.atLeastOneExam,
      );
    }

    // Validate weights
    final totalWeight = _exams.fold(0.0, (sum, exam) => sum + exam.weight);
    if ((totalWeight - 1.0).abs() > 0.001) {
      return ValidationResult(
        isValid: false,
        message: '${AppLocalizations.of(context)!.weightsMustBe100} (${AppLocalizations.of(context)!.weightsCurrently}: %${(totalWeight * 100).toStringAsFixed(1)})',
      );
    }

    // Check for negative weights
    final hasNegativeWeight = _exams.any((exam) => exam.weight <= 0);
    if (hasNegativeWeight) {
      return ValidationResult(
        isValid: false,
        message: AppLocalizations.of(context)!.weightsMustBePositive,
      );
    }

    // Check for empty exam names
    final hasEmptyName = _exams.any((exam) => exam.name.trim().isEmpty);
    if (hasEmptyName) {
      return ValidationResult(
        isValid: false,
        message: AppLocalizations.of(context)!.examNameRequired,
      );
    }

    // Validate scores (only for entered scores)
    for (final exam in _exams) {
      if (exam.score != null) {
        if (exam.score! < 0 || exam.score! > exam.maxScore) {
          return ValidationResult(
            isValid: false,
            message: '${exam.name} ${AppLocalizations.of(context)!.scoreOutOfRange(exam.maxScore.toString())}',
          );
        }
      }
    }

    // Check if we have any exams with scores
    final takenExams = _exams.where((exam) => exam.score != null).toList();
    
    // Allow calculation if we have at least one exam with a score
    if (takenExams.isEmpty) {
      return ValidationResult(
        isValid: false,
        message: AppLocalizations.of(context)!.atLeastOneExamScored,
      );
    }


    // Validate passing grade
    final passingGrade = double.tryParse(_passingGradeController.text);
    
    if (passingGrade == null || passingGrade <= 0 || passingGrade > 100) {
      return ValidationResult(
        isValid: false,
        message: AppLocalizations.of(context)!.passingGradeRange,
      );
    }

    return ValidationResult(isValid: true, message: AppLocalizations.of(context)!.formValid);
  }

  void _updateExam(int index, ExamScore updatedExam) {
    setState(() {
      _exams[index] = updatedExam;
      _calculationResult = null;
    });
  }

  void _addExam() {
    setState(() {
      _exams.add(ExamScore(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: '${AppLocalizations.of(context)!.exam} ${_exams.length + 1}',
        weight: 0.1,
        maxScore: 100.0,
      ));
      _calculationResult = null;
    });
    HapticFeedback.lightImpact();
  }

  void _removeExam(int index) {
    if (_exams.length > 1) {
      setState(() {
        _exams.removeAt(index);
        _calculationResult = null;
      });
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _calculateResults() async {
    setState(() {
      _isCalculating = true;
    });
    
    // Simulate calculation delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      final passingGrade = double.tryParse(_passingGradeController.text) ?? 60.0;
      final calculation = CourseCalculation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        courseName: _courseNameController.text.isEmpty 
          ? AppLocalizations.of(context)!.course 
          : _courseNameController.text,
        courseCode: _courseCodeController.text,
        exams: _exams,
        passingGrade: passingGrade,
        targetGrade: passingGrade, // Target grade is same as passing grade
        mode: _calculationMode,
      );
      
      final result = _calculatorService.calculateRequiredScore(calculation);
      
      setState(() {
        _calculationResult = result;
      });
      
      _resultAnimationController.forward();
      HapticFeedback.mediumImpact();
      
    } catch (e) {
      _showErrorDialog('${AppLocalizations.of(context)!.calculationError}: $e');
    } finally {
      setState(() {
        _isCalculating = false;
      });
    }
  }

  void _showTemplateDialog() {
    final templates = _calculatorService.getExamTemplates();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectExamTemplate),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return ListTile(
                title: Text(template.name),
                subtitle: Text(template.description),
                onTap: () {
                  setState(() {
                    _exams = List.from(template.exams);
                    _calculationResult = null;
                  });
                  Navigator.pop(context);
                  _examListAnimationController.reset();
                  _examListAnimationController.forward();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.howToUse),
        content: SingleChildScrollView(
          child: Text(AppLocalizations.of(context)!.helpText.replaceAll('\\\\n', '\n')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  void _showCalculationHistory() {
    // TODO: Implement calculation history
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.historyFeatureComingSoon),
      ),
    );
  }

  void _showActionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: Text(AppLocalizations.of(context)!.clearForm),
              onTap: () {
                Navigator.pop(context);
                _resetForm();
              },
            ),
            ListTile(
              leading: const Icon(Icons.save),
              title: Text(AppLocalizations.of(context)!.saveCalculation),
              onTap: () {
                Navigator.pop(context);
                _saveCalculation();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(AppLocalizations.of(context)!.shareResult),
              onTap: () {
                Navigator.pop(context);
                _shareResult();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _courseNameController.clear();
      _courseCodeController.clear();
      _passingGradeController.text = '60';
      _calculationResult = null;
      _loadDefaultTemplate();
    });
    _resultAnimationController.reset();
  }

  void _saveCalculation() {
    // TODO: Implement save calculation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.calculationSaved),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareResult() {
    // TODO: Implement share result
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.shareFeatureComingSoon),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.calculationError),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }
}