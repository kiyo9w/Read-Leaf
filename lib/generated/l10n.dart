// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Read Leaf`
  String get appName {
    return Intl.message(
      'Read Leaf',
      name: 'appName',
      desc: 'The name of the app',
      args: [],
    );
  }

  /// `Loading...`
  String get loading {
    return Intl.message(
      'Loading...',
      name: 'loading',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: 'OK button text',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: 'Cancel button text',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: 'Error title',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message(
      'Retry',
      name: 'retry',
      desc: 'Retry button text',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: 'Settings tab title',
      args: [],
    );
  }

  /// `Dark Mode`
  String get darkMode {
    return Intl.message(
      'Dark Mode',
      name: 'darkMode',
      desc: 'Dark mode setting title',
      args: [],
    );
  }

  /// `Light Mode`
  String get lightMode {
    return Intl.message(
      'Light Mode',
      name: 'lightMode',
      desc: '',
      args: [],
    );
  }

  /// `System Mode`
  String get systemMode {
    return Intl.message(
      'System Mode',
      name: 'systemMode',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: 'Language setting title',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message(
      'Theme',
      name: 'theme',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: 'Logout button text',
      args: [],
    );
  }

  /// `Sign Up`
  String get signUp {
    return Intl.message(
      'Sign Up',
      name: 'signUp',
      desc: 'Sign up button text',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: 'Password label',
      args: [],
    );
  }

  /// `Forgot Password?`
  String get forgotPassword {
    return Intl.message(
      'Forgot Password?',
      name: 'forgotPassword',
      desc: 'Forgot password link text',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Library`
  String get library {
    return Intl.message(
      'Library',
      name: 'library',
      desc: 'Library tab title',
      args: [],
    );
  }

  /// `My Books`
  String get myBooks {
    return Intl.message(
      'My Books',
      name: 'myBooks',
      desc: '',
      args: [],
    );
  }

  /// `Recent Books`
  String get recentBooks {
    return Intl.message(
      'Recent Books',
      name: 'recentBooks',
      desc: '',
      args: [],
    );
  }

  /// `Favorites`
  String get favorites {
    return Intl.message(
      'Favorites',
      name: 'favorites',
      desc: 'Favorites section title',
      args: [],
    );
  }

  /// `Characters`
  String get characters {
    return Intl.message(
      'Characters',
      name: 'characters',
      desc: '',
      args: [],
    );
  }

  /// `Chat`
  String get chat {
    return Intl.message(
      'Chat',
      name: 'chat',
      desc: '',
      args: [],
    );
  }

  /// `Reader`
  String get reader {
    return Intl.message(
      'Reader',
      name: 'reader',
      desc: '',
      args: [],
    );
  }

  /// `No books found`
  String get noBooks {
    return Intl.message(
      'No books found',
      name: 'noBooks',
      desc: '',
      args: [],
    );
  }

  /// `Add Book`
  String get addBook {
    return Intl.message(
      'Add Book',
      name: 'addBook',
      desc: '',
      args: [],
    );
  }

  /// `Delete Book`
  String get deleteBook {
    return Intl.message(
      'Delete Book',
      name: 'deleteBook',
      desc: '',
      args: [],
    );
  }

  /// `Share Book`
  String get shareBook {
    return Intl.message(
      'Share Book',
      name: 'shareBook',
      desc: 'Share book button text',
      args: [],
    );
  }

  /// `Book Details`
  String get bookDetails {
    return Intl.message(
      'Book Details',
      name: 'bookDetails',
      desc: '',
      args: [],
    );
  }

  /// `Author`
  String get author {
    return Intl.message(
      'Author',
      name: 'author',
      desc: 'Author label',
      args: [],
    );
  }

  /// `Publisher`
  String get publisher {
    return Intl.message(
      'Publisher',
      name: 'publisher',
      desc: 'Publisher label',
      args: [],
    );
  }

  /// `Published`
  String get published {
    return Intl.message(
      'Published',
      name: 'published',
      desc: '',
      args: [],
    );
  }

  /// `Pages`
  String get pages {
    return Intl.message(
      'Pages',
      name: 'pages',
      desc: '',
      args: [],
    );
  }

  /// `Chapters`
  String get chapterCount {
    return Intl.message(
      'Chapters',
      name: 'chapterCount',
      desc: '',
      args: [],
    );
  }

  /// `File Size`
  String get fileSize {
    return Intl.message(
      'File Size',
      name: 'fileSize',
      desc: '',
      args: [],
    );
  }

  /// `File Type`
  String get fileType {
    return Intl.message(
      'File Type',
      name: 'fileType',
      desc: '',
      args: [],
    );
  }

  /// `Import Book`
  String get importBook {
    return Intl.message(
      'Import Book',
      name: 'importBook',
      desc: '',
      args: [],
    );
  }

  /// `Export Book`
  String get exportBook {
    return Intl.message(
      'Export Book',
      name: 'exportBook',
      desc: '',
      args: [],
    );
  }

  /// `Sync Settings`
  String get syncSettings {
    return Intl.message(
      'Sync Settings',
      name: 'syncSettings',
      desc: '',
      args: [],
    );
  }

  /// `Enable Sync`
  String get enableSync {
    return Intl.message(
      'Enable Sync',
      name: 'enableSync',
      desc: '',
      args: [],
    );
  }

  /// `Sync Frequency`
  String get syncFrequency {
    return Intl.message(
      'Sync Frequency',
      name: 'syncFrequency',
      desc: '',
      args: [],
    );
  }

  /// `Backup`
  String get backup {
    return Intl.message(
      'Backup',
      name: 'backup',
      desc: '',
      args: [],
    );
  }

  /// `Restore`
  String get restore {
    return Intl.message(
      'Restore',
      name: 'restore',
      desc: '',
      args: [],
    );
  }

  /// `About App`
  String get aboutApp {
    return Intl.message(
      'About App',
      name: 'aboutApp',
      desc: 'About app section title',
      args: [],
    );
  }

  /// `Version`
  String get version {
    return Intl.message(
      'Version',
      name: 'version',
      desc: 'App version label',
      args: [],
    );
  }

  /// `Terms of Service`
  String get termsOfService {
    return Intl.message(
      'Terms of Service',
      name: 'termsOfService',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Licenses`
  String get licenses {
    return Intl.message(
      'Licenses',
      name: 'licenses',
      desc: '',
      args: [],
    );
  }

  /// `Send Feedback`
  String get feedback {
    return Intl.message(
      'Send Feedback',
      name: 'feedback',
      desc: '',
      args: [],
    );
  }

  /// `Rate App`
  String get rateApp {
    return Intl.message(
      'Rate App',
      name: 'rateApp',
      desc: 'Rate app button text',
      args: [],
    );
  }

  /// `Share App`
  String get shareApp {
    return Intl.message(
      'Share App',
      name: 'shareApp',
      desc: '',
      args: [],
    );
  }

  /// `Developer Options`
  String get developerOptions {
    return Intl.message(
      'Developer Options',
      name: 'developerOptions',
      desc: '',
      args: [],
    );
  }

  /// `Debug Mode`
  String get debugMode {
    return Intl.message(
      'Debug Mode',
      name: 'debugMode',
      desc: '',
      args: [],
    );
  }

  /// `Table of Contents`
  String get tableOfContents {
    return Intl.message(
      'Table of Contents',
      name: 'tableOfContents',
      desc: 'Table of contents title',
      args: [],
    );
  }

  /// `Highlights and Notes`
  String get highlightsAndNotes {
    return Intl.message(
      'Highlights and Notes',
      name: 'highlightsAndNotes',
      desc: '',
      args: [],
    );
  }

  /// `Thumbnails`
  String get thumbnails {
    return Intl.message(
      'Thumbnails',
      name: 'thumbnails',
      desc: '',
      args: [],
    );
  }

  /// `Can you explain what the text is about? After that share your thoughts in a single open ended question in the same paragraph, make the question short and concise.`
  String get explainTextAndAskQuestion {
    return Intl.message(
      'Can you explain what the text is about? After that share your thoughts in a single open ended question in the same paragraph, make the question short and concise.',
      name: 'explainTextAndAskQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Failed to get AI response`
  String get failedToGetAIResponse {
    return Intl.message(
      'Failed to get AI response',
      name: 'failedToGetAIResponse',
      desc: '',
      args: [],
    );
  }

  /// `Highlight`
  String get highlight {
    return Intl.message(
      'Highlight',
      name: 'highlight',
      desc: '',
      args: [],
    );
  }

  /// `Audio`
  String get audio {
    return Intl.message(
      'Audio',
      name: 'audio',
      desc: '',
      args: [],
    );
  }

  /// `Chapters`
  String get chapters {
    return Intl.message(
      'Chapters',
      name: 'chapters',
      desc: '',
      args: [],
    );
  }

  /// `Bookmarks`
  String get bookmarks {
    return Intl.message(
      'Bookmarks',
      name: 'bookmarks',
      desc: 'Bookmarks section title',
      args: [],
    );
  }

  /// `File deleted`
  String get fileDeleted {
    return Intl.message(
      'File deleted',
      name: 'fileDeleted',
      desc: 'Message shown when a file is deleted',
      args: [],
    );
  }

  /// `Leafy reader`
  String get leafyReader {
    return Intl.message(
      'Leafy reader',
      name: 'leafyReader',
      desc: '',
      args: [],
    );
  }

  /// `Last read`
  String get lastRead {
    return Intl.message(
      'Last read',
      name: 'lastRead',
      desc: '',
      args: [],
    );
  }

  /// `Your books`
  String get yourBooks {
    return Intl.message(
      'Your books',
      name: 'yourBooks',
      desc: '',
      args: [],
    );
  }

  /// `Book of the day`
  String get bookOfTheDay {
    return Intl.message(
      'Book of the day',
      name: 'bookOfTheDay',
      desc: '',
      args: [],
    );
  }

  /// `Result`
  String get result {
    return Intl.message(
      'Result',
      name: 'result',
      desc: '',
      args: [],
    );
  }

  /// `Results for {query}`
  String resultsFor(Object query) {
    return Intl.message(
      'Results for $query',
      name: 'resultsFor',
      desc: 'Results for search query label',
      args: [query],
    );
  }

  /// `Failed to get download link`
  String get failedToGetDownloadLink {
    return Intl.message(
      'Failed to get download link',
      name: 'failedToGetDownloadLink',
      desc: '',
      args: [],
    );
  }

  /// `No Results Found!`
  String get noResultsFound {
    return Intl.message(
      'No Results Found!',
      name: 'noResultsFound',
      desc: 'Message shown when no search results are found',
      args: [],
    );
  }

  /// `No content`
  String get noContent {
    return Intl.message(
      'No content',
      name: 'noContent',
      desc: '',
      args: [],
    );
  }

  /// `Downloading...`
  String get downloading {
    return Intl.message(
      'Downloading...',
      name: 'downloading',
      desc: '',
      args: [],
    );
  }

  /// `Not authenticated`
  String get notAuthenticated {
    return Intl.message(
      'Not authenticated',
      name: 'notAuthenticated',
      desc: '',
      args: [],
    );
  }

  /// `Failed to upload profile picture`
  String get failedToUploadProfilePicture {
    return Intl.message(
      'Failed to upload profile picture',
      name: 'failedToUploadProfilePicture',
      desc: '',
      args: [],
    );
  }

  /// `Profile updated successfully`
  String get profileUpdatedSuccessfully {
    return Intl.message(
      'Profile updated successfully',
      name: 'profileUpdatedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Password reset email sent`
  String get passwordResetEmailSent {
    return Intl.message(
      'Password reset email sent',
      name: 'passwordResetEmailSent',
      desc: 'Password reset email sent confirmation',
      args: [],
    );
  }

  /// `Delete Account`
  String get deleteAccount {
    return Intl.message(
      'Delete Account',
      name: 'deleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete your account? This action cannot be undone.`
  String get deleteAccountConfirmation {
    return Intl.message(
      'Are you sure you want to delete your account? This action cannot be undone.',
      name: 'deleteAccountConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: 'Delete button text',
      args: [],
    );
  }

  /// `Account deleted successfully`
  String get accountDeletedSuccessfully {
    return Intl.message(
      'Account deleted successfully',
      name: 'accountDeletedSuccessfully',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: 'Profile tab title',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message(
      'Username',
      name: 'username',
      desc: 'Username label',
      args: [],
    );
  }

  /// `Please enter a username`
  String get pleaseEnterUsername {
    return Intl.message(
      'Please enter a username',
      name: 'pleaseEnterUsername',
      desc: '',
      args: [],
    );
  }

  /// `Save Changes`
  String get saveChanges {
    return Intl.message(
      'Save Changes',
      name: 'saveChanges',
      desc: '',
      args: [],
    );
  }

  /// `Reset Password`
  String get resetPassword {
    return Intl.message(
      'Reset Password',
      name: 'resetPassword',
      desc: 'Reset password button text',
      args: [],
    );
  }

  /// `Sign Out`
  String get signOut {
    return Intl.message(
      'Sign Out',
      name: 'signOut',
      desc: '',
      args: [],
    );
  }

  /// `Could not launch {url}`
  String couldNotLaunch(Object url) {
    return Intl.message(
      'Could not launch $url',
      name: 'couldNotLaunch',
      desc: '',
      args: [url],
    );
  }

  /// `Check out this amazing ebook reader app!`
  String get checkOutThisApp {
    return Intl.message(
      'Check out this amazing ebook reader app!',
      name: 'checkOutThisApp',
      desc: 'Share app message',
      args: [],
    );
  }

  /// `Sign In / Sign Up`
  String get signInSignUp {
    return Intl.message(
      'Sign In / Sign Up',
      name: 'signInSignUp',
      desc: 'Sign in/sign up button text',
      args: [],
    );
  }

  /// `Sync your reading progress and preferences`
  String get syncReadingProgress {
    return Intl.message(
      'Sync your reading progress and preferences',
      name: 'syncReadingProgress',
      desc: 'Sync reading progress description',
      args: [],
    );
  }

  /// `Open favorites`
  String get openFavorites {
    return Intl.message(
      'Open favorites',
      name: 'openFavorites',
      desc: 'Open favorites button text',
      args: [],
    );
  }

  /// `Mark as favorite`
  String get markAsFavorite {
    return Intl.message(
      'Mark as favorite',
      name: 'markAsFavorite',
      desc: 'Mark as favorite button text',
      args: [],
    );
  }

  /// `Remove from favorites`
  String get unmarkAsFavorite {
    return Intl.message(
      'Remove from favorites',
      name: 'unmarkAsFavorite',
      desc: 'Unmark as favorite button text',
      args: [],
    );
  }

  /// `Press back again to exit`
  String get pressBackAgainToExit {
    return Intl.message(
      'Press back again to exit',
      name: 'pressBackAgainToExit',
      desc: 'Message shown when user presses back button',
      args: [],
    );
  }

  /// `Syncing {count} items...`
  String syncingItemsCount(int count) {
    return Intl.message(
      'Syncing $count items...',
      name: 'syncingItemsCount',
      desc: 'Text shown when syncing items',
      args: [count],
    );
  }

  /// `Offline`
  String get offline {
    return Intl.message(
      'Offline',
      name: 'offline',
      desc: 'Offline status text',
      args: [],
    );
  }

  /// `is thinking`
  String get isThinking {
    return Intl.message(
      'is thinking',
      name: 'isThinking',
      desc: 'Used when a character is thinking/typing',
      args: [],
    );
  }

  /// `No highlights or notes`
  String get noHighlightsOrNotes {
    return Intl.message(
      'No highlights or notes',
      name: 'noHighlightsOrNotes',
      desc: 'Message shown when there are no highlights or notes',
      args: [],
    );
  }

  /// `Select text and tap the highlight button to add`
  String get selectTextToHighlight {
    return Intl.message(
      'Select text and tap the highlight button to add',
      name: 'selectTextToHighlight',
      desc: 'Instructions for adding highlights',
      args: [],
    );
  }

  /// `Page {number}`
  String pageNumber(int number) {
    return Intl.message(
      'Page $number',
      name: 'pageNumber',
      desc: 'Page number label',
      args: [number],
    );
  }

  /// `Unknown Author`
  String get unknownAuthor {
    return Intl.message(
      'Unknown Author',
      name: 'unknownAuthor',
      desc: 'Text shown when author is unknown',
      args: [],
    );
  }

  /// `PDF`
  String get pdf {
    return Intl.message(
      'PDF',
      name: 'pdf',
      desc: 'PDF file format',
      args: [],
    );
  }

  /// `Mark as completed`
  String get markAsCompleted {
    return Intl.message(
      'Mark as completed',
      name: 'markAsCompleted',
      desc: 'Label for marking a book as completed',
      args: [],
    );
  }

  /// `Star`
  String get star {
    return Intl.message(
      'Star',
      name: 'star',
      desc: 'Label for starring a book',
      args: [],
    );
  }

  /// `Choose Character`
  String get chooseCharacter {
    return Intl.message(
      'Choose Character',
      name: 'chooseCharacter',
      desc: 'Title for the character selection screen',
      args: [],
    );
  }

  /// `Voices`
  String get voices {
    return Intl.message(
      'Voices',
      name: 'voices',
      desc: 'Title for the voices selection screen',
      args: [],
    );
  }

  /// `Create`
  String get create {
    return Intl.message(
      'Create',
      name: 'create',
      desc: 'Create button label',
      args: [],
    );
  }

  /// `Import`
  String get import {
    return Intl.message(
      'Import',
      name: 'import',
      desc: 'Import button label',
      args: [],
    );
  }

  /// `Voice`
  String get voice {
    return Intl.message(
      'Voice',
      name: 'voice',
      desc: 'Voice button label',
      args: [],
    );
  }

  /// `See All`
  String get seeAll {
    return Intl.message(
      'See All',
      name: 'seeAll',
      desc: 'See all button text',
      args: [],
    );
  }

  /// `Featured Characters`
  String get featuredCharacters {
    return Intl.message(
      'Featured Characters',
      name: 'featuredCharacters',
      desc: 'Section title for featured characters',
      args: [],
    );
  }

  /// `Trending`
  String get trending {
    return Intl.message(
      'Trending',
      name: 'trending',
      desc: 'Section title for trending characters',
      args: [],
    );
  }

  /// `All Characters`
  String get allCharacters {
    return Intl.message(
      'All Characters',
      name: 'allCharacters',
      desc: 'Section title for all characters',
      args: [],
    );
  }

  /// `Recent Characters`
  String get recentCharacters {
    return Intl.message(
      'Recent Characters',
      name: 'recentCharacters',
      desc: 'Section title for recent characters',
      args: [],
    );
  }

  /// `No featured characters available`
  String get noFeaturedCharacters {
    return Intl.message(
      'No featured characters available',
      name: 'noFeaturedCharacters',
      desc: 'Text shown when no featured characters are available',
      args: [],
    );
  }

  /// `No trending characters available`
  String get noTrendingCharacters {
    return Intl.message(
      'No trending characters available',
      name: 'noTrendingCharacters',
      desc: 'Text shown when no trending characters are available',
      args: [],
    );
  }

  /// `No characters found in this category`
  String get noCharactersInCategory {
    return Intl.message(
      'No characters found in this category',
      name: 'noCharactersInCategory',
      desc: 'Text shown when no characters are found in a category',
      args: [],
    );
  }

  /// `No recent characters in this category`
  String get noRecentCharacters {
    return Intl.message(
      'No recent characters in this category',
      name: 'noRecentCharacters',
      desc: 'Text shown when no recent characters are available',
      args: [],
    );
  }

  /// `Show More ({count})`
  String showMore(int count) {
    return Intl.message(
      'Show More ($count)',
      name: 'showMore',
      desc: 'Button to show more items with a count',
      args: [count],
    );
  }

  /// `Show Less`
  String get showLess {
    return Intl.message(
      'Show Less',
      name: 'showLess',
      desc: 'Button to show fewer items',
      args: [],
    );
  }

  /// `Unnamed Character`
  String get unnamedCharacter {
    return Intl.message(
      'Unnamed Character',
      name: 'unnamedCharacter',
      desc: 'Default name for a character without a name',
      args: [],
    );
  }

  /// `My Library`
  String get myLibrary {
    return Intl.message(
      'My Library',
      name: 'myLibrary',
      desc: 'Title for the library screen',
      args: [],
    );
  }

  /// `Starred Books`
  String get starredBooks {
    return Intl.message(
      'Starred Books',
      name: 'starredBooks',
      desc: 'Section title for starred books',
      args: [],
    );
  }

  /// `Have Read`
  String get haveRead {
    return Intl.message(
      'Have Read',
      name: 'haveRead',
      desc: 'Section title for books the user has read',
      args: [],
    );
  }

  /// `Local Storage`
  String get localStorage {
    return Intl.message(
      'Local Storage',
      name: 'localStorage',
      desc: 'Section title for books stored locally',
      args: [],
    );
  }

  /// `Select Language`
  String get selectLanguage {
    return Intl.message(
      'Select Language',
      name: 'selectLanguage',
      desc: 'Title for language selection dialog',
      args: [],
    );
  }

  /// `Select Theme`
  String get selectTheme {
    return Intl.message(
      'Select Theme',
      name: 'selectTheme',
      desc: 'Title for theme selection dialog',
      args: [],
    );
  }

  /// `Follow Device Setting`
  String get followDeviceSetting {
    return Intl.message(
      'Follow Device Setting',
      name: 'followDeviceSetting',
      desc: 'Text for system theme setting option',
      args: [],
    );
  }

  /// `Automatically switch between light and dark theme`
  String get automaticallySwitchTheme {
    return Intl.message(
      'Automatically switch between light and dark theme',
      name: 'automaticallySwitchTheme',
      desc: 'Description for system theme setting',
      args: [],
    );
  }

  /// `Default Themes`
  String get defaultThemes {
    return Intl.message(
      'Default Themes',
      name: 'defaultThemes',
      desc: 'Section title for default themes',
      args: [],
    );
  }

  /// `Light Themes`
  String get lightThemes {
    return Intl.message(
      'Light Themes',
      name: 'lightThemes',
      desc: 'Section title for light themes',
      args: [],
    );
  }

  /// `Dark Themes`
  String get darkThemes {
    return Intl.message(
      'Dark Themes',
      name: 'darkThemes',
      desc: 'Section title for dark themes',
      args: [],
    );
  }

  /// `Loading Screen`
  String get loadingScreen {
    return Intl.message(
      'Loading Screen',
      name: 'loadingScreen',
      desc: 'Title for loading screen setting',
      args: [],
    );
  }

  /// `Show book loading transition screen`
  String get showBookLoadingScreen {
    return Intl.message(
      'Show book loading transition screen',
      name: 'showBookLoadingScreen',
      desc: 'Description for loading screen setting',
      args: [],
    );
  }

  /// `Reading Reminders`
  String get readingReminders {
    return Intl.message(
      'Reading Reminders',
      name: 'readingReminders',
      desc: 'Title for reading reminders setting',
      args: [],
    );
  }

  /// `Get encouraged to continue reading`
  String get getEncouragedToContinueReading {
    return Intl.message(
      'Get encouraged to continue reading',
      name: 'getEncouragedToContinueReading',
      desc: 'Description for reading reminders setting',
      args: [],
    );
  }

  /// `AI Model`
  String get aiModel {
    return Intl.message(
      'AI Model',
      name: 'aiModel',
      desc: 'Title for AI model setting',
      args: [],
    );
  }

  /// `Select AI Model`
  String get selectAiModel {
    return Intl.message(
      'Select AI Model',
      name: 'selectAiModel',
      desc: 'Title for AI model selection dialog',
      args: [],
    );
  }

  /// `Account`
  String get account {
    return Intl.message(
      'Account',
      name: 'account',
      desc: 'Section title for account settings',
      args: [],
    );
  }

  /// `Appearance`
  String get appearance {
    return Intl.message(
      'Appearance',
      name: 'appearance',
      desc: 'Section title for appearance settings',
      args: [],
    );
  }

  /// `Reading`
  String get reading {
    return Intl.message(
      'Reading',
      name: 'reading',
      desc: 'Section title for reading settings',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: 'Section title for about settings',
      args: [],
    );
  }

  /// `Buy me a coffee`
  String get buyMeACoffee {
    return Intl.message(
      'Buy me a coffee',
      name: 'buyMeACoffee',
      desc: 'Title for donation option',
      args: [],
    );
  }

  /// `Support the developer`
  String get supportTheDeveloper {
    return Intl.message(
      'Support the developer',
      name: 'supportTheDeveloper',
      desc: 'Description for donation option',
      args: [],
    );
  }

  /// `Support this open source project`
  String get supportOpenSource {
    return Intl.message(
      'Support this open source project',
      name: 'supportOpenSource',
      desc: 'Title for open source support option',
      args: [],
    );
  }

  /// `Contribute on GitHub`
  String get contributeOnGitHub {
    return Intl.message(
      'Contribute on GitHub',
      name: 'contributeOnGitHub',
      desc: 'Description for open source support option',
      args: [],
    );
  }

  /// `Share this app with friends`
  String get shareWithFriends {
    return Intl.message(
      'Share this app with friends',
      name: 'shareWithFriends',
      desc: 'Title for share app option',
      args: [],
    );
  }

  /// `Spread the word`
  String get spreadTheWord {
    return Intl.message(
      'Spread the word',
      name: 'spreadTheWord',
      desc: 'Description for share app option',
      args: [],
    );
  }

  /// `Error loading book of the day`
  String get errorLoadingBookOfDay {
    return Intl.message(
      'Error loading book of the day',
      name: 'errorLoadingBookOfDay',
      desc: 'Error message when book of the day fails to load',
      args: [],
    );
  }

  /// `Error generating AI message`
  String get errorGeneratingAiMessage {
    return Intl.message(
      'Error generating AI message',
      name: 'errorGeneratingAiMessage',
      desc: 'Error message when AI message generation fails',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'vi'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
