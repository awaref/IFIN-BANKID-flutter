// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تطبيق BankID';

  @override
  String get splashScreenLogo => 'الشعار';

  @override
  String get languageSelectionTitle => 'اختر لغتك';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get continueButton => 'متابعة';

  @override
  String get onboardingTitle1 => 'هويتك الرقمية آمنة';

  @override
  String get onboardingDesc1 =>
      'تحقق بسهولة من هويتك الشخصية واحصل على حماية شاملة لجميع بياناتك.';

  @override
  String get onboardingTitle2 => 'وقّع بلمسة واحدة';

  @override
  String get onboardingDesc2 =>
      'وقّع مستنداتك رقميًا بسرعة بمجرد لمسة واحدة على شاشتك.';

  @override
  String get onboardingTitle3 => 'دفع سهل وآمن';

  @override
  String get onboardingDesc3 =>
      'استمتع بمدفوعات إلكترونية سريعة مع أمان عالٍ وسهولة استخدام.';

  @override
  String get getStartedButton => 'ابدأ الآن';

  @override
  String get addNewSignature => 'إضافة توقيع جديد';

  @override
  String get signatureName => 'اسم التوقيع';

  @override
  String get enterNameHere => 'أدخل الاسم هنا';

  @override
  String get uploadSignatureFile => 'تحميل ملف التوقيع';

  @override
  String get uploadImages => 'تحميل الصور';

  @override
  String get deleteImage => 'حذف الصورة';

  @override
  String get saveSignature => 'حفظ التوقيع';

  @override
  String get verifiedAccount => 'حساب موثق';

  @override
  String get uploadedDocumentsAndFiles => 'المستندات والملفات المرفوعة';

  @override
  String get scanQrCode => 'مسح رمز الاستجابة السريعة';

  @override
  String get keepYourDigitalIdentitySecure =>
      'حافظ على هويتك الرقمية آمنة. لا تشاركها أو تستخدمها بناءً على طلب شخص آخر.';

  @override
  String get home => 'الرئيسية';

  @override
  String get history => 'السجل';

  @override
  String get idCard => 'بطاقة الهوية';

  @override
  String get account => 'الحساب';

  @override
  String get setupPasscode => 'إعداد رمز المرور';

  @override
  String get createPinDescription =>
      'أنشئ رقم التعريف الشخصي المكون من 6 أرقام لحماية بياناتك الشخصية';

  @override
  String get passcode => 'رمز المرور';

  @override
  String get setPasscode => 'تعيين رمز المرور';

  @override
  String get delete => 'حذف';

  @override
  String get editSignature => 'تعديل التوقيع';

  @override
  String get deleteSignature => 'حذف التوقيع';

  @override
  String areYouSureYouWantToDeleteSignature(
    Object number,
    Object signatureNumber,
  ) {
    return 'هل أنت متأكد أنك تريد حذف التوقيع رقم $signatureNumber؟';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get digitalSignatures => 'التوقيعات الرقمية';

  @override
  String get fileAddedOn => 'تاريخ الإضافة ';

  @override
  String get settings => 'الإعدادات';
}
