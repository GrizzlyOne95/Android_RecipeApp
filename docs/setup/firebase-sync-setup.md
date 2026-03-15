# Firebase Sync Setup

This repo is now linked to Firebase project `nutrichef-recipeapp-6d24f`, but secret-bearing Firebase config files and API keys are intentionally not committed.

## Firebase State Already Completed

- Firebase project selected: `nutrichef-recipeapp-6d24f`
- Android app registered: `com.istuart.recipeapp`
- iOS app registered: `com.istuart.recipeapp.recipeApp`
- Repo default project stored in `.firebaserc`
- The app can accept Firebase values from local `--dart-define` flags or regenerated local config files
- A safe gitignored template lives at `firebase.local.example.json`

## Remaining Manual Console Steps

1. Open Firebase Console for `nutrichef-recipeapp-6d24f`
2. Enable Google as a sign-in provider in Firebase Authentication
3. Add the Android debug fingerprints to the Android app:

```text
SHA1:   E3:2E:1A:D2:99:0F:0F:6C:14:36:27:53:5F:2B:49:F1:52:85:01:BC
SHA256: A0:49:56:43:91:17:5E:D6:D5:B9:5C:20:5C:05:84:25:07:76:8F:A6:3F:C8:32:62:0C:B1:80:87:F6:46:C4:7A
```

4. Enable Cloud Firestore for the project
5. Wait a few minutes for the Firestore API enablement to propagate
6. Deploy the repo rules and indexes:

```powershell
firebase use nutrichef-recipeapp-6d24f
firebase deploy --only firestore:rules,firestore:indexes
```

## Values Still Needed Locally

- `FIREBASE_ANDROID_API_KEY`
- `FIREBASE_WEB_CLIENT_ID`
- `FIREBASE_IOS_API_KEY`
- `FIREBASE_IOS_CLIENT_ID`

The current build already knows the project id, sender id, storage bucket, Android app id, iOS app id, and iOS bundle id.

Google sign-in will stay disabled until the missing local values above are provided. Keep them local only: use `--dart-define`, untracked Firebase config files, or regenerate config on your own machine.

Optional local nutrition-import override:

- `USDA_API_KEY`

If `USDA_API_KEY` is not provided, the pantry barcode fallback uses USDA's public `DEMO_KEY` by default. A real USDA key is still recommended for steadier rate limits.

Recommended two-PC workflow:

1. Commit and sync only repo files through Git
2. On each PC, copy `firebase.local.example.json` to `firebase.local.json`
3. Fill in the real local-only values on that machine
4. Launch with:

```powershell
pwsh -File .\scripts\flutter_with_local_firebase.ps1 run -d emulator-5554
```

Example launch override:

```powershell
flutter run -d emulator-5554 `
  --dart-define FIREBASE_PROJECT_ID=nutrichef-recipeapp-6d24f `
  --dart-define FIREBASE_MESSAGING_SENDER_ID=144405192913 `
  --dart-define FIREBASE_STORAGE_BUCKET=nutrichef-recipeapp-6d24f.firebasestorage.app `
  --dart-define FIREBASE_WEB_CLIENT_ID=<web-client-id> `
  --dart-define FIREBASE_ANDROID_API_KEY=<android-api-key> `
  --dart-define FIREBASE_ANDROID_APP_ID=1:144405192913:android:0de9c5034bc37c52d9e5f0 `
  --dart-define FIREBASE_IOS_API_KEY=<ios-api-key> `
  --dart-define FIREBASE_IOS_APP_ID=1:144405192913:ios:fb8a8be93d31a042d9e5f0 `
  --dart-define FIREBASE_IOS_CLIENT_ID=<ios-client-id> `
  --dart-define FIREBASE_IOS_BUNDLE_ID=com.istuart.recipeapp.recipeApp `
  --dart-define USDA_API_KEY=<usda-api-key>
```

## Notes

- A direct `flutterfire configure` run from this Windows environment partially succeeded for Android, but failed while exporting the iOS artifact. Keep regenerated Firebase config files local and untracked.
- iOS Google sign-in still needs the eventual `CLIENT_ID` and reversed URL scheme, which usually gets validated on a Mac/Xcode machine.
- If you want release builds later, add your release signing SHA fingerprints too.
