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

## First Delivery Slice

The current repository implementation intentionally covers the shell and product framing first:

- adaptive 4-tab navigation
- real local SQLite-backed persistence for the current tab data
- seed cards for recipes, pantry items, grocery sections, and food-log goals
- tablet-aware layout behavior
- theme direction aligned to a cooking and planning product rather than a generic template

## Recommended Next Milestones

1. Add a real local database schema and repositories.
2. Introduce feature state management and editable forms.
3. Add Firebase Auth and opt-in sync.
4. Add barcode scanning and nutrition import.
5. Add recipe import parsing from URL, text, and OCR.
6. Add dependency graph recalculation for nested recipes and saved meals.
