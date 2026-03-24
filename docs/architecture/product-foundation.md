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

### Meal Plan

- id
- title
- note
- pinned for grocery export
- scheduled entries by weekday and meal slot
- timestamps

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
- recipe import from pasted text, fetched URLs, and screenshot OCR
- pantry CRUD with brand and barcode capture
- camera barcode scanning with Open Food Facts plus USDA fallback nutrition import
- persisted pantry product image URLs for imported product artwork
- grocery export from pinned recipes, saved meals, day plans, and pinned meal plans plus manual quick-add flows
- food-log entry, daily goal rollups, and saved-meal logging
- food-log suggestion cards that rank saved meals, recipes, and pantry items against remaining goals
- reusable Food Log day plans that can be captured from a logged day and replayed into today
- direct Food Log day-plan authoring/editing with linked saved meals, recipes, and pantry items
- weekly meal-plan boards with mixed recipe, saved-meal, and pantry scheduling plus grocery-export pinning
- universal quick add from the app shell
- local-first sync queue, Sync Center UI, and pull-first merge across recipes, pantry, grocery, saved meals, day plans, meal plans, and food log
- optional Firebase Auth + Firestore push scaffolding for the existing Firebase project

## Recommended Next Milestones

1. Complete Firebase console enablement and validate live Android sign-in plus Firestore push.
2. Validate full-entity cloud pull/merge behavior against live Firebase data.
3. Improve sync diagnostics, retry handling, and conflict transparency for the expanded synced entity set.
4. Add richer pantry media handling such as manual photo capture and local image management.
5. Deepen planning organization with richer foldering, categorization, and calendar-style views.
6. Add Mac-based iOS sign-in verification once Apple-side setup is available.
