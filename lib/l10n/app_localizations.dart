import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';

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
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
  ];

  /// No description provided for @appname.
  ///
  /// In en, this message translates to:
  /// **'Greenexis'**
  String get appname;

  /// No description provided for @taglinemain.
  ///
  /// In en, this message translates to:
  /// **'Smart Farming Assistant'**
  String get taglinemain;

  /// No description provided for @taglinesub.
  ///
  /// In en, this message translates to:
  /// **'Grow smarter. Farm better.'**
  String get taglinesub;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Smart Farming Assistant'**
  String get tagline;

  /// No description provided for @selectlanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Your Language'**
  String get selectlanguage;

  /// No description provided for @chooselanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language to continue'**
  String get chooselanguage;

  /// No description provided for @continuee.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continuee;

  /// No description provided for @selectalanguage.
  ///
  /// In en, this message translates to:
  /// **'Select a Language'**
  String get selectalanguage;

  /// No description provided for @pleaseselectlanguage.
  ///
  /// In en, this message translates to:
  /// **'Please select a language to continue'**
  String get pleaseselectlanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @gujarati.
  ///
  /// In en, this message translates to:
  /// **'Gujarati'**
  String get gujarati;

  /// No description provided for @titleone.
  ///
  /// In en, this message translates to:
  /// **'The Next Generation of Farming'**
  String get titleone;

  /// No description provided for @descriptionone.
  ///
  /// In en, this message translates to:
  /// **'We provide smart data that enables the goals of modern global agriculture.'**
  String get descriptionone;

  /// No description provided for @titletwo.
  ///
  /// In en, this message translates to:
  /// **'Detect Crop Diseases Easily'**
  String get titletwo;

  /// No description provided for @descriptiontwo.
  ///
  /// In en, this message translates to:
  /// **'Scan your plant using the camera and identify diseases instantly with AI.'**
  String get descriptiontwo;

  /// No description provided for @titlethree.
  ///
  /// In en, this message translates to:
  /// **'Track Your Farm Health'**
  String get titlethree;

  /// No description provided for @descriptionthree.
  ///
  /// In en, this message translates to:
  /// **'Monitor crops and keep a full history of all issues and treatments.'**
  String get descriptionthree;

  /// No description provided for @smartfarming.
  ///
  /// In en, this message translates to:
  /// **'Smart Farming'**
  String get smartfarming;

  /// No description provided for @aiscanner.
  ///
  /// In en, this message translates to:
  /// **'AI Scanner'**
  String get aiscanner;

  /// No description provided for @farmhealth.
  ///
  /// In en, this message translates to:
  /// **'Farm Health'**
  String get farmhealth;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getstarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getstarted;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcome;

  /// No description provided for @signinmessage.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your farm account'**
  String get signinmessage;

  /// No description provided for @phoneemail.
  ///
  /// In en, this message translates to:
  /// **'Phone or Email'**
  String get phoneemail;

  /// No description provided for @phoneemailhint.
  ///
  /// In en, this message translates to:
  /// **'Enter phone or email'**
  String get phoneemailhint;

  /// No description provided for @phoneemailerrorrequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get phoneemailerrorrequired;

  /// No description provided for @phoneemailerrorinvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter valid email or ten digit phone'**
  String get phoneemailerrorinvalid;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordhint.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get passwordhint;

  /// No description provided for @passworderrorrequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passworderrorrequired;

  /// No description provided for @passworderrormin.
  ///
  /// In en, this message translates to:
  /// **'Minimum six characters'**
  String get passworderrormin;

  /// No description provided for @rememberme.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberme;

  /// No description provided for @forgotpassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotpassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @orcontinuewith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orcontinuewith;

  /// No description provided for @googlelogin.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get googlelogin;

  /// No description provided for @newuser.
  ///
  /// In en, this message translates to:
  /// **'New farmer ?'**
  String get newuser;

  /// No description provided for @createaccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createaccount;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join Greenexis'**
  String get join;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register your farm today'**
  String get register;

  /// No description provided for @personaldetails.
  ///
  /// In en, this message translates to:
  /// **'Personal details'**
  String get personaldetails;

  /// No description provided for @fullname.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullname;

  /// No description provided for @enterfullname.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterfullname;

  /// No description provided for @namerequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get namerequired;

  /// No description provided for @phonenumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phonenumber;

  /// No description provided for @entermobile.
  ///
  /// In en, this message translates to:
  /// **'Enter mobile number'**
  String get entermobile;

  /// No description provided for @phonerequired.
  ///
  /// In en, this message translates to:
  /// **'Phone is required'**
  String get phonerequired;

  /// No description provided for @invalidphone.
  ///
  /// In en, this message translates to:
  /// **'Enter valid phone number'**
  String get invalidphone;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get email;

  /// No description provided for @enteremail.
  ///
  /// In en, this message translates to:
  /// **'Enter email optional'**
  String get enteremail;

  /// No description provided for @invalidemail.
  ///
  /// In en, this message translates to:
  /// **'Enter valid email'**
  String get invalidemail;

  /// No description provided for @createpass.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get createpass;

  /// No description provided for @createpassword.
  ///
  /// In en, this message translates to:
  /// **'Create password'**
  String get createpassword;

  /// No description provided for @minpassword.
  ///
  /// In en, this message translates to:
  /// **'Minimum six characters'**
  String get minpassword;

  /// No description provided for @confirmpassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmpassword;

  /// No description provided for @reenterpassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get reenterpassword;

  /// No description provided for @confirmrequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm password'**
  String get confirmrequired;

  /// No description provided for @passwordmismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordmismatch;

  /// No description provided for @weak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get weak;

  /// No description provided for @fair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get fair;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @strong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get strong;

  /// No description provided for @alreadyfarmer.
  ///
  /// In en, this message translates to:
  /// **'Already a farmer?'**
  String get alreadyfarmer;

  /// No description provided for @signin.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signin;
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
      <String>['en', 'gu', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
