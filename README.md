# CampusCare | Flutter + Firebase

A campus incident reporting app using the agreed green visual design and **the supplied photograph of ALU**. It has two roles, student and authorized campus staff.

## Important: How to use this package

You already created `campus_incident_reporting` using **VS Code → Flutter: New Project**. Keep your Flutter-generated `android/`, `ios/`, `.gitignore`, etc. Copy these supplied `lib/`, `assets/`, `pubspec.yaml`, and `firebase/` files into that project. **Do not replace your whole Flutter project with this ZIP** because this ZIP intentionally contains only the source and setup files, not Flutter's generated platform directories.

### 1. Requirements

- Flutter 3.27+ and Dart 3.6+ (prefer an up-to-date stable Flutter).
- A Firebase project and an Android app registration, and optionally iOS.
- A real ALU email domain. `alu.edu` in screenshots is an **example**, not verified as the true allowed domain.

### 2. Install dependencies

From the VS Code **terminal** inside your existing Flutter project:

```powershell
flutter pub get
```

### 3. Configure Firebase (mandatory)

Set up a Firebase project in https://console.firebase.google.com, enable Email/Password authentication, create a Cloud Firestore database, and provision Cloud Storage. Storage might require Firebase billing for a new project. Install the FlutterFire CLI if necessary:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

Follow the CLI prompts to select your Firebase project and Android package name. This generates **`lib/firebase_options.dart`**, which cannot be provided generically because it belongs to *your* Firebase project. Never paste service-account keys into Flutter client code.

Enable Firebase **Authentication → Sign-in method → Email/Password**. In Firebase Console, verify that authorized domains and email templates are configured. Email verification link is triggered after registration.

### 4. Apply security rules

Use `firebase/firestore.rules` for Cloud Firestore and `firebase/storage.rules` for Firebase Storage. You can paste them into the Rules pages in Firebase Console, or deploy with Firebase CLI after configuring your Firebase project.

**Replace every `alu.edu` occurrence in BOTH rule files with the actual domain.** Then run the app with the same domain:

```powershell
flutter run --dart-define=ALU_EMAIL_DOMAIN=actual-alu-domain.example
```

Default code and UI placeholders use `alu.edu` *only as an example*. If the ALU email domain is actually different, update UI hints in `auth_screens.dart` as well. Students with other domains must not be able to self-register, and **email verification is mandatory before entering the app**.

### 5. Give a staff account permission

A new account is **always a student**, even if they edit their own Firestore profile. Staff access is based on a Firebase Auth **custom claim** `staff: true`, issued only with the **Firebase Admin SDK** in a trusted administration environment. Do not place Admin credentials in the app. Example secure one-time administrative code (run separately in your local trusted Node admin environment with correctly configured Admin SDK credentials):

```js
const admin = require('firebase-admin');
admin.initializeApp();
(async () => {
  const user = await admin.auth().getUserByEmail('AUTHORIZED_STAFF_ALU_EMAIL');
  await admin.auth().setCustomUserClaims(user.uid, { staff: true });
  console.log('Granted staff permissions to', user.uid);
})();
```

Only assign `staff` after verifying the person is authorized. The staff user must sign out and sign in again (or refresh ID token) to pick up their new claim. In the app, the staff tab set displays a staff dashboard and status management.

### 6. Run on Android

Start the emulator from Android Studio, then use VS Code / `F5` or `flutter run --dart-define=ALU_EMAIL_DOMAIN=...`. This is a native app, not browser-only.

You should also configure platform photo-picker permissions per the `image_picker` package guidance for your Flutter/Android/iOS SDK. Gallery picking on current Android typically uses the system picker.

## What is included

- Sign up, login, email verification, resend email, password reset, logout
- ALU photograph on both authentication screens, shared green theme
- Home summary and recent own reports
- Incident report create with category, description, location, optional photo
- Firestore report create/read/update/delete (editing/deleting allowed only before staff starts working)
- Search, status filters, report details and timeline
- Staff dashboard and staff-only status updates, enforced by Firestore security rules
- Profile and basic account status
- Cubit-based auth and real-time report state; shared widgets and repository layer

## Current UX assumptions and limits

- Reports are readable by verified ALU members to support campus-wide browsing. The student Reports screen currently shows **only reports by the signed-in student**. Adjust the query/UI if a separate community feed is desired.
- Statuses: Submitted → In Progress → Resolved (staff can select any different status in this code).
- There is no push notification service. Updates are live in Firestore and immediately appear when viewing reports; notification banners and a notifications inbox are not included.
- Photos use Firebase Storage download URLs. Rules restrict reading the storage object, but **download tokens in URLs are bearer capabilities** and can be shared. Avoid sensitive photos in an educational demo.
- The upload happens before Firestore document creation; rare interrupted requests can leave an orphaned image. A production app would use retry or server cleanup.
- UI mockups are **references**, not app screenshots. Use emulator screenshots in your report.
- Google Sign-In, Apple Sign-In, and terms/privacy links are intentionally not included, by design decision.
- This source was prepared without a Flutter SDK in the current execution environment; it **has not been compiled or emulator-tested**. Run `flutter analyze`, then `flutter run` in VS Code and share any diagnostics for fixes.

## Development checks

```powershell
flutter pub get
flutter analyze
flutter run --dart-define=ALU_EMAIL_DOMAIN=actual-alu-domain.example
```

## Rubric submission checklist

- GitHub repository URL
- Working Flutter Android/iOS emulator demo
- 7–10 minute recorded app demonstration including student and staff accounts, Firebase Auth/Firestore Console views
- PDF technical report with architecture, state management, Firestore schema, authorization/security rules, UI/UX, screenshots, testing, challenges, lessons, and APA/IEEE citations

**Suggested Firestore schema**

`users/{uid}`: `firstName`, `lastName`, `email`, `createdAt`.

`incidents/{incidentId}`: `reporterId`, `reporterName`, `title`, `description`, `category`, `location`, `photoUrl`, `photoPath`, `status`, `createdAt`, `updatedAt`, `statusHistory: [{status, by, at, note}]`.
