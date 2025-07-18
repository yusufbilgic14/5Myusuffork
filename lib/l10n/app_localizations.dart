import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Medipol University'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Login with your student information'**
  String get loginSubtitle;

  /// No description provided for @studentId.
  ///
  /// In en, this message translates to:
  /// **'Student ID'**
  String get studentId;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @loginWithMicrosoft.
  ///
  /// In en, this message translates to:
  /// **'Login with Microsoft'**
  String get loginWithMicrosoft;

  /// No description provided for @invalidStudentId.
  ///
  /// In en, this message translates to:
  /// **'Please enter your student ID'**
  String get invalidStudentId;

  /// No description provided for @invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get invalidPassword;

  /// No description provided for @languageTurkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get languageTurkish;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome,'**
  String get homeWelcome;

  /// No description provided for @announcements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcements;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @todaysCourses.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Courses'**
  String get todaysCourses;

  /// No description provided for @todayDate.
  ///
  /// In en, this message translates to:
  /// **'Friday, May 24'**
  String get todayDate;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark All as Read'**
  String get markAllRead;

  /// No description provided for @navigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get navigation;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @mondayShort.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mondayShort;

  /// No description provided for @tuesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesdayShort;

  /// No description provided for @wednesdayShort.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesdayShort;

  /// No description provided for @thursdayShort.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursdayShort;

  /// No description provided for @fridayShort.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fridayShort;

  /// No description provided for @saturdayShort.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturdayShort;

  /// No description provided for @sundayShort.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sundayShort;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'Elif Yılmaz'**
  String get userName;

  /// No description provided for @userDepartment.
  ///
  /// In en, this message translates to:
  /// **'MIS'**
  String get userDepartment;

  /// No description provided for @userGrade.
  ///
  /// In en, this message translates to:
  /// **'3rd Grade'**
  String get userGrade;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your account?'**
  String get logoutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @messageBox.
  ///
  /// In en, this message translates to:
  /// **'Message Box'**
  String get messageBox;

  /// No description provided for @feedbacks.
  ///
  /// In en, this message translates to:
  /// **'Feedbacks'**
  String get feedbacks;

  /// No description provided for @cafeteriaMenu.
  ///
  /// In en, this message translates to:
  /// **'Cafeteria Menu'**
  String get cafeteriaMenu;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @academicCalendar.
  ///
  /// In en, this message translates to:
  /// **'Academic Calendar'**
  String get academicCalendar;

  /// No description provided for @courseGrades.
  ///
  /// In en, this message translates to:
  /// **'Course Grades'**
  String get courseGrades;

  /// No description provided for @upcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Events'**
  String get upcomingEvents;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @clubs.
  ///
  /// In en, this message translates to:
  /// **'Clubs'**
  String get clubs;

  /// No description provided for @myEvents.
  ///
  /// In en, this message translates to:
  /// **'My Events'**
  String get myEvents;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @inbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get inbox;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @quickStats.
  ///
  /// In en, this message translates to:
  /// **'Quick Stats'**
  String get quickStats;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @qrAccess.
  ///
  /// In en, this message translates to:
  /// **'QR Access'**
  String get qrAccess;

  /// No description provided for @campusTransport.
  ///
  /// In en, this message translates to:
  /// **'Campus Transport'**
  String get campusTransport;

  /// No description provided for @statsEvents.
  ///
  /// In en, this message translates to:
  /// **'Attended Events'**
  String get statsEvents;

  /// No description provided for @statsGpa.
  ///
  /// In en, this message translates to:
  /// **'GPA'**
  String get statsGpa;

  /// No description provided for @statsComplaints.
  ///
  /// In en, this message translates to:
  /// **'Number of Complaints'**
  String get statsComplaints;

  /// No description provided for @statsAssignments.
  ///
  /// In en, this message translates to:
  /// **'Completed Assignments'**
  String get statsAssignments;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @eventNotifications.
  ///
  /// In en, this message translates to:
  /// **'Event Notifications'**
  String get eventNotifications;

  /// No description provided for @gradeNotifications.
  ///
  /// In en, this message translates to:
  /// **'Exam Notifications'**
  String get gradeNotifications;

  /// No description provided for @messageNotifications.
  ///
  /// In en, this message translates to:
  /// **'Message Notifications'**
  String get messageNotifications;

  /// No description provided for @clubNotifications.
  ///
  /// In en, this message translates to:
  /// **'Club and Community Announcements'**
  String get clubNotifications;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @notificationSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Notification settings saved.'**
  String get notificationSettingsSaved;

  /// No description provided for @notificationSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Select which notifications you want to receive'**
  String get notificationSettingsDesc;

  /// No description provided for @helpSupportDesc.
  ///
  /// In en, this message translates to:
  /// **'FAQ and contact information'**
  String get helpSupportDesc;

  /// No description provided for @campusTransportDesc.
  ///
  /// In en, this message translates to:
  /// **'The following lines and routes are for transportation to Istanbul Medipol University Kavacık South and North Campuses.'**
  String get campusTransportDesc;

  /// No description provided for @europeanSide.
  ///
  /// In en, this message translates to:
  /// **'European Side'**
  String get europeanSide;

  /// No description provided for @anatolianSide.
  ///
  /// In en, this message translates to:
  /// **'Anatolian Side'**
  String get anatolianSide;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @allergens.
  ///
  /// In en, this message translates to:
  /// **'Allergens: {allergens}'**
  String allergens(Object allergens);

  /// No description provided for @menuNotFound.
  ///
  /// In en, this message translates to:
  /// **'Menu Not Found'**
  String get menuNotFound;

  /// No description provided for @menuNotFoundFilter.
  ///
  /// In en, this message translates to:
  /// **'No {mealName} menu found for the selected filters.'**
  String menuNotFoundFilter(Object mealName);

  /// No description provided for @noEventsFound.
  ///
  /// In en, this message translates to:
  /// **'No Events Found'**
  String get noEventsFound;

  /// No description provided for @noEventsFilter.
  ///
  /// In en, this message translates to:
  /// **'No academic calendar events found for the selected filters.'**
  String get noEventsFilter;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endDate;

  /// No description provided for @logoutDesc.
  ///
  /// In en, this message translates to:
  /// **'Log out of your account securely'**
  String get logoutDesc;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeDesc.
  ///
  /// In en, this message translates to:
  /// **'Change the app theme (light/dark)'**
  String get themeDesc;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @contactDesc.
  ///
  /// In en, this message translates to:
  /// **'For any questions, feedback or support requests, you can use the contact channels below.'**
  String get contactDesc;

  /// No description provided for @kavacikNorth.
  ///
  /// In en, this message translates to:
  /// **'Kavacık North Campus'**
  String get kavacikNorth;

  /// No description provided for @kavacikNorthDesc.
  ///
  /// In en, this message translates to:
  /// **'Campus; Medipol University Kavacık (Main Campus Rectorate)'**
  String get kavacikNorthDesc;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Feedback is Valuable to Us'**
  String get feedbackTitle;

  /// No description provided for @feedbackDesc.
  ///
  /// In en, this message translates to:
  /// **'Share your feedback and suggestions to help us improve the Medipol app.'**
  String get feedbackDesc;

  /// No description provided for @feedbackDetail.
  ///
  /// In en, this message translates to:
  /// **'Detailed Description'**
  String get feedbackDetail;

  /// No description provided for @feedbackDetailHint.
  ///
  /// In en, this message translates to:
  /// **'Please explain your feedback in detail...'**
  String get feedbackDetailHint;

  /// No description provided for @feedbackRequired.
  ///
  /// In en, this message translates to:
  /// **'Description required'**
  String get feedbackRequired;

  /// No description provided for @feedbackMinLength.
  ///
  /// In en, this message translates to:
  /// **'Description must be at least 20 characters'**
  String get feedbackMinLength;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @clearForm.
  ///
  /// In en, this message translates to:
  /// **'Clear Form'**
  String get clearForm;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Click here to rate and review the app'**
  String get rateApp;

  /// No description provided for @what_do_you_want_to_do.
  ///
  /// In en, this message translates to:
  /// **'What do you want to do?'**
  String get what_do_you_want_to_do;

  /// No description provided for @request.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get request;

  /// No description provided for @select_request_category.
  ///
  /// In en, this message translates to:
  /// **'Select Request Category'**
  String get select_request_category;

  /// No description provided for @select_feedback_category.
  ///
  /// In en, this message translates to:
  /// **'Select Feedback Category'**
  String get select_feedback_category;

  /// No description provided for @rate_and_comment_app.
  ///
  /// In en, this message translates to:
  /// **'Click here to rate and comment the app'**
  String get rate_and_comment_app;

  /// No description provided for @redirect_to_app_store.
  ///
  /// In en, this message translates to:
  /// **'You will be redirected to the app store...'**
  String get redirect_to_app_store;

  /// No description provided for @anonymous_feedback.
  ///
  /// In en, this message translates to:
  /// **'Anonymous Feedback'**
  String get anonymous_feedback;

  /// No description provided for @keep_my_identity_private.
  ///
  /// In en, this message translates to:
  /// **'I want to keep my identity private and send feedback anonymously.'**
  String get keep_my_identity_private;

  /// No description provided for @relevant_department.
  ///
  /// In en, this message translates to:
  /// **'Relevant Department'**
  String get relevant_department;

  /// No description provided for @select_department.
  ///
  /// In en, this message translates to:
  /// **'Select department'**
  String get select_department;

  /// No description provided for @please_select_department.
  ///
  /// In en, this message translates to:
  /// **'Please select a department'**
  String get please_select_department;

  /// No description provided for @priority_level.
  ///
  /// In en, this message translates to:
  /// **'Priority Level'**
  String get priority_level;

  /// No description provided for @email_address.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email_address;

  /// No description provided for @example_email.
  ///
  /// In en, this message translates to:
  /// **'example@medipol.edu.tr'**
  String get example_email;

  /// No description provided for @email_address_required.
  ///
  /// In en, this message translates to:
  /// **'Email address required'**
  String get email_address_required;

  /// No description provided for @valid_email_address.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get valid_email_address;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @feedback_subject.
  ///
  /// In en, this message translates to:
  /// **'Feedback subject'**
  String get feedback_subject;

  /// No description provided for @subject_required.
  ///
  /// In en, this message translates to:
  /// **'Subject required'**
  String get subject_required;

  /// No description provided for @subject_min_length.
  ///
  /// In en, this message translates to:
  /// **'Subject must be at least 5 characters'**
  String get subject_min_length;

  /// No description provided for @detailed_description.
  ///
  /// In en, this message translates to:
  /// **'Detailed Description'**
  String get detailed_description;

  /// No description provided for @describe_your_feedback.
  ///
  /// In en, this message translates to:
  /// **'Describe your feedback in detail...'**
  String get describe_your_feedback;

  /// No description provided for @description_required.
  ///
  /// In en, this message translates to:
  /// **'Description required'**
  String get description_required;

  /// No description provided for @description_min_length.
  ///
  /// In en, this message translates to:
  /// **'Description must be at least 20 characters'**
  String get description_min_length;

  /// No description provided for @add_photo_or_document.
  ///
  /// In en, this message translates to:
  /// **'Add Photo or Document'**
  String get add_photo_or_document;

  /// No description provided for @click_to_select_file.
  ///
  /// In en, this message translates to:
  /// **'Click to select file'**
  String get click_to_select_file;

  /// No description provided for @file_types_max_size.
  ///
  /// In en, this message translates to:
  /// **'JPG, PNG, PDF (Maximum 10MB)'**
  String get file_types_max_size;

  /// No description provided for @selected_files.
  ///
  /// In en, this message translates to:
  /// **'Selected Files:'**
  String get selected_files;

  /// No description provided for @file_added.
  ///
  /// In en, this message translates to:
  /// **'File added:'**
  String get file_added;

  /// No description provided for @file_removed.
  ///
  /// In en, this message translates to:
  /// **'File removed:'**
  String get file_removed;

  /// No description provided for @please_select_feedback_or_request_type.
  ///
  /// In en, this message translates to:
  /// **'Please select feedback or request type'**
  String get please_select_feedback_or_request_type;

  /// No description provided for @please_select_request_category.
  ///
  /// In en, this message translates to:
  /// **'Please select a request category'**
  String get please_select_request_category;

  /// No description provided for @please_select_feedback_category.
  ///
  /// In en, this message translates to:
  /// **'Please select a feedback category'**
  String get please_select_feedback_category;

  /// No description provided for @your_feedback_submitted_successfully.
  ///
  /// In en, this message translates to:
  /// **'Your feedback has been submitted successfully! Thank you.'**
  String get your_feedback_submitted_successfully;

  /// No description provided for @clear_form.
  ///
  /// In en, this message translates to:
  /// **'Clear Form'**
  String get clear_form;

  /// No description provided for @your_feedback_is_valuable.
  ///
  /// In en, this message translates to:
  /// **'Your Feedback is Valuable to Us'**
  String get your_feedback_is_valuable;

  /// No description provided for @share_your_opinions_and_suggestions_for_better_app.
  ///
  /// In en, this message translates to:
  /// **'Share your opinions and suggestions to make the Medipol app better.'**
  String get share_your_opinions_and_suggestions_for_better_app;

  /// No description provided for @submitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// No description provided for @send_feedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get send_feedback;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'messages'**
  String get messages;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'unread'**
  String get unread;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @forward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get forward;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @pointPDF.
  ///
  /// In en, this message translates to:
  /// **'Point PDF'**
  String get pointPDF;

  /// No description provided for @transcript.
  ///
  /// In en, this message translates to:
  /// **'Transcript'**
  String get transcript;

  /// No description provided for @semesterGPA.
  ///
  /// In en, this message translates to:
  /// **'Semester GPA'**
  String get semesterGPA;

  /// No description provided for @cumulativeGPA.
  ///
  /// In en, this message translates to:
  /// **'Cumulative GPA'**
  String get cumulativeGPA;

  /// No description provided for @totalCourses.
  ///
  /// In en, this message translates to:
  /// **'Total Courses'**
  String get totalCourses;

  /// No description provided for @completedCourses.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedCourses;

  /// No description provided for @waitingGrades.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get waitingGrades;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// No description provided for @searchCourseNameOrCode.
  ///
  /// In en, this message translates to:
  /// **'Search course name or code...'**
  String get searchCourseNameOrCode;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @noCoursesFound.
  ///
  /// In en, this message translates to:
  /// **'No courses found matching your search criteria.'**
  String get noCoursesFound;

  /// No description provided for @gpa.
  ///
  /// In en, this message translates to:
  /// **'GPA'**
  String get gpa;

  /// No description provided for @detailedGrades.
  ///
  /// In en, this message translates to:
  /// **'Detailed Grades'**
  String get detailedGrades;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting...'**
  String get waiting;

  /// No description provided for @semester.
  ///
  /// In en, this message translates to:
  /// **'Semester'**
  String get semester;

  /// No description provided for @semesterGpa.
  ///
  /// In en, this message translates to:
  /// **'Semester GPA'**
  String get semesterGpa;

  /// No description provided for @cumulativeGpa.
  ///
  /// In en, this message translates to:
  /// **'Cumulative GPA'**
  String get cumulativeGpa;

  /// No description provided for @pdfReportWillBeGenerated.
  ///
  /// In en, this message translates to:
  /// **'A PDF report will be generated for this semester...'**
  String get pdfReportWillBeGenerated;

  /// No description provided for @pdfFeatureWillBeAddedSoon.
  ///
  /// In en, this message translates to:
  /// **'PDF feature will be added soon.'**
  String get pdfFeatureWillBeAddedSoon;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @overallTranscriptForAllSemestersWillBePrepared.
  ///
  /// In en, this message translates to:
  /// **'An overall transcript for all semesters will be prepared...'**
  String get overallTranscriptForAllSemestersWillBePrepared;

  /// No description provided for @totalGpa.
  ///
  /// In en, this message translates to:
  /// **'Total GPA'**
  String get totalGpa;

  /// No description provided for @totalCredits.
  ///
  /// In en, this message translates to:
  /// **'Total Credits'**
  String get totalCredits;

  /// No description provided for @content.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get content;

  /// No description provided for @courses.
  ///
  /// In en, this message translates to:
  /// **'courses'**
  String get courses;

  /// No description provided for @transcriptFeatureWillBeAddedSoon.
  ///
  /// In en, this message translates to:
  /// **'Transcript feature will be added soon.'**
  String get transcriptFeatureWillBeAddedSoon;

  /// No description provided for @refreshingGrades.
  ///
  /// In en, this message translates to:
  /// **'Refreshing grades...'**
  String get refreshingGrades;

  /// No description provided for @gradesUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Grades updated successfully!'**
  String get gradesUpdatedSuccessfully;

  /// No description provided for @qrScanner.
  ///
  /// In en, this message translates to:
  /// **'QR Code Scanner'**
  String get qrScanner;

  /// No description provided for @cameraPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission permanently denied. Please enable it in settings.'**
  String get cameraPermissionPermanentlyDenied;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera Permission Required'**
  String get cameraPermissionRequired;

  /// No description provided for @enableCameraPermissionInSettings.
  ///
  /// In en, this message translates to:
  /// **'Enable camera permission in settings.'**
  String get enableCameraPermissionInSettings;

  /// No description provided for @needCameraPermissionToScan.
  ///
  /// In en, this message translates to:
  /// **'We need camera permission to scan QR codes.'**
  String get needCameraPermissionToScan;

  /// No description provided for @startingCamera.
  ///
  /// In en, this message translates to:
  /// **'Starting camera...'**
  String get startingCamera;

  /// No description provided for @filterBuildingTypes.
  ///
  /// In en, this message translates to:
  /// **'Filter Building Types'**
  String get filterBuildingTypes;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @academicBuildings.
  ///
  /// In en, this message translates to:
  /// **'Academic Buildings'**
  String get academicBuildings;

  /// No description provided for @administrativeBuildings.
  ///
  /// In en, this message translates to:
  /// **'Administrative Buildings'**
  String get administrativeBuildings;

  /// No description provided for @socialAreas.
  ///
  /// In en, this message translates to:
  /// **'Social Areas'**
  String get socialAreas;

  /// No description provided for @sportsFacilities.
  ///
  /// In en, this message translates to:
  /// **'Sports Facilities'**
  String get sportsFacilities;

  /// No description provided for @shuttleStops.
  ///
  /// In en, this message translates to:
  /// **'Shuttle Stops'**
  String get shuttleStops;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @mapNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Map Not Loaded'**
  String get mapNotLoaded;

  /// No description provided for @googleMapsNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Google Maps could not be loaded.'**
  String get googleMapsNotLoaded;

  /// No description provided for @checkApiKeyOrInternet.
  ///
  /// In en, this message translates to:
  /// **'Check API key configuration or verify your internet connection.'**
  String get checkApiKeyOrInternet;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @courseVisualProgramming.
  ///
  /// In en, this message translates to:
  /// **'Visual Programming'**
  String get courseVisualProgramming;

  /// No description provided for @courseDataStructures.
  ///
  /// In en, this message translates to:
  /// **'Data Structures'**
  String get courseDataStructures;

  /// No description provided for @courseDiscreteMathematics.
  ///
  /// In en, this message translates to:
  /// **'Discrete Mathematics'**
  String get courseDiscreteMathematics;

  /// No description provided for @courseTechnicalEnglish.
  ///
  /// In en, this message translates to:
  /// **'Technical English'**
  String get courseTechnicalEnglish;

  /// No description provided for @instructorAhmetYilmaz.
  ///
  /// In en, this message translates to:
  /// **'Dr. Ahmet Yılmaz'**
  String get instructorAhmetYilmaz;

  /// No description provided for @instructorFatmaKaya.
  ///
  /// In en, this message translates to:
  /// **'Prof. Fatma Kaya'**
  String get instructorFatmaKaya;

  /// No description provided for @instructorMehmetOzkan.
  ///
  /// In en, this message translates to:
  /// **'Dr. Mehmet Özkan'**
  String get instructorMehmetOzkan;

  /// No description provided for @instructorSarahJohnson.
  ///
  /// In en, this message translates to:
  /// **'Ms. Sarah Johnson'**
  String get instructorSarahJohnson;

  /// No description provided for @noCoursesToday.
  ///
  /// In en, this message translates to:
  /// **'No courses found for today.'**
  String get noCoursesToday;

  /// No description provided for @timelineView.
  ///
  /// In en, this message translates to:
  /// **'Timeline View'**
  String get timelineView;

  /// No description provided for @monthView.
  ///
  /// In en, this message translates to:
  /// **'Month View'**
  String get monthView;

  /// No description provided for @campusQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Campus Entry QR Code'**
  String get campusQrTitle;

  /// No description provided for @validTime.
  ///
  /// In en, this message translates to:
  /// **'Valid time'**
  String get validTime;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @scanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQr;

  /// No description provided for @qrInfo.
  ///
  /// In en, this message translates to:
  /// **'Use this QR code at campus entry scanners. For security, the code is automatically refreshed.'**
  String get qrInfo;

  /// No description provided for @secureCampusAccess.
  ///
  /// In en, this message translates to:
  /// **'Secure campus access'**
  String get secureCampusAccess;

  /// No description provided for @urlCouldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Could not open URL'**
  String get urlCouldNotOpen;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// No description provided for @studentIdHint.
  ///
  /// In en, this message translates to:
  /// **'2024520001'**
  String get studentIdHint;

  /// No description provided for @inboxSubject1.
  ///
  /// In en, this message translates to:
  /// **'About Your Student Certificate Request'**
  String get inboxSubject1;

  /// No description provided for @inboxSender1.
  ///
  /// In en, this message translates to:
  /// **'Student Affairs'**
  String get inboxSender1;

  /// No description provided for @inboxContent1.
  ///
  /// In en, this message translates to:
  /// **'Dear Elif Yılmaz,\n\nYour student certificate requested on 24.06.2025 has been prepared.\n\nYou can obtain your document in the following ways:\n• You can personally collect it from our Student Affairs office\n• You can apply for delivery to your address by cargo for an additional fee\n\nOffice hours: Monday-Friday 09:00-17:00\n\nBest regards,\nStudent Affairs Directorate'**
  String get inboxContent1;

  /// No description provided for @inboxSubject2.
  ///
  /// In en, this message translates to:
  /// **'Scholarship Application Result'**
  String get inboxSubject2;

  /// No description provided for @inboxSender2.
  ///
  /// In en, this message translates to:
  /// **'Scholarship and Aid Office'**
  String get inboxSender2;

  /// No description provided for @inboxContent2.
  ///
  /// In en, this message translates to:
  /// **'Dear Elif Yılmaz,\n\nYour 2024-2025 Academic Year Achievement Scholarship application has been evaluated and we inform you that your application has been ACCEPTED.\n\nScholarship Details:\n• Scholarship Type: Achievement Scholarship (25%)\n• Valid Term: 2025-2026 Fall Term\n• Payment Date: After registration renewal\n\nBest regards,\nScholarship and Aid Office'**
  String get inboxContent2;

  /// No description provided for @requestCategoryAcademicSupport.
  ///
  /// In en, this message translates to:
  /// **'Academic Support'**
  String get requestCategoryAcademicSupport;

  /// No description provided for @requestCategoryTechnicalHelp.
  ///
  /// In en, this message translates to:
  /// **'Technical Help'**
  String get requestCategoryTechnicalHelp;

  /// No description provided for @requestCategoryLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library Services'**
  String get requestCategoryLibrary;

  /// No description provided for @requestCategoryCafeteria.
  ///
  /// In en, this message translates to:
  /// **'Cafeteria Services'**
  String get requestCategoryCafeteria;

  /// No description provided for @requestCategoryTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport Request'**
  String get requestCategoryTransport;

  /// No description provided for @requestCategorySecurity.
  ///
  /// In en, this message translates to:
  /// **'Security Support'**
  String get requestCategorySecurity;

  /// No description provided for @requestCategoryFinance.
  ///
  /// In en, this message translates to:
  /// **'Financial Affairs'**
  String get requestCategoryFinance;

  /// No description provided for @requestCategoryGeneral.
  ///
  /// In en, this message translates to:
  /// **'General Request'**
  String get requestCategoryGeneral;

  /// No description provided for @feedbackCategoryBugReport.
  ///
  /// In en, this message translates to:
  /// **'Bug Report'**
  String get feedbackCategoryBugReport;

  /// No description provided for @feedbackCategorySuggestion.
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get feedbackCategorySuggestion;

  /// No description provided for @feedbackCategoryComplaint.
  ///
  /// In en, this message translates to:
  /// **'Complaint'**
  String get feedbackCategoryComplaint;

  /// No description provided for @feedbackCategoryAppreciation.
  ///
  /// In en, this message translates to:
  /// **'Appreciation'**
  String get feedbackCategoryAppreciation;

  /// No description provided for @feedbackCategoryFeatureRequest.
  ///
  /// In en, this message translates to:
  /// **'Feature Request'**
  String get feedbackCategoryFeatureRequest;

  /// No description provided for @feedbackCategoryAppReview.
  ///
  /// In en, this message translates to:
  /// **'App Review'**
  String get feedbackCategoryAppReview;

  /// No description provided for @feedbackCategoryGeneral.
  ///
  /// In en, this message translates to:
  /// **'General Feedback'**
  String get feedbackCategoryGeneral;

  /// No description provided for @searchBuildingOrLocation.
  ///
  /// In en, this message translates to:
  /// **'Search building or location...'**
  String get searchBuildingOrLocation;

  /// No description provided for @routeInfo.
  ///
  /// In en, this message translates to:
  /// **'Route Info'**
  String get routeInfo;

  /// No description provided for @yourCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Your Current Location'**
  String get yourCurrentLocation;

  /// No description provided for @engineeringFaculty.
  ///
  /// In en, this message translates to:
  /// **'Engineering Faculty'**
  String get engineeringFaculty;

  /// No description provided for @walking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get walking;

  /// No description provided for @shuttle.
  ///
  /// In en, this message translates to:
  /// **'Shuttle'**
  String get shuttle;

  /// No description provided for @bike.
  ///
  /// In en, this message translates to:
  /// **'Bike'**
  String get bike;

  /// No description provided for @startNavigation.
  ///
  /// In en, this message translates to:
  /// **'Start Navigation'**
  String get startNavigation;

  /// No description provided for @mainBuilding.
  ///
  /// In en, this message translates to:
  /// **'Main Building'**
  String get mainBuilding;

  /// No description provided for @northCampus.
  ///
  /// In en, this message translates to:
  /// **'North Campus'**
  String get northCampus;

  /// No description provided for @kavacikBridgeBusStop.
  ///
  /// In en, this message translates to:
  /// **'Kavacık Bridge Bus Stop'**
  String get kavacikBridgeBusStop;

  /// No description provided for @asiaRoad.
  ///
  /// In en, this message translates to:
  /// **'Asia Road'**
  String get asiaRoad;

  /// No description provided for @europeRoad.
  ///
  /// In en, this message translates to:
  /// **'Europe Road'**
  String get europeRoad;

  /// No description provided for @kavacikBusStop.
  ///
  /// In en, this message translates to:
  /// **'Kavacık Bus Stop'**
  String get kavacikBusStop;

  /// No description provided for @ataturkStreetBeykoz.
  ///
  /// In en, this message translates to:
  /// **'Ataturk Street/Beykoz'**
  String get ataturkStreetBeykoz;

  /// No description provided for @kavacikJunctionBusStop.
  ///
  /// In en, this message translates to:
  /// **'Kavacık Junction Bus Stop'**
  String get kavacikJunctionBusStop;

  /// No description provided for @kavacikJunctionBeykoz.
  ///
  /// In en, this message translates to:
  /// **'Kavacik Junction/Beykoz'**
  String get kavacikJunctionBeykoz;

  /// No description provided for @yeniRivaYoluBusStop.
  ///
  /// In en, this message translates to:
  /// **'Yeni Riva Yolu Bus Stop'**
  String get yeniRivaYoluBusStop;

  /// No description provided for @mapLoading.
  ///
  /// In en, this message translates to:
  /// **'Map is loading...'**
  String get mapLoading;

  /// No description provided for @monShort.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monShort;

  /// No description provided for @tueShort.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tueShort;

  /// No description provided for @wedShort.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wedShort;

  /// No description provided for @thuShort.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thuShort;

  /// No description provided for @friShort.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friShort;

  /// No description provided for @satShort.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get satShort;

  /// No description provided for @sunShort.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunShort;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
