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
  String get splashScreenLogo => 'اللوجو';

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
  String get reportProblemButton => 'الإبلاغ عن مشكلة';

  @override
  String get reportProblemTitle => 'الإبلاغ عن مشكلة';

  @override
  String get supportPhoneNumber => '000-000-0000';

  @override
  String get closeButton => 'إغلاق';

  @override
  String get callButton => 'اتصال';

  @override
  String get uploadImages => 'تحميل الصور';

  @override
  String get deleteImage => 'حذف الصورة';

  @override
  String get cancel => 'إلغاء';

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
  String get idCardViewerTitle => 'عارض بطاقة الهوية';

  @override
  String get idCardScanUsingDigitalIdApp =>
      'المسح باستخدام تطبيق الهوية الرقمية';

  @override
  String get idCardQrData => 'https://www.bankid.com/qr-data';

  @override
  String get idCardShareViaQrCode => 'المشاركة عبر رمز الاستجابة السريعة';

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
  String get accountFullName => 'أيهم محمود عزيمة';

  @override
  String get accountPersonalId => '711025–1357';

  @override
  String get accountPhoneNumberActual => '+999 999 999 999';

  @override
  String get accountGenderActual => 'ذكر';

  @override
  String get accountDateOfBirthActual => '10/25/1971';

  @override
  String get accountNationalityActual => 'بريطاني';

  @override
  String get accountNationalIdNumberActual => '71105350328';

  @override
  String get accountDateOfIssueActual => '01/19/2022';

  @override
  String get accountDateOfExpirationActual => '01/19/2027';

  @override
  String get accountIDCardImageTitle => 'صورة بطاقة الهوية';

  @override
  String get accountIDCardImageDescription => 'Image389074292303.JPEG';

  @override
  String get nationalIdScreenTitle => 'ابدأ برقم هويتك الوطنية.';

  @override
  String get nationalIdNumberLabel => 'رقم الهوية الوطنية';

  @override
  String get nationalIdNumberHint => 'أدخل رقمًا مكونًا من 9 أرقام';

  @override
  String get yourPhoneNumbersTitle => 'أرقام هاتفك';

  @override
  String get yourPhoneNumbersDescription =>
      'وجدنا هذه الأرقام على هويتك الوطنية. اختر رقمًا لتبدأ به.';

  @override
  String get pickNumberButton => 'اختر رقمًا';

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
  String get digitalSignatures => 'التوقيعات الرقمية';

  @override
  String get fileAddedOn => 'تاريخ الإضافة ';

  @override
  String get settings => 'الإعدادات';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountConfirmationTitle => 'تأكيد حذف الحساب';

  @override
  String get deleteAccountConfirmationMessage =>
      'هل أنت متأكد أنك تريد حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get enterPinToDeleteAccount =>
      'أدخل رقم التعريف الشخصي المكون من 6 أرقام لتأكيد حذف الحساب.';

  @override
  String get sixDigitPin => 'رقم التعريف الشخصي المكون من 6 أرقام';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get pleaseEnterSixDigitPin =>
      'الرجاء إدخال رقم التعريف الشخصي المكون من 6 أرقام.';

  @override
  String get accountDeletionSuccess => 'تم حذف الحساب بنجاح.';

  @override
  String get aboutAppTitle => 'حول التطبيق';

  @override
  String get aboutAppDescription1 =>
      'تطبيق BankID هو هويتك الرقمية الآمنة. تحقق بسهولة من هويتك الشخصية واحصل على حماية شاملة لجميع بياناتك.';

  @override
  String get aboutAppDescription2 =>
      'وقّع مستنداتك رقميًا بسرعة بمجرد لمسة واحدة على شاشتك.';

  @override
  String get aboutAppDescription3 =>
      'استمتع بمدفوعات إلكترونية سريعة مع أمان عالٍ وسهولة استخدام.';

  @override
  String get aboutAppVersion => 'الإصدار 1.0';

  @override
  String get accountVerifiedAccount => 'حساب موثق';

  @override
  String get accountNotVerified => 'غير موثق';

  @override
  String get accountPhoneNumber => 'رقم الهاتف';

  @override
  String get accountPhoneNumberValue => '+999 999 999 999';

  @override
  String get accountGender => 'النوع';

  @override
  String get accountMale => 'ذكر';

  @override
  String get accountDateOfBirth => 'تاريخ الميلاد';

  @override
  String get accountDateOfBirthValue => '10/25/1971';

  @override
  String get accountNationality => 'الجنسية';

  @override
  String get accountBritish => 'بريطاني';

  @override
  String get accountNationalIdNumber => 'رقم الهوية الوطنية';

  @override
  String get accountNationalIdNumberValue => '71105350328';

  @override
  String get accountDateOfIssue => 'تاريخ الإصدار';

  @override
  String get accountDateOfIssueValue => '01/19/2022';

  @override
  String get accountDateOfExpiration => 'تاريخ الانتهاء';

  @override
  String get accountDateOfExpirationValue => '01/19/2027';

  @override
  String get accountIDCardImage => 'صورة بطاقة الهوية';

  @override
  String get accountIDCardImageValue => 'Image389074292303.JPEG';

  @override
  String get appProtectionScanFingerprint => 'امسح بصمة إصبعك للمصادقة';

  @override
  String get appProtectionActivateProtection => 'تفعيل حماية التطبيق';

  @override
  String get appProtectionChooseOption =>
      'اختر الخيار لتأمين تسجيل الدخول الخاص بك باستخدام معرف التطبيق';

  @override
  String get appProtectionUseBiometrics => 'استخدام القياسات الحيوية';

  @override
  String get appProtectionUseSecureWay =>
      'استخدم تطبيق الهوية بأكثر الطرق أمانًا';

  @override
  String get appProtectionSetUpPasscode => 'إعداد رمز مرور';

  @override
  String get appProtectionCreatePin =>
      'أنشئ رقم التعريف الشخصي المكون من 6 أرقام لحماية بياناتك الشخصية';

  @override
  String get appProtectionContinue => 'متابعة';

  @override
  String get appProtectionRecommended => 'موصى به';

  @override
  String get checkInformationTitle => 'تحقق من معلوماتك.';

  @override
  String get checkInformationFirstName => 'الاسم الأول';

  @override
  String get checkInformationFirstNameValue => 'أيهم';

  @override
  String get checkInformationLastName => 'اسم العائلة';

  @override
  String get checkInformationLastNameValue => 'عزيمة';

  @override
  String get checkInformationGender => 'النوع';

  @override
  String get checkInformationGenderValue => 'ذكر';

  @override
  String get checkInformationDateOfBirth => 'تاريخ الميلاد';

  @override
  String get checkInformationDateOfBirthValue => '25/10/1971';

  @override
  String get checkInformationNationality => 'الجنسية';

  @override
  String get checkInformationNationalityValue => 'بريطاني';

  @override
  String get checkInformationNationalIdNumber => 'رقم الهوية الوطنية';

  @override
  String get checkInformationNationalIdNumberValue => '71105350328';

  @override
  String get checkInformationDateOfIssue => 'تاريخ الإصدار';

  @override
  String get checkInformationDateOfIssueValue => '19/01/2022';

  @override
  String get checkInformationDateOfExpiry => 'تاريخ الانتهاء';

  @override
  String get checkInformationDateOfExpiryValue => '19/01/2027';

  @override
  String get checkInformationConfirm => 'تأكيد';

  @override
  String get twoFactorAuthenticationTitle => 'المصادقة الثنائية';

  @override
  String get enterConfirmationCode => 'أدخل رمز التأكيد';

  @override
  String get confirmationCodeDescription =>
      'الرجاء إدخال الرمز المكون من 6 أرقام المرسل إلى عنوان بريدك الإلكتروني المسجل.';

  @override
  String get codeLabel => 'الرمز';

  @override
  String get codeHint => 'أدخل الرمز';

  @override
  String get backButton => 'رجوع';

  @override
  String get twoFactorAuthSetupAuthenticatorApp =>
      'إعداد تطبيق المصادقة الخاص بك';

  @override
  String get twoFactorAuthScanQrDescription =>
      'امسح رمز الاستجابة السريعة أدناه في تطبيق المصادقة الخاص بك وأنت جاهز! (إذا لم تكن قد قمت بتثبيت تطبيق المصادقة بعد.)';

  @override
  String get twoFactorAuthIssuer => 'المُصدر';

  @override
  String get twoFactorAuthAccount => 'الحساب';

  @override
  String get twoFactorAuthSecretKey => 'المفتاح السري';

  @override
  String get confirmButton => 'تأكيد';

  @override
  String get saveOneTimeRecoveryCodeTitle =>
      'احفظ رمز الاسترداد هذا لمرة واحدة';

  @override
  String get oneTimeRecoveryCodeDescription =>
      'إذا فقدت الوصول إلى بريدك الإلكتروني، فمن المحتمل أن يتم قفل حسابك. احفظ هذا الرمز في مكان آمن لاستخدامه إذا لم تتمكن من تسجيل الدخول باستخدام بريدك الإلكتروني.';

  @override
  String get twoFactorAuthDescription => 'احمِ حسابك بطبقة إضافية من الأمان.';

  @override
  String get twoFactorAuthExplanation =>
      'تضيف المصادقة الثنائية طبقة إضافية من الأمان إلى حسابك من خلال طلب شكل ثانٍ للتحقق بالإضافة إلى كلمة المرور الخاصة بك.';

  @override
  String get enableTwoFactorAuthButton => 'تمكين المصادقة الثنائية';

  @override
  String get setUpAuthenticatorAppTitle => 'إعداد تطبيق المصادقة';

  @override
  String get setUpAuthenticatorAppDescription =>
      'قم بمسح رمز QR أدناه في تطبيق المصادقة الخاص بك وستكون جاهزًا! (إذا لم تكن قد قمت بتثبيت تطبيق مصادقة بعد.)';

  @override
  String authenticatorDetails(
    Object issuer,
    Object accountEmail,
    Object secretKey,
  ) {
    return 'لإعداد تطبيق المصادقة الخاص بك، امسح رمز الاستجابة السريعة ضوئيًا أو أدخل التفاصيل التالية يدويًا:\n\nالمُصدر: $issuer\nالحساب: $accountEmail\nالمفتاح السري: $secretKey';
  }

  @override
  String get contractScreenNameLabel => 'الاسم:';

  @override
  String get contractScreenIdPassportNumberLabel => 'رقم الهوية/جواز السفر:';

  @override
  String get contractScreenAddressLabel => 'العنوان:';

  @override
  String get contractScreenPhoneLabel => 'الهاتف:';

  @override
  String get contractScreenEmailLabel => 'البريد الإلكتروني:';

  @override
  String get contractScreenPartyOneNameValue => 'أحمد خالد مصطفى';

  @override
  String get contractScreenPartyOneIdPassportNumberValue => 'SY24567891';

  @override
  String get contractScreenPartyOneAddressValue =>
      'دمشق – مشروع دمر – شارع اليرموك – بناء رقم 12';

  @override
  String get contractScreenPartyOnePhoneValue => '+963 944 321 567';

  @override
  String get contractScreenPartyOneEmailValue => 'ahmad.mustafa@example.com';

  @override
  String get contractScreenPartyTwoTitle => 'الطرف الثاني:';

  @override
  String get contractScreenPartyTwoNameValue =>
      'شركة النور للتقنيات الحديثة (يمثلها السيد سامر عبد الله)';

  @override
  String get contractScreenCommercialRegistrationLabel => 'السجل التجاري:';

  @override
  String get contractScreenPartyTwoCommercialRegistrationValue =>
      '102547 – دمشق';

  @override
  String get contractScreenPartyTwoAddressValue =>
      'دمشق – أبو رمانة – شارع الجلاء – بناء رقم 8';

  @override
  String get contractScreenPartyTwoPhoneValue => '+963 944 654 789';

  @override
  String get contractScreenPartyTwoEmailValue => 'info@alnoortech.com';

  @override
  String get contractScreenIntroductionTitle => 'مقدمة العقد:';

  @override
  String get contractScreenIntroductionDescription =>
      'حيث أن الطرف الأول يرغب في تصميم وتطوير تطبيق جوال لإدارة الحجوزات، وحيث أن الطرف الثاني يمتلك الخبرة اللازمة لتنفيذ هذا المشروع، فقد اتفق الطرفان على ما يلي:';

  @override
  String get contractScreenArticleOneTitle => 'المادة الأولى – موضوع العقد:';

  @override
  String get contractScreenArticleOneDescription =>
      'يتعهد الطرف الثاني (شركة النور للتقنيات الحديثة) بتصميم وتطوير تطبيق جوال يعمل على نظامي أندرويد و iOS، مخصص لإدارة وحجز المواعيد، وذلك وفقًا للمواصفات المتفق عليها مع الطرف الأول.';

  @override
  String get contractScreenArticleTwoTitle => 'المادة الثانية – مدة العقد:';

  @override
  String get contractScreenArticleTwoDescription =>
      'تبدأ مدة العقد من تاريخ 15/08/2025 ولمدة ثلاثة أشهر، قابلة للتجديد بموافقة خطية من الطرفين.';

  @override
  String get contractScreenArticleThreeTitle =>
      'المادة الثالثة – المقابل المالي:';

  @override
  String get contractScreenArticleThreeDescription =>
      'يلتزم الطرف الأول بدفع مبلغ وقدره 4,500 دولار أمريكي، يتم دفعه على النحو التالي: الدفعة الأولى: 2,000 دولار عند توقيع العقد. الدفعة النهائية: 2,500 دولار عند التسليم النهائي للمشروع.';

  @override
  String get contractScreenArticleFourTitle =>
      'المادة الرابعة – حقوق والتزامات الطرفين:';

  @override
  String get contractScreenArticleFourDescription =>
      'يلتزم الطرف الثاني بتسليم المشروع في الموعد المحدد ووفقًا للمعايير الفنية. يلتزم الطرف الأول بتقديم كافة المعلومات والمواد اللازمة للتصميم والتطوير في الوقت المناسب.';

  @override
  String get contractScreenArticleFiveTitle => 'المادة الخامسة – الإنهاء:';

  @override
  String get contractScreenArticleFiveDescription =>
      'يجوز لأي من الطرفين إنهاء العقد بإشعار خطي قبل 15 يومًا على الأقل، مع تسوية المستحقات المالية للطرف الآخر وفقًا للعمل المنجز.';

  @override
  String get contractScreenArticleSixTitle =>
      'المادة السادسة – القانون الحاكم:';

  @override
  String get contractScreenArticleSixDescription =>
      'يخضع هذا العقد لقوانين وأنظمة الجمهورية العربية السورية، ويتم حل أي نزاع وديًا، وفي حال تعذر ذلك، يتم إحالته إلى المحكمة المدنية في دمشق.';

  @override
  String get contractScreenSignaturesTitle => 'التوقيعات:';

  @override
  String get contractScreenSignatureLabel => 'التوقيع:';

  @override
  String get contractScreenSignatureValue => '___________';

  @override
  String get contractScreenDateLabel => 'التاريخ:';

  @override
  String get contractScreenDateValue => '15/08/2025';

  @override
  String get contractScreenPartyTwoSignatureValue =>
      'شركة النور للتقنيات الحديثة – الممثل: سامر عبد الله';

  @override
  String get contractScreenSignContractButton => 'توقيع العقد';

  @override
  String get contractScreenTitle => 'توقيع عقد';

  @override
  String get contractScreenPartyOneTitle => 'الطرف الأول:';

  @override
  String get deleteAccountTitle => 'حذف الحساب.';

  @override
  String get deleteAccountDescription =>
      'هل أنت متأكد أنك تريد حذف حسابك؟ يجب عليك إدخال كلمة المرور الخاصة بك للتأكيد.';

  @override
  String get deleteAccountPasswordLabel => 'كلمة المرور';

  @override
  String get deleteAccountButton => 'حذف';

  @override
  String get fileAddedOnLabel => 'تمت الإضافة في';

  @override
  String get digitalSignaturesListTitle => 'التوقيعات الرقمية';

  @override
  String digitalSignatureNumber(Object number) {
    return 'التوقيع الرقمي $number';
  }

  @override
  String get addNewSignatureButton => 'إضافة توقيع جديد';

  @override
  String get editPhoneNumberTitle => 'تعديل رقم الهاتف';

  @override
  String get editPhoneNumberLabel => 'رقم الهاتف';

  @override
  String get editPhoneNumberHint => '+999 999 999 999';

  @override
  String get cancelButton => 'إلغاء';

  @override
  String get twoFactorAuthTitle => 'المصادقة الثنائية';

  @override
  String get authenticatorAppTitle => 'تطبيق المصادقة';

  @override
  String get authenticatorAppDescription =>
      'استخدم تطبيق المصادقة لإنشاء رمز لمرة واحدة.';

  @override
  String get emailOptionTitle => 'البريد الإلكتروني';

  @override
  String get emailOptionDescription =>
      'استقبل رمزًا لمرة واحدة عبر البريد الإلكتروني.';

  @override
  String get setupAuthenticatorAppTitle => 'إعداد تطبيق المصادقة الخاص بك';

  @override
  String get setupAuthenticatorAppDescription =>
      'امسح رمز الاستجابة السريعة أدناه في تطبيق المصادقة الخاص بك وأنت جاهز! (إذا لم تكن قد قمت بتثبيت تطبيق المصادقة بعد.)';

  @override
  String get issuerLabel => 'الناشر: ';

  @override
  String get accountLabel => 'الحساب: ';

  @override
  String get secretKeyLabel => 'المفتاح السري: ';

  @override
  String get noInternetConnectionTitle => 'لا يوجد اتصال بالإنترنت';

  @override
  String get noInternetConnectionDescription =>
      'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get retryButton => 'إعادة المحاولة';

  @override
  String get noResultsFoundTitle => 'لم يتم العثور على نتائج';

  @override
  String noResultsFoundDescription(Object searchQuery) {
    return 'لم يتم العثور على نتائج لـ \"$searchQuery\". يرجى تجربة بحث آخر.';
  }

  @override
  String get searchHint => 'بحث';

  @override
  String get historyItemSeb => 'SEB';

  @override
  String get historyItemIdentity => 'الهوية';

  @override
  String get historyItemSignature => 'التوقيع';

  @override
  String get historyItemSwishAtSeb => 'Swish في SEB';

  @override
  String get historyItemMinimumApplicationDate => 'الحد الأدنى لتاريخ التطبيق';

  @override
  String get historyItemApplicationIdKort => 'تطبيق بطاقة الهوية';

  @override
  String get userName => 'أيهم محمود عزيمة';

  @override
  String get homeScreenUserName => 'أيهم محمود عزيمة';

  @override
  String get homeScreenUserNationalId => '711025-1357';

  @override
  String get homeScreenVerifiedAccount => 'حساب موثق';

  @override
  String get enterVerificationCode => 'أدخل رمز التحقق.';

  @override
  String get verificationCodeSentTo => 'تم إرسال رمز التحقق إلى ';

  @override
  String get verificationCode => 'رمز التحقق';

  @override
  String get resendSmsWithin => 'يمكنك إعادة إرسال الرسالة النصية خلال';

  @override
  String get retryVerification => 'إعادة محاولة التحقق';

  @override
  String get letsCreateYourIdAppIdentity => 'لنقم بإنشاء هوية خاص بك.';

  @override
  String get performingThisProcess => 'إجراء هذه العملية ';

  @override
  String get forFunOrAsATest => 'للمتعة أو كاختبار';

  @override
  String get mayResultInPermanentBlock =>
      'قد يؤدي إلى حظرك بشكل دائم ويمنعك من استخدام تطبيق الهوية.';

  @override
  String get followTheseSteps => 'اتبع هذه الخطوات';

  @override
  String get takeASelfieVideo => 'التقط فيديو سيلفي.';

  @override
  String get takeAPhotoOfYourNationalIdCard =>
      'التقط صورة لبطاقة الهوية الوطنية الخاصة بك';

  @override
  String get startEnrollment => 'بدء التسجيل';

  @override
  String get onTheNextScreenFollowInstructions =>
      'في الشاشة التالية، اتبع التعليمات لتسجيل سيلفي.';

  @override
  String get pleaseNoteSurroundingsVisible =>
      'يرجى ملاحظة أن محيطك سيكون مرئيًا أثناء التقاط صورة السيلفي';

  @override
  String get tryMovingToBetterLighting =>
      'حاول الانتقال إلى منطقة ذات إضاءة أفضل وإزالة نظارتك أو أي شيء آخر يغطي وجهك';

  @override
  String get takeASelfie => 'التقط سيلفي';

  @override
  String get takeAPictureOfYourNationalIdCard =>
      'التقط صورة لبطاقة الهوية الوطنية الخاصة بك.';

  @override
  String get pleaseEnsure => 'يرجى التأكد:';

  @override
  String get usingCorrectNationalIdCard =>
      'أنت تستخدم بطاقة الهوية الوطنية الصحيحة';

  @override
  String get nationalIdCardWithinScanningFrame =>
      'بطاقة الهوية الوطنية ضمن إطار المسح ومرئية بالكامل';

  @override
  String get fingersDontCoverNationalId =>
      'لا تغطي أصابعك أي جزء من بطاقة الهوية الوطنية';

  @override
  String get imageClearWithoutGlare => 'الصورة واضحة بدون أي وهج أو ظلال';

  @override
  String get takeAPicture => 'التقط صورة';

  @override
  String get signAContract => 'توقيع عقد';

  @override
  String get youCanSignAContractFromHere => 'يمكنك توقيع عقد من هنا';

  @override
  String get scanTheQrCode => 'امسح رمز الاستجابة السريعة';

  @override
  String get keepDigitalIdentitySecure =>
      'حافظ على هويتك الرقمية آمنة. لا تشاركها أو تستخدمها بناءً على طلب شخص آخر.';

  @override
  String get search => 'بحث';

  @override
  String get identity => 'الهوية';

  @override
  String get signature => 'التوقيع';

  @override
  String get codeCopiedToClipboard => 'تم نسخ الرمز إلى الحافظة';

  @override
  String get copyCodeButton => 'نسخ الرمز';

  @override
  String get doneButton => 'تم';

  @override
  String get privacyPolicyTitle => 'سياسة الخصوصية';

  @override
  String get privacyPolicyDescription => 'هذا هو وصف سياسة الخصوصية.';

  @override
  String get privacyPolicyInfoCollectTitle => 'جمع المعلومات';

  @override
  String get privacyPolicyInfoCollectDescription =>
      'نقوم بجمع أنواع مختلفة من المعلومات عند استخدامك لتطبيقنا.';

  @override
  String get privacyPolicyHowToUseTitle => 'كيف نستخدم معلوماتك';

  @override
  String get privacyPolicyHowToUseDescription =>
      'تُستخدم معلوماتك لتقديم خدماتنا وتحسينها.';

  @override
  String get privacyPolicyInfoProtectionTitle => 'حماية المعلومات';

  @override
  String get privacyPolicyInfoProtectionDescription =>
      'نحن نطبق مجموعة متنوعة من الإجراءات الأمنية للحفاظ على سلامة معلوماتك الشخصية.';

  @override
  String get privacyPolicyYourRightsTitle => 'حقوقك';

  @override
  String get privacyPolicyYourRightsDescription =>
      'لديك الحق في الوصول إلى بياناتك الشخصية أو تصحيحها أو حذفها.';

  @override
  String get authenticateReason =>
      'امسح بصمة إصبعك (أو وجهك أو أي مقياس حيوي آخر) للمصادقة';

  @override
  String get authenticationError => 'خطأ - ';

  @override
  String get authorizedStatus => 'مصرح به';

  @override
  String get notAuthorizedStatus => 'غير مصرح به';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get generalSettingsTitle => 'الإعدادات العامة';

  @override
  String get appFingerprintTitle => 'بصمة التطبيق';

  @override
  String get turnOff => 'إيقاف';

  @override
  String get turnOn => 'تشغيل';

  @override
  String get appLanguageTitle => 'لغة التطبيق';

  @override
  String get helpAndSupportTitle => 'المساعدة والدعم';

  @override
  String get aboutTheAppTitle => 'حول التطبيق';

  @override
  String get termsOfUseTitle => 'شروط الاستخدام';

  @override
  String get termsOfUseDescription => 'هذا هو وصف شروط الاستخدام.';

  @override
  String get termsOfUseAcceptance => 'قبول الشروط';

  @override
  String get termsOfUseRegistration => 'التسجيل والحساب';

  @override
  String get termsOfUsePermittedUse => 'الاستخدام المسموح به';

  @override
  String get termsOfUseSecurity => 'الأمان';

  @override
  String get termsOfUseChanges => 'تغييرات على الشروط';

  @override
  String get accountSettingsTitle => 'إعدادات الحساب';

  @override
  String get changePasswordTitle => 'تغيير كلمة المرور';

  @override
  String get transactionHistoryTitle => 'سجل المعاملات';

  @override
  String get idCardTitle => 'بطاقة الهوية';

  @override
  String get idCardSubtitle => 'إدارة بطاقة الهوية الرقمية الخاصة بك';

  @override
  String get newAccountSectionTitle => 'حساب جديد';

  @override
  String get addNewAccountTitle => 'إضافة حساب جديد';

  @override
  String get updateInformationTitle => 'تحديث المعلومات';

  @override
  String get firstNameLabel => 'الاسم الأول';

  @override
  String get lastNameLabel => 'اسم العائلة';

  @override
  String get genderLabel => 'الجنس';

  @override
  String get dateOfBirthLabel => 'تاريخ الميلاد';

  @override
  String get nationalityLabel => 'الجنسية';

  @override
  String get dateOfIssueLabel => 'تاريخ الإصدار';

  @override
  String get dateOfExpiryLabel => 'تاريخ الانتهاء';

  @override
  String get updateInformationButton => 'تحديث المعلومات';

  @override
  String get enterPinCode => 'أدخل رمز PIN';

  @override
  String get pinCodeDescription =>
      'الرجاء إدخال رمز PIN المكون من 6 أرقام للمتابعة.';

  @override
  String get incorrectPin => 'رمز PIN غير صحيح. الرجاء المحاولة مرة أخرى.';

  @override
  String get verify => 'تحقق';

  @override
  String get issuer => 'التدفق الاجتماعي';
}
