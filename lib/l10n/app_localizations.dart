import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';

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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en')
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'UGO Driver'**
  String get appName;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @amharic.
  ///
  /// In en, this message translates to:
  /// **'አማርኛ'**
  String get amharic;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get retry;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMsg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmMsg;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @aboutUGODriver.
  ///
  /// In en, this message translates to:
  /// **'About UGO Driver'**
  String get aboutUGODriver;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @driver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// No description provided for @school.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get school;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduled;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @declined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get declined;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @ride.
  ///
  /// In en, this message translates to:
  /// **'ride'**
  String get ride;

  /// No description provided for @rides.
  ///
  /// In en, this message translates to:
  /// **'rides'**
  String get rides;

  /// No description provided for @students.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get students;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @route.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get route;

  /// No description provided for @package.
  ///
  /// In en, this message translates to:
  /// **'Package'**
  String get package;

  /// No description provided for @parent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get parent;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @grade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get grade;

  /// No description provided for @gradeLabel.
  ///
  /// In en, this message translates to:
  /// **'Grade {grade}'**
  String gradeLabel(String grade);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{m}m ago'**
  String minutesAgo(int m);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{h}h ago'**
  String hoursAgo(int h);

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{d}d ago'**
  String daysAgo(int d);

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signInToDriverAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your driver account'**
  String get signInToDriverAccount;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone is required'**
  String get phoneRequired;

  /// No description provided for @enter9Digits.
  ///
  /// In en, this message translates to:
  /// **'Enter exactly 9 digits'**
  String get enter9Digits;

  /// No description provided for @numberMustStart79.
  ///
  /// In en, this message translates to:
  /// **'Number must start with 7 or 9'**
  String get numberMustStart79;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfo;

  /// No description provided for @vehicleInfo.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Info'**
  String get vehicleInfo;

  /// No description provided for @joinUGONetwork.
  ///
  /// In en, this message translates to:
  /// **'Join the UGO driver network'**
  String get joinUGONetwork;

  /// No description provided for @identityLicenseDetails.
  ///
  /// In en, this message translates to:
  /// **'Identity & license details'**
  String get identityLicenseDetails;

  /// No description provided for @yourVehicleDetails.
  ///
  /// In en, this message translates to:
  /// **'Your vehicle details'**
  String get yourVehicleDetails;

  /// No description provided for @stepOf3.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of 3'**
  String stepOf3(int step);

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get enterFullName;

  /// No description provided for @enterYourFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterYourFullName;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneNumber;

  /// No description provided for @minCharsHint.
  ///
  /// In en, this message translates to:
  /// **'Min 8 characters'**
  String get minCharsHint;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordHint;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @atLeast8Chars.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get atLeast8Chars;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @selectDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Select date of birth'**
  String get selectDateOfBirth;

  /// No description provided for @educationLevel.
  ///
  /// In en, this message translates to:
  /// **'Education Level'**
  String get educationLevel;

  /// No description provided for @selectEducationLevel.
  ///
  /// In en, this message translates to:
  /// **'Select education level'**
  String get selectEducationLevel;

  /// No description provided for @nationalIdNumber.
  ///
  /// In en, this message translates to:
  /// **'National ID Number'**
  String get nationalIdNumber;

  /// No description provided for @enterNationalId.
  ///
  /// In en, this message translates to:
  /// **'Enter national ID number'**
  String get enterNationalId;

  /// No description provided for @enterNationalIdRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your national ID number'**
  String get enterNationalIdRequired;

  /// No description provided for @nationalIdPhoto.
  ///
  /// In en, this message translates to:
  /// **'National ID Photo'**
  String get nationalIdPhoto;

  /// No description provided for @tapToUploadIdPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload ID photo'**
  String get tapToUploadIdPhoto;

  /// No description provided for @requiredForVerification.
  ///
  /// In en, this message translates to:
  /// **'Required for verification'**
  String get requiredForVerification;

  /// No description provided for @driverLicenseNumber.
  ///
  /// In en, this message translates to:
  /// **'Driver License Number'**
  String get driverLicenseNumber;

  /// No description provided for @enterLicenseNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter license number'**
  String get enterLicenseNumber;

  /// No description provided for @enterLicenseRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your license number'**
  String get enterLicenseRequired;

  /// No description provided for @licenseExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'License Expiry Date'**
  String get licenseExpiryDate;

  /// No description provided for @selectExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Select expiry date'**
  String get selectExpiryDate;

  /// No description provided for @pleaseUploadNationalId.
  ///
  /// In en, this message translates to:
  /// **'Please upload your National ID photo'**
  String get pleaseUploadNationalId;

  /// No description provided for @pleaseSelectLicenseExpiry.
  ///
  /// In en, this message translates to:
  /// **'Please select your license expiry date'**
  String get pleaseSelectLicenseExpiry;

  /// No description provided for @vehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicleType;

  /// No description provided for @selectVehicleType.
  ///
  /// In en, this message translates to:
  /// **'Select vehicle type'**
  String get selectVehicleType;

  /// No description provided for @vehicleTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Select your vehicle type'**
  String get vehicleTypeRequired;

  /// No description provided for @plateNumber.
  ///
  /// In en, this message translates to:
  /// **'Plate Number'**
  String get plateNumber;

  /// No description provided for @enterPlateNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your plate number'**
  String get enterPlateNumber;

  /// No description provided for @vehicleColor.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Color'**
  String get vehicleColor;

  /// No description provided for @enterVehicleColor.
  ///
  /// In en, this message translates to:
  /// **'Enter vehicle color'**
  String get enterVehicleColor;

  /// No description provided for @vehicleModelYear.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Model / Year'**
  String get vehicleModelYear;

  /// No description provided for @accountReviewNotice.
  ///
  /// In en, this message translates to:
  /// **'Your account will be reviewed by the admin team before activation.'**
  String get accountReviewNotice;

  /// No description provided for @submitRegistration.
  ///
  /// In en, this message translates to:
  /// **'Submit Registration'**
  String get submitRegistration;

  /// No description provided for @takeAPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takeAPhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @stepAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get stepAccount;

  /// No description provided for @stepPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get stepPersonal;

  /// No description provided for @stepVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get stepVehicle;

  /// No description provided for @educNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get educNone;

  /// No description provided for @educPrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary School'**
  String get educPrimary;

  /// No description provided for @educSecondary.
  ///
  /// In en, this message translates to:
  /// **'Secondary School'**
  String get educSecondary;

  /// No description provided for @educDiploma.
  ///
  /// In en, this message translates to:
  /// **'Diploma'**
  String get educDiploma;

  /// No description provided for @educDegree.
  ///
  /// In en, this message translates to:
  /// **'Bachelor\'s Degree'**
  String get educDegree;

  /// No description provided for @educMasters.
  ///
  /// In en, this message translates to:
  /// **'Master\'s Degree'**
  String get educMasters;

  /// No description provided for @educPhd.
  ///
  /// In en, this message translates to:
  /// **'PhD'**
  String get educPhd;

  /// No description provided for @vehBajaj.
  ///
  /// In en, this message translates to:
  /// **'Bajaj (3-Wheeler)'**
  String get vehBajaj;

  /// No description provided for @vehElectric.
  ///
  /// In en, this message translates to:
  /// **'Electric Bajaj'**
  String get vehElectric;

  /// No description provided for @vehForce.
  ///
  /// In en, this message translates to:
  /// **'Force / Mini-bus'**
  String get vehForce;

  /// No description provided for @otpVerification.
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get otpVerification;

  /// No description provided for @codeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Code sent to'**
  String get codeSentTo;

  /// No description provided for @enter6DigitCode.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit code'**
  String get enter6DigitCode;

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get verifyCode;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get didntReceiveCode;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @retryInSeconds.
  ///
  /// In en, this message translates to:
  /// **'Retry in {seconds}s'**
  String retryInSeconds(int seconds);

  /// No description provided for @changePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Change phone number'**
  String get changePhoneNumber;

  /// No description provided for @phoneVerifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Phone verified successfully!'**
  String get phoneVerifiedSuccessfully;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordTitle;

  /// No description provided for @sendCodeToPhone.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a code to your phone'**
  String get sendCodeToPhone;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @repeatPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get repeatPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @newPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordTitle;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordResetSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully!'**
  String get passwordResetSuccessfully;

  /// No description provided for @underReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get underReview;

  /// No description provided for @pendingReviewMessage.
  ///
  /// In en, this message translates to:
  /// **'Your registration is complete. Our admin team is reviewing your information and documents.\n\nYou will be notified once your account is approved.'**
  String get pendingReviewMessage;

  /// No description provided for @registrationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Registration submitted'**
  String get registrationSubmitted;

  /// No description provided for @documentVerificationInProgress.
  ///
  /// In en, this message translates to:
  /// **'Document verification in progress'**
  String get documentVerificationInProgress;

  /// No description provided for @accountActivation.
  ///
  /// In en, this message translates to:
  /// **'Account activation'**
  String get accountActivation;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @netEarnings.
  ///
  /// In en, this message translates to:
  /// **'Net Earnings'**
  String get netEarnings;

  /// No description provided for @thisMonthTapDetails.
  ///
  /// In en, this message translates to:
  /// **'This month · Tap to view details'**
  String get thisMonthTapDetails;

  /// No description provided for @todaysTrips.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Trips'**
  String get todaysTrips;

  /// No description provided for @nominations.
  ///
  /// In en, this message translates to:
  /// **'Nominations'**
  String get nominations;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @noActiveTripsSub.
  ///
  /// In en, this message translates to:
  /// **'No active trips'**
  String get noActiveTripsSub;

  /// No description provided for @activeTripsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String activeTripsCount(int count);

  /// No description provided for @noPending.
  ///
  /// In en, this message translates to:
  /// **'No pending'**
  String get noPending;

  /// No description provided for @tapToRespond.
  ///
  /// In en, this message translates to:
  /// **'Tap to respond'**
  String get tapToRespond;

  /// No description provided for @allClear.
  ///
  /// In en, this message translates to:
  /// **'All clear'**
  String get allClear;

  /// No description provided for @tapToRead.
  ///
  /// In en, this message translates to:
  /// **'Tap to read'**
  String get tapToRead;

  /// No description provided for @todaysRoutes.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Routes'**
  String get todaysRoutes;

  /// No description provided for @noRoutesScheduledHome.
  ///
  /// In en, this message translates to:
  /// **'No routes scheduled for today.\nCheck back after your groups are set up.'**
  String get noRoutesScheduledHome;

  /// No description provided for @viewMoreRoutes.
  ///
  /// In en, this message translates to:
  /// **'View {count} more route'**
  String viewMoreRoutes(int count);

  /// No description provided for @viewMoreRoutesPlural.
  ///
  /// In en, this message translates to:
  /// **'View {count} more routes'**
  String viewMoreRoutesPlural(int count);

  /// No description provided for @statusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusDone;

  /// No description provided for @startRoute.
  ///
  /// In en, this message translates to:
  /// **'Start Route'**
  String get startRoute;

  /// No description provided for @resumeRoute.
  ///
  /// In en, this message translates to:
  /// **'Resume Route'**
  String get resumeRoute;

  /// No description provided for @startRouteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Start Route?'**
  String get startRouteConfirm;

  /// No description provided for @startRouteConfirmMsg.
  ///
  /// In en, this message translates to:
  /// **'Start the \"{route}\" route?\n\nParents will be notified immediately.'**
  String startRouteConfirmMsg(String route);

  /// No description provided for @noRoutesToday.
  ///
  /// In en, this message translates to:
  /// **'No routes today'**
  String get noRoutesToday;

  /// No description provided for @noRoutesMessage.
  ///
  /// In en, this message translates to:
  /// **'You have no assigned groups or no routes scheduled for today.'**
  String get noRoutesMessage;

  /// No description provided for @pickedUpStat.
  ///
  /// In en, this message translates to:
  /// **'Picked up'**
  String get pickedUpStat;

  /// No description provided for @endRoute.
  ///
  /// In en, this message translates to:
  /// **'End Route'**
  String get endRoute;

  /// No description provided for @endingRoute.
  ///
  /// In en, this message translates to:
  /// **'Ending Route…'**
  String get endingRoute;

  /// No description provided for @endRouteConfirm.
  ///
  /// In en, this message translates to:
  /// **'End Route?'**
  String get endRouteConfirm;

  /// No description provided for @endRouteMsg.
  ///
  /// In en, this message translates to:
  /// **'Mark this route as completed?\nParents will be notified that all students have been delivered.'**
  String get endRouteMsg;

  /// No description provided for @onBoard.
  ///
  /// In en, this message translates to:
  /// **'On board'**
  String get onBoard;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get live;

  /// No description provided for @noGps.
  ///
  /// In en, this message translates to:
  /// **'No GPS'**
  String get noGps;

  /// No description provided for @noStudentsForTrip.
  ///
  /// In en, this message translates to:
  /// **'No students for this trip.'**
  String get noStudentsForTrip;

  /// No description provided for @pickedUpAction.
  ///
  /// In en, this message translates to:
  /// **'Picked Up'**
  String get pickedUpAction;

  /// No description provided for @dropOff.
  ///
  /// In en, this message translates to:
  /// **'Drop Off'**
  String get dropOff;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get waiting;

  /// No description provided for @scanPassengerQr.
  ///
  /// In en, this message translates to:
  /// **'Scan Passenger QR'**
  String get scanPassengerQr;

  /// No description provided for @refreshStudents.
  ///
  /// In en, this message translates to:
  /// **'Refresh students'**
  String get refreshStudents;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// No description provided for @locationUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Location update failed'**
  String get locationUpdateFailed;

  /// No description provided for @scanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan – QR Code'**
  String get scanQrCode;

  /// No description provided for @scanNfcCard.
  ///
  /// In en, this message translates to:
  /// **'Scan – NFC Card'**
  String get scanNfcCard;

  /// No description provided for @qrCode.
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get qrCode;

  /// No description provided for @nfcCard.
  ///
  /// In en, this message translates to:
  /// **'NFC Card'**
  String get nfcCard;

  /// No description provided for @offlineLocalQr.
  ///
  /// In en, this message translates to:
  /// **'Offline – local QR verification'**
  String get offlineLocalQr;

  /// No description provided for @qrDetected.
  ///
  /// In en, this message translates to:
  /// **'QR code detected…'**
  String get qrDetected;

  /// No description provided for @holdSteady.
  ///
  /// In en, this message translates to:
  /// **'Hold steady…'**
  String get holdSteady;

  /// No description provided for @pointCameraAtQr.
  ///
  /// In en, this message translates to:
  /// **'Point camera at the passenger\'s QR code'**
  String get pointCameraAtQr;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @cameraFailed.
  ///
  /// In en, this message translates to:
  /// **'Camera failed to start'**
  String get cameraFailed;

  /// No description provided for @tapToRetry.
  ///
  /// In en, this message translates to:
  /// **'Tap to retry'**
  String get tapToRetry;

  /// No description provided for @lookingUpStudent.
  ///
  /// In en, this message translates to:
  /// **'Looking up student…'**
  String get lookingUpStudent;

  /// No description provided for @holdCardToBack.
  ///
  /// In en, this message translates to:
  /// **'Hold card to back of phone'**
  String get holdCardToBack;

  /// No description provided for @readyTapCard.
  ///
  /// In en, this message translates to:
  /// **'Ready – tap card to phone'**
  String get readyTapCard;

  /// No description provided for @forNfcCardsOnly.
  ///
  /// In en, this message translates to:
  /// **'For physical UGO NFC cards only.\nTo scan a QR code, use the QR Code tab.'**
  String get forNfcCardsOnly;

  /// No description provided for @tapToListenAgain.
  ///
  /// In en, this message translates to:
  /// **'Tap to listen again'**
  String get tapToListenAgain;

  /// No description provided for @scanFailed.
  ///
  /// In en, this message translates to:
  /// **'Scan Failed'**
  String get scanFailed;

  /// No description provided for @syncedOfflineRides.
  ///
  /// In en, this message translates to:
  /// **'Synced {count} offline rides'**
  String syncedOfflineRides(int count);

  /// No description provided for @syncedOfflineRide.
  ///
  /// In en, this message translates to:
  /// **'Synced {count} offline ride'**
  String syncedOfflineRide(int count);

  /// No description provided for @rideRecorded.
  ///
  /// In en, this message translates to:
  /// **'Ride Recorded'**
  String get rideRecorded;

  /// No description provided for @passengerDetails.
  ///
  /// In en, this message translates to:
  /// **'Passenger Details'**
  String get passengerDetails;

  /// No description provided for @scanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan Again'**
  String get scanAgain;

  /// No description provided for @qrVerified.
  ///
  /// In en, this message translates to:
  /// **'QR Verified'**
  String get qrVerified;

  /// No description provided for @selectRidesToDeduct.
  ///
  /// In en, this message translates to:
  /// **'Select rides to deduct below'**
  String get selectRidesToDeduct;

  /// No description provided for @passengerInfo.
  ///
  /// In en, this message translates to:
  /// **'Passenger Info'**
  String get passengerInfo;

  /// No description provided for @packageInfo.
  ///
  /// In en, this message translates to:
  /// **'Package Info'**
  String get packageInfo;

  /// No description provided for @expires.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get expires;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// No description provided for @ridesToDeduct.
  ///
  /// In en, this message translates to:
  /// **'Rides to Deduct'**
  String get ridesToDeduct;

  /// No description provided for @payingForOthers.
  ///
  /// In en, this message translates to:
  /// **'Increase if the passenger is paying for others'**
  String get payingForOthers;

  /// No description provided for @deductingForOthers.
  ///
  /// In en, this message translates to:
  /// **'Deducting {count} rides – passenger paying for others'**
  String deductingForOthers(int count);

  /// No description provided for @confirmRideCount.
  ///
  /// In en, this message translates to:
  /// **'Confirm {count} Ride'**
  String confirmRideCount(int count);

  /// No description provided for @confirmRidesCount.
  ///
  /// In en, this message translates to:
  /// **'Confirm {count} Rides'**
  String confirmRidesCount(int count);

  /// No description provided for @rideDeductedFrom.
  ///
  /// In en, this message translates to:
  /// **'{count} ride deducted from {name}'**
  String rideDeductedFrom(int count, String name);

  /// No description provided for @ridesDeductedFrom.
  ///
  /// In en, this message translates to:
  /// **'{count} rides deducted from {name}'**
  String ridesDeductedFrom(int count, String name);

  /// No description provided for @updatedBalance.
  ///
  /// In en, this message translates to:
  /// **'Updated Balance'**
  String get updatedBalance;

  /// No description provided for @deductedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} deducted'**
  String deductedCount(int count);

  /// No description provided for @ridesLeftCount.
  ///
  /// In en, this message translates to:
  /// **'{count} left'**
  String ridesLeftCount(int count);

  /// No description provided for @ridesUsedOf.
  ///
  /// In en, this message translates to:
  /// **'{used} / {total} rides used'**
  String ridesUsedOf(int used, int total);

  /// No description provided for @onlyRideRemaining.
  ///
  /// In en, this message translates to:
  /// **'Only {count} ride remaining!'**
  String onlyRideRemaining(int count);

  /// No description provided for @onlyRidesRemaining.
  ///
  /// In en, this message translates to:
  /// **'Only {count} rides remaining!'**
  String onlyRidesRemaining(int count);

  /// No description provided for @scanAnother.
  ///
  /// In en, this message translates to:
  /// **'Scan Another'**
  String get scanAnother;

  /// No description provided for @ridesRecorded.
  ///
  /// In en, this message translates to:
  /// **'{count} Rides Recorded'**
  String ridesRecorded(int count);

  /// No description provided for @offlineScan.
  ///
  /// In en, this message translates to:
  /// **'Offline Scan'**
  String get offlineScan;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// No description provided for @qrVerifiedLocally.
  ///
  /// In en, this message translates to:
  /// **'QR verified locally. Ride will sync when online.'**
  String get qrVerifiedLocally;

  /// No description provided for @qrSignatureValid.
  ///
  /// In en, this message translates to:
  /// **'QR Signature Valid'**
  String get qrSignatureValid;

  /// No description provided for @passengerQrGenuine.
  ///
  /// In en, this message translates to:
  /// **'Passenger QR is genuine. Select rides to queue.'**
  String get passengerQrGenuine;

  /// No description provided for @willBeRecordedOnline.
  ///
  /// In en, this message translates to:
  /// **'Will be recorded once back online'**
  String get willBeRecordedOnline;

  /// No description provided for @queueRide.
  ///
  /// In en, this message translates to:
  /// **'Queue Ride'**
  String get queueRide;

  /// No description provided for @rideQueued.
  ///
  /// In en, this message translates to:
  /// **'{count} ride queued'**
  String rideQueued(int count);

  /// No description provided for @ridesQueued.
  ///
  /// In en, this message translates to:
  /// **'{count} rides queued'**
  String ridesQueued(int count);

  /// No description provided for @willBeSyncedOnline.
  ///
  /// In en, this message translates to:
  /// **'Will be deducted from the passenger\'s account when you reconnect.'**
  String get willBeSyncedOnline;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @deleteAllNotificationsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete all notifications? This cannot be undone.'**
  String get deleteAllNotificationsConfirm;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get allCaughtUp;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @loadingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Loading notifications...'**
  String get loadingNotifications;

  /// No description provided for @myEarnings.
  ///
  /// In en, this message translates to:
  /// **'My Earnings'**
  String get myEarnings;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @platformFee.
  ///
  /// In en, this message translates to:
  /// **'Platform Fee'**
  String get platformFee;

  /// No description provided for @revenueBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Revenue Breakdown'**
  String get revenueBreakdown;

  /// No description provided for @grossRevenue.
  ///
  /// In en, this message translates to:
  /// **'Gross Revenue'**
  String get grossRevenue;

  /// No description provided for @fromParents.
  ///
  /// In en, this message translates to:
  /// **'from parents'**
  String get fromParents;

  /// No description provided for @ugoCommission.
  ///
  /// In en, this message translates to:
  /// **'UGO Commission'**
  String get ugoCommission;

  /// No description provided for @platformFeePercent.
  ///
  /// In en, this message translates to:
  /// **'15% platform fee'**
  String get platformFeePercent;

  /// No description provided for @yourNetEarnings.
  ///
  /// In en, this message translates to:
  /// **'Your Net Earnings'**
  String get yourNetEarnings;

  /// No description provided for @beforePlatformSub.
  ///
  /// In en, this message translates to:
  /// **'before platform sub'**
  String get beforePlatformSub;

  /// No description provided for @tripsDone.
  ///
  /// In en, this message translates to:
  /// **'Trips Done'**
  String get tripsDone;

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptions;

  /// No description provided for @estimatedPayout.
  ///
  /// In en, this message translates to:
  /// **'Estimated Payout'**
  String get estimatedPayout;

  /// No description provided for @takeHomeThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Take-home this month'**
  String get takeHomeThisMonth;

  /// No description provided for @platformSubscription.
  ///
  /// In en, this message translates to:
  /// **'Platform subscription'**
  String get platformSubscription;

  /// No description provided for @payPlatformFee.
  ///
  /// In en, this message translates to:
  /// **'Pay Platform Fee'**
  String get payPlatformFee;

  /// No description provided for @totalEarnedThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Total Earned This Month'**
  String get totalEarnedThisMonth;

  /// No description provided for @packages.
  ///
  /// In en, this message translates to:
  /// **'Packages'**
  String get packages;

  /// No description provided for @packageEarnings.
  ///
  /// In en, this message translates to:
  /// **'Package Earnings'**
  String get packageEarnings;

  /// No description provided for @subscriptionEarnings.
  ///
  /// In en, this message translates to:
  /// **'Subscription Earnings'**
  String get subscriptionEarnings;

  /// No description provided for @tapADayForDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap a day for details'**
  String get tapADayForDetails;

  /// No description provided for @hasEarnings.
  ///
  /// In en, this message translates to:
  /// **'Has earnings'**
  String get hasEarnings;

  /// No description provided for @tapForDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap for details'**
  String get tapForDetails;

  /// No description provided for @noPackagesScanned.
  ///
  /// In en, this message translates to:
  /// **'No packages scanned on this day'**
  String get noPackagesScanned;

  /// No description provided for @noSubscriptionRoutes.
  ///
  /// In en, this message translates to:
  /// **'No subscription routes on this day'**
  String get noSubscriptionRoutes;

  /// No description provided for @scannedPackages.
  ///
  /// In en, this message translates to:
  /// **'Scanned Packages'**
  String get scannedPackages;

  /// No description provided for @routesCompleted.
  ///
  /// In en, this message translates to:
  /// **'Routes Completed'**
  String get routesCompleted;

  /// No description provided for @paymentWindow.
  ///
  /// In en, this message translates to:
  /// **'Payment Window'**
  String get paymentWindow;

  /// No description provided for @openNow.
  ///
  /// In en, this message translates to:
  /// **'OPEN NOW'**
  String get openNow;

  /// No description provided for @estimatedPayoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated payout'**
  String get estimatedPayoutLabel;

  /// No description provided for @opensInDay.
  ///
  /// In en, this message translates to:
  /// **'Opens in {count} day'**
  String opensInDay(int count);

  /// No description provided for @opensInDays.
  ///
  /// In en, this message translates to:
  /// **'Opens in {count} days'**
  String opensInDays(int count);

  /// No description provided for @paymentWindowClosed.
  ///
  /// In en, this message translates to:
  /// **'Payment window for this period has closed.'**
  String get paymentWindowClosed;

  /// No description provided for @noEarningsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No earnings recorded this month.'**
  String get noEarningsRecorded;

  /// No description provided for @withdrawPackageEarnings.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Package Earnings'**
  String get withdrawPackageEarnings;

  /// No description provided for @withdrawalAmount.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Amount'**
  String get withdrawalAmount;

  /// No description provided for @selectBank.
  ///
  /// In en, this message translates to:
  /// **'Select Bank'**
  String get selectBank;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get accountNumber;

  /// No description provided for @enterAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your bank account number'**
  String get enterAccountNumber;

  /// No description provided for @requestWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Request Withdrawal'**
  String get requestWithdrawal;

  /// No description provided for @withdrawalRequested.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Requested'**
  String get withdrawalRequested;

  /// No description provided for @withdrawalSuccessMsg.
  ///
  /// In en, this message translates to:
  /// **'ETB {amount} will be transferred to your {bank} account. Admin will process within 1–2 business days.'**
  String withdrawalSuccessMsg(String amount, String bank);

  /// No description provided for @dayPackageEarnings.
  ///
  /// In en, this message translates to:
  /// **'Day\'s Package Earnings'**
  String get dayPackageEarnings;

  /// No description provided for @dayRouteEarnings.
  ///
  /// In en, this message translates to:
  /// **'Day\'s Route Earnings'**
  String get dayRouteEarnings;

  /// No description provided for @packagesScannedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} package scanned'**
  String packagesScannedCount(int count);

  /// No description provided for @packagesScannedCountPlural.
  ///
  /// In en, this message translates to:
  /// **'{count} packages scanned'**
  String packagesScannedCountPlural(int count);

  /// No description provided for @routesCompletedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} route completed'**
  String routesCompletedCount(int count);

  /// No description provided for @routesCompletedCountPlural.
  ///
  /// In en, this message translates to:
  /// **'{count} routes completed'**
  String routesCompletedCountPlural(int count);

  /// No description provided for @scans.
  ///
  /// In en, this message translates to:
  /// **'scans'**
  String get scans;

  /// No description provided for @routesLabel.
  ///
  /// In en, this message translates to:
  /// **'routes'**
  String get routesLabel;

  /// No description provided for @monthEarningsPaidOut.
  ///
  /// In en, this message translates to:
  /// **'{month} earnings are paid out:'**
  String monthEarningsPaidOut(String month);

  /// No description provided for @packageScan.
  ///
  /// In en, this message translates to:
  /// **'Package scan'**
  String get packageScan;

  /// No description provided for @routeMorningToSchool.
  ///
  /// In en, this message translates to:
  /// **'Morning → School'**
  String get routeMorningToSchool;

  /// No description provided for @routeMiddayToHome.
  ///
  /// In en, this message translates to:
  /// **'Midday → Home'**
  String get routeMiddayToHome;

  /// No description provided for @routeAfternoonToSchool.
  ///
  /// In en, this message translates to:
  /// **'Afternoon → School'**
  String get routeAfternoonToSchool;

  /// No description provided for @routeAfternoonToHome.
  ///
  /// In en, this message translates to:
  /// **'Afternoon → Home'**
  String get routeAfternoonToHome;

  /// No description provided for @noPendingNominations.
  ///
  /// In en, this message translates to:
  /// **'No pending nominations'**
  String get noPendingNominations;

  /// No description provided for @noneYet.
  ///
  /// In en, this message translates to:
  /// **'None yet'**
  String get noneYet;

  /// No description provided for @loadingNominations.
  ///
  /// In en, this message translates to:
  /// **'Loading nominations...'**
  String get loadingNominations;

  /// No description provided for @nominationAccepted.
  ///
  /// In en, this message translates to:
  /// **'Nomination accepted!'**
  String get nominationAccepted;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @pendingCount.
  ///
  /// In en, this message translates to:
  /// **'Pending ({count})'**
  String pendingCount(int count);

  /// No description provided for @acceptedCount.
  ///
  /// In en, this message translates to:
  /// **'Accepted ({count})'**
  String acceptedCount(int count);

  /// No description provided for @declinedCount.
  ///
  /// In en, this message translates to:
  /// **'Declined ({count})'**
  String declinedCount(int count);

  /// No description provided for @myGroups.
  ///
  /// In en, this message translates to:
  /// **'My Groups'**
  String get myGroups;

  /// No description provided for @noActiveGroupsYet.
  ///
  /// In en, this message translates to:
  /// **'No active groups yet'**
  String get noActiveGroupsYet;

  /// No description provided for @acceptNominationToStart.
  ///
  /// In en, this message translates to:
  /// **'Accept a nomination to get started'**
  String get acceptNominationToStart;

  /// No description provided for @viewNominations.
  ///
  /// In en, this message translates to:
  /// **'View Nominations'**
  String get viewNominations;

  /// No description provided for @loadingGroups.
  ///
  /// In en, this message translates to:
  /// **'Loading groups...'**
  String get loadingGroups;

  /// No description provided for @accountSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get accountSectionLabel;

  /// No description provided for @earningsSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'EARNINGS'**
  String get earningsSectionLabel;

  /// No description provided for @settingsSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settingsSectionLabel;

  /// No description provided for @supportSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT'**
  String get supportSectionLabel;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @emailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailOptional;

  /// No description provided for @addressOptional.
  ///
  /// In en, this message translates to:
  /// **'Address (optional)'**
  String get addressOptional;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated!'**
  String get profileUpdated;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @personalInfoSection.
  ///
  /// In en, this message translates to:
  /// **'PERSONAL INFO'**
  String get personalInfoSection;

  /// No description provided for @contactSection.
  ///
  /// In en, this message translates to:
  /// **'CONTACT'**
  String get contactSection;

  /// No description provided for @verifyOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtpTitle;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @currentPasswordSection.
  ///
  /// In en, this message translates to:
  /// **'CURRENT PASSWORD'**
  String get currentPasswordSection;

  /// No description provided for @newPasswordSection.
  ///
  /// In en, this message translates to:
  /// **'NEW PASSWORD'**
  String get newPasswordSection;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @changePasswordInfo.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password and choose a new one. An OTP will be sent to your device to confirm.'**
  String get changePasswordInfo;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to your registered device ({phone}). Enter it below.'**
  String otpSentTo(String phone);

  /// No description provided for @verificationCodeSection.
  ///
  /// In en, this message translates to:
  /// **'VERIFICATION CODE'**
  String get verificationCodeSection;

  /// No description provided for @newPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'New password must be at least 8 characters'**
  String get newPasswordTooShort;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully!'**
  String get passwordChangedSuccessfully;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @helpAndSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupportTitle;

  /// No description provided for @ugoDriverSupport.
  ///
  /// In en, this message translates to:
  /// **'UGO Driver Support'**
  String get ugoDriverSupport;

  /// No description provided for @availableHours.
  ///
  /// In en, this message translates to:
  /// **'Available 7 days a week, 6 AM – 8 PM'**
  String get availableHours;

  /// No description provided for @faqSection.
  ///
  /// In en, this message translates to:
  /// **'FREQUENTLY ASKED QUESTIONS'**
  String get faqSection;

  /// No description provided for @quickLinksSection.
  ///
  /// In en, this message translates to:
  /// **'QUICK LINKS'**
  String get quickLinksSection;

  /// No description provided for @driverTerms.
  ///
  /// In en, this message translates to:
  /// **'Driver Terms & Conditions'**
  String get driverTerms;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @emailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupport;

  /// No description provided for @faq1q.
  ///
  /// In en, this message translates to:
  /// **'How do I start a route?'**
  String get faq1q;

  /// No description provided for @faq1a.
  ///
  /// In en, this message translates to:
  /// **'Go to the Routes tab and tap \"Start\" on the route you want to begin. Make sure you are at the pickup location before starting.'**
  String get faq1a;

  /// No description provided for @faq2q.
  ///
  /// In en, this message translates to:
  /// **'What if a student is absent?'**
  String get faq2q;

  /// No description provided for @faq2a.
  ///
  /// In en, this message translates to:
  /// **'When running a route, tap the student\'s name and mark them as absent. The parent will be notified automatically.'**
  String get faq2a;

  /// No description provided for @faq3q.
  ///
  /// In en, this message translates to:
  /// **'How are my earnings calculated?'**
  String get faq3q;

  /// No description provided for @faq3a.
  ///
  /// In en, this message translates to:
  /// **'Earnings are based on completed trips and your contract rate. You can view a full breakdown in the Earnings section of your profile.'**
  String get faq3a;

  /// No description provided for @faq4q.
  ///
  /// In en, this message translates to:
  /// **'What do I do if my vehicle breaks down?'**
  String get faq4q;

  /// No description provided for @faq4a.
  ///
  /// In en, this message translates to:
  /// **'Contact UGO support immediately using the number below. Inform parents of the delay through the app by pausing the route.'**
  String get faq4a;

  /// No description provided for @faq5q.
  ///
  /// In en, this message translates to:
  /// **'How do I scan a student\'s QR code?'**
  String get faq5q;

  /// No description provided for @faq5a.
  ///
  /// In en, this message translates to:
  /// **'Tap the scan icon on the home screen or routes screen. Hold the camera over the student\'s QR code to record their pickup or drop-off.'**
  String get faq5a;

  /// No description provided for @faq6q.
  ///
  /// In en, this message translates to:
  /// **'Can I decline a group nomination?'**
  String get faq6q;

  /// No description provided for @faq6a.
  ///
  /// In en, this message translates to:
  /// **'Yes. Open the Nominations tab, select the group, and tap \"Decline\". You can provide an optional reason.'**
  String get faq6a;

  /// No description provided for @aboutUGODriverTitle.
  ///
  /// In en, this message translates to:
  /// **'About UGO Driver'**
  String get aboutUGODriverTitle;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version 1.1.0'**
  String get versionLabel;

  /// No description provided for @studentTransportPlatform.
  ///
  /// In en, this message translates to:
  /// **'Student Transport Platform'**
  String get studentTransportPlatform;

  /// No description provided for @aboutUGOTitle.
  ///
  /// In en, this message translates to:
  /// **'About UGO'**
  String get aboutUGOTitle;

  /// No description provided for @aboutUGOContent.
  ///
  /// In en, this message translates to:
  /// **'UGO is a student transport management platform connecting parents, drivers, and school administrators. It enables safe, trackable, and organised school transport for families across Ethiopia.'**
  String get aboutUGOContent;

  /// No description provided for @driverMission.
  ///
  /// In en, this message translates to:
  /// **'Driver Mission'**
  String get driverMission;

  /// No description provided for @driverMissionContent.
  ///
  /// In en, this message translates to:
  /// **'As a UGO driver you are responsible for the safe and timely transport of students. Your commitment to punctuality and professionalism directly impacts the trust families place in UGO.'**
  String get driverMissionContent;

  /// No description provided for @appInfoSection.
  ///
  /// In en, this message translates to:
  /// **'APP INFO'**
  String get appInfoSection;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get appVersion;

  /// No description provided for @appPlatform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get appPlatform;

  /// No description provided for @appDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get appDeveloper;

  /// No description provided for @appContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get appContact;

  /// No description provided for @appCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get appCountry;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2025 UGO Technologies. All rights reserved.'**
  String get copyright;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['am', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
