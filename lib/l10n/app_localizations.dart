import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'BankID App'**
  String get appTitle;

  /// No description provided for @splashScreenLogo.
  ///
  /// In en, this message translates to:
  /// **'Logo'**
  String get splashScreenLogo;

  /// No description provided for @languageSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get languageSelectionTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Title for onboarding screen 1
  ///
  /// In en, this message translates to:
  /// **'Your digital identity is secure'**
  String get onboardingTitle1;

  /// Description for onboarding screen 1
  ///
  /// In en, this message translates to:
  /// **'Easily verify your personal identity and get comprehensive protection for all your data.'**
  String get onboardingDesc1;

  /// Title for onboarding screen 2
  ///
  /// In en, this message translates to:
  /// **'Sign with a single touch'**
  String get onboardingTitle2;

  /// Description for onboarding screen 2
  ///
  /// In en, this message translates to:
  /// **'Quickly sign your documents digitally with just a single touch on your screen.'**
  String get onboardingDesc2;

  /// Title for onboarding screen 3
  ///
  /// In en, this message translates to:
  /// **'Easy, secure payment'**
  String get onboardingTitle3;

  /// Description for onboarding screen 3
  ///
  /// In en, this message translates to:
  /// **'Enjoy fast electronic payments with high security and ease of use.'**
  String get onboardingDesc3;

  /// Text for the 'Get started now' button
  ///
  /// In en, this message translates to:
  /// **'Get started now'**
  String get getStartedButton;

  /// No description provided for @addNewSignature.
  ///
  /// In en, this message translates to:
  /// **'Add New Signature'**
  String get addNewSignature;

  /// No description provided for @signatureName.
  ///
  /// In en, this message translates to:
  /// **'Signature Name'**
  String get signatureName;

  /// No description provided for @enterNameHere.
  ///
  /// In en, this message translates to:
  /// **'Enter name here'**
  String get enterNameHere;

  /// No description provided for @uploadSignatureFile.
  ///
  /// In en, this message translates to:
  /// **'Upload Signature File'**
  String get uploadSignatureFile;

  /// No description provided for @uploadImages.
  ///
  /// In en, this message translates to:
  /// **'Upload Images'**
  String get uploadImages;

  /// No description provided for @deleteImage.
  ///
  /// In en, this message translates to:
  /// **'Delete Image'**
  String get deleteImage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @saveSignature.
  ///
  /// In en, this message translates to:
  /// **'Save Signature'**
  String get saveSignature;

  /// No description provided for @verifiedAccount.
  ///
  /// In en, this message translates to:
  /// **'Verified Account'**
  String get verifiedAccount;

  /// No description provided for @uploadedDocumentsAndFiles.
  ///
  /// In en, this message translates to:
  /// **'Uploaded Documents and Files'**
  String get uploadedDocumentsAndFiles;

  /// No description provided for @scanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR Code'**
  String get scanQrCode;

  /// No description provided for @keepYourDigitalIdentitySecure.
  ///
  /// In en, this message translates to:
  /// **'Keep your digital identity secure. Do not share it or use it at someone else\'s request.'**
  String get keepYourDigitalIdentitySecure;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @idCard.
  ///
  /// In en, this message translates to:
  /// **'ID Card'**
  String get idCard;

  /// No description provided for @idCardViewerTitle.
  ///
  /// In en, this message translates to:
  /// **'ID Card Viewer'**
  String get idCardViewerTitle;

  /// No description provided for @idCardScanUsingDigitalIdApp.
  ///
  /// In en, this message translates to:
  /// **'Scan using Digital ID App'**
  String get idCardScanUsingDigitalIdApp;

  /// No description provided for @idCardQrData.
  ///
  /// In en, this message translates to:
  /// **'https://www.bankid.com/qr-data'**
  String get idCardQrData;

  /// No description provided for @idCardShareViaQrCode.
  ///
  /// In en, this message translates to:
  /// **'Share via QR Code'**
  String get idCardShareViaQrCode;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @setupPasscode.
  ///
  /// In en, this message translates to:
  /// **'Setup the passcode'**
  String get setupPasscode;

  /// No description provided for @createPinDescription.
  ///
  /// In en, this message translates to:
  /// **'Create your 6-digit PIN to protect your personal data'**
  String get createPinDescription;

  /// No description provided for @passcode.
  ///
  /// In en, this message translates to:
  /// **'Passcode'**
  String get passcode;

  /// No description provided for @setPasscode.
  ///
  /// In en, this message translates to:
  /// **'Set passcode'**
  String get setPasscode;

  /// No description provided for @accountFullName.
  ///
  /// In en, this message translates to:
  /// **'Ayham Mahmoud Azeemah'**
  String get accountFullName;

  /// No description provided for @accountPersonalId.
  ///
  /// In en, this message translates to:
  /// **'711025–1357'**
  String get accountPersonalId;

  /// No description provided for @accountPhoneNumberActual.
  ///
  /// In en, this message translates to:
  /// **'+999 999 999 999'**
  String get accountPhoneNumberActual;

  /// No description provided for @accountGenderActual.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get accountGenderActual;

  /// No description provided for @accountDateOfBirthActual.
  ///
  /// In en, this message translates to:
  /// **'10/25/1971'**
  String get accountDateOfBirthActual;

  /// No description provided for @accountNationalityActual.
  ///
  /// In en, this message translates to:
  /// **'British'**
  String get accountNationalityActual;

  /// No description provided for @accountNationalIdNumberActual.
  ///
  /// In en, this message translates to:
  /// **'71105350328'**
  String get accountNationalIdNumberActual;

  /// No description provided for @accountDateOfIssueActual.
  ///
  /// In en, this message translates to:
  /// **'01/19/2022'**
  String get accountDateOfIssueActual;

  /// No description provided for @accountDateOfExpirationActual.
  ///
  /// In en, this message translates to:
  /// **'01/19/2027'**
  String get accountDateOfExpirationActual;

  /// No description provided for @accountIDCardImageTitle.
  ///
  /// In en, this message translates to:
  /// **'ID Card Image'**
  String get accountIDCardImageTitle;

  /// No description provided for @accountIDCardImageDescription.
  ///
  /// In en, this message translates to:
  /// **'Image389074292303.JPEG'**
  String get accountIDCardImageDescription;

  /// No description provided for @nationalIdScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with your National ID number.'**
  String get nationalIdScreenTitle;

  /// No description provided for @nationalIdNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'National ID Number'**
  String get nationalIdNumberLabel;

  /// No description provided for @nationalIdNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 9-digits number'**
  String get nationalIdNumberHint;

  /// No description provided for @yourPhoneNumbersTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Phone numbers'**
  String get yourPhoneNumbersTitle;

  /// No description provided for @yourPhoneNumbersDescription.
  ///
  /// In en, this message translates to:
  /// **'We found these numbers on your National ID. Pick one to start with it.'**
  String get yourPhoneNumbersDescription;

  /// No description provided for @pickNumberButton.
  ///
  /// In en, this message translates to:
  /// **'Pick number'**
  String get pickNumberButton;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @editSignature.
  ///
  /// In en, this message translates to:
  /// **'Edit Signature'**
  String get editSignature;

  /// No description provided for @deleteSignature.
  ///
  /// In en, this message translates to:
  /// **'Delete Signature'**
  String get deleteSignature;

  /// No description provided for @areYouSureYouWantToDeleteSignature.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete Signature Number {number}?'**
  String areYouSureYouWantToDeleteSignature(
    Object number,
    Object signatureNumber,
  );

  /// No description provided for @digitalSignatures.
  ///
  /// In en, this message translates to:
  /// **'Digital Signatures'**
  String get digitalSignatures;

  /// No description provided for @fileAddedOn.
  ///
  /// In en, this message translates to:
  /// **'File added on '**
  String get fileAddedOn;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Account Deletion'**
  String get deleteAccountConfirmationTitle;

  /// No description provided for @deleteAccountConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountConfirmationMessage;

  /// No description provided for @enterPinToDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Enter your 6-digit PIN to confirm account deletion.'**
  String get enterPinToDeleteAccount;

  /// No description provided for @sixDigitPin.
  ///
  /// In en, this message translates to:
  /// **'6-digit PIN'**
  String get sixDigitPin;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @pleaseEnterSixDigitPin.
  ///
  /// In en, this message translates to:
  /// **'Please enter a 6-digit PIN.'**
  String get pleaseEnterSixDigitPin;

  /// No description provided for @accountDeletionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully.'**
  String get accountDeletionSuccess;

  /// No description provided for @aboutAppTitle.
  ///
  /// In en, this message translates to:
  /// **'About the App'**
  String get aboutAppTitle;

  /// No description provided for @aboutAppDescription1.
  ///
  /// In en, this message translates to:
  /// **'Our app is your ideal digital identity that simplifies payment and electronic signature processes. The app allows you to carry out financial transactions easily and securely, saving you time and effort. With its modern interface, you can manage your payments and sign documents anywhere, anytime. We are committed to providing a seamless user experience, where you can easily access all features. We continuously develop the app, listening to your feedback to improve performance and add new features that meet your needs. Join us today and enjoy a comprehensive digital experience that simplifies your life!'**
  String get aboutAppDescription1;

  /// No description provided for @aboutAppDescription2.
  ///
  /// In en, this message translates to:
  /// **'We believe that technology should be accessible to everyone, so we designed the app to be user-friendly, even for new users. Additionally, the app offers multiple payment options, allowing you to choose the method that suits you best. Whether you prefer to pay via credit cards, digital wallets, or even bank transfers, we cover all options.'**
  String get aboutAppDescription2;

  /// No description provided for @aboutAppDescription3.
  ///
  /// In en, this message translates to:
  /// **'We also work to enhance the security of your data through advanced encryption technologies, ensuring that your personal and financial information is fully protected. We understand that security is a top priority, so we are committed to providing a safe environment for all our users.'**
  String get aboutAppDescription3;

  /// No description provided for @aboutAppVersion.
  ///
  /// In en, this message translates to:
  /// **'V 1.0'**
  String get aboutAppVersion;

  /// No description provided for @accountVerifiedAccount.
  ///
  /// In en, this message translates to:
  /// **'Verified Account'**
  String get accountVerifiedAccount;

  /// No description provided for @accountNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Not Verified'**
  String get accountNotVerified;

  /// No description provided for @accountPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get accountPhoneNumber;

  /// No description provided for @accountPhoneNumberValue.
  ///
  /// In en, this message translates to:
  /// **'+999 999 999 999'**
  String get accountPhoneNumberValue;

  /// No description provided for @accountGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get accountGender;

  /// No description provided for @accountMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get accountMale;

  /// No description provided for @accountDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get accountDateOfBirth;

  /// No description provided for @accountDateOfBirthValue.
  ///
  /// In en, this message translates to:
  /// **'10/25/1971'**
  String get accountDateOfBirthValue;

  /// No description provided for @accountNationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get accountNationality;

  /// No description provided for @accountBritish.
  ///
  /// In en, this message translates to:
  /// **'British'**
  String get accountBritish;

  /// No description provided for @accountNationalIdNumber.
  ///
  /// In en, this message translates to:
  /// **'National ID Number'**
  String get accountNationalIdNumber;

  /// No description provided for @accountNationalIdNumberValue.
  ///
  /// In en, this message translates to:
  /// **'71105350328'**
  String get accountNationalIdNumberValue;

  /// No description provided for @accountDateOfIssue.
  ///
  /// In en, this message translates to:
  /// **'Date of Issue'**
  String get accountDateOfIssue;

  /// No description provided for @accountDateOfIssueValue.
  ///
  /// In en, this message translates to:
  /// **'01/19/2022'**
  String get accountDateOfIssueValue;

  /// No description provided for @accountDateOfExpiration.
  ///
  /// In en, this message translates to:
  /// **'Date of Expiration'**
  String get accountDateOfExpiration;

  /// No description provided for @accountDateOfExpirationValue.
  ///
  /// In en, this message translates to:
  /// **'01/19/2027'**
  String get accountDateOfExpirationValue;

  /// No description provided for @accountIDCardImage.
  ///
  /// In en, this message translates to:
  /// **'ID Card Image'**
  String get accountIDCardImage;

  /// No description provided for @accountIDCardImageValue.
  ///
  /// In en, this message translates to:
  /// **'Image389074292303.JPEG'**
  String get accountIDCardImageValue;

  /// No description provided for @appProtectionScanFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Scan your fingerprint to authenticate'**
  String get appProtectionScanFingerprint;

  /// No description provided for @appProtectionActivateProtection.
  ///
  /// In en, this message translates to:
  /// **'Activate app protection'**
  String get appProtectionActivateProtection;

  /// No description provided for @appProtectionChooseOption.
  ///
  /// In en, this message translates to:
  /// **'Choose the option to secure your login using the app ID'**
  String get appProtectionChooseOption;

  /// No description provided for @appProtectionUseBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics'**
  String get appProtectionUseBiometrics;

  /// No description provided for @appProtectionUseSecureWay.
  ///
  /// In en, this message translates to:
  /// **'Use the ID APP in the most secure way'**
  String get appProtectionUseSecureWay;

  /// No description provided for @appProtectionSetUpPasscode.
  ///
  /// In en, this message translates to:
  /// **'Set up a passcode'**
  String get appProtectionSetUpPasscode;

  /// No description provided for @appProtectionCreatePin.
  ///
  /// In en, this message translates to:
  /// **'Create your 6-digit PIN to protect your personal data'**
  String get appProtectionCreatePin;

  /// No description provided for @appProtectionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get appProtectionContinue;

  /// No description provided for @appProtectionRecommended.
  ///
  /// In en, this message translates to:
  /// **'RECOMMENDED'**
  String get appProtectionRecommended;

  /// No description provided for @checkInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your information.'**
  String get checkInformationTitle;

  /// No description provided for @checkInformationFirstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get checkInformationFirstName;

  /// No description provided for @checkInformationFirstNameValue.
  ///
  /// In en, this message translates to:
  /// **'AYHAM'**
  String get checkInformationFirstNameValue;

  /// No description provided for @checkInformationLastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get checkInformationLastName;

  /// No description provided for @checkInformationLastNameValue.
  ///
  /// In en, this message translates to:
  /// **'AZEEMAH'**
  String get checkInformationLastNameValue;

  /// No description provided for @checkInformationGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get checkInformationGender;

  /// No description provided for @checkInformationGenderValue.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get checkInformationGenderValue;

  /// No description provided for @checkInformationDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get checkInformationDateOfBirth;

  /// No description provided for @checkInformationDateOfBirthValue.
  ///
  /// In en, this message translates to:
  /// **'25/10/1971'**
  String get checkInformationDateOfBirthValue;

  /// No description provided for @checkInformationNationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get checkInformationNationality;

  /// No description provided for @checkInformationNationalityValue.
  ///
  /// In en, this message translates to:
  /// **'British'**
  String get checkInformationNationalityValue;

  /// No description provided for @checkInformationNationalIdNumber.
  ///
  /// In en, this message translates to:
  /// **'National ID number'**
  String get checkInformationNationalIdNumber;

  /// No description provided for @checkInformationNationalIdNumberValue.
  ///
  /// In en, this message translates to:
  /// **'71105350328'**
  String get checkInformationNationalIdNumberValue;

  /// No description provided for @checkInformationDateOfIssue.
  ///
  /// In en, this message translates to:
  /// **'Date of Issue'**
  String get checkInformationDateOfIssue;

  /// No description provided for @checkInformationDateOfIssueValue.
  ///
  /// In en, this message translates to:
  /// **'19/01/2022'**
  String get checkInformationDateOfIssueValue;

  /// No description provided for @checkInformationDateOfExpiry.
  ///
  /// In en, this message translates to:
  /// **'Date of expiry'**
  String get checkInformationDateOfExpiry;

  /// No description provided for @checkInformationDateOfExpiryValue.
  ///
  /// In en, this message translates to:
  /// **'19/01/2027'**
  String get checkInformationDateOfExpiryValue;

  /// No description provided for @checkInformationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get checkInformationConfirm;

  /// No description provided for @twoFactorAuthenticationTitle.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twoFactorAuthenticationTitle;

  /// No description provided for @enterConfirmationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Confirmation Code'**
  String get enterConfirmationCode;

  /// No description provided for @confirmationCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit code sent to your registered email address.'**
  String get confirmationCodeDescription;

  /// No description provided for @codeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get codeLabel;

  /// No description provided for @codeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get codeHint;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @twoFactorAuthSetupAuthenticatorApp.
  ///
  /// In en, this message translates to:
  /// **'Set up your authenticator app'**
  String get twoFactorAuthSetupAuthenticatorApp;

  /// No description provided for @twoFactorAuthScanQrDescription.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code below in your authenticator app and you’re all set! (If you haven’t installed an authenticator app yet.)'**
  String get twoFactorAuthScanQrDescription;

  /// No description provided for @twoFactorAuthIssuer.
  ///
  /// In en, this message translates to:
  /// **'Issuer'**
  String get twoFactorAuthIssuer;

  /// No description provided for @twoFactorAuthAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get twoFactorAuthAccount;

  /// No description provided for @twoFactorAuthSecretKey.
  ///
  /// In en, this message translates to:
  /// **'Secret Key'**
  String get twoFactorAuthSecretKey;

  /// No description provided for @confirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmButton;

  /// No description provided for @saveOneTimeRecoveryCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Save this one-time recovery code'**
  String get saveOneTimeRecoveryCodeTitle;

  /// No description provided for @oneTimeRecoveryCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'If you lose access to your email there\'s a possibility you could get locked out of your account. Save this code in a safe place to use if you can\'t log in with your email.'**
  String get oneTimeRecoveryCodeDescription;

  /// No description provided for @twoFactorAuthDescription.
  ///
  /// In en, this message translates to:
  /// **'Protect your account with an extra layer of security.'**
  String get twoFactorAuthDescription;

  /// No description provided for @twoFactorAuthExplanation.
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication adds an extra layer of security to your account by requiring a second form of verification in addition to your password.'**
  String get twoFactorAuthExplanation;

  /// No description provided for @enableTwoFactorAuthButton.
  ///
  /// In en, this message translates to:
  /// **'Enable Two-Factor Authentication'**
  String get enableTwoFactorAuthButton;

  /// No description provided for @setUpAuthenticatorAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your authenticator app'**
  String get setUpAuthenticatorAppTitle;

  /// No description provided for @setUpAuthenticatorAppDescription.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code below in your authenticator app and you’re all set! (If you haven’t installed an authenticator app yet.)'**
  String get setUpAuthenticatorAppDescription;

  /// No description provided for @authenticatorDetails.
  ///
  /// In en, this message translates to:
  /// **'To set up your authenticator app, scan the QR code or manually enter the following details:\n\nIssuer: {issuer}\nAccount: {accountEmail}\nSecret Key: {secretKey}'**
  String authenticatorDetails(
    Object issuer,
    Object accountEmail,
    Object secretKey,
  );

  /// No description provided for @contractScreenNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name:'**
  String get contractScreenNameLabel;

  /// No description provided for @contractScreenIdPassportNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'ID/Passport Number:'**
  String get contractScreenIdPassportNumberLabel;

  /// No description provided for @contractScreenAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address:'**
  String get contractScreenAddressLabel;

  /// No description provided for @contractScreenPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone:'**
  String get contractScreenPhoneLabel;

  /// No description provided for @contractScreenEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email:'**
  String get contractScreenEmailLabel;

  /// No description provided for @contractScreenPartyOneNameValue.
  ///
  /// In en, this message translates to:
  /// **'Ahmad Khaled Mustafa'**
  String get contractScreenPartyOneNameValue;

  /// No description provided for @contractScreenPartyOneIdPassportNumberValue.
  ///
  /// In en, this message translates to:
  /// **'SY24567891'**
  String get contractScreenPartyOneIdPassportNumberValue;

  /// No description provided for @contractScreenPartyOneAddressValue.
  ///
  /// In en, this message translates to:
  /// **'Damascus – Dummar Project – Al-Yarmouk Street – Building No. 12'**
  String get contractScreenPartyOneAddressValue;

  /// No description provided for @contractScreenPartyOnePhoneValue.
  ///
  /// In en, this message translates to:
  /// **'+963 944 321 567'**
  String get contractScreenPartyOnePhoneValue;

  /// No description provided for @contractScreenPartyOneEmailValue.
  ///
  /// In en, this message translates to:
  /// **'ahmad.mustafa@example.com'**
  String get contractScreenPartyOneEmailValue;

  /// No description provided for @contractScreenPartyTwoTitle.
  ///
  /// In en, this message translates to:
  /// **'Party Two:'**
  String get contractScreenPartyTwoTitle;

  /// No description provided for @contractScreenPartyTwoNameValue.
  ///
  /// In en, this message translates to:
  /// **'Al-Noor Modern Technologies Company (represented by Mr. Samer Abdullah)'**
  String get contractScreenPartyTwoNameValue;

  /// No description provided for @contractScreenCommercialRegistrationLabel.
  ///
  /// In en, this message translates to:
  /// **'Commercial Registration:'**
  String get contractScreenCommercialRegistrationLabel;

  /// No description provided for @contractScreenPartyTwoCommercialRegistrationValue.
  ///
  /// In en, this message translates to:
  /// **'102547 – Damascus'**
  String get contractScreenPartyTwoCommercialRegistrationValue;

  /// No description provided for @contractScreenPartyTwoAddressValue.
  ///
  /// In en, this message translates to:
  /// **'Damascus – Abu Rummaneh – Al-Jalaa Street – Building No. 8'**
  String get contractScreenPartyTwoAddressValue;

  /// No description provided for @contractScreenPartyTwoPhoneValue.
  ///
  /// In en, this message translates to:
  /// **'+963 944 654 789'**
  String get contractScreenPartyTwoPhoneValue;

  /// No description provided for @contractScreenPartyTwoEmailValue.
  ///
  /// In en, this message translates to:
  /// **'info@alnoortech.com'**
  String get contractScreenPartyTwoEmailValue;

  /// No description provided for @contractScreenIntroductionTitle.
  ///
  /// In en, this message translates to:
  /// **'Contract Introduction:'**
  String get contractScreenIntroductionTitle;

  /// No description provided for @contractScreenIntroductionDescription.
  ///
  /// In en, this message translates to:
  /// **'Whereas Party One wishes to design and develop a mobile application for managing bookings, and whereas Party Two has the necessary expertise to implement this project, the parties have agreed as follows:'**
  String get contractScreenIntroductionDescription;

  /// No description provided for @contractScreenArticleOneTitle.
  ///
  /// In en, this message translates to:
  /// **'Article One – Subject of the Contract:'**
  String get contractScreenArticleOneTitle;

  /// No description provided for @contractScreenArticleOneDescription.
  ///
  /// In en, this message translates to:
  /// **'Party Two (Al-Noor Modern Technologies) undertakes to design and develop a mobile application that works on both Android and iOS systems, dedicated to managing and booking appointments, according to the specifications agreed upon with Party One.'**
  String get contractScreenArticleOneDescription;

  /// No description provided for @contractScreenArticleTwoTitle.
  ///
  /// In en, this message translates to:
  /// **'Article Two – Duration of the Contract:'**
  String get contractScreenArticleTwoTitle;

  /// No description provided for @contractScreenArticleTwoDescription.
  ///
  /// In en, this message translates to:
  /// **'The duration of the contract starts from 15/08/2025 for a period of three months, renewable with the written consent of both parties.'**
  String get contractScreenArticleTwoDescription;

  /// No description provided for @contractScreenArticleThreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Article Three – Financial Compensation:'**
  String get contractScreenArticleThreeTitle;

  /// No description provided for @contractScreenArticleThreeDescription.
  ///
  /// In en, this message translates to:
  /// **'Party One commits to pay an amount of 4,500 US dollars, to be paid as follows: First payment: 2,000 dollars upon signing the contract. Final payment: 2,500 dollars upon final delivery of the project.'**
  String get contractScreenArticleThreeDescription;

  /// No description provided for @contractScreenArticleFourTitle.
  ///
  /// In en, this message translates to:
  /// **'Article Four – Rights and Obligations of the Parties:'**
  String get contractScreenArticleFourTitle;

  /// No description provided for @contractScreenArticleFourDescription.
  ///
  /// In en, this message translates to:
  /// **'Party Two is committed to delivering the project within the specified time and according to technical standards. Party One is committed to providing all necessary information and materials for design and development in a timely manner.'**
  String get contractScreenArticleFourDescription;

  /// No description provided for @contractScreenArticleFiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Article Five – Termination:'**
  String get contractScreenArticleFiveTitle;

  /// No description provided for @contractScreenArticleFiveDescription.
  ///
  /// In en, this message translates to:
  /// **'Either party may terminate the contract with written notice at least 15 days in advance, with payment of the financial dues to the other party according to the work completed.'**
  String get contractScreenArticleFiveDescription;

  /// No description provided for @contractScreenArticleSixTitle.
  ///
  /// In en, this message translates to:
  /// **'Article Six – Governing Law:'**
  String get contractScreenArticleSixTitle;

  /// No description provided for @contractScreenArticleSixDescription.
  ///
  /// In en, this message translates to:
  /// **'This contract is subject to the laws and regulations of the Syrian Arab Republic, and any dispute shall be resolved amicably, and if that is not possible, it shall be referred to the Civil Court of Damascus.'**
  String get contractScreenArticleSixDescription;

  /// No description provided for @contractScreenSignaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Signatures:'**
  String get contractScreenSignaturesTitle;

  /// No description provided for @contractScreenSignatureLabel.
  ///
  /// In en, this message translates to:
  /// **'Signature:'**
  String get contractScreenSignatureLabel;

  /// No description provided for @contractScreenSignatureValue.
  ///
  /// In en, this message translates to:
  /// **'___________'**
  String get contractScreenSignatureValue;

  /// No description provided for @contractScreenDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date:'**
  String get contractScreenDateLabel;

  /// No description provided for @contractScreenDateValue.
  ///
  /// In en, this message translates to:
  /// **'15/08/2025'**
  String get contractScreenDateValue;

  /// No description provided for @contractScreenPartyTwoSignatureValue.
  ///
  /// In en, this message translates to:
  /// **'Al-Noor Modern Technologies – Representative: Samer Abdullah'**
  String get contractScreenPartyTwoSignatureValue;

  /// No description provided for @contractScreenSignContractButton.
  ///
  /// In en, this message translates to:
  /// **'Sign the contract'**
  String get contractScreenSignContractButton;

  /// No description provided for @contractScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign a contract'**
  String get contractScreenTitle;

  /// No description provided for @contractScreenPartyOneTitle.
  ///
  /// In en, this message translates to:
  /// **'Party One:'**
  String get contractScreenPartyOneTitle;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account.'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? You must enter your password to confirm.'**
  String get deleteAccountDescription;

  /// No description provided for @deleteAccountPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get deleteAccountPasswordLabel;

  /// No description provided for @deleteAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAccountButton;

  /// No description provided for @fileAddedOnLabel.
  ///
  /// In en, this message translates to:
  /// **'File added on'**
  String get fileAddedOnLabel;

  /// No description provided for @digitalSignaturesListTitle.
  ///
  /// In en, this message translates to:
  /// **'Digital Signatures'**
  String get digitalSignaturesListTitle;

  /// No description provided for @digitalSignatureNumber.
  ///
  /// In en, this message translates to:
  /// **'Digital Signature Number {number}'**
  String digitalSignatureNumber(Object number);

  /// No description provided for @addNewSignatureButton.
  ///
  /// In en, this message translates to:
  /// **'Add New Signature'**
  String get addNewSignatureButton;

  /// No description provided for @editPhoneNumberTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Phone Number'**
  String get editPhoneNumberTitle;

  /// No description provided for @editPhoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get editPhoneNumberLabel;

  /// No description provided for @editPhoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'+999 999 999 999'**
  String get editPhoneNumberHint;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @twoFactorAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twoFactorAuthTitle;

  /// No description provided for @authenticatorAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Authenticator App'**
  String get authenticatorAppTitle;

  /// No description provided for @authenticatorAppDescription.
  ///
  /// In en, this message translates to:
  /// **'Use an authenticator app to generate a one-time code.'**
  String get authenticatorAppDescription;

  /// No description provided for @emailOptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailOptionTitle;

  /// No description provided for @emailOptionDescription.
  ///
  /// In en, this message translates to:
  /// **'Receive an email with one-time code.'**
  String get emailOptionDescription;

  /// No description provided for @setupAuthenticatorAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your authenticator app'**
  String get setupAuthenticatorAppTitle;

  /// No description provided for @setupAuthenticatorAppDescription.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code below in your authenticator app and you’re all set! (If you haven’t installed an authenticator app yet.)'**
  String get setupAuthenticatorAppDescription;

  /// No description provided for @issuerLabel.
  ///
  /// In en, this message translates to:
  /// **'Issuer: '**
  String get issuerLabel;

  /// No description provided for @accountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account: '**
  String get accountLabel;

  /// No description provided for @secretKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Secret Key: '**
  String get secretKeyLabel;

  /// No description provided for @noInternetConnectionTitle.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnectionTitle;

  /// No description provided for @noInternetConnectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get noInternetConnectionDescription;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @noResultsFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFoundTitle;

  /// No description provided for @noResultsFoundDescription.
  ///
  /// In en, this message translates to:
  /// **'No results found for \"{searchQuery}\". Please try another search.'**
  String noResultsFoundDescription(Object searchQuery);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchHint;

  /// No description provided for @historyItemSeb.
  ///
  /// In en, this message translates to:
  /// **'SEB'**
  String get historyItemSeb;

  /// No description provided for @historyItemIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get historyItemIdentity;

  /// No description provided for @historyItemSignature.
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get historyItemSignature;

  /// No description provided for @historyItemSwishAtSeb.
  ///
  /// In en, this message translates to:
  /// **'Swish at SEB'**
  String get historyItemSwishAtSeb;

  /// No description provided for @historyItemMinimumApplicationDate.
  ///
  /// In en, this message translates to:
  /// **'Minimum application - date'**
  String get historyItemMinimumApplicationDate;

  /// No description provided for @historyItemApplicationIdKort.
  ///
  /// In en, this message translates to:
  /// **'Application ID-Kort'**
  String get historyItemApplicationIdKort;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'Ayham Mahmoud Azeemah'**
  String get userName;

  /// No description provided for @homeScreenUserName.
  ///
  /// In en, this message translates to:
  /// **'Ayham Mahmoud Azeemah'**
  String get homeScreenUserName;

  /// No description provided for @homeScreenUserNationalId.
  ///
  /// In en, this message translates to:
  /// **'711025-1357'**
  String get homeScreenUserNationalId;

  /// No description provided for @homeScreenVerifiedAccount.
  ///
  /// In en, this message translates to:
  /// **'Verified Account'**
  String get homeScreenVerifiedAccount;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Verification code.'**
  String get enterVerificationCode;

  /// No description provided for @verificationCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Verification code has been sent to '**
  String get verificationCodeSentTo;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get verificationCode;

  /// No description provided for @resendSmsWithin.
  ///
  /// In en, this message translates to:
  /// **'You can resend the SMS within'**
  String get resendSmsWithin;

  /// No description provided for @retryVerification.
  ///
  /// In en, this message translates to:
  /// **'Retry Verification'**
  String get retryVerification;

  /// No description provided for @letsCreateYourIdAppIdentity.
  ///
  /// In en, this message translates to:
  /// **'Let\'s create your ID App identity.'**
  String get letsCreateYourIdAppIdentity;

  /// No description provided for @performingThisProcess.
  ///
  /// In en, this message translates to:
  /// **'Performing this process '**
  String get performingThisProcess;

  /// No description provided for @forFunOrAsATest.
  ///
  /// In en, this message translates to:
  /// **'for fun or as a test'**
  String get forFunOrAsATest;

  /// No description provided for @mayResultInPermanentBlock.
  ///
  /// In en, this message translates to:
  /// **'may result in you being permanently blocked and can prohibit you from using ID App.'**
  String get mayResultInPermanentBlock;

  /// No description provided for @followTheseSteps.
  ///
  /// In en, this message translates to:
  /// **'Follow these steps'**
  String get followTheseSteps;

  /// No description provided for @takeASelfieVideo.
  ///
  /// In en, this message translates to:
  /// **'Take a selfie video.'**
  String get takeASelfieVideo;

  /// No description provided for @takeAPhotoOfYourNationalIdCard.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of your National ID card'**
  String get takeAPhotoOfYourNationalIdCard;

  /// No description provided for @startEnrollment.
  ///
  /// In en, this message translates to:
  /// **'Start Enrollment'**
  String get startEnrollment;

  /// No description provided for @onTheNextScreenFollowInstructions.
  ///
  /// In en, this message translates to:
  /// **'On the next screen, follow the instructions to record a selfie.'**
  String get onTheNextScreenFollowInstructions;

  /// No description provided for @pleaseNoteSurroundingsVisible.
  ///
  /// In en, this message translates to:
  /// **'Please note that your surroundings will be visible while taking the selfie'**
  String get pleaseNoteSurroundingsVisible;

  /// No description provided for @tryMovingToBetterLighting.
  ///
  /// In en, this message translates to:
  /// **'Try moving to an area with better lighting and remove your glasses or anything else covering your face'**
  String get tryMovingToBetterLighting;

  /// No description provided for @takeASelfie.
  ///
  /// In en, this message translates to:
  /// **'Take a selfie'**
  String get takeASelfie;

  /// No description provided for @takeAPictureOfYourNationalIdCard.
  ///
  /// In en, this message translates to:
  /// **'Take a picture of your National ID card.'**
  String get takeAPictureOfYourNationalIdCard;

  /// No description provided for @pleaseEnsure.
  ///
  /// In en, this message translates to:
  /// **'Please Ensure:'**
  String get pleaseEnsure;

  /// No description provided for @usingCorrectNationalIdCard.
  ///
  /// In en, this message translates to:
  /// **'You are using the correct National ID Card'**
  String get usingCorrectNationalIdCard;

  /// No description provided for @nationalIdCardWithinScanningFrame.
  ///
  /// In en, this message translates to:
  /// **'The National ID Card is within the scanning frame and is fully visible'**
  String get nationalIdCardWithinScanningFrame;

  /// No description provided for @fingersDontCoverNationalId.
  ///
  /// In en, this message translates to:
  /// **'Your Fingers don’t cover any part of the National ID'**
  String get fingersDontCoverNationalId;

  /// No description provided for @imageClearWithoutGlare.
  ///
  /// In en, this message translates to:
  /// **'The image is clear without any glare or shadows'**
  String get imageClearWithoutGlare;

  /// No description provided for @takeAPicture.
  ///
  /// In en, this message translates to:
  /// **'Take a Picture'**
  String get takeAPicture;

  /// No description provided for @signAContract.
  ///
  /// In en, this message translates to:
  /// **'Sign a contract'**
  String get signAContract;

  /// No description provided for @youCanSignAContractFromHere.
  ///
  /// In en, this message translates to:
  /// **'You can sign a contract from here'**
  String get youCanSignAContractFromHere;

  /// No description provided for @scanTheQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR Code'**
  String get scanTheQrCode;

  /// No description provided for @keepDigitalIdentitySecure.
  ///
  /// In en, this message translates to:
  /// **'Keep your digital identity secure. Do not share it or use it at someone else\'s request.'**
  String get keepDigitalIdentitySecure;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @identity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get identity;

  /// No description provided for @signature.
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get signature;

  /// No description provided for @codeCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get codeCopiedToClipboard;

  /// No description provided for @copyCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Copy Code'**
  String get copyCodeButton;

  /// No description provided for @doneButton.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneButton;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyDescription.
  ///
  /// In en, this message translates to:
  /// **'This is the privacy policy description.'**
  String get privacyPolicyDescription;

  /// No description provided for @privacyPolicyInfoCollectTitle.
  ///
  /// In en, this message translates to:
  /// **'Information Collection'**
  String get privacyPolicyInfoCollectTitle;

  /// No description provided for @privacyPolicyInfoCollectDescription.
  ///
  /// In en, this message translates to:
  /// **'We collect various types of information when you use our app.'**
  String get privacyPolicyInfoCollectDescription;

  /// No description provided for @privacyPolicyHowToUseTitle.
  ///
  /// In en, this message translates to:
  /// **'How We Use Your Information'**
  String get privacyPolicyHowToUseTitle;

  /// No description provided for @privacyPolicyHowToUseDescription.
  ///
  /// In en, this message translates to:
  /// **'Your information is used to provide and improve our services.'**
  String get privacyPolicyHowToUseDescription;

  /// No description provided for @privacyPolicyInfoProtectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Information Protection'**
  String get privacyPolicyInfoProtectionTitle;

  /// No description provided for @privacyPolicyInfoProtectionDescription.
  ///
  /// In en, this message translates to:
  /// **'We implement a variety of security measures to maintain the safety of your personal information.'**
  String get privacyPolicyInfoProtectionDescription;

  /// No description provided for @privacyPolicyYourRightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Rights'**
  String get privacyPolicyYourRightsTitle;

  /// No description provided for @privacyPolicyYourRightsDescription.
  ///
  /// In en, this message translates to:
  /// **'You have the right to access, correct, or delete your personal data.'**
  String get privacyPolicyYourRightsDescription;

  /// No description provided for @authenticateReason.
  ///
  /// In en, this message translates to:
  /// **'Scan your fingerprint (or face or other biometric) to authenticate'**
  String get authenticateReason;

  /// No description provided for @authenticationError.
  ///
  /// In en, this message translates to:
  /// **'Error - '**
  String get authenticationError;

  /// No description provided for @authorizedStatus.
  ///
  /// In en, this message translates to:
  /// **'Authorized'**
  String get authorizedStatus;

  /// No description provided for @notAuthorizedStatus.
  ///
  /// In en, this message translates to:
  /// **'Not Authorized'**
  String get notAuthorizedStatus;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @generalSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettingsTitle;

  /// No description provided for @appFingerprintTitle.
  ///
  /// In en, this message translates to:
  /// **'App Fingerprint'**
  String get appFingerprintTitle;

  /// No description provided for @turnOff.
  ///
  /// In en, this message translates to:
  /// **'Turn Off'**
  String get turnOff;

  /// No description provided for @turnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn On'**
  String get turnOn;

  /// No description provided for @appLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguageTitle;

  /// No description provided for @helpAndSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupportTitle;

  /// No description provided for @aboutTheAppTitle.
  ///
  /// In en, this message translates to:
  /// **'About the App'**
  String get aboutTheAppTitle;

  /// No description provided for @termsOfUseTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUseTitle;

  /// No description provided for @termsOfUseDescription.
  ///
  /// In en, this message translates to:
  /// **'This is the terms of use description.'**
  String get termsOfUseDescription;

  /// No description provided for @termsOfUseAcceptance.
  ///
  /// In en, this message translates to:
  /// **'Acceptance of Terms'**
  String get termsOfUseAcceptance;

  /// No description provided for @termsOfUseRegistration.
  ///
  /// In en, this message translates to:
  /// **'Registration and Account'**
  String get termsOfUseRegistration;

  /// No description provided for @termsOfUsePermittedUse.
  ///
  /// In en, this message translates to:
  /// **'Permitted Use'**
  String get termsOfUsePermittedUse;

  /// No description provided for @termsOfUseSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get termsOfUseSecurity;

  /// No description provided for @termsOfUseChanges.
  ///
  /// In en, this message translates to:
  /// **'Changes to Terms'**
  String get termsOfUseChanges;

  /// No description provided for @accountSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettingsTitle;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @transactionHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistoryTitle;

  /// No description provided for @idCardTitle.
  ///
  /// In en, this message translates to:
  /// **'ID Card'**
  String get idCardTitle;

  /// No description provided for @idCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your digital ID card'**
  String get idCardSubtitle;

  /// No description provided for @newAccountSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'New Account'**
  String get newAccountSectionTitle;

  /// No description provided for @addNewAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Account'**
  String get addNewAccountTitle;

  /// No description provided for @updateInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Information'**
  String get updateInformationTitle;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstNameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastNameLabel;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @dateOfBirthLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirthLabel;

  /// No description provided for @nationalityLabel.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationalityLabel;

  /// No description provided for @dateOfIssueLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of Issue'**
  String get dateOfIssueLabel;

  /// No description provided for @dateOfExpiryLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of Expiry'**
  String get dateOfExpiryLabel;

  /// No description provided for @updateInformationButton.
  ///
  /// In en, this message translates to:
  /// **'Update Information'**
  String get updateInformationButton;

  /// No description provided for @enterPinCode.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN Code'**
  String get enterPinCode;

  /// No description provided for @pinCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter your 6-digit PIN to proceed.'**
  String get pinCodeDescription;

  /// No description provided for @incorrectPin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN. Please try again.'**
  String get incorrectPin;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @issuer.
  ///
  /// In en, this message translates to:
  /// **'Social Flow'**
  String get issuer;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
