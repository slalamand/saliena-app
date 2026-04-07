// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Saliena Support';

  @override
  String get welcome => 'Добро пожаловать в Saliena Support';

  @override
  String get welcomeSubtitle => 'Сообщайте о проблемах в вашем муниципалитете';

  @override
  String get municipality => 'Муниципалитет';

  @override
  String get getStarted => 'Начать';

  @override
  String get login => 'Войти';

  @override
  String get signIn => 'Войти';

  @override
  String get signup => 'Регистрация';

  @override
  String get email => 'Электронная почта';

  @override
  String get password => 'Пароль';

  @override
  String get confirmPassword => 'Подтвердите пароль';

  @override
  String get phone => 'Номер телефона';

  @override
  String get fullName => 'Полное имя';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get noAccount => 'Нет аккаунта?';

  @override
  String get hasAccount => 'Уже есть аккаунт?';

  @override
  String get welcomeBack => 'С возвращением';

  @override
  String get signInSubtitle =>
      'Войдите для управления запросами в муниципалитет';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get joinCommunity => 'Присоединяйтесь к сообществу Saliena';

  @override
  String get municipalityPortal => 'Портал муниципалитета';

  @override
  String get resetPassword => 'Сбросить пароль';

  @override
  String get resetPasswordSubtitle =>
      'Введите email для получения инструкций по сбросу';

  @override
  String get sendResetLink => 'Отправить ссылку для сброса';

  @override
  String get checkEmail => 'Проверьте почту';

  @override
  String resetLinkSent(String email) {
    return 'Мы отправили ссылку для сброса пароля на $email';
  }

  @override
  String get backToSignIn => 'Вернуться к входу';

  @override
  String get emailAddress => 'Адрес электронной почты';

  @override
  String get phoneNumber => 'Номер телефона';

  @override
  String get address => 'Адрес проживания';

  @override
  String get addressHint => 'Улица, Город, Почтовый индекс';

  @override
  String get termsAgreement =>
      'Создавая аккаунт, вы соглашаетесь с Условиями использования и Политикой конфиденциальности';

  @override
  String get emailRequired => 'Пожалуйста, введите email';

  @override
  String get emailInvalid => 'Пожалуйста, введите корректный email';

  @override
  String get passwordRequired => 'Пожалуйста, введите пароль';

  @override
  String passwordMinLength(int length) {
    return 'Пароль должен содержать минимум $length символов';
  }

  @override
  String get passwordUppercase => 'Пароль должен содержать заглавную букву';

  @override
  String get passwordNumber => 'Пароль должен содержать цифру';

  @override
  String get nameRequired => 'Пожалуйста, введите полное имя';

  @override
  String get nameMinLength => 'Имя должно содержать минимум 2 символа';

  @override
  String get phoneRequired => 'Пожалуйста, введите номер телефона';

  @override
  String get phoneInvalid => 'Пожалуйста, введите корректный номер телефона';

  @override
  String get confirmPasswordRequired => 'Пожалуйста, подтвердите пароль';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String signInWith(String provider) {
    return 'Войти через $provider';
  }

  @override
  String get verifyPhone => 'Подтвердите email';

  @override
  String verifyPhoneSubtitle(String email) {
    return 'Введите код, отправленный на $email';
  }

  @override
  String get otpCode => 'Код подтверждения';

  @override
  String get resendCode => 'Отправить код повторно';

  @override
  String resendCodeIn(int seconds) {
    return 'Отправить код повторно через $secondsс';
  }

  @override
  String get setup2FA => 'Настройка двухфакторной аутентификации';

  @override
  String get setup2FASubtitle =>
      'Отсканируйте этот QR-код приложением-аутентификатором';

  @override
  String get enter2FACode => 'Введите 6-значный код из приложения';

  @override
  String get verify => 'Подтвердить';

  @override
  String get home => 'Главная';

  @override
  String get map => 'Карта';

  @override
  String get report => 'Сообщение';

  @override
  String get profile => 'Профиль';

  @override
  String get settings => 'Настройки';

  @override
  String get createReport => 'Создать сообщение';

  @override
  String get reportTitle => 'Заголовок';

  @override
  String get reportTitleHint => 'Краткое описание проблемы';

  @override
  String get reportDescription => 'Описание';

  @override
  String get reportDescriptionHint =>
      'Предоставьте больше информации о проблеме';

  @override
  String get takePhoto => 'Сделать фото';

  @override
  String get choosePhoto => 'Выбрать из галереи';

  @override
  String get location => 'Местоположение';

  @override
  String get locationDetected => 'Местоположение определено автоматически';

  @override
  String get submit => 'Отправить';

  @override
  String get submitting => 'Отправка...';

  @override
  String get reportStatus => 'Статус';

  @override
  String get statusPending => 'Ожидает';

  @override
  String get statusInProgress => 'В работе';

  @override
  String get statusFixed => 'Исправлено';

  @override
  String get markAsFixed => 'Отметить как исправленное';

  @override
  String reportedBy(String name) {
    return 'Сообщил $name';
  }

  @override
  String reportedOn(String date) {
    return 'Сообщено $date';
  }

  @override
  String fixedBy(String name) {
    return 'Исправил $name';
  }

  @override
  String get myReports => 'Мои сообщения';

  @override
  String get communityReports => 'Сообщения сообщества';

  @override
  String get allReports => 'Все отчеты';

  @override
  String get noReports => 'Пока нет сообщений';

  @override
  String get noReportsSubtitle =>
      'Будьте первым, кто сообщит о проблеме в вашем районе';

  @override
  String get language => 'Язык';

  @override
  String get english => 'Английский';

  @override
  String get latvian => 'Латышский';

  @override
  String get russian => 'Русский';

  @override
  String get notifications => 'Уведомления';

  @override
  String get security => 'Безопасность';

  @override
  String get about => 'О приложении';

  @override
  String get logout => 'Выйти';

  @override
  String get logoutConfirm => 'Вы уверены, что хотите выйти?';

  @override
  String get cancel => 'Отмена';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get delete => 'Удалить';

  @override
  String get save => 'Сохранить';

  @override
  String get edit => 'Редактировать';

  @override
  String get close => 'Закрыть';

  @override
  String get retry => 'Повторить';

  @override
  String get loading => 'Загрузка...';

  @override
  String get errorGeneric =>
      'Что-то пошло не так. Пожалуйста, попробуйте снова.';

  @override
  String get errorNetwork => 'Нет подключения к интернету. Проверьте сеть.';

  @override
  String get errorAuth => 'Ошибка аутентификации. Попробуйте снова.';

  @override
  String get errorPermission => 'У вас нет разрешения на это действие.';

  @override
  String get errorNotFound => 'Запрошенный ресурс не найден.';

  @override
  String get errorValidation =>
      'Проверьте введённые данные и попробуйте снова.';

  @override
  String get permissionCamera => 'Для съёмки фото требуется разрешение камеры';

  @override
  String get permissionLocation =>
      'Для отправки сообщений требуется разрешение на местоположение';

  @override
  String get permissionStorage =>
      'Для сохранения фото требуется разрешение на хранилище';

  @override
  String get grantPermission => 'Предоставить разрешение';

  @override
  String get verificationPending => 'Проверка в процессе';

  @override
  String get verificationPendingSubtitle =>
      'Ваш аккаунт проверяется как житель Saliena. Обычно это занимает 1-2 рабочих дня.';

  @override
  String get twoFactorAuth => 'Двухфакторная аутентификация';

  @override
  String get twoFactorAuthSubtitle =>
      'Введите код из приложения-аутентификатора';

  @override
  String get verifyPhoneNumber => 'Подтвердите email';

  @override
  String get verifyPhoneNumberSubtitle =>
      'Введите код подтверждения, отправленный на ваш email';

  @override
  String get checkYourPhone => 'Проверьте почту';

  @override
  String get checkYourPhoneDesc => 'Код подтверждения отправлен на ваш email';

  @override
  String get codeSentTo => 'Код отправлен на';

  @override
  String get codeSentToDesc => 'Введите 6-значный код из письма:';

  @override
  String get enterVerificationCode => 'Введите код подтверждения';

  @override
  String get enterVerificationCodeDesc => 'Введите 6-значный код из письма:';

  @override
  String get verifyCode => 'Подтвердить код';

  @override
  String get useDifferentAccount => 'Использовать другой аккаунт';

  @override
  String get accountInfo => 'Информация об аккаунте';

  @override
  String get memberSince => 'Участник с';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get changePassword => 'Сменить пароль';

  @override
  String get theme => 'Тема';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Темная';

  @override
  String get helpSupport => 'Помощь и поддержка';

  @override
  String get filterReports => 'Фильтр сообщений';

  @override
  String get applyFilters => 'Применить фильтры';

  @override
  String get unknownLocation => 'Неизвестное местоположение';

  @override
  String get gettingLocation => 'Определение местоположения...';

  @override
  String get notSet => 'Не задано';

  @override
  String get verified => 'Подтвержден';

  @override
  String get pending => 'Ожидает';

  @override
  String get today => 'Сегодня';

  @override
  String get yesterday => 'Вчера';

  @override
  String daysAgo(int days) {
    return '$days дн. назад';
  }

  @override
  String get chooseTheme => 'Выберите тему';

  @override
  String get reportIssue => 'Сообщить о проблеме';

  @override
  String get addPhoto => 'Добавить фото';

  @override
  String get addPhotoSubtitle => 'Сделайте или выберите фото проблемы';

  @override
  String get confirmLocation => 'Подтвердить местоположение';

  @override
  String get confirmLocationSubtitle =>
      'Перетащите карту для уточнения местоположения';

  @override
  String get addDetails => 'Добавить детали';

  @override
  String get addDetailsSubtitle =>
      'Опишите проблему, чтобы мы могли разобраться';

  @override
  String get reportSummary => 'Сводка отчета';

  @override
  String get photoAdded => 'Фото добавлено';

  @override
  String get locationNotSet => 'Местоположение не задано';

  @override
  String get back => 'Назад';

  @override
  String get continueStep => 'Далее';

  @override
  String get submitReport => 'Отправить отчет';

  @override
  String get reportsFeed => 'Лента отчетов';

  @override
  String get viewOnMap => 'Показать на карте';

  @override
  String get deleteReport => 'Удалить отчет';

  @override
  String get markAsInProgress => 'Отметить \'В работе\'';

  @override
  String get tapToAddPhoto => 'Нажмите, чтобы добавить фото';

  @override
  String get takePhotoOrGallery => 'Сделайте фото или выберите из галереи';

  @override
  String get reportSubmittedSuccess => 'Отчет успешно отправлен!';

  @override
  String get photoRequired => 'Пожалуйста, добавьте фото проблемы';

  @override
  String get locationRequired => 'Требуется местоположение';

  @override
  String get photo => 'Фото';

  @override
  String get details => 'Детали';

  @override
  String get useMyLocation => 'Использовать моё местоположение';

  @override
  String get tapToSelectLocation =>
      'Нажмите на карту, чтобы выбрать местоположение';

  @override
  String get tapToReportNewIssue => 'Нажмите, чтобы сообщить о новой проблеме';

  @override
  String get viewAll => 'Посмотреть все';

  @override
  String get verifyingLocation => 'Проверка местоположения...';

  @override
  String get outsideServiceArea => 'За пределами зоны обслуживания';

  @override
  String get locationPermissionDenied =>
      'Разрешение на определение местоположения отклонено. Нам нужно ваше местоположение для проверки места жительства.';

  @override
  String get locationServicesDisabled =>
      'Службы определения местоположения отключены. Пожалуйста, включите GPS, чтобы продолжить.';

  @override
  String get signupRestrictedToResidents =>
      'Регистрация доступна только жителям Салиены.';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get enableGPS => 'Включить GPS';

  @override
  String get accountDeleted => 'Аккаунт успешно удален';

  @override
  String get accountDeletedMessage => 'Ваш аккаунт был навсегда удален.';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get deleteAccountConfirm =>
      'Вы уверены, что хотите удалить свой аккаунт? Это действие нельзя отменить.';

  @override
  String get deleteAccountWarning =>
      'Все ваши данные будут безвозвратно удалены.';

  @override
  String get signOut => 'Выйти';

  @override
  String get signOutConfirm => 'Вы уверены, что хотите выйти?';

  @override
  String get preferredLanguage => 'Предпочтительный язык';

  @override
  String get personalInformation => 'Личная информация';

  @override
  String get firstName => 'Имя';

  @override
  String get lastName => 'Фамилия';

  @override
  String get mobileNumber => 'Номер мобильного телефона';

  @override
  String get residentialAddress => 'Адрес проживания';

  @override
  String get accountActions => 'Аккаунт';

  @override
  String get danger => 'Опасная зона';

  @override
  String get addMedia => 'Добавить медиа';

  @override
  String get addMediaOptional => 'Добавить медиа (необязательно)';

  @override
  String addMediaSubtitle(int maxPhotos, int maxSeconds) {
    return 'Добавьте до $maxPhotos фото и 1 видео ($maxSeconds сек макс.), или пропустите для продолжения без медиа';
  }

  @override
  String get addMoreMedia => 'Добавить ещё';

  @override
  String captureWithCamera(int maxPhotos) {
    return 'Снять камерой (до $maxPhotos фото)';
  }

  @override
  String selectFromGallery(int maxPhotos) {
    return 'Выбрать из галереи (до $maxPhotos фото)';
  }

  @override
  String get chooseVideo => 'Выбрать видео';

  @override
  String selectShortVideo(int maxSeconds) {
    return 'Короткое видео (макс. $maxSeconds секунд)';
  }

  @override
  String get noMediaUploaded => 'Медиа не загружено';

  @override
  String get reportDetails => 'Детали сообщения';

  @override
  String get roleResident => 'Житель';

  @override
  String get roleWorker => 'Работник';

  @override
  String get roleOfficeAdmin => 'Администратор офиса';

  @override
  String get deleteReportConfirm =>
      'Вы уверены, что хотите удалить этот отчет? Это действие нельзя отменить.';

  @override
  String get reportDeleted => 'Отчет успешно удален';

  @override
  String get reporterInfo => 'Информация о заявителе';

  @override
  String get reporterFullName => 'Полное имя';

  @override
  String get reporterPhoneNumber => 'Номер телефона';

  @override
  String get reports => 'Отчёты';

  @override
  String get locationFromPhoto => 'Местоположение извлечено из GPS фото';

  @override
  String get locationFromDevice =>
      'Используется местоположение вашего устройства';

  @override
  String get locationManual => 'Местоположение настроено вручную';

  @override
  String get dragToAdjust => 'Перетащите карту, чтобы настроить местоположение';

  @override
  String get profileUpdated => 'Профиль успешно обновлен';

  @override
  String get tapToViewAndRetry => 'Нажмите для просмотра и повтора';

  @override
  String get issues => 'Проблемы';

  @override
  String get aboutSaliena => 'О Салиене';

  @override
  String get developer => 'Разработчик';

  @override
  String get contact => 'Контакты';

  @override
  String get website => 'Веб-сайт';

  @override
  String get legal => 'Правовая информация';

  @override
  String get termsOfService => 'Условия обслуживания';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get openSourceLicenses => 'Лицензии открытого кода';

  @override
  String get contactUs => 'Свяжитесь с нами';

  @override
  String get emailSupport => 'Поддержка по email';

  @override
  String get phoneSupport => 'Телефонная поддержка';

  @override
  String get frequentlyAskedQuestions => 'Часто задаваемые вопросы';

  @override
  String get supportHours => 'Часы поддержки';

  @override
  String get noMedia => 'Нет медиа';

  @override
  String get areYouSureSubmitWithoutMedia =>
      'Вы уверены, что хотите отправить без фото или видео?';

  @override
  String get submitAnyway => 'Отправить в любом случае';

  @override
  String get pleaseEnterTitle => 'Пожалуйста, введите заголовок';

  @override
  String get describeTheIssue => 'Опишите проблему';

  @override
  String get noInternetConnection => 'Нет подключения к интернету';

  @override
  String get reportDataNotFound => 'Данные отчета не найдены';

  @override
  String deleteReportFromQueue(String title) {
    return 'Удалить \"$title\" из очереди?';
  }

  @override
  String get nameSurname => 'Имя Фамилия';

  @override
  String get mobile => 'Мобильный';

  @override
  String get recordVideo => 'Записать видео';

  @override
  String recordVideoWithDuration(int maxSeconds) {
    return 'Записать видео (макс. $maxSecondsс)';
  }

  @override
  String get locationFromDeviceGPS => 'Местоположение с GPS устройства';

  @override
  String maximumPhotosAllowed(int maxPhotos) {
    return 'Максимум $maxPhotos фото разрешено';
  }

  @override
  String get onlyOneVideoAllowed => 'Только 1 видео разрешено на отчет';

  @override
  String onlyMorePhotosAllowed(int remaining) {
    return 'Только $remaining фото разрешено. Добавлены первые $remaining.';
  }
}
