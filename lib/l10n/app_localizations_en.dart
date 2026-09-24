// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get back => 'Back';

  @override
  String get cancel => 'Cancel';

  @override
  String get signInTitle => 'Welcome back';

  @override
  String get signInSubtitle =>
      'Sign in to see your requests, tasks and certificates.';

  @override
  String get workEmail => 'Work email';

  @override
  String get emailHint => 'name@company.com';

  @override
  String get password => 'Password';

  @override
  String get keepMeSignedIn => 'Keep me signed in';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signIn => 'Sign in';

  @override
  String get signInRoleHint =>
      'You\'ll go straight to your own screens — supervisor, coordinator, inspector or technical manager.';

  @override
  String get noAccount => 'No account? Ask your admin to add you.';

  @override
  String get resetTitle => 'Reset your password';

  @override
  String get resetSubtitle =>
      'Enter your work email and we\'ll send you a link to set a new password.';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get resendResetLink => 'Send again';

  @override
  String get checkInboxTitle => 'Check your inbox';

  @override
  String get checkInboxMessage =>
      'If this email has an account, a reset link is on its way. It expires in 1 hour.';

  @override
  String get rememberedIt => 'Remembered it?';

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get errorEmailRequired => 'Enter your work email.';

  @override
  String get errorEmailInvalid => 'Enter a valid email address.';

  @override
  String get errorPasswordRequired => 'Enter your password.';

  @override
  String get errorInvalidCredentials => 'Email or password is incorrect.';

  @override
  String get errorAccountDisabled =>
      'This account is deactivated. Contact your admin.';

  @override
  String get errorNoProfile =>
      'Your account isn\'t set up yet. Ask your admin to give you a role.';

  @override
  String get errorTooManyAttempts =>
      'Too many failed attempts. Wait a few minutes and try again.';

  @override
  String get errorNetwork =>
      'No connection. Check your internet and try again.';

  @override
  String get errorUnavailable =>
      'Sign-in isn\'t available right now. Try again later.';

  @override
  String get errorUnknown => 'Something went wrong. Try again.';

  @override
  String get profile => 'Profile';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get qualifications => 'Qualifications';

  @override
  String get notSet => 'Not set';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutConfirmTitle => 'Sign out?';

  @override
  String get signOutConfirmMessage =>
      'You\'ll need your email and password to sign in again.';

  @override
  String get roleSupervisor => 'Supervisor';

  @override
  String get roleCoordinator => 'Coordinator';

  @override
  String get roleInspector => 'Inspector';

  @override
  String get roleTechnicalManager => 'Technical manager';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get homeSupervisor => 'Requests inbox';

  @override
  String get homeCoordinator => 'Ready to assign';

  @override
  String get homeInspector => 'My tasks';

  @override
  String get homeTechnicalManager => 'Review queue';

  @override
  String get homeAdmin => 'Users';

  @override
  String homeGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get homeComingSoon =>
      'You\'re signed in and on the right screen. This list is built in a later feature.';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count m ago',
      one: '1 m ago',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count h ago',
      one: '1 h ago',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count d ago',
      one: '1 d ago',
    );
    return '$_temp0';
  }

  @override
  String get statusRequestReceived => 'New';

  @override
  String get statusQuoteDraft => 'Draft';

  @override
  String get statusQuoteSent => 'Sent';

  @override
  String get statusClientCountered => 'Countered';

  @override
  String get statusQuoteRejected => 'Rejected';

  @override
  String get statusClientDeclined => 'Declined';

  @override
  String get statusQuoteAccepted => 'Accepted';

  @override
  String get statusAssigned => 'Assigned';

  @override
  String get statusTaskAccepted => 'Task accepted';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusCertificateSubmitted => 'Certificate submitted';

  @override
  String get statusCertificateReturned => 'Returned';

  @override
  String get statusCertificateApproved => 'Approved';

  @override
  String get statusSentToClient => 'Sent to client';

  @override
  String get waitingOver24h => 'Waiting 24h+';

  @override
  String get requestsGreetingMorning => 'Good morning';

  @override
  String get requestsGreetingAfternoon => 'Good afternoon';

  @override
  String get requestsGreetingEvening => 'Good evening';

  @override
  String requestsGreetingNameRole(String name, String role) {
    return '$name · $role';
  }

  @override
  String get notifications => 'Notifications';

  @override
  String get navRequests => 'Requests';

  @override
  String get navQuotations => 'Quotations';

  @override
  String get navClients => 'Clients';

  @override
  String get searchRequestsHint => 'Search client, equipment or ID';

  @override
  String get tabNew => 'New';

  @override
  String get tabAll => 'All';

  @override
  String tabCount(String label, int count) {
    return '$label · $count';
  }

  @override
  String get needsYourReply => 'Needs your reply';

  @override
  String get allRequestsHeading => 'All requests';

  @override
  String get newestFirst => 'Newest first';

  @override
  String get reviewAndQuote => 'Review & quote';

  @override
  String get continueQuote => 'Continue quote';

  @override
  String clientReplied(String name) {
    return '$name replied';
  }

  @override
  String get reply => 'Reply';

  @override
  String get newClientTag => 'New client';

  @override
  String unitsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count units',
      one: '1 unit',
    );
    return '$_temp0';
  }

  @override
  String get emptyNewRequests => 'No new requests. Nice and clear.';

  @override
  String get emptyAllRequests => 'No requests yet.';

  @override
  String emptySearch(String query) {
    return 'Nothing matches \"$query\".';
  }

  @override
  String get requestsLoadError => 'Couldn\'t load the requests inbox.';

  @override
  String get requestsPermissionDenied =>
      'You don\'t have permission to view the requests inbox.';

  @override
  String get retry => 'Retry';

  @override
  String get requestDetailTitle => 'Request';

  @override
  String get stepRequest => 'Request';

  @override
  String get stepQuote => 'Quote';

  @override
  String get stepAssign => 'Assign';

  @override
  String get stepInspect => 'Inspect';

  @override
  String get stepCertify => 'Certify';

  @override
  String get stepSent => 'Sent';

  @override
  String get clientLabel => 'Client';

  @override
  String get locationLabel => 'Location';

  @override
  String get preferredDateLabel => 'Preferred date';

  @override
  String get accessNotesLabel => 'Access notes';

  @override
  String get equipmentLabel => 'Equipment';

  @override
  String get capacityLabel => 'Capacity';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get readFullEmail => 'Read full email';

  @override
  String get notReadyToQuote =>
      'Add the client, at least one equipment item and the location before quoting.';

  @override
  String get quotationBackendNotBuiltYet =>
      'Saving and sending aren\'t connected to a server yet.';

  @override
  String get comingSoon => 'This isn\'t built yet.';

  @override
  String get howDoYouWantToReply => 'How do you want to reply?';

  @override
  String get replyAccept => 'Accept';

  @override
  String get replyAcceptSubtitle => 'Use your standard rate';

  @override
  String get replyOffer => 'Send price offer';

  @override
  String get replyOfferSubtitle => 'Set a price for this request';

  @override
  String get replyReject => 'Reject';

  @override
  String get replyRejectSubtitle => 'Tell the client why';

  @override
  String get pricePerUnit => 'Price per unit';

  @override
  String get validFor => 'Valid for';

  @override
  String validityDaysOption(int days) {
    return '$days days';
  }

  @override
  String get messageToClient => 'Message to client';

  @override
  String get optionalLabel => 'optional';

  @override
  String get reasonToClient => 'Reason for rejecting';

  @override
  String totalForUnits(String units) {
    return 'Total for $units';
  }

  @override
  String get standardRateApplies => 'Uses your standard rate';

  @override
  String get saveDraft => 'Save draft';

  @override
  String get sendQuotation => 'Send quotation';

  @override
  String get errorPriceRequired => 'Enter a price per unit.';

  @override
  String get errorReasonRequired => 'Tell the client why you\'re rejecting.';

  @override
  String get actionPermissionDenied => 'You don\'t have permission to do that.';

  @override
  String get actionFailed => 'Something went wrong. Try again.';

  @override
  String get draftSaved => 'Draft saved.';

  @override
  String quotationSent(int version) {
    return 'Quotation sent (v$version).';
  }

  @override
  String get requestRejected => 'Request rejected.';

  @override
  String get quotationsTitle => 'Quotations';

  @override
  String get quotationsSupervisorLabel => 'Supervisor';

  @override
  String get filter => 'Filter';

  @override
  String get quotationsEmpty => 'No quotations yet.';

  @override
  String quoteVersionLabel(int version) {
    return 'v$version';
  }

  @override
  String get quoteDraftLabel => 'Draft';

  @override
  String get quotationExpiredLabel => 'Expired';

  @override
  String get quotationSupersededLabel => 'Superseded';

  @override
  String get requestNoLongerAvailable => 'This request is no longer available.';

  @override
  String quoteNumberVersion(String quoteNumber, String version) {
    return '$quoteNumber · $version';
  }

  @override
  String get tabOpen => 'Open';

  @override
  String get tabReplied => 'Replied';

  @override
  String get tabAccepted => 'Accepted';

  @override
  String get tabLost => 'Lost';

  @override
  String get tileAwaitingClient => 'Awaiting client';

  @override
  String get tileClientReplied => 'Client replied';

  @override
  String get tileExpiringSoon => 'Expiring soon';

  @override
  String get tileAcceptedThisMonth => 'Accepted this month';

  @override
  String get openValueLabel => 'Open value';

  @override
  String get sortOldestFirstLabel => 'Oldest first';

  @override
  String sentAgo(String time) {
    return 'Sent $time';
  }

  @override
  String repliedAgo(String time) {
    return 'Replied $time';
  }

  @override
  String expiresIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Expires in $count days',
      one: 'Expires in 1 day',
      zero: 'Expires today',
    );
    return '$_temp0';
  }

  @override
  String expiredLabel(String time) {
    return 'Expired $time';
  }

  @override
  String get quoteBadgeCounterOffer => 'Counter-offer';

  @override
  String get quoteBadgeQuestion => 'Question';

  @override
  String get yourPriceLabel => 'Your price';

  @override
  String get clientAsksLabel => 'Client asks';

  @override
  String get actionSendReminder => 'Send reminder';

  @override
  String get actionRespond => 'Respond';

  @override
  String get actionExtendOrResend => 'Extend or resend';

  @override
  String get actionViewJob => 'View job';

  @override
  String get actionRequote => 'Re-quote';

  @override
  String get reminderSent => 'Reminder logged.';

  @override
  String get boardEmptyOpen => 'Nothing awaiting a client right now.';

  @override
  String get boardEmptyReplied => 'No replies waiting on you.';

  @override
  String get boardEmptyAccepted => 'Nothing accepted yet.';

  @override
  String get boardEmptyLost => 'Nothing lost — good sign.';

  @override
  String boardEmptySearch(String query) {
    return 'Nothing matches \"$query\".';
  }

  @override
  String get searchQuotesHint => 'Search client, request ID or quote number';

  @override
  String get quoteDetailTitle => 'Quote history';

  @override
  String timelineSent(int version) {
    return 'Quote v$version sent';
  }

  @override
  String get timelineDraft => 'Draft';

  @override
  String timelineClientCountered(String price) {
    return 'Client countered $price';
  }

  @override
  String get timelineClientAccepted => 'Client accepted';

  @override
  String get timelineClientDeclined => 'Client declined';

  @override
  String get timelineRejectedByYou => 'You rejected the request';

  @override
  String get timelineSupersededLabel => 'Superseded';

  @override
  String get logClientReplyTitle => 'Log the client\'s reply';

  @override
  String get outcomeCounter => 'Countered';

  @override
  String get outcomeCounterSubtitle => 'They proposed a different price';

  @override
  String get outcomeAccepted => 'Accepted';

  @override
  String get outcomeAcceptedSubtitle => 'They agreed to this version';

  @override
  String get outcomeDeclined => 'Declined';

  @override
  String get outcomeDeclinedSubtitle => 'They\'re not moving forward';

  @override
  String get clientPriceLabel => 'Their price per unit';

  @override
  String get noteLabel => 'Note';

  @override
  String get noteOptionalLabel => 'Note (optional)';

  @override
  String get logReply => 'Log reply';

  @override
  String get replyLogged => 'Reply logged.';

  @override
  String get sendNewVersion => 'Send new version';

  @override
  String acceptedVersionLabel(String version) {
    return 'Accepted: $version';
  }

  @override
  String get readOnlyAcceptedNotice =>
      'This quote was accepted. The price is locked.';

  @override
  String get errorClientPriceRequired => 'Enter the client\'s price.';

  @override
  String get negotiationHistoryTitle => 'Negotiation history';

  @override
  String get timelineRequestReceived => 'Request received';

  @override
  String get timelineViaEmail => 'email';

  @override
  String get timelineViaManual => 'manual entry';

  @override
  String timelineReceivedVia(String date, String source) {
    return '$date · by $source';
  }

  @override
  String timelineSentByYouMeta(String date) {
    return '$date · by you';
  }

  @override
  String timelineValidDays(int days) {
    return 'valid $days days';
  }

  @override
  String get timelineYourResponseTitle => 'Your response';

  @override
  String get timelineChooseOption => 'Choose an option below';

  @override
  String get requestLabel => 'Request';

  @override
  String get statusLabel => 'Status';

  @override
  String validUntilLabel(String version) {
    return '$version valid until';
  }

  @override
  String get yourTurnBadge => 'Your turn';

  @override
  String sendNewPriceVersion(String version) {
    return 'Send new price ($version)';
  }

  @override
  String get acceptClientPrice => 'Accept client\'s price';

  @override
  String get logOtherReply => 'Log other reply';

  @override
  String get markDeclined => 'Mark declined';

  @override
  String get acceptDisclaimer =>
      'Accepting sends the job to the coordinator and locks the price.';

  @override
  String get respondToClientTitle => 'Respond to client';

  @override
  String get clientsTitle => 'Clients';

  @override
  String get addClient => 'Add client';

  @override
  String get searchClientsHint => 'Search company, contact or email';

  @override
  String get clientsFilterAll => 'All';

  @override
  String get clientsFilterOpenJobs => 'Open jobs';

  @override
  String get clientsFilterDueSoon => 'Due soon';

  @override
  String get clientsSortedByActivity => 'Sorted by latest activity';

  @override
  String equipmentCountChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count equipment',
      one: '1 equipment',
    );
    return '$_temp0';
  }

  @override
  String openJobsCountChip(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count open jobs',
      one: '1 open job',
    );
    return '$_temp0';
  }

  @override
  String dueSoonCountChip(int count) {
    return '$count due in 30 days';
  }

  @override
  String get newSenderNeedsClient => 'New sender needs a client';

  @override
  String get matchAction => 'Match';

  @override
  String get clientsEmpty => 'No clients yet.';

  @override
  String get clientDetailEdit => 'Edit';

  @override
  String get newRequestButton => 'New request';

  @override
  String get callAction => 'Call';

  @override
  String get emailAction => 'Email';

  @override
  String get phoneCopied => 'Phone number copied.';

  @override
  String get emailCopied => 'Email copied.';

  @override
  String get noPhoneNumber => 'No phone number on file.';

  @override
  String get noEmailOnFile => 'No email on file.';

  @override
  String get equipmentStatLabel => 'Equipment';

  @override
  String get openJobsStatLabel => 'Open jobs';

  @override
  String get dueSoonStatLabel => 'Due in 30 days';

  @override
  String get contactsTitle => 'Contacts';

  @override
  String get addContactAction => '+ Add';

  @override
  String get mainContactBadge => 'Main';

  @override
  String get certificatesSentToLabel => 'Certificates are sent to';

  @override
  String get changeAction => 'Change';

  @override
  String get noCertificatesEmail => 'Not set';

  @override
  String get historyTabRequests => 'Requests';

  @override
  String get historyTabEquipment => 'Equipment';

  @override
  String get historyTabCertificates => 'Certificates';

  @override
  String get clientHistoryEmptyRequests => 'No requests from this client yet.';

  @override
  String get clientHistoryEmptyEquipment => 'No equipment on record yet.';

  @override
  String get clientHistoryEmptyCertificates =>
      'Certificates aren\'t tracked yet.';

  @override
  String get addClientSheetTitle => 'Add client';

  @override
  String get companyNameLabel => 'Company name';

  @override
  String get contactNameLabel => 'Contact name';

  @override
  String get roleLabel => 'Role';

  @override
  String get emailLabel => 'Email';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get createAction => 'Create';

  @override
  String get errorCompanyNameRequired => 'Enter the company name.';

  @override
  String get errorContactNameRequired => 'Enter the contact\'s name.';

  @override
  String get errorLocationRequired => 'Enter the location.';

  @override
  String get clientCreated => 'Client added.';

  @override
  String get addContactSheetTitle => 'Add contact';

  @override
  String get contactAdded => 'Contact added.';

  @override
  String get matchSheetTitle => 'Match to a client';

  @override
  String get matchNewClientOption => 'New client';

  @override
  String get clientMatched => 'Matched to client.';

  @override
  String get certificatesEmailUpdated => 'Certificates email updated.';
}
