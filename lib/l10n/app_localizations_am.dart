// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get appName => 'UGO ሹፌር';

  @override
  String get language => 'ቋንቋ';

  @override
  String get english => 'English';

  @override
  String get amharic => 'አማርኛ';

  @override
  String get selectLanguage => 'ቋንቋ ይምረጡ';

  @override
  String get save => 'አስቀምጥ';

  @override
  String get cancel => 'ሰርዝ';

  @override
  String get confirm => 'አረጋግጥ';

  @override
  String get done => 'ተጠናቋል';

  @override
  String get retry => 'እንደገና ሞክር';

  @override
  String get refresh => 'አድስ';

  @override
  String get loading => 'በመጫን ላይ…';

  @override
  String get error => 'ችግር ተፈጥሯል';

  @override
  String get noData => 'ምንም መረጃ የለም';

  @override
  String get submit => 'ላክ';

  @override
  String get back => 'ተመለስ';

  @override
  String get next => 'ቀጥል';

  @override
  String get yes => 'አዎ';

  @override
  String get no => 'አይ';

  @override
  String get logout => 'ውጣ';

  @override
  String get logoutConfirmTitle => 'ውጣ';

  @override
  String get logoutConfirmMsg => 'ከፕሮግራሙ ለወጥ ፈቃደኛ ነዎት?';

  @override
  String get signOut => 'ውጣ';

  @override
  String get account => 'መለያ';

  @override
  String get editProfile => 'መገለጫ አርትዕ';

  @override
  String get changePassword => 'የይለፍ ቃል ቀይር';

  @override
  String get notifications => 'ማሳወቂያዎች';

  @override
  String get helpAndSupport => 'እርዳታ እና ድጋፍ';

  @override
  String get aboutUGODriver => 'UGO ሹፌር ስለ';

  @override
  String get home => 'ቤት';

  @override
  String get driver => 'ሹፌር';

  @override
  String get school => 'ት/ቤት';

  @override
  String get phone => 'ስልክ';

  @override
  String get name => 'ስም';

  @override
  String get email => 'ኢሜይል';

  @override
  String get address => 'አድራሻ';

  @override
  String get active => 'ንቁ';

  @override
  String get inactive => 'ቅርቡ ያልሆነ';

  @override
  String get scheduled => 'የተቀመጠ';

  @override
  String get completed => 'ተጠናቋል';

  @override
  String get cancelled => 'ተሰርዟል';

  @override
  String get pending => 'በጥበቃ ላይ';

  @override
  String get accepted => 'ተቀባይ';

  @override
  String get declined => 'ተቀባይነት የለም';

  @override
  String get viewAll => 'ሁሉንም ይመልከቱ';

  @override
  String get total => 'ጠቅላላ';

  @override
  String get ride => 'ጉዞ';

  @override
  String get rides => 'ጉዞዎች';

  @override
  String get students => 'ተማሪዎች';

  @override
  String get time => 'ጊዜ';

  @override
  String get route => 'መስመር';

  @override
  String get package => 'ጥቅል';

  @override
  String get parent => 'ወላጅ';

  @override
  String get student => 'ተማሪ';

  @override
  String get grade => 'ክፍል';

  @override
  String gradeLabel(String grade) {
    return 'ክፍል $grade';
  }

  @override
  String get justNow => 'ሁኔታ ልክ አሁን';

  @override
  String minutesAgo(int m) {
    return '$m ደቂቃ በፊት';
  }

  @override
  String hoursAgo(int h) {
    return '$h ሰዓት በፊት';
  }

  @override
  String get yesterday => 'ትናንት';

  @override
  String daysAgo(int d) {
    return '$d ቀን በፊት';
  }

  @override
  String get welcomeBack => 'እንኳን ደህና መጡ';

  @override
  String get signInToDriverAccount => 'ወደ ሹፌር መለያዎ ይግቡ';

  @override
  String get phoneNumber => 'ስልክ ቁጥር';

  @override
  String get password => 'የይለፍ ቃል';

  @override
  String get forgotPassword => 'ይለፍ ቃል ረሳዎት?';

  @override
  String get signIn => 'ግባ';

  @override
  String get dontHaveAccount => 'መለያ የለዎትም?';

  @override
  String get register => 'ይመዝገቡ';

  @override
  String get phoneRequired => 'ስልክ ቁጥር ያስፈልጋል';

  @override
  String get enter9Digits => 'ትክክለኛ 9 አሃዞች ያስፈሩ';

  @override
  String get numberMustStart79 => 'ቁጥሩ በ7 ወይም 9 መጀመር አለበት';

  @override
  String get passwordRequired => 'የይለፍ ቃል ያስፈልጋል';

  @override
  String get createAccount => 'መለያ ይፍጠሩ';

  @override
  String get personalInfo => 'የግል መረጃ';

  @override
  String get vehicleInfo => 'የተሽከርካሪ መረጃ';

  @override
  String get joinUGONetwork => 'ወደ UGO ሹፌር አውታር ይቀላቀሉ';

  @override
  String get identityLicenseDetails => 'ማንነት እና የፈቃድ ዝርዝሮች';

  @override
  String get yourVehicleDetails => 'የተሽከርካሪዎ ዝርዝሮች';

  @override
  String stepOf3(int step) {
    return 'ደረጃ $step ከ 3';
  }

  @override
  String get fullName => 'ሙሉ ስም';

  @override
  String get enterFullName => 'ሙሉ ስም ያስፈሩ';

  @override
  String get enterYourFullName => 'ሙሉ ስምዎን ያስፈሩ';

  @override
  String get enterPhoneNumber => 'ስልክ ቁጥርዎን ያስፈሩ';

  @override
  String get minCharsHint => 'ቢያንስ 8 ፊደሎች';

  @override
  String get confirmPassword => 'ይለፍ ቃል ያረጋግጡ';

  @override
  String get confirmPasswordHint => 'ይለፍ ቃሉን ያረጋግጡ';

  @override
  String get passwordsDoNotMatch => 'የይለፍ ቃሎቹ አይዛመዱም';

  @override
  String get atLeast8Chars => 'ቢያንስ 8 ፊደሎች';

  @override
  String get alreadyHaveAccount => 'መለያ አሎዎ?';

  @override
  String get continueButton => 'ቀጥል';

  @override
  String get dateOfBirth => 'የትውልድ ቀን';

  @override
  String get selectDateOfBirth => 'የትውልድ ቀን ይምረጡ';

  @override
  String get educationLevel => 'የትምህርት ደረጃ';

  @override
  String get selectEducationLevel => 'የትምህርት ደረጃ ይምረጡ';

  @override
  String get nationalIdNumber => 'ብሔራዊ መታወቂያ ቁጥር';

  @override
  String get enterNationalId => 'ብሔራዊ መታወቂያ ቁጥር ያስፈሩ';

  @override
  String get enterNationalIdRequired => 'ብሔራዊ መታወቂያ ቁጥርዎን ያስፈሩ';

  @override
  String get nationalIdPhoto => 'የብሔራዊ መታወቂያ ፎቶ';

  @override
  String get tapToUploadIdPhoto => 'ፎቶ ለማስቀረጥ ይጫኑ';

  @override
  String get requiredForVerification => 'ለማረጋገጫ ያስፈልጋል';

  @override
  String get driverLicenseNumber => 'የሹፌር ፈቃድ ቁጥር';

  @override
  String get enterLicenseNumber => 'የፈቃድ ቁጥር ያስፈሩ';

  @override
  String get enterLicenseRequired => 'የፈቃድ ቁጥርዎን ያስፈሩ';

  @override
  String get licenseExpiryDate => 'የፈቃድ ማብቂያ ቀን';

  @override
  String get selectExpiryDate => 'የማብቂያ ቀን ይምረጡ';

  @override
  String get pleaseUploadNationalId => 'የብሔራዊ መታወቂያ ፎቶ ይጫኑ';

  @override
  String get pleaseSelectLicenseExpiry => 'የፈቃድ ማብቂያ ቀን ይምረጡ';

  @override
  String get vehicleType => 'የተሽከርካሪ ዓይነት';

  @override
  String get selectVehicleType => 'የተሽከርካሪ ዓይነት ይምረጡ';

  @override
  String get vehicleTypeRequired => 'የተሽከርካሪ ዓይነት ይምረጡ';

  @override
  String get plateNumber => 'ሰሌዳ ቁጥር';

  @override
  String get enterPlateNumber => 'ሰሌዳ ቁጥር ያስፈሩ';

  @override
  String get vehicleColor => 'የተሽከርካሪ ቀለም';

  @override
  String get enterVehicleColor => 'የተሽከርካሪ ቀለም ያስፈሩ';

  @override
  String get vehicleModelYear => 'የተሽከርካሪ ሞዴል / ዓመት';

  @override
  String get accountReviewNotice => 'መለያዎ ከመነቃቃቱ በፊት የአስተዳዳሪ ቡድን ይገመግማል።';

  @override
  String get submitRegistration => 'ምዝገባ ይላኩ';

  @override
  String get takeAPhoto => 'ፎቶ ይሳሉ';

  @override
  String get chooseFromGallery => 'ከጋለሪ ይምረጡ';

  @override
  String get stepAccount => 'መለያ';

  @override
  String get stepPersonal => 'ግላዊ';

  @override
  String get stepVehicle => 'ተሽከርካሪ';

  @override
  String get educNone => 'ምንም';

  @override
  String get educPrimary => 'አንደኛ ደረጃ';

  @override
  String get educSecondary => 'ሁለተኛ ደረጃ';

  @override
  String get educDiploma => 'ዲፕሎማ';

  @override
  String get educDegree => 'የባቸለር ዲግሪ';

  @override
  String get educMasters => 'የማስተርስ ዲግሪ';

  @override
  String get educPhd => 'ፒኤችዲ';

  @override
  String get vehBajaj => 'ባጃጅ (3-ጎማ)';

  @override
  String get vehElectric => 'ኤሌክትሪክ ባጃጅ';

  @override
  String get vehForce => 'ፎርስ / ሚኒባስ';

  @override
  String get otpVerification => 'OTP ማረጋገጫ';

  @override
  String get codeSentTo => 'ኮድ ተልኳል ወደ';

  @override
  String get enter6DigitCode => '6 አሃዝ ኮድ ያስፈሩ';

  @override
  String get verifyCode => 'ኮድ አረጋግጥ';

  @override
  String get didntReceiveCode => 'ኮዱን አልተቀበሉም?';

  @override
  String get resendCode => 'ኮድ እንደገና ይላኩ';

  @override
  String retryInSeconds(int seconds) {
    return 'በ$secondsሰ ዳግም ሞክሩ';
  }

  @override
  String get changePhoneNumber => 'ስልክ ቁጥር ቀይሩ';

  @override
  String get phoneVerifiedSuccessfully => 'ስልክ በሰለሙ ተረጋግጧል!';

  @override
  String get forgotPasswordTitle => 'ይለፍ ቃል ረሳዎት?';

  @override
  String get sendCodeToPhone => 'ኮድ ወደ ስልክዎ እናስተናግዳለን';

  @override
  String get sendOtp => 'OTP ላክ';

  @override
  String get newPassword => 'አዲስ ይለፍ ቃል';

  @override
  String get repeatPassword => 'ይለፍ ቃሉን ድጋሜ ያስፈሩ';

  @override
  String get resetPassword => 'ይለፍ ቃል ዳግም ሰናቡ';

  @override
  String get newPasswordTitle => 'አዲስ ይለፍ ቃል';

  @override
  String get passwordTooShort => 'ይለፍ ቃሉ ቢያንስ 6 ፊደሎች ሊኖረው ይገባል';

  @override
  String get passwordResetSuccessfully => 'ይለፍ ቃሉ ተስናቅቷል!';

  @override
  String get underReview => 'በምርመራ ሥር';

  @override
  String get pendingReviewMessage =>
      'ምዝገባዎ ተጠናቋል። የአስተዳዳሪ ቡድናችን መረጃዎ እና ሰነዶቹን እየገመገሙ ናቸው።\n\nመለያዎ ሲጸድቅ ያሳወቅዎታለን።';

  @override
  String get registrationSubmitted => 'ምዝገባ ተልኳል';

  @override
  String get documentVerificationInProgress => 'ሰነድ ማረጋገጫ በሂደት ላይ';

  @override
  String get accountActivation => 'የመለያ ማንቃት';

  @override
  String get goodMorning => 'እንዴት አደሩ';

  @override
  String get goodAfternoon => 'ሰላም ከሰዓት';

  @override
  String get goodEvening => 'ሰላም ወደ ምሽቱ';

  @override
  String get netEarnings => 'ጠቅላላ ገቢ';

  @override
  String get thisMonthTapDetails => 'ይህ ወር · ዝርዝር ለማየት ይጫኑ';

  @override
  String get todaysTrips => 'የዛሬ ጉዞዎች';

  @override
  String get nominations => 'ሹሙ';

  @override
  String get alerts => 'ማሳወቂያዎች';

  @override
  String get noActiveTripsSub => 'ንቁ ጉዞ የለም';

  @override
  String activeTripsCount(int count) {
    return '$count ንቁ';
  }

  @override
  String get noPending => 'ምንም አቤቱታ የለም';

  @override
  String get tapToRespond => 'ለምላሽ ይጫኑ';

  @override
  String get allClear => 'ሁሉም ጥሩ ነው';

  @override
  String get tapToRead => 'ለማንበብ ይጫኑ';

  @override
  String get todaysRoutes => 'የዛሬ መስመሮች';

  @override
  String get noRoutesScheduledHome => 'ዛሬ የተቀመጠ መስመር የለም።\nቡድኖቹ ሲዘጋጁ ደግሞ ይፈትሹ።';

  @override
  String viewMoreRoutes(int count) {
    return 'ሌሎች $count መስመር ይመልከቱ';
  }

  @override
  String viewMoreRoutesPlural(int count) {
    return 'ሌሎች $count መስመሮች ይመልከቱ';
  }

  @override
  String get statusDone => 'ተጠናቋል';

  @override
  String get startRoute => 'መስመር ጀምር';

  @override
  String get resumeRoute => 'መስመር ቀጥል';

  @override
  String get startRouteConfirm => 'መስመር ይጀምሩ?';

  @override
  String startRouteConfirmMsg(String route) {
    return 'የ\"$route\" መስመር ይጀምሩ?\n\nወላጆች ወዲያው ያሳወቃቸዋል።';
  }

  @override
  String get noRoutesToday => 'ዛሬ መስመር የለም';

  @override
  String get noRoutesMessage => 'ምደባ ያልተሰጣቸው ቡድኖች ወይም ዛሬ የተቀመጠ መስመር የለም።';

  @override
  String get pickedUpStat => 'የተሰቡ';

  @override
  String get endRoute => 'መስመር አጠናቅቅ';

  @override
  String get endingRoute => 'መስመር እያጠናቀቁ…';

  @override
  String get endRouteConfirm => 'መስመር ይጨርሱ?';

  @override
  String get endRouteMsg =>
      'ይህ መስመር እንደተጠናቀቀ ይምዝግቡ?\nወላጆች ሁሉም ተማሪዎች መድረሳቸውን ያሳወቃቸዋል።';

  @override
  String get onBoard => 'ሳጥን ውስጥ';

  @override
  String get delivered => 'ደርሷል';

  @override
  String get live => 'ቀጥታ';

  @override
  String get noGps => 'GPS የለም';

  @override
  String get noStudentsForTrip => 'ለዚህ ጉዞ ምንም ተማሪ የለም።';

  @override
  String get pickedUpAction => 'ተሰብስቧል';

  @override
  String get dropOff => 'አወርዱ';

  @override
  String get waiting => 'እየጠበቀ';

  @override
  String get scanPassengerQr => 'የተሳፋሪ QR ስካን';

  @override
  String get refreshStudents => 'ተማሪዎችን አድስ';

  @override
  String get locationPermissionDenied => 'የቦታ ፈቃድ ተከልክሏል';

  @override
  String get locationUpdateFailed => 'የቦታ ዝማኔ አልተሳካም';

  @override
  String get scanQrCode => 'ስካን – QR ኮድ';

  @override
  String get scanNfcCard => 'ስካን – NFC ካርድ';

  @override
  String get qrCode => 'QR ኮድ';

  @override
  String get nfcCard => 'NFC ካርድ';

  @override
  String get offlineLocalQr => 'ኦፍላይን – ቦታዊ QR ማረጋገጫ';

  @override
  String get qrDetected => 'QR ኮድ ተፈልጎ…';

  @override
  String get holdSteady => 'ቋሙ…';

  @override
  String get pointCameraAtQr => 'ካሜራዎን ወደ ተሳፋሪው QR ኮድ ይጠቁሙ';

  @override
  String get processing => 'እየተሰራ ነው...';

  @override
  String get cameraFailed => 'ካሜራ ሊጀምር አልቻለም';

  @override
  String get tapToRetry => 'ዳግም ለመሞከር ይጫኑ';

  @override
  String get lookingUpStudent => 'ተማሪ እየተፈለጉ…';

  @override
  String get holdCardToBack => 'ካርዱን ወደ ስልኩ ጀርባ ይያዙ';

  @override
  String get readyTapCard => 'ዝግጁ – ካርዱን ወደ ስልኩ ይጫኑ';

  @override
  String get forNfcCardsOnly =>
      'ለፊዚካዊ UGO NFC ካርዶች ብቻ።\nQR ኮድ ለስካን፣ QR ኮድ ትር ይጠቀሙ።';

  @override
  String get tapToListenAgain => 'ዳግም ለማዳመጥ ይጫኑ';

  @override
  String get scanFailed => 'ስካን አልተሳካም';

  @override
  String syncedOfflineRides(int count) {
    return '$count ኦፍላይን ጉዞዎች ተዳቅለዋል';
  }

  @override
  String syncedOfflineRide(int count) {
    return '$count ኦፍላይን ጉዞ ተዳቅሏል';
  }

  @override
  String get rideRecorded => 'ጉዞ ተመዝግቧል';

  @override
  String get passengerDetails => 'የተሳፋሪ ዝርዝሮች';

  @override
  String get scanAgain => 'ዳግም ስካን';

  @override
  String get qrVerified => 'QR ተረጋግጧል';

  @override
  String get selectRidesToDeduct => 'ለመቀነስ ጉዞዎችን ይምረጡ';

  @override
  String get passengerInfo => 'የተሳፋሪ መረጃ';

  @override
  String get packageInfo => 'የጥቅል መረጃ';

  @override
  String get expires => 'ያልቃል';

  @override
  String get currentBalance => 'ወቅታዊ ቀሪ';

  @override
  String get ridesToDeduct => 'ለመቀነስ ጉዞዎች';

  @override
  String get payingForOthers => 'ተሳፋሪው ለሌሎች ከፈለ ጨምሩ';

  @override
  String deductingForOthers(int count) {
    return '$count ጉዞዎች እየቀነሱ – ተሳፋሪው ለሌሎች እየከፈሉ';
  }

  @override
  String confirmRideCount(int count) {
    return '$count ጉዞ አረጋግጥ';
  }

  @override
  String confirmRidesCount(int count) {
    return '$count ጉዞዎች አረጋግጥ';
  }

  @override
  String rideDeductedFrom(int count, String name) {
    return '$count ጉዞ ከ$name ተቀንሷል';
  }

  @override
  String ridesDeductedFrom(int count, String name) {
    return '$count ጉዞዎች ከ$name ተቀንሰዋል';
  }

  @override
  String get updatedBalance => 'ዘምነ ቀሪ';

  @override
  String deductedCount(int count) {
    return '$count ተቀንሷል';
  }

  @override
  String ridesLeftCount(int count) {
    return '$count ቀርቷል';
  }

  @override
  String ridesUsedOf(int used, int total) {
    return '$used / $total ጉዞዎች ጥቅም ላይ ዋለ';
  }

  @override
  String onlyRideRemaining(int count) {
    return 'ቀሪ $count ጉዞ ብቻ!';
  }

  @override
  String onlyRidesRemaining(int count) {
    return 'ቀሪ $count ጉዞዎች ብቻ!';
  }

  @override
  String get scanAnother => 'ሌላ ስካን';

  @override
  String ridesRecorded(int count) {
    return '$count ጉዞዎች ተመዝግበዋል';
  }

  @override
  String get offlineScan => 'ኦፍላይን ስካን';

  @override
  String get offlineMode => 'ኦፍላይን ሁናቴ';

  @override
  String get qrVerifiedLocally => 'QR በቦታ ተረጋግጧል። ኦንላይን ሲሆኑ ይዳቀሉ።';

  @override
  String get qrSignatureValid => 'QR ፊርማ ትክክለኛ ነው';

  @override
  String get passengerQrGenuine => 'የተሳፋሪው QR ትክክለኛ ነው። ለወረፋ ጉዞዎችን ይምረጡ።';

  @override
  String get willBeRecordedOnline => 'ኦንላይን ሲሆኑ ይመዘገባሉ';

  @override
  String get queueRide => 'ጉዞ ወረፋ ያስቀምጡ';

  @override
  String rideQueued(int count) {
    return '$count ጉዞ ወረፋ ተቀምጧል';
  }

  @override
  String ridesQueued(int count) {
    return '$count ጉዞዎች ወረፋ ተቀምጠዋል';
  }

  @override
  String get willBeSyncedOnline => 'ዳግም ኦንላይን ሲሆኑ ከተሳፋሪው መለያ ይቀነሳሉ።';

  @override
  String get markAllRead => 'ሁሉንም ያንብቡ';

  @override
  String get clearAll => 'ሁሉንም አጽዳ';

  @override
  String get deleteAllNotificationsConfirm =>
      'ሁሉም ማሳወቂያዎች ይሰረዛሉ? ይህ ሊቀለበስ አይችልም።';

  @override
  String get allCaughtUp => 'ሁሉም ታዋሎ!';

  @override
  String get noNotificationsYet => 'እስካሁን ምንም ማሳወቂያ የለም';

  @override
  String get delete => 'ሰርዝ';

  @override
  String get loadingNotifications => 'ማሳወቂያዎች እየጫኑ...';

  @override
  String get myEarnings => 'ገቢዬ';

  @override
  String get summary => 'ማጠቃለያ';

  @override
  String get daily => 'ዕለታዊ';

  @override
  String get earnings => 'ገቢዎች';

  @override
  String get platformFee => 'የፕላትፎርም ክፍያ';

  @override
  String get revenueBreakdown => 'የገቢ ዝርዝር';

  @override
  String get grossRevenue => 'አጠቃላይ ገቢ';

  @override
  String get fromParents => 'ከወላጆች';

  @override
  String get ugoCommission => 'UGO ኮሚሽን';

  @override
  String get platformFeePercent => '15% የፕላትፎርም ክፍያ';

  @override
  String get yourNetEarnings => 'ጠቅላላ ገቢዎ';

  @override
  String get beforePlatformSub => 'ከፕላትፎርም ደንበኝነት በፊት';

  @override
  String get tripsDone => 'ያለቁ ጉዞዎች';

  @override
  String get subscriptions => 'ደንበኝነቶች';

  @override
  String get estimatedPayout => 'የሚገመት ክፍያ';

  @override
  String get takeHomeThisMonth => 'ይህ ወር ቤት ይዘው ይሄዳሉ';

  @override
  String get platformSubscription => 'የፕላትፎርም ደንበኝነት';

  @override
  String get payPlatformFee => 'የፕላትፎርም ክፍያ ይክፈሉ';

  @override
  String get totalEarnedThisMonth => 'ይህ ወር ጠቅላላ';

  @override
  String get packages => 'ጥቅሎች';

  @override
  String get packageEarnings => 'የጥቅል ገቢ';

  @override
  String get subscriptionEarnings => 'የደንበኝነት ገቢ';

  @override
  String get tapADayForDetails => 'ዝርዝር ለማየት ቀን ይጫኑ';

  @override
  String get hasEarnings => 'ገቢ አለ';

  @override
  String get tapForDetails => 'ዝርዝር ለማየት ይጫኑ';

  @override
  String get noPackagesScanned => 'ዛሬ ምንም ጥቅሎች አልተቆጠሩም';

  @override
  String get noSubscriptionRoutes => 'ዛሬ ምንም ደንበኝነት መስመሮች የሉም';

  @override
  String get scannedPackages => 'የተቆጠሩ ጥቅሎች';

  @override
  String get routesCompleted => 'የተጠናቀቁ መስመሮች';

  @override
  String get paymentWindow => 'የክፍያ መስኮት';

  @override
  String get openNow => 'አሁን ክፍት';

  @override
  String get estimatedPayoutLabel => 'የሚገመት ክፍያ';

  @override
  String opensInDay(int count) {
    return 'ከ$count ቀን ውስጥ ይከፈታል';
  }

  @override
  String opensInDays(int count) {
    return 'ከ$count ቀናት ውስጥ ይከፈታል';
  }

  @override
  String get paymentWindowClosed => 'ለዚህ ወቅት የክፍያ መስኮት ተዘግቷል።';

  @override
  String get noEarningsRecorded => 'ይህ ወር ምንም ገቢ አልተመዘገበም።';

  @override
  String get withdrawPackageEarnings => 'የጥቅል ገቢ ወደ ባንክ ዝውውር';

  @override
  String get withdrawalAmount => 'የዝውውር መጠን';

  @override
  String get selectBank => 'ባንክ ይምረጡ';

  @override
  String get accountNumber => 'የባንክ ቁጥር';

  @override
  String get enterAccountNumber => 'የባንክ ቁጥርዎን ያስፈሩ';

  @override
  String get requestWithdrawal => 'ዝውውር ይጠይቁ';

  @override
  String get withdrawalRequested => 'ዝውውር ተጠይቋል';

  @override
  String withdrawalSuccessMsg(String amount, String bank) {
    return 'ETB $amount ወደ $bank ባንክ መለያዎ ይተላለፋሉ። አስተዳዳሪው ከ1–2 የሥራ ቀናት ውስጥ ያስተናግዳሉ።';
  }

  @override
  String get dayPackageEarnings => 'ዛሬ የጥቅል ገቢ';

  @override
  String get dayRouteEarnings => 'ዛሬ የመስመር ገቢ';

  @override
  String packagesScannedCount(int count) {
    return '$count ጥቅል ተቆጥሯል';
  }

  @override
  String packagesScannedCountPlural(int count) {
    return '$count ጥቅሎች ተቆጥረዋል';
  }

  @override
  String routesCompletedCount(int count) {
    return '$count መስመር ተጠናቋል';
  }

  @override
  String routesCompletedCountPlural(int count) {
    return '$count መስመሮች ተጠናቅቀዋል';
  }

  @override
  String get scans => 'ስካኖች';

  @override
  String get routesLabel => 'መስመሮች';

  @override
  String monthEarningsPaidOut(String month) {
    return 'የ$month ገቢ ይከፈሉ:';
  }

  @override
  String get packageScan => 'ጥቅል ስካን';

  @override
  String get routeMorningToSchool => 'ጧት → ት/ቤት';

  @override
  String get routeMiddayToHome => 'ቀኑ → ቤት';

  @override
  String get routeAfternoonToSchool => 'ከሰዓት → ት/ቤት';

  @override
  String get routeAfternoonToHome => 'ከሰዓት → ቤት';

  @override
  String get noPendingNominations => 'ምንም በጥበቃ ላይ ሹሙ የለም';

  @override
  String get noneYet => 'ምንም አልተሰጠም';

  @override
  String get loadingNominations => 'ሹሙ እየጫኑ...';

  @override
  String get nominationAccepted => 'ሹሙ ተቀቧ!';

  @override
  String get decline => 'አትቀበሉ';

  @override
  String get accept => 'ተቀበሉ';

  @override
  String pendingCount(int count) {
    return 'በጥበቃ ላይ ($count)';
  }

  @override
  String acceptedCount(int count) {
    return 'ተቀባይ ($count)';
  }

  @override
  String declinedCount(int count) {
    return 'ተቀባይነት የለም ($count)';
  }

  @override
  String get myGroups => 'ቡድኖቼ';

  @override
  String get noActiveGroupsYet => 'ምንም ንቁ ቡድኖች የሉም';

  @override
  String get acceptNominationToStart => 'ለመጀመር ሹሙ ይቀበሉ';

  @override
  String get viewNominations => 'ሹሙ ይመልከቱ';

  @override
  String get loadingGroups => 'ቡድኖች እየጫኑ...';

  @override
  String get accountSectionLabel => 'መለያ';

  @override
  String get earningsSectionLabel => 'ገቢዎች';

  @override
  String get settingsSectionLabel => 'ቅንብሮች';

  @override
  String get supportSectionLabel => 'ድጋፍ';

  @override
  String get firstName => 'ስም';

  @override
  String get lastName => 'ዝያ';

  @override
  String get emailOptional => 'ኢሜይል (አማራጭ)';

  @override
  String get addressOptional => 'አድራሻ (አማራጭ)';

  @override
  String get enterValidEmail => 'ትክክለኛ ኢሜይል ያስፈሩ';

  @override
  String get required => 'ያስፈልጋል';

  @override
  String get profileUpdated => 'ፕሮፋይሉ ዘምኗ!';

  @override
  String get saveChanges => 'ለውጦቹ ያስቀምጡ';

  @override
  String get personalInfoSection => 'ግላዊ መረጃ';

  @override
  String get contactSection => 'ግንኙነት';

  @override
  String get verifyOtpTitle => 'OTP አረጋግጡ';

  @override
  String get currentPassword => 'ወቅታዊ ይለፍ ቃል';

  @override
  String get currentPasswordSection => 'ወቅታዊ ይለፍ ቃል';

  @override
  String get newPasswordSection => 'አዲስ ይለፍ ቃል';

  @override
  String get confirmNewPassword => 'አዲስ ይለፍ ቃሉን ያረጋግጡ';

  @override
  String get changePasswordInfo =>
      'ወቅታዊ ይለፍ ቃልዎን ያስፈሩ እና አዲስ ይምረጡ። OTP ወደ ስልክዎ ይላካሉ።';

  @override
  String otpSentTo(String phone) {
    return 'OTP ወደ ስልክዎ ($phone) ተልኳል። ከዚህ በታች ያስፈሩ።';
  }

  @override
  String get verificationCodeSection => 'ማረጋገጫ ኮድ';

  @override
  String get newPasswordTooShort => 'አዲስ ይለፍ ቃሉ ቢያንስ 8 ፊደሎች ሊኖረው ይገባል';

  @override
  String get passwordChangedSuccessfully => 'ይለፍ ቃሉ ተቀይሯል!';

  @override
  String get resendOtp => 'OTP ዳግም ላክ';

  @override
  String get helpAndSupportTitle => 'እርዳታ እና ድጋፍ';

  @override
  String get ugoDriverSupport => 'UGO ሹፌር ድጋፍ';

  @override
  String get availableHours => '7 ቀናት፣ ከ6 ጥዋት – 8 ምሽቱ ይቻላሉ';

  @override
  String get faqSection => 'ተደጋጋሚ ጥያቄዎች';

  @override
  String get quickLinksSection => 'ፈጣን ሊንኮች';

  @override
  String get driverTerms => 'የሹፌር ውሎች';

  @override
  String get privacyPolicy => 'የምስጢርነት ፖሊሲ';

  @override
  String get emailSupport => 'ኢሜይል ድጋፍ';

  @override
  String get faq1q => 'እንዴት መስመር እጀምራለሁ?';

  @override
  String get faq1a =>
      'ወደ መስመሮች ትር ሂዱ እና ጀምር ይጫኑ። ከመጀመርዎ በፊት በጠፋ ቦታ ላይ መሆን አለብዎ።';

  @override
  String get faq2q => 'ተማሪ ሌለ ቢሆን ምን ማድረግ አለብኝ?';

  @override
  String get faq2a =>
      'መስመሩ ሲሄዱ፣ የተማሪው ስም ይጫኑ እና እንደ ሌለ ምልክት ያድርጉ። ወላጆች ወዲያ ያሳወቃቸዋሉ።';

  @override
  String get faq3q => 'ገቢዬ እንዴት ይሰላሉ?';

  @override
  String get faq3a =>
      'ገቢዎ በተጠናቀቁ ጉዞዎች እና ስምምነት ዋጋ ይሰላሉ። ሙሉ ዝርዝር ለማየት ፕሮፋይሉ ውስጥ ሂዱ።';

  @override
  String get faq4q => 'ተሽከርካሪዬ ቢበቃ ምን ማድረግ አለብኝ?';

  @override
  String get faq4a => 'ወዲያው UGO ድጋፍ ያናግሩ። ወደ ምልክቱ መስመሩን ያቁሙ።';

  @override
  String get faq5q => 'የተማሪ QR ኮድ እንዴት ስካን ማድረግ አለብኝ?';

  @override
  String get faq5a =>
      'ቤት ስክሪን ወይም መስመሮች ስክሪን ላይ ስካን አዶ ይጫኑ። ካሜራዉን ወደ ተማሪው QR ኮድ ይጠቁሙ።';

  @override
  String get faq6q => 'የቡድን ሹሙ መቃወም እቻሉ?';

  @override
  String get faq6a => 'አዎ። ሹሙ ትር ይክፈቱ፣ ቡድኑን ይምረጡ፣ እና አትቀበሉ ይጫኑ።';

  @override
  String get aboutUGODriverTitle => 'UGO ሹፌር ስለ';

  @override
  String get versionLabel => 'ስሪት 1.1.0';

  @override
  String get studentTransportPlatform => 'የተማሪ ትራንስፖርት ፕላትፎርም';

  @override
  String get aboutUGOTitle => 'UGO ስለ';

  @override
  String get aboutUGOContent =>
      'UGO ወላጆችን፣ ሹፌሮችን፣ እና ትምህርት ቤት አስተዳዳሪዎችን የሚያስተሳስር የተማሪ ትራንስፖርት አስተዳደር ፕላትፎርም ነው። ለኢትዮጵያ ቤተሰቦች ደህንነቱ የተጠበቀ፣ ሊከታተሉ የሚችሉ እና የተደራጀ ትምህርት ቤት ትራንስፖርት ያቀርባል።';

  @override
  String get driverMission => 'የሹፌር ተልዕኮ';

  @override
  String get driverMissionContent =>
      'የUGO ሹፌር ስለሆኑ ተማሪዎቹን በወቅቱ እና ሌሎ ማጓጓዝ ሃላፊነት አለብዎ። ትጋትዎ እና ሙያዊ አቀራረብ ቤተሰቦቹ ለUGO ያላቸው እምነት ቀጥታ ይነካዋሉ።';

  @override
  String get appInfoSection => 'የፕሮግራም ዝርዝሮች';

  @override
  String get appVersion => 'ስሪት';

  @override
  String get appPlatform => 'ፕላትፎርም';

  @override
  String get appDeveloper => 'ገንቢ';

  @override
  String get appContact => 'ግንኙነት';

  @override
  String get appCountry => 'አገር';

  @override
  String get copyright => '© 2025 UGO Technologies. ሁሉም መብቶች የተጠበቁ ናቸው።';
}
