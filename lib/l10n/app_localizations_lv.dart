// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Latvian (`lv`).
class AppLocalizationsLv extends AppLocalizations {
  AppLocalizationsLv([String locale = 'lv']) : super(locale);

  @override
  String get appName => 'Saliena Support';

  @override
  String get welcome => 'Laipni lūdzam Saliena Support';

  @override
  String get welcomeSubtitle => 'Ziņojiet par problēmām savā pašvaldībā';

  @override
  String get municipality => 'Pašvaldība';

  @override
  String get getStarted => 'Sākt';

  @override
  String get login => 'Pieslēgties';

  @override
  String get signIn => 'Pieslēgties';

  @override
  String get signup => 'Reģistrēties';

  @override
  String get email => 'E-pasts';

  @override
  String get password => 'Parole';

  @override
  String get confirmPassword => 'Apstiprināt paroli';

  @override
  String get phone => 'Tālruņa numurs';

  @override
  String get fullName => 'Pilns vārds';

  @override
  String get forgotPassword => 'Aizmirsāt paroli?';

  @override
  String get noAccount => 'Nav konta?';

  @override
  String get hasAccount => 'Jau ir konts?';

  @override
  String get welcomeBack => 'Laipni lūgti atpakaļ';

  @override
  String get signInSubtitle =>
      'Piesakieties, lai pārvaldītu pašvaldības pieprasījumus';

  @override
  String get createAccount => 'Izveidot kontu';

  @override
  String get joinCommunity => 'Pievienojieties Saliena kopienai';

  @override
  String get municipalityPortal => 'Pašvaldības portāls';

  @override
  String get resetPassword => 'Atiestatīt paroli';

  @override
  String get resetPasswordSubtitle =>
      'Ievadiet e-pastu, lai saņemtu atiestatīšanas norādījumus';

  @override
  String get sendResetLink => 'Nosūtīt atiestatīšanas saiti';

  @override
  String get checkEmail => 'Pārbaudiet e-pastu';

  @override
  String resetLinkSent(String email) {
    return 'Mēs nosūtījām paroles atiestatīšanas saiti uz $email';
  }

  @override
  String get backToSignIn => 'Atpakaļ uz pierakstīšanos';

  @override
  String get emailAddress => 'E-pasta adrese';

  @override
  String get phoneNumber => 'Tālruņa numurs';

  @override
  String get address => 'Dzīvesvietas adrese';

  @override
  String get addressHint => 'Iela, Pilsēta, Pasta indekss';

  @override
  String get termsAgreement =>
      'Izveidojot kontu, jūs piekrītat mūsu Pakalpojumu noteikumiem un Privātuma politikai';

  @override
  String get emailRequired => 'Lūdzu, ievadiet e-pastu';

  @override
  String get emailInvalid => 'Lūdzu, ievadiet derīgu e-pastu';

  @override
  String get passwordRequired => 'Lūdzu, ievadiet paroli';

  @override
  String passwordMinLength(int length) {
    return 'Parolei jābūt vismaz $length rakstzīmēm';
  }

  @override
  String get passwordUppercase => 'Parolei jāsatur liels burts';

  @override
  String get passwordNumber => 'Parolei jāsatur cipars';

  @override
  String get nameRequired => 'Lūdzu, ievadiet pilnu vārdu';

  @override
  String get nameMinLength => 'Vārdam jābūt vismaz 2 rakstzīmēm';

  @override
  String get phoneRequired => 'Lūdzu, ievadiet tālruņa numuru';

  @override
  String get phoneInvalid => 'Lūdzu, ievadiet derīgu tālruņa numuru';

  @override
  String get confirmPasswordRequired => 'Lūdzu, apstipriniet paroli';

  @override
  String get passwordsDoNotMatch => 'Paroles nesakrīt';

  @override
  String signInWith(String provider) {
    return 'Pieslēgties ar $provider';
  }

  @override
  String get verifyPhone => 'Verificēt e-pastu';

  @override
  String verifyPhoneSubtitle(String email) {
    return 'Ievadiet kodu, kas nosūtīts uz $email';
  }

  @override
  String get otpCode => 'Verifikācijas kods';

  @override
  String get resendCode => 'Nosūtīt kodu vēlreiz';

  @override
  String resendCodeIn(int seconds) {
    return 'Nosūtīt kodu vēlreiz pēc ${seconds}s';
  }

  @override
  String get setup2FA => 'Iestatīt divfaktoru autentifikāciju';

  @override
  String get setup2FASubtitle =>
      'Skenējiet šo QR kodu ar savu autentifikatora lietotni';

  @override
  String get enter2FACode => 'Ievadiet 6 ciparu kodu no savas lietotnes';

  @override
  String get verify => 'Verificēt';

  @override
  String get home => 'Sākums';

  @override
  String get map => 'Karte';

  @override
  String get report => 'Ziņojums';

  @override
  String get profile => 'Profils';

  @override
  String get settings => 'Iestatījumi';

  @override
  String get createReport => 'Izveidot ziņojumu';

  @override
  String get reportTitle => 'Virsraksts';

  @override
  String get reportTitleHint => 'Īss problēmas apraksts';

  @override
  String get reportDescription => 'Apraksts';

  @override
  String get reportDescriptionHint =>
      'Sniedziet vairāk informācijas par problēmu';

  @override
  String get takePhoto => 'Uzņemt fotoattēlu';

  @override
  String get choosePhoto => 'Izvēlēties no galerijas';

  @override
  String get location => 'Atrašanās vieta';

  @override
  String get locationDetected => 'Atrašanās vieta noteikta automātiski';

  @override
  String get submit => 'Iesniegt';

  @override
  String get submitting => 'Iesniedz...';

  @override
  String get reportStatus => 'Statuss';

  @override
  String get statusPending => 'Gaida';

  @override
  String get statusInProgress => 'Procesā';

  @override
  String get statusFixed => 'Novērsts';

  @override
  String get markAsFixed => 'Atzīmēt kā novērstu';

  @override
  String reportedBy(String name) {
    return 'Ziņoja $name';
  }

  @override
  String reportedOn(String date) {
    return 'Ziņots $date';
  }

  @override
  String fixedBy(String name) {
    return 'Novērsa $name';
  }

  @override
  String get myReports => 'Mani ziņojumi';

  @override
  String get communityReports => 'Kopienas ziņojumi';

  @override
  String get allReports => 'Visi ziņojumi';

  @override
  String get noReports => 'Pagaidām nav ziņojumu';

  @override
  String get noReportsSubtitle =>
      'Esiet pirmais, kas ziņo par problēmu savā apkārtnē';

  @override
  String get language => 'Valoda';

  @override
  String get english => 'Angļu';

  @override
  String get latvian => 'Latviešu';

  @override
  String get russian => 'Krievu';

  @override
  String get notifications => 'Paziņojumi';

  @override
  String get security => 'Drošība';

  @override
  String get about => 'Par lietotni';

  @override
  String get logout => 'Iziet';

  @override
  String get logoutConfirm => 'Vai tiešām vēlaties iziet?';

  @override
  String get cancel => 'Atcelt';

  @override
  String get confirm => 'Apstiprināt';

  @override
  String get delete => 'Dzēst';

  @override
  String get save => 'Saglabāt';

  @override
  String get edit => 'Rediģēt';

  @override
  String get close => 'Aizvērt';

  @override
  String get retry => 'Mēģināt vēlreiz';

  @override
  String get loading => 'Ielādē...';

  @override
  String get errorGeneric => 'Kaut kas nogāja greizi. Lūdzu, mēģiniet vēlreiz.';

  @override
  String get errorNetwork =>
      'Nav interneta savienojuma. Lūdzu, pārbaudiet tīklu.';

  @override
  String get errorAuth => 'Autentifikācija neizdevās. Lūdzu, mēģiniet vēlreiz.';

  @override
  String get errorPermission => 'Jums nav atļaujas veikt šo darbību.';

  @override
  String get errorNotFound => 'Pieprasītais resurss netika atrasts.';

  @override
  String get errorValidation =>
      'Lūdzu, pārbaudiet ievadītos datus un mēģiniet vēlreiz.';

  @override
  String get permissionCamera =>
      'Kameras atļauja nepieciešama fotoattēlu uzņemšanai';

  @override
  String get permissionLocation =>
      'Atrašanās vietas atļauja nepieciešama ziņojumu iesniegšanai';

  @override
  String get permissionStorage =>
      'Krātuves atļauja nepieciešama fotoattēlu saglabāšanai';

  @override
  String get grantPermission => 'Piešķirt atļauju';

  @override
  String get verificationPending => 'Verifikācija procesā';

  @override
  String get verificationPendingSubtitle =>
      'Jūsu konts tiek verificēts kā Salienas iedzīvotājs. Tas parasti aizņem 1-2 darba dienas.';

  @override
  String get twoFactorAuth => 'Divfaktoru autentifikācija';

  @override
  String get twoFactorAuthSubtitle =>
      'Ievadiet kodu no savas autentifikatora lietotnes';

  @override
  String get verifyPhoneNumber => 'Verificēt e-pastu';

  @override
  String get verifyPhoneNumberSubtitle =>
      'Ievadiet verifikācijas kodu, kas nosūtīts uz jūsu e-pastu';

  @override
  String get checkYourPhone => 'Pārbaudiet e-pastu';

  @override
  String get checkYourPhoneDesc =>
      'Verifikācijas kods ir nosūtīts uz jūsu e-pastu';

  @override
  String get codeSentTo => 'Kods nosūtīts uz';

  @override
  String get codeSentToDesc => 'Ievadiet 6 ciparu kodu no e-pasta:';

  @override
  String get enterVerificationCode => 'Ievadiet verifikācijas kodu';

  @override
  String get enterVerificationCodeDesc => 'Ievadiet 6 ciparu kodu no e-pasta:';

  @override
  String get verifyCode => 'Verificēt kodu';

  @override
  String get useDifferentAccount => 'Izmantot citu kontu';

  @override
  String get accountInfo => 'Konta informācija';

  @override
  String get memberSince => 'Reģistrēts kopš';

  @override
  String get editProfile => 'Rediģēt profilu';

  @override
  String get changePassword => 'Mainīt paroli';

  @override
  String get theme => 'Tēma';

  @override
  String get themeSystem => 'Sistēmas';

  @override
  String get themeLight => 'Gaiša';

  @override
  String get themeDark => 'Tumša';

  @override
  String get helpSupport => 'Palīdzība un atbalsts';

  @override
  String get filterReports => 'Filtrēt ziņojumus';

  @override
  String get applyFilters => 'Lietot filtrus';

  @override
  String get unknownLocation => 'Nezināma atrašanās vieta';

  @override
  String get gettingLocation => 'Nosaka atrašanās vietu...';

  @override
  String get notSet => 'Nav iestatīts';

  @override
  String get verified => 'Verificēts';

  @override
  String get pending => 'Gaida';

  @override
  String get today => 'Šodien';

  @override
  String get yesterday => 'Vakar';

  @override
  String daysAgo(int days) {
    return 'Pirms $days dienām';
  }

  @override
  String get chooseTheme => 'Izvēlēties tēmu';

  @override
  String get reportIssue => 'Ziņot par problēmu';

  @override
  String get addPhoto => 'Pievienot fotoattēlu';

  @override
  String get addPhotoSubtitle =>
      'Uzņemiet vai izvēlieties fotoattēlu par problēmu';

  @override
  String get confirmLocation => 'Apstiprināt atrašanās vietu';

  @override
  String get confirmLocationSubtitle =>
      'Velciet karti, lai precizētu atrašanās vietu';

  @override
  String get addDetails => 'Pievienot informāciju';

  @override
  String get addDetailsSubtitle => 'Aprakstiet problēmu, lai mēs to saprastu';

  @override
  String get reportSummary => 'Ziņojuma kopsavilkums';

  @override
  String get photoAdded => 'Fotoattēls pievienots';

  @override
  String get locationNotSet => 'Atrašanās vieta nav iestatīta';

  @override
  String get back => 'Atpakaļ';

  @override
  String get continueStep => 'Turpināt';

  @override
  String get submitReport => 'Iesniegt ziņojumu';

  @override
  String get reportsFeed => 'Ziņojumu plūsma';

  @override
  String get viewOnMap => 'Skatīt kartē';

  @override
  String get deleteReport => 'Dzēst ziņojumu';

  @override
  String get markAsInProgress => 'Atzīmēt kā procesā';

  @override
  String get tapToAddPhoto => 'Pieskarieties, lai pievienotu foto';

  @override
  String get takePhotoOrGallery => 'Uzņemiet foto vai izvēlieties no galerijas';

  @override
  String get reportSubmittedSuccess => 'Ziņojums veiksmīgi iesniegts!';

  @override
  String get photoRequired => 'Lūdzu, pievienojiet problēmas fotoattēlu';

  @override
  String get locationRequired => 'Atrašanās vieta ir obligāta';

  @override
  String get photo => 'Foto';

  @override
  String get details => 'Detaļas';

  @override
  String get useMyLocation => 'Izmantot manu atrašanās vietu';

  @override
  String get tapToSelectLocation =>
      'Pieskarieties kartei, lai izvēlētos atrašanās vietu';

  @override
  String get tapToReportNewIssue =>
      'Pieskarieties, lai ziņotu par jaunu problēmu';

  @override
  String get viewAll => 'Skatīt visus';

  @override
  String get verifyingLocation => 'Pārbauda atrašanās vietu...';

  @override
  String get outsideServiceArea => 'Ārpus apkalpošanas zonas';

  @override
  String get locationPermissionDenied =>
      'Atrašanās vietas atļauja liegta. Mums ir nepieciešama jūsu atrašanās vieta, lai pārbaudītu dzīvesvietu.';

  @override
  String get locationServicesDisabled =>
      'Atrašanās vietas pakalpojumi ir atspējoti. Lūdzu, ieslēdziet GPS, lai turpinātu.';

  @override
  String get signupRestrictedToResidents =>
      'Reģistrācija ir pieejama tikai Salienas iedzīvotājiem.';

  @override
  String get openSettings => 'Atvērt iestatījumus';

  @override
  String get enableGPS => 'Ieslēgt GPS';

  @override
  String get accountDeleted => 'Konts veiksmīgi dzēsts';

  @override
  String get accountDeletedMessage => 'Jūsu konts ir neatgriezeniski dzēsts.';

  @override
  String get deleteAccount => 'Dzēst kontu';

  @override
  String get deleteAccountConfirm =>
      'Vai tiešām vēlaties dzēst savu kontu? Šo darbību nevar atsaukt.';

  @override
  String get deleteAccountWarning =>
      'Visi jūsu dati tiks neatgriezeniski dzēsti.';

  @override
  String get signOut => 'Izrakstīties';

  @override
  String get signOutConfirm => 'Vai tiešām vēlaties izrakstīties?';

  @override
  String get preferredLanguage => 'Vēlamā valoda';

  @override
  String get personalInformation => 'Personīgā informācija';

  @override
  String get firstName => 'Vārds';

  @override
  String get lastName => 'Uzvārds';

  @override
  String get mobileNumber => 'Mobilā tālruņa numurs';

  @override
  String get residentialAddress => 'Dzīvesvietas adrese';

  @override
  String get accountActions => 'Konts';

  @override
  String get danger => 'Bīstamā zona';

  @override
  String get addMedia => 'Pievienot multividi';

  @override
  String get addMediaOptional => 'Pievienot multividi (neobligāti)';

  @override
  String addMediaSubtitle(int maxPhotos, int maxSeconds) {
    return 'Pievienojiet līdz $maxPhotos foto un 1 video ($maxSeconds sek maks.), vai izlaidiet, lai turpinātu bez multivides';
  }

  @override
  String get addMoreMedia => 'Pievienot vairāk';

  @override
  String captureWithCamera(int maxPhotos) {
    return 'Uzņemt ar kameru (līdz $maxPhotos foto)';
  }

  @override
  String selectFromGallery(int maxPhotos) {
    return 'Izvēlēties no galerijas (līdz $maxPhotos foto)';
  }

  @override
  String get chooseVideo => 'Izvēlēties video';

  @override
  String selectShortVideo(int maxSeconds) {
    return 'Īsu video (maks. $maxSeconds sekundes)';
  }

  @override
  String get noMediaUploaded => 'Nav augšupielādēta multivide';

  @override
  String get reportDetails => 'Ziņojuma detaļas';

  @override
  String get roleResident => 'Iedzīvotājs';

  @override
  String get roleWorker => 'Darbinieks';

  @override
  String get roleOfficeAdmin => 'Biroja administrators';

  @override
  String get deleteReportConfirm =>
      'Vai tiešām vēlaties dzēst šo ziņojumu? Šo darbību nevar atsaukt.';

  @override
  String get reportDeleted => 'Ziņojums veiksmīgi dzēsts';

  @override
  String get reporterInfo => 'Ziņotāja informācija';

  @override
  String get reporterFullName => 'Pilns vārds';

  @override
  String get reporterPhoneNumber => 'Tālruņa numurs';

  @override
  String get reports => 'Ziņojumi';

  @override
  String get locationFromPhoto => 'Atrašanās vieta iegūta no foto GPS';

  @override
  String get locationFromDevice => 'Izmanto jūsu ierīces atrašanās vietu';

  @override
  String get locationManual => 'Atrašanās vieta pielāgota manuāli';

  @override
  String get dragToAdjust => 'Velciet karti, lai pielāgotu atrašanās vietu';

  @override
  String get profileUpdated => 'Profils veiksmīgi atjaunināts';

  @override
  String get tapToViewAndRetry =>
      'Pieskarieties, lai skatītu un mēģinātu vēlreiz';

  @override
  String get issues => 'Problēmas';

  @override
  String get aboutSaliena => 'Par Salienu';

  @override
  String get developer => 'Izstrādātājs';

  @override
  String get contact => 'Kontakti';

  @override
  String get website => 'Tīmekļa vietne';

  @override
  String get legal => 'Juridiskā informācija';

  @override
  String get termsOfService => 'Pakalpojumu noteikumi';

  @override
  String get privacyPolicy => 'Privātuma politika';

  @override
  String get openSourceLicenses => 'Atvērtā koda licences';

  @override
  String get contactUs => 'Sazinieties ar mums';

  @override
  String get emailSupport => 'E-pasta atbalsts';

  @override
  String get phoneSupport => 'Tālruņa atbalsts';

  @override
  String get frequentlyAskedQuestions => 'Biežāk uzdotie jautājumi';

  @override
  String get supportHours => 'Atbalsta laiks';

  @override
  String get noMedia => 'Nav multivides';

  @override
  String get areYouSureSubmitWithoutMedia =>
      'Vai tiešām vēlaties iesniegt bez foto vai video?';

  @override
  String get submitAnyway => 'Iesniegt tik un tā';

  @override
  String get pleaseEnterTitle => 'Lūdzu, ievadiet virsrakstu';

  @override
  String get describeTheIssue => 'Aprakstiet problēmu';

  @override
  String get noInternetConnection => 'Nav interneta savienojuma';

  @override
  String get reportDataNotFound => 'Ziņojuma dati nav atrasti';

  @override
  String deleteReportFromQueue(String title) {
    return 'Dzēst \"$title\" no rindas?';
  }

  @override
  String get nameSurname => 'Vārds Uzvārds';

  @override
  String get mobile => 'Mobilais';

  @override
  String get recordVideo => 'Ierakstīt video';

  @override
  String recordVideoWithDuration(int maxSeconds) {
    return 'Ierakstīt video (maks. ${maxSeconds}s)';
  }

  @override
  String get locationFromDeviceGPS => 'Atrašanās vieta no ierīces GPS';

  @override
  String maximumPhotosAllowed(int maxPhotos) {
    return 'Maksimums $maxPhotos foto atļauts';
  }

  @override
  String get onlyOneVideoAllowed => 'Tikai 1 video atļauts vienam ziņojumam';

  @override
  String onlyMorePhotosAllowed(int remaining) {
    return 'Tikai $remaining vairāk foto atļauts. Pievienoti pirmie $remaining.';
  }
}
