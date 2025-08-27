# Flutter Health Questionnaire App

## Overview
A Flutter app featuring:
- Email & Password Authentication via Firebase
- User questionnaire storing data in Firebase Firestore
- Health data integration from Apple HealthKit (iOS) or Google Fit (Android)
- Health data stored securely in Firebase linked to user UID

## Setup Instructions

### Prerequisites
- Flutter SDK (>=3.x)
- Firebase CLI & Project
- Android Studio (for Android)

### Firebase Setup
1. Create a Firebase project in [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication:
   - Email/Password
3. Set up Firestore Database with security rules as needed.
4. Download `google-services.json` (Android) into your Flutter project under respective folders.

### Google Fit Setup
- Android: Configure Google Fit API and permissions in `AndroidManifest.xml`

### Run the app
```bash
flutter pub get
flutter run
