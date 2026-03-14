# Current Status

This snapshot reflects the repo state on March 14, 2026.

## Alignment Estimate

- The project is currently about 65-75% aligned with the stated Android recipe, pantry, grocery, and nutrition-tracking goals.
- The core local app foundation is strong.
- The biggest remaining gaps are richer recipe ingestion, smarter planning, and final cloud validation.

## Built And Working

- Local-first app shell with Recipes, Grocery, Pantry, and Food Log tabs
- Drift-backed persistence with seeded data and upgrade-safe migrations
- Recipe CRUD with linked pantry ingredients, nested recipe nutrition, and saved-meal composition
- Pantry brand and barcode capture
- Camera barcode scanning with Open Food Facts nutrition import
- Universal Quick Add for grocery, pantry, and food-log entry
- Grocery list generation plus manual add/edit flows
- Food-log goals, entry logging, and saved-meal logging
- Sync queue, Sync Center UI, and optional Firebase Auth + Firestore push scaffolding
- Firebase project binding for `nutrichef-recipeapp-6d24f`
- Secret-bearing Firebase API keys and config artifacts are intentionally kept out of Git

## Verified

- `flutter analyze`
- `flutter test`
- `flutter build apk --debug`
- Android emulator smoke test across Recipes, Grocery, Pantry, Food Log, Quick Add, and pantry barcode import

## Validation Notes

- The pantry barcode import flow was verified end to end on the Android emulator using a real Open Food Facts lookup.
- The live scanner sheet opens and requests camera permission correctly on emulator.
- A real Android device is still needed for final live-camera barcode validation because the emulator camera backend did not provide a reliable preview stream.

## In Progress

- Firebase console enablement for live sign-in and Firestore access

## Manual Steps Still Required

- Enable Google sign-in in Firebase Auth
- Add Android SHA fingerprints for `com.istuart.recipeapp`
- Enable Cloud Firestore for `nutrichef-recipeapp-6d24f`
- Provide the remaining OAuth client ids:
  - `FIREBASE_ANDROID_API_KEY`
  - `FIREBASE_WEB_CLIENT_ID`
  - `FIREBASE_IOS_API_KEY`
  - `FIREBASE_IOS_CLIENT_ID`
- Validate iOS Google sign-in later on a Mac/Xcode machine

## Safe Multi-PC Workflow

- Sync code and docs through Git as usual
- Keep real Firebase values in a local `firebase.local.json` on each machine
- Start Firebase-enabled runs with `pwsh -File .\scripts\flutter_with_local_firebase.ps1`
- Keep downloaded Firebase config files local and untracked

## Next Development Slice

1. Validate real Android sign-in and Firestore push once console setup is complete.
2. Expand recipe import to URL and OCR sources.
3. Add cloud pull, merge, and conflict handling.
4. Build richer meal-planning and macro suggestion flows on top of the current recipe and food-log data.
5. Add pantry item photo import and richer imported-product image handling.
