# Changelog

Radventure Application for multipurpose usage;

## [3.0] (34) (2026-09-12)
- Rebuilt the app for the free Firebase Spark plan (September 2026 rebuild).
- Replaced the unavailable school Exchange login with email and password accounts.
- Moved shared team gameplay to Firestore transactions and security rules, with timestamped answer receipts and no Cloud Functions.
- Added organizer tools for course import and live device verification.
- Moved dependencies from CocoaPods to Swift Package Manager and removed obsolete CocoaPods and Functions artifacts.
- Kept the Radventure project name and bundle identity so it ships as an update to the existing app.

Entries for 2.x and earlier are legacy (the 2023 Radventure releases).

## [2.0.0] (1) (2023-08-30)
- Ver. 2.0.0 buid is ready for testing.
- Added team synchronization.
- Added options to play more than one game.
- Added buttons for changing map view.
- Added support for various multiple choice question (e.g. multiple choice and open-ended questions)
- Added option to see last four games in scoreboard.
- Updated Firebase connection.
- Update zoom in and zoom out function to eliminate the crashing error.

## [1.2.0] (1) (2023-08-08)
- Ver. 1.2.0 buid is ready for testing.
- Updated login function.
- Adjusted login function for Microsoft login.
- Removed Firebase Authentication, using email and password.
- Added profile page, enabling previous scores view.
- Added delete score option with administration password.
- Added loading view for login page.
- Changed the alert message about losing data when "Start Activity" button clicked.

## [1.1.0] (1) (2023-07-20)
- Ver. 1.1.0 buid is ready for testing.
- Adjusted to iOS 14.0.
- Updated login function and fixed alert bug.
- Added compass feature to home page.
- Added Firebase Analytics, Messaging, Crashlytics, Performance, App Check, In-app Messaging features. 

## [1.0.0] (1) (2023-07-20)
- Ver. 1.0.0 build is ready for testing. 
- Login page is created with Firebase.
- Homepage for starting the activity is created with features of rules, timer, zoom in and out, and etc.
- Two-factor authentication for answering the question is enabled. Application both checks your location and also asks a question about the place. Every question worth 100 scores.
- Force quit button is added, and it can be used with administrator password.
- Logout button is created.
- Leaderboard page is created and it is updated in every 10 seconds automatically. It arranges firstly according to the scores and secondly, if scores are equal, according to the remaining time.

## [0.0.0] (1) (2023-07-10)
- Ver. 0.0.0 build is initalized for development. 
