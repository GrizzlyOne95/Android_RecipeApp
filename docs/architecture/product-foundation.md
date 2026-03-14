# Product Foundation

## Confirmed Product Decisions

- Platforms: Android now, shared codebase structured for iPhone support.
- Auth: optional Google sign-in.
- Data mode: local-first with cloud sync when the user opts in.
- Account model: one personal account for now.
- Nutrition tracking in scope for v1 foundation:
  - calories
  - protein
  - carbs
  - fat
  - fiber
  - sodium
  - sugar
- Recipe import targets:
  - URL paste
  - plain text paste
  - OCR from screenshots
- Layout target: phone and tablet.

## Architecture Direction

### Frontend

- Framework: Flutter
- Reason:
  - one codebase for Android and iPhone
  - Android development is fully workable on this Windows machine
  - camera, barcode scanning, OCR, local persistence, and Firebase are all well supported

### Data Strategy

- Source of truth on device first
- Cloud sync as an overlay, not a requirement for use
- Sync candidate: Firebase Auth + Cloud Firestore
- Local database baseline: SQLite via Drift

Drift is now the local persistence baseline because this app has strongly relational data:

- recipes contain ingredients
- recipes can reference other recipes
- saved meals reference recipes and standalone pantry items
- food logs reference saved meals or individual ingredients
- recipe updates need downstream recalculation prompts

## Core Domain Objects

### Recipe

- id
- title
- master_recipe_id nullable
- version_name nullable
- servings
- instructions
- notes
- favorite_scales
- sort metadata
- timestamps

### Recipe Ingredient

- id
- recipe_id
- position
- ingredient_type enum:
  - pantry_item
  - freeform_ingredient
  - recipe_reference
- linked_item_id nullable
- quantity
- unit
- grams override nullable
- preparation note nullable

### Pantry Item

- id
- title
- barcode nullable
- brand nullable
- package size
- image url nullable
- nutrition per reference unit
- source enum:
  - scanned
  - imported
  - manual
  - recipe-derived

### Saved Meal

- id
- title
- meal components
- default quantities
- user notes

### Food Log Entry

- id
- date
- meal slot
- source type:
  - saved meal
  - recipe
  - pantry item
- quantity snapshot
- nutrition snapshot

### Grocery List Item

- id
- list id
- source reference nullable
- title
- quantity
- unit
- checked state

## Current Delivery State

The current repository implementation has moved well beyond the initial shell slice:

- adaptive 4-tab navigation with phone and tablet layouts
- local SQLite-backed persistence through Drift
- editable recipe CRUD with linked ingredients, nested recipe nutrition, and saved-meal composition
- pantry CRUD with brand and barcode capture
- camera barcode scanning with Open Food Facts nutrition import
- grocery export plus manual quick-add flows
- food-log entry, daily goal rollups, and saved-meal logging
- universal quick add from the app shell
- local-first sync queue and Sync Center UI
- optional Firebase Auth + Firestore push scaffolding for the existing Firebase project

## Recommended Next Milestones

1. Complete Firebase console enablement and validate live Android sign-in plus Firestore push.
2. Add cloud pull, merge, and conflict resolution.
3. Expand recipe import from plain text into URL and OCR ingestion.
4. Improve sync diagnostics, retry handling, and conflict transparency.
5. Add pantry item image persistence and richer imported-product media handling.
6. Add Mac-based iOS sign-in verification once Apple-side setup is available.
