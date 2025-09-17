// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BankID App';

  @override
  String get splashScreenLogo => 'Logo';

  @override
  String get languageSelectionTitle => 'Choose your language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get continueButton => 'Continue';

  @override
  String get onboardingTitle1 => 'Your digital identity is secure';

  @override
  String get onboardingDesc1 =>
      'Easily verify your personal identity and get comprehensive protection for all your data.';

  @override
  String get onboardingTitle2 => 'Sign with a single touch';

  @override
  String get onboardingDesc2 =>
      'Quickly sign your documents digitally with just a single touch on your screen.';

  @override
  String get onboardingTitle3 => 'Easy, secure payment';

  @override
  String get onboardingDesc3 =>
      'Enjoy fast electronic payments with high security and ease of use.';

  @override
  String get getStartedButton => 'Get started now';

  @override
  String get addNewSignature => 'Add New Signature';

  @override
  String get signatureName => 'Signature Name';

  @override
  String get enterNameHere => 'Enter name here';

  @override
  String get uploadSignatureFile => 'Upload Signature File';

  @override
  String get uploadImages => 'Upload Images';

  @override
  String get deleteImage => 'Delete Image';

  @override
  String get saveSignature => 'Save Signature';

  @override
  String get verifiedAccount => 'Verified Account';

  @override
  String get uploadedDocumentsAndFiles => 'Uploaded Documents and Files';

  @override
  String get scanQrCode => 'Scan the QR Code';

  @override
  String get keepYourDigitalIdentitySecure =>
      'Keep your digital identity secure. Do not share it or use it at someone else\'s request.';

  @override
  String get home => 'Home';

  @override
  String get history => 'History';

  @override
  String get idCard => 'ID Card';

  @override
  String get account => 'Account';

  @override
  String get setupPasscode => 'Setup the passcode';

  @override
  String get createPinDescription =>
      'Create your 6-digit PIN to protect your personal data';

  @override
  String get passcode => 'Passcode';

  @override
  String get setPasscode => 'Set passcode';

  @override
  String get delete => 'Delete';

  @override
  String get editSignature => 'Edit Signature';

  @override
  String get deleteSignature => 'Delete Signature';

  @override
  String areYouSureYouWantToDeleteSignature(
    Object number,
    Object signatureNumber,
  ) {
    return 'Are you sure you want to delete Signature Number $number?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get digitalSignatures => 'Digital Signatures';

  @override
  String get fileAddedOn => 'File added on ';

  @override
  String get settings => 'Settings';
}
