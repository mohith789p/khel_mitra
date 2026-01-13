# Firebase Setup

This project uses Firebase Phone Authentication. Follow these steps to configure Firebase:

## 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project or select existing one

## 2. Add Android App

1. In Project Settings → Add app → Android
2. Package name: `com.khelmitra.khel_mitra`
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`

## 3. Create firebase_options.dart

Create `lib/firebase_options.dart` with the following structure (fill in your values from google-services.json):

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',           // from google-services.json → client → api_key → current_key
    appId: 'YOUR_APP_ID',             // from google-services.json → client → client_info → mobilesdk_app_id
    messagingSenderId: 'YOUR_SENDER', // from google-services.json → project_info → project_number
    projectId: 'YOUR_PROJECT_ID',     // from google-services.json → project_info → project_id
    storageBucket: 'YOUR_BUCKET',     // from google-services.json → project_info → storage_bucket
  );
}
```

## 4. Enable Phone Authentication

1. Firebase Console → Authentication → Sign-in method
2. Enable **Phone** provider

## 5. (Optional) Test Phone Numbers

For development without real SMS:
1. Firebase Console → Authentication → Sign-in method → Phone
2. Add test phone numbers (e.g., `+919999999999` → `123456`)

---

## ⚠️ Security: Gitignored Files

The following files contain sensitive data and are **NOT committed to git**:

| File | Location | Why Ignored |
|------|----------|-------------|
| `google-services.json` | `android/app/` | Contains Firebase API keys |
| `firebase_options.dart` | `lib/` | Contains Firebase API keys |
| `local.properties` | `android/` | Contains local SDK paths |

> **Each developer must create these files locally** by following steps 2-3 above.

---

## Troubleshooting

### "Failed to load FirebaseOptions from resource"
- Ensure `firebase_options.dart` exists in `lib/`
- Check that `main.dart` imports and uses `DefaultFirebaseOptions.currentPlatform`

### "Missing project_info object"
- You downloaded the wrong JSON file (Admin SDK instead of Android app config)
- Re-download `google-services.json` from Project Settings → Your apps → Android
