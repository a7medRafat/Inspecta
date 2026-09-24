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

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see your requests, tasks and certificates.'**
  String get signInSubtitle;

  /// No description provided for @workEmail.
  ///
  /// In en, this message translates to:
  /// **'Work email'**
  String get workEmail;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'name@company.com'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @keepMeSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Keep me signed in'**
  String get keepMeSignedIn;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signInRoleHint.
  ///
  /// In en, this message translates to:
  /// **'You\'ll go straight to your own screens — supervisor, coordinator, inspector or technical manager.'**
  String get signInRoleHint;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'No account? Ask your admin to add you.'**
  String get noAccount;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get resetTitle;

  /// No description provided for @resetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your work email and we\'ll send you a link to set a new password.'**
  String get resetSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @resendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send again'**
  String get resendResetLink;

  /// No description provided for @checkInboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox'**
  String get checkInboxTitle;

  /// No description provided for @checkInboxMessage.
  ///
  /// In en, this message translates to:
  /// **'If this email has an account, a reset link is on its way. It expires in 1 hour.'**
  String get checkInboxMessage;

  /// No description provided for @rememberedIt.
  ///
  /// In en, this message translates to:
  /// **'Remembered it?'**
  String get rememberedIt;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// No description provided for @errorEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your work email.'**
  String get errorEmailRequired;

  /// No description provided for @errorEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get errorEmailInvalid;

  /// No description provided for @errorPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get errorPasswordRequired;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorAccountDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account is deactivated. Contact your admin.'**
  String get errorAccountDisabled;

  /// No description provided for @errorNoProfile.
  ///
  /// In en, this message translates to:
  /// **'Your account isn\'t set up yet. Ask your admin to give you a role.'**
  String get errorNoProfile;

  /// No description provided for @errorTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many failed attempts. Wait a few minutes and try again.'**
  String get errorTooManyAttempts;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your internet and try again.'**
  String get errorNetwork;

  /// No description provided for @errorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Sign-in isn\'t available right now. Try again later.'**
  String get errorUnavailable;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get errorUnknown;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @qualifications.
  ///
  /// In en, this message translates to:
  /// **'Qualifications'**
  String get qualifications;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need your email and password to sign in again.'**
  String get signOutConfirmMessage;

  /// No description provided for @roleSupervisor.
  ///
  /// In en, this message translates to:
  /// **'Supervisor'**
  String get roleSupervisor;

  /// No description provided for @roleCoordinator.
  ///
  /// In en, this message translates to:
  /// **'Coordinator'**
  String get roleCoordinator;

  /// No description provided for @roleInspector.
  ///
  /// In en, this message translates to:
  /// **'Inspector'**
  String get roleInspector;

  /// No description provided for @roleTechnicalManager.
  ///
  /// In en, this message translates to:
  /// **'Technical manager'**
  String get roleTechnicalManager;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @homeSupervisor.
  ///
  /// In en, this message translates to:
  /// **'Requests inbox'**
  String get homeSupervisor;

  /// No description provided for @homeCoordinator.
  ///
  /// In en, this message translates to:
  /// **'Ready to assign'**
  String get homeCoordinator;

  /// No description provided for @homeInspector.
  ///
  /// In en, this message translates to:
  /// **'My tasks'**
  String get homeInspector;

  /// No description provided for @homeTechnicalManager.
  ///
  /// In en, this message translates to:
  /// **'Review queue'**
  String get homeTechnicalManager;

  /// No description provided for @homeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get homeAdmin;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeComingSoon.
  ///
  /// In en, this message translates to:
  /// **'You\'re signed in and on the right screen. This list is built in a later feature.'**
  String get homeComingSoon;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 m ago} other{{count} m ago}}'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 h ago} other{{count} h ago}}'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 d ago} other{{count} d ago}}'**
  String daysAgo(int count);

  /// No description provided for @statusRequestReceived.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get statusRequestReceived;

  /// No description provided for @statusQuoteDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusQuoteDraft;

  /// No description provided for @statusQuoteSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get statusQuoteSent;

  /// No description provided for @statusClientCountered.
  ///
  /// In en, this message translates to:
  /// **'Countered'**
  String get statusClientCountered;

  /// No description provided for @statusQuoteRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusQuoteRejected;

  /// No description provided for @statusClientDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get statusClientDeclined;

  /// No description provided for @statusQuoteAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusQuoteAccepted;

  /// No description provided for @statusAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get statusAssigned;

  /// No description provided for @statusTaskAccepted.
  ///
  /// In en, this message translates to:
  /// **'Task accepted'**
  String get statusTaskAccepted;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get statusInProgress;

  /// No description provided for @statusCertificateSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Certificate submitted'**
  String get statusCertificateSubmitted;

  /// No description provided for @statusCertificateReturned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get statusCertificateReturned;

  /// No description provided for @statusCertificateApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusCertificateApproved;

  /// No description provided for @statusSentToClient.
  ///
  /// In en, this message translates to:
  /// **'Sent to client'**
  String get statusSentToClient;

  /// No description provided for @waitingOver24h.
  ///
  /// In en, this message translates to:
  /// **'Waiting 24h+'**
  String get waitingOver24h;

  /// No description provided for @requestsGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get requestsGreetingMorning;

  /// No description provided for @requestsGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get requestsGreetingAfternoon;

  /// No description provided for @requestsGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get requestsGreetingEvening;

  /// No description provided for @requestsGreetingNameRole.
  ///
  /// In en, this message translates to:
  /// **'{name} · {role}'**
  String requestsGreetingNameRole(String name, String role);

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @navRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get navRequests;

  /// No description provided for @navQuotations.
  ///
  /// In en, this message translates to:
  /// **'Quotations'**
  String get navQuotations;

  /// No description provided for @navClients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get navClients;

  /// No description provided for @searchRequestsHint.
  ///
  /// In en, this message translates to:
  /// **'Search client, equipment or ID'**
  String get searchRequestsHint;

  /// No description provided for @tabNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get tabNew;

  /// No description provided for @tabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get tabAll;

  /// No description provided for @tabCount.
  ///
  /// In en, this message translates to:
  /// **'{label} · {count}'**
  String tabCount(String label, int count);

  /// No description provided for @needsYourReply.
  ///
  /// In en, this message translates to:
  /// **'Needs your reply'**
  String get needsYourReply;

  /// No description provided for @allRequestsHeading.
  ///
  /// In en, this message translates to:
  /// **'All requests'**
  String get allRequestsHeading;

  /// No description provided for @newestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get newestFirst;

  /// No description provided for @reviewAndQuote.
  ///
  /// In en, this message translates to:
  /// **'Review & quote'**
  String get reviewAndQuote;

  /// No description provided for @continueQuote.
  ///
  /// In en, this message translates to:
  /// **'Continue quote'**
  String get continueQuote;

  /// No description provided for @clientReplied.
  ///
  /// In en, this message translates to:
  /// **'{name} replied'**
  String clientReplied(String name);

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @newClientTag.
  ///
  /// In en, this message translates to:
  /// **'New client'**
  String get newClientTag;

  /// No description provided for @unitsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 unit} other{{count} units}}'**
  String unitsCount(int count);

  /// No description provided for @emptyNewRequests.
  ///
  /// In en, this message translates to:
  /// **'No new requests. Nice and clear.'**
  String get emptyNewRequests;

  /// No description provided for @emptyAllRequests.
  ///
  /// In en, this message translates to:
  /// **'No requests yet.'**
  String get emptyAllRequests;

  /// No description provided for @emptySearch.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches \"{query}\".'**
  String emptySearch(String query);

  /// No description provided for @requestsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the requests inbox.'**
  String get requestsLoadError;

  /// No description provided for @requestsPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to view the requests inbox.'**
  String get requestsPermissionDenied;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @requestDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get requestDetailTitle;

  /// No description provided for @stepRequest.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get stepRequest;

  /// No description provided for @stepQuote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get stepQuote;

  /// No description provided for @stepAssign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get stepAssign;

  /// No description provided for @stepInspect.
  ///
  /// In en, this message translates to:
  /// **'Inspect'**
  String get stepInspect;

  /// No description provided for @stepCertify.
  ///
  /// In en, this message translates to:
  /// **'Certify'**
  String get stepCertify;

  /// No description provided for @stepSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get stepSent;

  /// No description provided for @clientLabel.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get clientLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @preferredDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Preferred date'**
  String get preferredDateLabel;

  /// No description provided for @accessNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Access notes'**
  String get accessNotesLabel;

  /// No description provided for @equipmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equipmentLabel;

  /// No description provided for @capacityLabel.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get capacityLabel;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @readFullEmail.
  ///
  /// In en, this message translates to:
  /// **'Read full email'**
  String get readFullEmail;

  /// No description provided for @notReadyToQuote.
  ///
  /// In en, this message translates to:
  /// **'Add the client, at least one equipment item and the location before quoting.'**
  String get notReadyToQuote;

  /// No description provided for @quotationBackendNotBuiltYet.
  ///
  /// In en, this message translates to:
  /// **'Saving and sending aren\'t connected to a server yet.'**
  String get quotationBackendNotBuiltYet;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'This isn\'t built yet.'**
  String get comingSoon;

  /// No description provided for @howDoYouWantToReply.
  ///
  /// In en, this message translates to:
  /// **'How do you want to reply?'**
  String get howDoYouWantToReply;

  /// No description provided for @replyAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get replyAccept;

  /// No description provided for @replyAcceptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use your standard rate'**
  String get replyAcceptSubtitle;

  /// No description provided for @replyOffer.
  ///
  /// In en, this message translates to:
  /// **'Send price offer'**
  String get replyOffer;

  /// No description provided for @replyOfferSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set a price for this request'**
  String get replyOfferSubtitle;

  /// No description provided for @replyReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get replyReject;

  /// No description provided for @replyRejectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell the client why'**
  String get replyRejectSubtitle;

  /// No description provided for @pricePerUnit.
  ///
  /// In en, this message translates to:
  /// **'Price per unit'**
  String get pricePerUnit;

  /// No description provided for @validFor.
  ///
  /// In en, this message translates to:
  /// **'Valid for'**
  String get validFor;

  /// No description provided for @validityDaysOption.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String validityDaysOption(int days);

  /// No description provided for @messageToClient.
  ///
  /// In en, this message translates to:
  /// **'Message to client'**
  String get messageToClient;

  /// No description provided for @optionalLabel.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get optionalLabel;

  /// No description provided for @reasonToClient.
  ///
  /// In en, this message translates to:
  /// **'Reason for rejecting'**
  String get reasonToClient;

  /// No description provided for @totalForUnits.
  ///
  /// In en, this message translates to:
  /// **'Total for {units}'**
  String totalForUnits(String units);

  /// No description provided for @standardRateApplies.
  ///
  /// In en, this message translates to:
  /// **'Uses your standard rate'**
  String get standardRateApplies;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get saveDraft;

  /// No description provided for @sendQuotation.
  ///
  /// In en, this message translates to:
  /// **'Send quotation'**
  String get sendQuotation;

  /// No description provided for @errorPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a price per unit.'**
  String get errorPriceRequired;

  /// No description provided for @errorReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Tell the client why you\'re rejecting.'**
  String get errorReasonRequired;

  /// No description provided for @actionPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to do that.'**
  String get actionPermissionDenied;

  /// No description provided for @actionFailed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get actionFailed;

  /// No description provided for @draftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved.'**
  String get draftSaved;

  /// No description provided for @quotationSent.
  ///
  /// In en, this message translates to:
  /// **'Quotation sent (v{version}).'**
  String quotationSent(int version);

  /// No description provided for @requestRejected.
  ///
  /// In en, this message translates to:
  /// **'Request rejected.'**
  String get requestRejected;

  /// No description provided for @quotationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quotations'**
  String get quotationsTitle;

  /// No description provided for @quotationsSupervisorLabel.
  ///
  /// In en, this message translates to:
  /// **'Supervisor'**
  String get quotationsSupervisorLabel;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @quotationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No quotations yet.'**
  String get quotationsEmpty;

  /// No description provided for @quoteVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'v{version}'**
  String quoteVersionLabel(int version);

  /// No description provided for @quoteDraftLabel.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get quoteDraftLabel;

  /// No description provided for @quotationExpiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get quotationExpiredLabel;

  /// No description provided for @quotationSupersededLabel.
  ///
  /// In en, this message translates to:
  /// **'Superseded'**
  String get quotationSupersededLabel;

  /// No description provided for @requestNoLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'This request is no longer available.'**
  String get requestNoLongerAvailable;

  /// No description provided for @quoteNumberVersion.
  ///
  /// In en, this message translates to:
  /// **'{quoteNumber} · {version}'**
  String quoteNumberVersion(String quoteNumber, String version);

  /// No description provided for @tabOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get tabOpen;

  /// No description provided for @tabReplied.
  ///
  /// In en, this message translates to:
  /// **'Replied'**
  String get tabReplied;

  /// No description provided for @tabAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get tabAccepted;

  /// No description provided for @tabLost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get tabLost;

  /// No description provided for @tileAwaitingClient.
  ///
  /// In en, this message translates to:
  /// **'Awaiting client'**
  String get tileAwaitingClient;

  /// No description provided for @tileClientReplied.
  ///
  /// In en, this message translates to:
  /// **'Client replied'**
  String get tileClientReplied;

  /// No description provided for @tileExpiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get tileExpiringSoon;

  /// No description provided for @tileAcceptedThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Accepted this month'**
  String get tileAcceptedThisMonth;

  /// No description provided for @openValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Open value'**
  String get openValueLabel;

  /// No description provided for @sortOldestFirstLabel.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get sortOldestFirstLabel;

  /// No description provided for @sentAgo.
  ///
  /// In en, this message translates to:
  /// **'Sent {time}'**
  String sentAgo(String time);

  /// No description provided for @repliedAgo.
  ///
  /// In en, this message translates to:
  /// **'Replied {time}'**
  String repliedAgo(String time);

  /// No description provided for @expiresIn.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Expires today} one{Expires in 1 day} other{Expires in {count} days}}'**
  String expiresIn(int count);

  /// No description provided for @expiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Expired {time}'**
  String expiredLabel(String time);

  /// No description provided for @quoteBadgeCounterOffer.
  ///
  /// In en, this message translates to:
  /// **'Counter-offer'**
  String get quoteBadgeCounterOffer;

  /// No description provided for @quoteBadgeQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get quoteBadgeQuestion;

  /// No description provided for @yourPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Your price'**
  String get yourPriceLabel;

  /// No description provided for @clientAsksLabel.
  ///
  /// In en, this message translates to:
  /// **'Client asks'**
  String get clientAsksLabel;

  /// No description provided for @actionSendReminder.
  ///
  /// In en, this message translates to:
  /// **'Send reminder'**
  String get actionSendReminder;

  /// No description provided for @actionRespond.
  ///
  /// In en, this message translates to:
  /// **'Respond'**
  String get actionRespond;

  /// No description provided for @actionExtendOrResend.
  ///
  /// In en, this message translates to:
  /// **'Extend or resend'**
  String get actionExtendOrResend;

  /// No description provided for @actionViewJob.
  ///
  /// In en, this message translates to:
  /// **'View job'**
  String get actionViewJob;

  /// No description provided for @actionRequote.
  ///
  /// In en, this message translates to:
  /// **'Re-quote'**
  String get actionRequote;

  /// No description provided for @reminderSent.
  ///
  /// In en, this message translates to:
  /// **'Reminder logged.'**
  String get reminderSent;

  /// No description provided for @boardEmptyOpen.
  ///
  /// In en, this message translates to:
  /// **'Nothing awaiting a client right now.'**
  String get boardEmptyOpen;

  /// No description provided for @boardEmptyReplied.
  ///
  /// In en, this message translates to:
  /// **'No replies waiting on you.'**
  String get boardEmptyReplied;

  /// No description provided for @boardEmptyAccepted.
  ///
  /// In en, this message translates to:
  /// **'Nothing accepted yet.'**
  String get boardEmptyAccepted;

  /// No description provided for @boardEmptyLost.
  ///
  /// In en, this message translates to:
  /// **'Nothing lost — good sign.'**
  String get boardEmptyLost;

  /// No description provided for @boardEmptySearch.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches \"{query}\".'**
  String boardEmptySearch(String query);

  /// No description provided for @searchQuotesHint.
  ///
  /// In en, this message translates to:
  /// **'Search client, request ID or quote number'**
  String get searchQuotesHint;

  /// No description provided for @quoteDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Quote history'**
  String get quoteDetailTitle;

  /// No description provided for @timelineSent.
  ///
  /// In en, this message translates to:
  /// **'Quote v{version} sent'**
  String timelineSent(int version);

  /// No description provided for @timelineDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get timelineDraft;

  /// No description provided for @timelineClientCountered.
  ///
  /// In en, this message translates to:
  /// **'Client countered {price}'**
  String timelineClientCountered(String price);

  /// No description provided for @timelineClientAccepted.
  ///
  /// In en, this message translates to:
  /// **'Client accepted'**
  String get timelineClientAccepted;

  /// No description provided for @timelineClientDeclined.
  ///
  /// In en, this message translates to:
  /// **'Client declined'**
  String get timelineClientDeclined;

  /// No description provided for @timelineRejectedByYou.
  ///
  /// In en, this message translates to:
  /// **'You rejected the request'**
  String get timelineRejectedByYou;

  /// No description provided for @timelineSupersededLabel.
  ///
  /// In en, this message translates to:
  /// **'Superseded'**
  String get timelineSupersededLabel;

  /// No description provided for @logClientReplyTitle.
  ///
  /// In en, this message translates to:
  /// **'Log the client\'s reply'**
  String get logClientReplyTitle;

  /// No description provided for @outcomeCounter.
  ///
  /// In en, this message translates to:
  /// **'Countered'**
  String get outcomeCounter;

  /// No description provided for @outcomeCounterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'They proposed a different price'**
  String get outcomeCounterSubtitle;

  /// No description provided for @outcomeAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get outcomeAccepted;

  /// No description provided for @outcomeAcceptedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'They agreed to this version'**
  String get outcomeAcceptedSubtitle;

  /// No description provided for @outcomeDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get outcomeDeclined;

  /// No description provided for @outcomeDeclinedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'They\'re not moving forward'**
  String get outcomeDeclinedSubtitle;

  /// No description provided for @clientPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Their price per unit'**
  String get clientPriceLabel;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteLabel;

  /// No description provided for @noteOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptionalLabel;

  /// No description provided for @logReply.
  ///
  /// In en, this message translates to:
  /// **'Log reply'**
  String get logReply;

  /// No description provided for @replyLogged.
  ///
  /// In en, this message translates to:
  /// **'Reply logged.'**
  String get replyLogged;

  /// No description provided for @sendNewVersion.
  ///
  /// In en, this message translates to:
  /// **'Send new version'**
  String get sendNewVersion;

  /// No description provided for @acceptedVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Accepted: {version}'**
  String acceptedVersionLabel(String version);

  /// No description provided for @readOnlyAcceptedNotice.
  ///
  /// In en, this message translates to:
  /// **'This quote was accepted. The price is locked.'**
  String get readOnlyAcceptedNotice;

  /// No description provided for @errorClientPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the client\'s price.'**
  String get errorClientPriceRequired;

  /// No description provided for @negotiationHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Negotiation history'**
  String get negotiationHistoryTitle;

  /// No description provided for @timelineRequestReceived.
  ///
  /// In en, this message translates to:
  /// **'Request received'**
  String get timelineRequestReceived;

  /// No description provided for @timelineViaEmail.
  ///
  /// In en, this message translates to:
  /// **'email'**
  String get timelineViaEmail;

  /// No description provided for @timelineViaManual.
  ///
  /// In en, this message translates to:
  /// **'manual entry'**
  String get timelineViaManual;

  /// No description provided for @timelineReceivedVia.
  ///
  /// In en, this message translates to:
  /// **'{date} · by {source}'**
  String timelineReceivedVia(String date, String source);

  /// No description provided for @timelineSentByYouMeta.
  ///
  /// In en, this message translates to:
  /// **'{date} · by you'**
  String timelineSentByYouMeta(String date);

  /// No description provided for @timelineValidDays.
  ///
  /// In en, this message translates to:
  /// **'valid {days} days'**
  String timelineValidDays(int days);

  /// No description provided for @timelineYourResponseTitle.
  ///
  /// In en, this message translates to:
  /// **'Your response'**
  String get timelineYourResponseTitle;

  /// No description provided for @timelineChooseOption.
  ///
  /// In en, this message translates to:
  /// **'Choose an option below'**
  String get timelineChooseOption;

  /// No description provided for @requestLabel.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get requestLabel;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @validUntilLabel.
  ///
  /// In en, this message translates to:
  /// **'{version} valid until'**
  String validUntilLabel(String version);

  /// No description provided for @yourTurnBadge.
  ///
  /// In en, this message translates to:
  /// **'Your turn'**
  String get yourTurnBadge;

  /// No description provided for @sendNewPriceVersion.
  ///
  /// In en, this message translates to:
  /// **'Send new price ({version})'**
  String sendNewPriceVersion(String version);

  /// No description provided for @acceptClientPrice.
  ///
  /// In en, this message translates to:
  /// **'Accept client\'s price'**
  String get acceptClientPrice;

  /// No description provided for @logOtherReply.
  ///
  /// In en, this message translates to:
  /// **'Log other reply'**
  String get logOtherReply;

  /// No description provided for @markDeclined.
  ///
  /// In en, this message translates to:
  /// **'Mark declined'**
  String get markDeclined;

  /// No description provided for @acceptDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Accepting sends the job to the coordinator and locks the price.'**
  String get acceptDisclaimer;

  /// No description provided for @respondToClientTitle.
  ///
  /// In en, this message translates to:
  /// **'Respond to client'**
  String get respondToClientTitle;

  /// No description provided for @clientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clientsTitle;

  /// No description provided for @addClient.
  ///
  /// In en, this message translates to:
  /// **'Add client'**
  String get addClient;

  /// No description provided for @searchClientsHint.
  ///
  /// In en, this message translates to:
  /// **'Search company, contact or email'**
  String get searchClientsHint;

  /// No description provided for @clientsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get clientsFilterAll;

  /// No description provided for @clientsFilterOpenJobs.
  ///
  /// In en, this message translates to:
  /// **'Open jobs'**
  String get clientsFilterOpenJobs;

  /// No description provided for @clientsFilterDueSoon.
  ///
  /// In en, this message translates to:
  /// **'Due soon'**
  String get clientsFilterDueSoon;

  /// No description provided for @clientsSortedByActivity.
  ///
  /// In en, this message translates to:
  /// **'Sorted by latest activity'**
  String get clientsSortedByActivity;

  /// No description provided for @equipmentCountChip.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 equipment} other{{count} equipment}}'**
  String equipmentCountChip(int count);

  /// No description provided for @openJobsCountChip.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 open job} other{{count} open jobs}}'**
  String openJobsCountChip(int count);

  /// No description provided for @dueSoonCountChip.
  ///
  /// In en, this message translates to:
  /// **'{count} due in 30 days'**
  String dueSoonCountChip(int count);

  /// No description provided for @newSenderNeedsClient.
  ///
  /// In en, this message translates to:
  /// **'New sender needs a client'**
  String get newSenderNeedsClient;

  /// No description provided for @matchAction.
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get matchAction;

  /// No description provided for @clientsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No clients yet.'**
  String get clientsEmpty;

  /// No description provided for @clientDetailEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get clientDetailEdit;

  /// No description provided for @newRequestButton.
  ///
  /// In en, this message translates to:
  /// **'New request'**
  String get newRequestButton;

  /// No description provided for @callAction.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callAction;

  /// No description provided for @emailAction.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailAction;

  /// No description provided for @phoneCopied.
  ///
  /// In en, this message translates to:
  /// **'Phone number copied.'**
  String get phoneCopied;

  /// No description provided for @emailCopied.
  ///
  /// In en, this message translates to:
  /// **'Email copied.'**
  String get emailCopied;

  /// No description provided for @noPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'No phone number on file.'**
  String get noPhoneNumber;

  /// No description provided for @noEmailOnFile.
  ///
  /// In en, this message translates to:
  /// **'No email on file.'**
  String get noEmailOnFile;

  /// No description provided for @equipmentStatLabel.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equipmentStatLabel;

  /// No description provided for @openJobsStatLabel.
  ///
  /// In en, this message translates to:
  /// **'Open jobs'**
  String get openJobsStatLabel;

  /// No description provided for @dueSoonStatLabel.
  ///
  /// In en, this message translates to:
  /// **'Due in 30 days'**
  String get dueSoonStatLabel;

  /// No description provided for @contactsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contactsTitle;

  /// No description provided for @addContactAction.
  ///
  /// In en, this message translates to:
  /// **'+ Add'**
  String get addContactAction;

  /// No description provided for @mainContactBadge.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get mainContactBadge;

  /// No description provided for @certificatesSentToLabel.
  ///
  /// In en, this message translates to:
  /// **'Certificates are sent to'**
  String get certificatesSentToLabel;

  /// No description provided for @changeAction.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeAction;

  /// No description provided for @noCertificatesEmail.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get noCertificatesEmail;

  /// No description provided for @historyTabRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get historyTabRequests;

  /// No description provided for @historyTabEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get historyTabEquipment;

  /// No description provided for @historyTabCertificates.
  ///
  /// In en, this message translates to:
  /// **'Certificates'**
  String get historyTabCertificates;

  /// No description provided for @clientHistoryEmptyRequests.
  ///
  /// In en, this message translates to:
  /// **'No requests from this client yet.'**
  String get clientHistoryEmptyRequests;

  /// No description provided for @clientHistoryEmptyEquipment.
  ///
  /// In en, this message translates to:
  /// **'No equipment on record yet.'**
  String get clientHistoryEmptyEquipment;

  /// No description provided for @clientHistoryEmptyCertificates.
  ///
  /// In en, this message translates to:
  /// **'Certificates aren\'t tracked yet.'**
  String get clientHistoryEmptyCertificates;

  /// No description provided for @addClientSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add client'**
  String get addClientSheetTitle;

  /// No description provided for @companyNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get companyNameLabel;

  /// No description provided for @contactNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact name'**
  String get contactNameLabel;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @createAction.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createAction;

  /// No description provided for @errorCompanyNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the company name.'**
  String get errorCompanyNameRequired;

  /// No description provided for @errorContactNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the contact\'s name.'**
  String get errorContactNameRequired;

  /// No description provided for @errorLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the location.'**
  String get errorLocationRequired;

  /// No description provided for @clientCreated.
  ///
  /// In en, this message translates to:
  /// **'Client added.'**
  String get clientCreated;

  /// No description provided for @addContactSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add contact'**
  String get addContactSheetTitle;

  /// No description provided for @contactAdded.
  ///
  /// In en, this message translates to:
  /// **'Contact added.'**
  String get contactAdded;

  /// No description provided for @matchSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Match to a client'**
  String get matchSheetTitle;

  /// No description provided for @matchNewClientOption.
  ///
  /// In en, this message translates to:
  /// **'New client'**
  String get matchNewClientOption;

  /// No description provided for @clientMatched.
  ///
  /// In en, this message translates to:
  /// **'Matched to client.'**
  String get clientMatched;

  /// No description provided for @certificatesEmailUpdated.
  ///
  /// In en, this message translates to:
  /// **'Certificates email updated.'**
  String get certificatesEmailUpdated;
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
