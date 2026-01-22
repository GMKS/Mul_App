import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_te.dart';

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
    Locale('hi'),
    Locale('te')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'My City App'**
  String get appTitle;

  /// No description provided for @regional.
  ///
  /// In en, this message translates to:
  /// **'Regional'**
  String get regional;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @devotional.
  ///
  /// In en, this message translates to:
  /// **'Devotional'**
  String get devotional;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @cabServices.
  ///
  /// In en, this message translates to:
  /// **'Cab Services'**
  String get cabServices;

  /// No description provided for @localAlerts.
  ///
  /// In en, this message translates to:
  /// **'Local Alerts'**
  String get localAlerts;

  /// No description provided for @eventsAndFestivals.
  ///
  /// In en, this message translates to:
  /// **'Events & Festivals'**
  String get eventsAndFestivals;

  /// No description provided for @emergencyServices.
  ///
  /// In en, this message translates to:
  /// **'Emergency Services'**
  String get emergencyServices;

  /// No description provided for @jobsAndOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Jobs & Opportunities'**
  String get jobsAndOpportunities;

  /// No description provided for @educationCorner.
  ///
  /// In en, this message translates to:
  /// **'Education Corner'**
  String get educationCorner;

  /// No description provided for @marketPrices.
  ///
  /// In en, this message translates to:
  /// **'Market Prices'**
  String get marketPrices;

  /// No description provided for @marketplaceAndClassifieds.
  ///
  /// In en, this message translates to:
  /// **'Marketplace & Classifieds'**
  String get marketplaceAndClassifieds;

  /// No description provided for @communityHelp.
  ///
  /// In en, this message translates to:
  /// **'Community Help'**
  String get communityHelp;

  /// No description provided for @homeServices.
  ///
  /// In en, this message translates to:
  /// **'Home Services'**
  String get homeServices;

  /// No description provided for @feedbackAndSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Feedback & Suggestions'**
  String get feedbackAndSuggestions;

  /// No description provided for @servicesDirectory.
  ///
  /// In en, this message translates to:
  /// **'Services Directory'**
  String get servicesDirectory;

  /// No description provided for @buySellRent.
  ///
  /// In en, this message translates to:
  /// **'Buy/Sell/Rent'**
  String get buySellRent;

  /// No description provided for @jobsAndGigs.
  ///
  /// In en, this message translates to:
  /// **'Jobs & Gigs'**
  String get jobsAndGigs;

  /// No description provided for @servicesOffered.
  ///
  /// In en, this message translates to:
  /// **'Services Offered'**
  String get servicesOffered;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @reportIssues.
  ///
  /// In en, this message translates to:
  /// **'Report Issues'**
  String get reportIssues;

  /// No description provided for @civicServices.
  ///
  /// In en, this message translates to:
  /// **'Civic Services'**
  String get civicServices;

  /// No description provided for @billPayments.
  ///
  /// In en, this message translates to:
  /// **'Bill Payments'**
  String get billPayments;

  /// No description provided for @cleaningAndRepair.
  ///
  /// In en, this message translates to:
  /// **'Cleaning & Repair'**
  String get cleaningAndRepair;

  /// No description provided for @homeDelivery.
  ///
  /// In en, this message translates to:
  /// **'Home Delivery'**
  String get homeDelivery;

  /// No description provided for @laundryAndTailoring.
  ///
  /// In en, this message translates to:
  /// **'Laundry & Tailoring'**
  String get laundryAndTailoring;

  /// No description provided for @communityPolls.
  ///
  /// In en, this message translates to:
  /// **'Community Polls'**
  String get communityPolls;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @suggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// No description provided for @bloodDonation.
  ///
  /// In en, this message translates to:
  /// **'Blood Donation'**
  String get bloodDonation;

  /// No description provided for @volunteerOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Volunteer Opportunities'**
  String get volunteerOpportunities;

  /// No description provided for @helpRequests.
  ///
  /// In en, this message translates to:
  /// **'Help Requests'**
  String get helpRequests;

  /// No description provided for @garbageCollection.
  ///
  /// In en, this message translates to:
  /// **'Garbage Collection'**
  String get garbageCollection;

  /// No description provided for @potholesAndRoads.
  ///
  /// In en, this message translates to:
  /// **'Potholes & Roads'**
  String get potholesAndRoads;

  /// No description provided for @waterSupply.
  ///
  /// In en, this message translates to:
  /// **'Water Supply'**
  String get waterSupply;

  /// No description provided for @streetLights.
  ///
  /// In en, this message translates to:
  /// **'Street Lights'**
  String get streetLights;

  /// No description provided for @governmentSchemes.
  ///
  /// In en, this message translates to:
  /// **'Government Schemes'**
  String get governmentSchemes;

  /// No description provided for @municipalityContacts.
  ///
  /// In en, this message translates to:
  /// **'Municipality Contacts'**
  String get municipalityContacts;

  /// No description provided for @furniture.
  ///
  /// In en, this message translates to:
  /// **'Furniture'**
  String get furniture;

  /// No description provided for @electronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get electronics;

  /// No description provided for @vehicles.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get vehicles;

  /// No description provided for @realEstate.
  ///
  /// In en, this message translates to:
  /// **'Real Estate'**
  String get realEstate;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// No description provided for @urgent.
  ///
  /// In en, this message translates to:
  /// **'URGENT'**
  String get urgent;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'REQUIRED'**
  String get required;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not Available'**
  String get notAvailable;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @reported.
  ///
  /// In en, this message translates to:
  /// **'Reported'**
  String get reported;

  /// No description provided for @acknowledged.
  ///
  /// In en, this message translates to:
  /// **'Acknowledged'**
  String get acknowledged;

  /// No description provided for @resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @book.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

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

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// Distance in kilometers
  ///
  /// In en, this message translates to:
  /// **'{distance} km away'**
  String kmAway(String distance);

  /// Hourly rate
  ///
  /// In en, this message translates to:
  /// **'₹{amount}/hour'**
  String perHour(String amount);

  /// Price per kilogram
  ///
  /// In en, this message translates to:
  /// **'₹{amount}/kg'**
  String perKg(String amount);

  /// Star rating
  ///
  /// In en, this message translates to:
  /// **'{rating} ★'**
  String rating(String rating);

  /// Years of experience
  ///
  /// In en, this message translates to:
  /// **'{years} years experience'**
  String yearsExperience(String years);

  /// Vote count
  ///
  /// In en, this message translates to:
  /// **'{count} votes'**
  String votes(String count);

  /// No description provided for @postVideo.
  ///
  /// In en, this message translates to:
  /// **'Post Video'**
  String get postVideo;

  /// No description provided for @quickAction.
  ///
  /// In en, this message translates to:
  /// **'Quick Action'**
  String get quickAction;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @primaryLanguage.
  ///
  /// In en, this message translates to:
  /// **'Primary Language'**
  String get primaryLanguage;

  /// No description provided for @secondaryLanguage.
  ///
  /// In en, this message translates to:
  /// **'Secondary Language (Optional)'**
  String get secondaryLanguage;

  /// No description provided for @selectRegion.
  ///
  /// In en, this message translates to:
  /// **'Select Region'**
  String get selectRegion;

  /// No description provided for @selectState.
  ///
  /// In en, this message translates to:
  /// **'Select State'**
  String get selectState;

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select City'**
  String get selectCity;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @telugu.
  ///
  /// In en, this message translates to:
  /// **'Telugu'**
  String get telugu;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @tamil.
  ///
  /// In en, this message translates to:
  /// **'Tamil'**
  String get tamil;

  /// No description provided for @kannada.
  ///
  /// In en, this message translates to:
  /// **'Kannada'**
  String get kannada;

  /// No description provided for @malayalam.
  ///
  /// In en, this message translates to:
  /// **'Malayalam'**
  String get malayalam;

  /// No description provided for @bengali.
  ///
  /// In en, this message translates to:
  /// **'Bengali'**
  String get bengali;

  /// No description provided for @marathi.
  ///
  /// In en, this message translates to:
  /// **'Marathi'**
  String get marathi;

  /// No description provided for @gujarati.
  ///
  /// In en, this message translates to:
  /// **'Gujarati'**
  String get gujarati;

  /// No description provided for @punjabi.
  ///
  /// In en, this message translates to:
  /// **'Punjabi'**
  String get punjabi;

  /// No description provided for @deepCleaning.
  ///
  /// In en, this message translates to:
  /// **'Deep Cleaning'**
  String get deepCleaning;

  /// No description provided for @pestControl.
  ///
  /// In en, this message translates to:
  /// **'Pest Control'**
  String get pestControl;

  /// No description provided for @acRepair.
  ///
  /// In en, this message translates to:
  /// **'AC Repair'**
  String get acRepair;

  /// No description provided for @plumbing.
  ///
  /// In en, this message translates to:
  /// **'Plumbing'**
  String get plumbing;

  /// No description provided for @electrical.
  ///
  /// In en, this message translates to:
  /// **'Electrical Work'**
  String get electrical;

  /// No description provided for @carpentry.
  ///
  /// In en, this message translates to:
  /// **'Carpentry'**
  String get carpentry;

  /// No description provided for @painting.
  ///
  /// In en, this message translates to:
  /// **'Painting'**
  String get painting;

  /// No description provided for @groceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get groceries;

  /// No description provided for @medicines.
  ///
  /// In en, this message translates to:
  /// **'Medicines'**
  String get medicines;

  /// No description provided for @milk.
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get milk;

  /// No description provided for @lpgGas.
  ///
  /// In en, this message translates to:
  /// **'LPG Gas'**
  String get lpgGas;

  /// No description provided for @waterCans.
  ///
  /// In en, this message translates to:
  /// **'Water Cans'**
  String get waterCans;

  /// No description provided for @washAndIron.
  ///
  /// In en, this message translates to:
  /// **'Wash & Iron'**
  String get washAndIron;

  /// No description provided for @dryCleaning.
  ///
  /// In en, this message translates to:
  /// **'Dry Cleaning'**
  String get dryCleaning;

  /// No description provided for @stitching.
  ///
  /// In en, this message translates to:
  /// **'Stitching'**
  String get stitching;

  /// No description provided for @alterations.
  ///
  /// In en, this message translates to:
  /// **'Alterations'**
  String get alterations;

  /// No description provided for @createPoll.
  ///
  /// In en, this message translates to:
  /// **'Create Poll'**
  String get createPoll;

  /// No description provided for @submitFeedback.
  ///
  /// In en, this message translates to:
  /// **'Submit Feedback'**
  String get submitFeedback;

  /// No description provided for @suggestFeature.
  ///
  /// In en, this message translates to:
  /// **'Suggest Feature'**
  String get suggestFeature;

  /// No description provided for @appExperience.
  ///
  /// In en, this message translates to:
  /// **'App Experience'**
  String get appExperience;

  /// No description provided for @mostVotedSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Most Voted Suggestions'**
  String get mostVotedSuggestions;

  /// No description provided for @recentSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Recent Suggestions'**
  String get recentSuggestions;

  /// No description provided for @activePoll.
  ///
  /// In en, this message translates to:
  /// **'Active Polls'**
  String get activePoll;

  /// No description provided for @closedPolls.
  ///
  /// In en, this message translates to:
  /// **'Closed Polls'**
  String get closedPolls;

  /// No description provided for @recentFeedback.
  ///
  /// In en, this message translates to:
  /// **'Recent Community Feedback'**
  String get recentFeedback;

  /// No description provided for @electricityBill.
  ///
  /// In en, this message translates to:
  /// **'Electricity Bill'**
  String get electricityBill;

  /// No description provided for @waterBill.
  ///
  /// In en, this message translates to:
  /// **'Water Bill'**
  String get waterBill;

  /// No description provided for @gasBill.
  ///
  /// In en, this message translates to:
  /// **'Gas Bill'**
  String get gasBill;

  /// No description provided for @propertyTax.
  ///
  /// In en, this message translates to:
  /// **'Property Tax'**
  String get propertyTax;

  /// No description provided for @mobileRecharge.
  ///
  /// In en, this message translates to:
  /// **'Mobile Recharge'**
  String get mobileRecharge;

  /// No description provided for @dthRecharge.
  ///
  /// In en, this message translates to:
  /// **'DTH Recharge'**
  String get dthRecharge;

  /// No description provided for @broadbandBill.
  ///
  /// In en, this message translates to:
  /// **'Broadband Bill'**
  String get broadbandBill;

  /// No description provided for @metroCard.
  ///
  /// In en, this message translates to:
  /// **'Metro Card Recharge'**
  String get metroCard;

  /// No description provided for @bloodType.
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get bloodType;

  /// No description provided for @hospitalName.
  ///
  /// In en, this message translates to:
  /// **'Hospital Name'**
  String get hospitalName;

  /// No description provided for @contactNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact Number'**
  String get contactNumber;

  /// No description provided for @donateNow.
  ///
  /// In en, this message translates to:
  /// **'Donate Now'**
  String get donateNow;

  /// No description provided for @volunteer.
  ///
  /// In en, this message translates to:
  /// **'Volunteer'**
  String get volunteer;

  /// No description provided for @viewMore.
  ///
  /// In en, this message translates to:
  /// **'View More'**
  String get viewMore;

  /// No description provided for @upvote.
  ///
  /// In en, this message translates to:
  /// **'Upvote'**
  String get upvote;

  /// No description provided for @downvote.
  ///
  /// In en, this message translates to:
  /// **'Downvote'**
  String get downvote;
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
      <String>['en', 'hi', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
