# Current Status

This snapshot reflects the repo state on March 14, 2026.

## Built And Working

- Local-first app shell with Recipes, Grocery, Pantry, and Food Log tabs
- Drift-backed persistence with seeded data and upgrade-safe migrations
- Recipe CRUD with linked pantry ingredients, nested recipe nutrition, and saved-meal composition
- Pantry brand and barcode capture
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

## Next Development Slice

1. Validate real Android sign-in and Firestore push once console setup is complete.
2. Add cloud pull, merge, and conflict handling.
3. Add camera barcode scanning and nutrition import.
4. Expand recipe import to URL and OCR sources.
5. Improve sync retry and conflict diagnostics.
