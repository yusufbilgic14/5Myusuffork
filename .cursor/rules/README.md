# Cursor Rules Organization

This directory contains organized development rules and guidelines for Flutter/Dart development, categorized for better maintainability and reference.

## 📁 Rule Categories

### 🎯 [Core Principles](./core.cursorrules)
- Development persona and approach
- Core objectives and philosophy
- Safety and approval guidelines
- Continuous learning principles

### 🎨 [Flutter & Dart Guidelines](./flutter_dart.cursorrules)
- Language-specific best practices
- Dart fundamentals and conventions
- Flutter framework guidelines
- Code generation and tooling

### 🏗️ [Architecture Guidelines](./architecture.cursorrules)
- Clean Architecture principles
- Feature-first organization
- Repository pattern implementation
- Dependency injection strategies
- Directory structure standards

### 🔄 [State Management](./state_management.cursorrules)
- Riverpod best practices
- flutter_bloc implementation
- State design patterns
- UI integration guidelines

### 🎨 [UI & Design Guidelines](./ui_design.cursorrules)
- Widget design principles
- Responsive design patterns
- Theme implementation
- Performance considerations
- Accessibility guidelines

### ⚠️ [Error Handling](./error_handling.cursorrules)
- Functional error handling with Dartz
- Custom failure classes
- UI error display patterns
- Network error handling
- Validation strategies

### 🧪 [Testing Guidelines](./testing.cursorrules)
- Unit testing strategies
- Widget testing patterns
- Bloc testing approaches
- Integration testing
- Mocking guidelines
- Test organization

### ⚡ [Performance Guidelines](./performance.cursorrules)
- Widget performance optimization
- Memory management
- List and data performance
- Image optimization
- Profiling and monitoring

### 🔍 [Code Quality](./code_quality.cursorrules)
- SOLID principles
- Naming conventions
- Function and class design
- Refactoring guidelines
- Quality metrics

### 🔒 [Security Guidelines](./security.cursorrules)
- Security by design
- Data protection
- Authentication & authorization
- Input validation
- Mobile app security
- API security

### 📚 [Documentation Standards](./documentation.cursorrules)
- Code documentation patterns
- API documentation
- Architectural documentation
- Turkish comments guidelines
- README standards

## 🚀 How to Use These Rules

### 1. **Comprehensive Reference**
Each file can be referenced independently based on your current development focus:
- Working on UI? → Reference `ui_design.cursorrules`
- Implementing state management? → Check `state_management.cursorrules`
- Setting up architecture? → Follow `architecture.cursorrules`

### 2. **Code Review Checklist**
Use these categories during code reviews:
```bash
# Example code review process
1. Check against code_quality.cursorrules
2. Verify error_handling.cursorrules compliance
3. Review performance.cursorrules considerations
4. Ensure security.cursorrules adherence
5. Validate testing.cursorrules coverage
```

### 3. **Project Setup Reference**
When starting new features or projects:
1. Review `architecture.cursorrules` for structure
2. Set up according to `flutter_dart.cursorrules`
3. Implement based on `state_management.cursorrules`
4. Follow `ui_design.cursorrules` for UI components

### 4. **Learning Path**
Recommended reading order for new team members:
1. `core.cursorrules` - Understand the development philosophy
2. `flutter_dart.cursorrules` - Learn language conventions
3. `architecture.cursorrules` - Understand project structure
4. `state_management.cursorrules` - Master state handling
5. Remaining files based on immediate needs

## 🔄 Maintenance

### Adding New Rules
1. Identify the appropriate category
2. Add to the relevant `.cursorrules` file
3. Update this README if new categories are needed
4. Ensure consistency with existing guidelines

### Updating Rules
1. Make changes in the specific category file
2. Check for cross-references in other files
3. Update examples if needed
4. Validate with team members

### Rule Conflicts
If rules conflict between files:
1. `core.cursorrules` takes precedence for general principles
2. More specific files (e.g., `ui_design.cursorrules`) override general ones
3. Security and performance guidelines are non-negotiable
4. Document any exceptions clearly

## 📋 Quick Reference Checklist

### Before Starting Development
- [ ] Reviewed relevant category guidelines
- [ ] Understood architecture requirements
- [ ] Set up proper tooling and linting
- [ ] Planned testing strategy

### During Development
- [ ] Following code quality standards
- [ ] Implementing proper error handling
- [ ] Adding Turkish comments for code explanation
- [ ] Considering performance implications
- [ ] Following security best practices

### Before Code Review
- [ ] Self-reviewed against relevant rule categories
- [ ] Added/updated tests
- [ ] Updated documentation
- [ ] Verified performance considerations
- [ ] Checked security implications

## 🤝 Contributing

When contributing to these rules:
1. Follow the existing format and structure
2. Provide practical examples where helpful
3. Consider the impact on existing projects
4. Discuss major changes with the team
5. Update this README for structural changes

---

> **Note**: These rules are living documents that should evolve with the project and team experience. Regular review and updates ensure they remain relevant and helpful. 