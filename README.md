# Recipe App

Cross-platform recipe, pantry, grocery, and nutrition tracking app built with Flutter for Android first and iOS-ready architecture.

## Current State

This repository now includes:

- A working Flutter project scaffold for Android and iOS.
- A real local SQLite database layer implemented with Drift.
- Android emulator-ready local setup on this Windows workstation.
- Local recipe CRUD with persisted ingredients and directions.
- Recipe detail flows with scaling, calorie sorting, pantry links, and variation duplication.
- Pantry brand and barcode capture.
- Camera barcode scanning plus Open Food Facts pantry nutrition import.
- Universal Quick Add for grocery, pantry, and food-log entry.
- A local-first sync queue with optional Firebase Auth + Firestore push wiring when cloud config is present.
- An adaptive mobile shell with the four primary tabs:
  - Recipes
  - Grocery List
  - Pantry
  - Food Log
- Seed product architecture and setup documentation for reproducing the environment on another machine.

## Progress Snapshot

- Local-first recipe, pantry, grocery, and food-log flows are implemented and verified.
- Pantry items now support camera barcode scanning, pasted barcode lookup, and nutrition import through Open Food Facts.
- Universal Quick Add is live from the main shell for grocery, pantry, and food-log entry.
- Nested recipe and saved-meal nutrition flows are wired through the local database.
- Optional Firebase sync has a real queue, Sync Center UI, Android/iOS app registration, and project-bound config scaffolding for `nutrichef-recipeapp-6d24f`.
- The remaining Firebase work is console-side enablement plus cloud pull and merge behavior.
- Overall alignment to the target product vision is currently estimated at about 65-75%.

## Product Direction

The initial architecture is being built around these principles:

- Local-first storage so the app works without an account.
- Optional Google sign-in for sync and backup.
- Android and iPhone support from one shared codebase.
- Phone and tablet responsive layouts.
- Nutrition tracking that covers calories, protein, carbs, fat, fiber, sodium, and sugar.

## Run The App

Open a new terminal after the environment-variable changes, then run:

```powershell
flutter pub get
flutter run -d emulator-5554
```

If you need to boot the Android emulator first:

```powershell
emulator -avd NutriChef_Emulator
```

## Optional Firebase Sync

The app still works fully offline without Firebase.

This repo is already pointed at Firebase project `nutrichef-recipeapp-6d24f`, and the mobile app registrations are in place.

The remaining manual console work is:

- Enable Google sign-in in Firebase Auth
- Add the Android SHA fingerprints for `com.istuart.recipeapp`
- Enable Cloud Firestore for the project
- Supply the missing local Firebase API keys and OAuth client ids without committing them

To keep Git safe across multiple PCs:

1. Copy `firebase.local.example.json` to `firebase.local.json`
2. Fill in the missing local-only Firebase values on that machine
3. Run Flutter through the helper script:

```powershell
pwsh -File .\scripts\flutter_with_local_firebase.ps1 run -d emulator-5554
```

`firebase.local.json` is gitignored, so each PC can keep its own real values while Git only syncs the codebase.

The current build still accepts these `--dart-define` values directly if you prefer to launch manually:

- `FIREBASE_PROJECT_ID`
- `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_STORAGE_BUCKET`
- `FIREBASE_WEB_CLIENT_ID`
- `FIREBASE_ANDROID_API_KEY`
- `FIREBASE_ANDROID_APP_ID`
- `FIREBASE_IOS_API_KEY`
- `FIREBASE_IOS_APP_ID`
- `FIREBASE_IOS_CLIENT_ID`
- `FIREBASE_IOS_BUNDLE_ID`

## Verification Status

The current draft has passed:

- `flutter analyze`
- `flutter test`
- `flutter build apk --debug`
- Android emulator smoke test across Recipes, Grocery, Pantry, Food Log, Quick Add, and pantry barcode import

The emulator also verified the manual barcode import path end to end. Live camera scanning still needs one real Android device check because the emulator camera backend opens the scanner sheet and permission flow but does not provide a reliable barcode preview.

## Key Docs

- [Windows workstation setup](./docs/setup/windows-mobile-workstation.md)
- [Firebase sync setup](./docs/setup/firebase-sync-setup.md)
- [Current progress snapshot](./docs/progress/current-status.md)
- [Goal alignment checklist](./docs/progress/goal-alignment.md)
- [Product and architecture foundation](./docs/architecture/product-foundation.md)

## Near-Term Build Plan

1. Finish real Firebase enablement in the console and validate end-to-end Android sign-in plus Firestore push.
2. Expand recipe import from pasted text into URL and OCR screenshot flows.
3. Add cloud pull, merge, and conflict handling on top of the Firestore push queue.
4. Build the smarter planning layer: meal-plan folders, macro-aware suggestions, and richer organization/sorting.
5. Add pantry item photo import and richer imported-product image handling on top of the barcode flow.
