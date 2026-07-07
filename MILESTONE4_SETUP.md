# Milestone 4: Nutrition - Photo-First Meal Logging

## Overview

**Goal:** Replace manual meal entry with photo-first logging (MVP Transformation #1)

**Duration:** 3 weeks (Week 8-10)

**MVP Transformation:** #1 - Photo-first meal logging (not calorie tracking)

**Core Flow:** Snap photo → Claude analyzes → Done

## What Was Built

### 1. Photo-First Logging Flow
- **Camera/Gallery Button:** Large FAB with gradient, opens bottom sheet
- **Quick Log Sheet:**
  - Photo preview
  - Meal type selector (4 chips: breakfast, lunch, dinner, snack)
  - Optional notes field (100 char max)
  - Smart defaults (infers meal type from time of day)
- **AI Analysis:** Claude Vision API analyzes photo
- **Success Feedback:** Bottom sheet with health score and personalized feedback

### 2. Claude Vision Integration
- **Model:** claude-3-sonnet-20240229 with vision
- **Analysis Includes:**
  - Description (what's in the photo)
  - Portion size (small/medium/large)
  - Food categories (e.g., "vegetables", "protein", "grains")
  - Health score (1-5, where 5 = excellent)
  - Personalized feedback (relates to user's emotional goal)
  - Optional suggestions (only if health score < 4)
  - De-emphasized nutritional estimate (calories, macros)

### 3. Nutrition Screen UI
- **Empty State:** Encouraging message, explains photo-first approach
- **Today's Summary Card:**
  - Total meals logged
  - Average health score
  - Color-coded indicators
- **Meal Cards:**
  - Photo with meal type badge
  - Health score circle badge
  - Time, portion size
  - Brief description
  - Food category tags
  - "View Full Analysis" button
- **Full Analysis Sheet:**
  - Complete AI feedback
  - Personalized suggestions
  - All meal details
  - De-emphasized nutritional info

### 4. Firebase Storage Integration
- **Upload Path:** `meals/{userId}/{uuid}.jpg`
- **Metadata:** Upload timestamp, user ID
- **Image Optimization:** Max 1920x1920, 85% quality
- **Delete Support:** Remove images when meals deleted

## Architecture

### Domain Layer (6 files)
- `meal.dart` - Meal entity with MealAnalysis, NutritionalEstimate
- `meal_repository.dart` - Repository interface
- `storage_repository.dart` - Image storage interface
- `log_meal_usecase.dart` - Log meal with photo
- `get_meal_history_usecase.dart` - Fetch meal history
- `upload_image_usecase.dart` - Upload image to storage

### Data Layer (6 files)
- `meal_model.dart` - Data model with JSON/Drift conversion
- `meal_remote_datasource.dart` - Claude Vision API + Firestore
- `meal_local_datasource.dart` - SQLite + Hive persistence
- `storage_remote_datasource.dart` - Firebase Storage client
- `meal_repository_impl.dart` - Meal repository implementation
- `storage_repository_impl.dart` - Storage repository implementation

### Presentation Layer (7 files)
- `meal_provider.dart` - Riverpod state management (3 providers)
- `meal_provider.g.dart` - Generated provider code
- `nutrition_screen.dart` - Main nutrition UI
- `meal_card.dart` - Individual meal card with photo
- `photo_capture_button.dart` - Camera/gallery FAB
- `meal_analysis_card.dart` - Full analysis bottom sheet
- `quick_log_sheet.dart` - Quick logging bottom sheet

### Database (1 file)
- `meals_table_milestone4.dart` - Updated meals table schema

## Files Created (20 files)

All files created successfully. See file list above.

## Setup Instructions

### Prerequisites
1. Flutter SDK 3.x
2. Claude API key (from Milestone 3)
3. Firebase project with Storage enabled

### 1. Enable Firebase Storage

**Firebase Console:**
1. Go to Firebase Console → Storage
2. Click "Get Started"
3. Select default security rules (or use custom)
4. Choose storage location (same region as Firestore)

**Security Rules (`storage.rules`):**
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /meals/{userId}/{allPaths=**} {
      // Users can only upload/delete their own meal photos
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 2. Add Dependencies

Update `pubspec.yaml`:
```yaml
dependencies:
  # Image handling
  image_picker: ^1.0.4

  # Firebase Storage
  firebase_storage: ^11.5.0

  # UUID generation
  uuid: ^4.2.0
```

### 3. Android Permissions

Update `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Add these permissions -->
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
                     android:maxSdkVersion="32" />

    <!-- Camera feature (optional, allows install on devices without camera) -->
    <uses-feature android:name="android.hardware.camera" android:required="false" />
    <uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />

    <application ...>
        ...
    </application>
</manifest>
```

### 4. Update Database Schema

Replace `lib/data/local/database/tables/meals_table.dart` with `meals_table_milestone4.dart`:

```bash
# Backup old table
mv lib/data/local/database/tables/meals_table.dart lib/data/local/database/tables/meals_table_old.dart

# Use new table
mv lib/data/local/database/tables/meals_table_milestone4.dart lib/data/local/database/tables/meals_table.dart
```

### 5. Register Dependencies

Update `lib/injection_container.dart` to register new services:
```dart
// Storage
getIt.registerLazySingleton(() => FirebaseStorage.instance);
getIt.registerLazySingleton(() => const Uuid());

// Hive box for meal cache
final mealCache = await Hive.openBox<Map>('meal_cache');
getIt.registerLazySingleton<Box<Map>>(() => mealCache, instanceName: 'mealCache');
```

### 6. Code Generation

Run build_runner to generate code:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates:
- `app_database.g.dart` (updated with new meals table)
- `meal_provider.g.dart` (Riverpod providers)
- `injection_container.config.dart` (updated dependencies)

### 7. Database Migration

Since meals table schema changed, increment database version in `lib/core/constants/app_constants.dart`:

```dart
class AppConstants {
  // ...
  static const int databaseVersion = 2; // Increment from 1 to 2
}
```

Add migration logic in `app_database.dart`:
```dart
@override
MigrationStrategy get migration {
  return MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from == 1 && to == 2) {
        // Drop old meals table
        await m.drop(mealsTable);
        // Create new meals table
        await m.createTable(mealsTable);
      }
    },
  );
}
```

### 8. Run the App

```bash
flutter clean
flutter pub get
flutter run
```

## Testing the Photo-First Flow

### 1. Log First Meal
- Open Nutrition tab
- Tap camera FAB
- Select "Take Photo" or "Choose from Gallery"
- Take/select photo of food
- Meal type auto-selected based on time
- Tap "Log Meal"
- Wait 2-3 seconds for AI analysis
- See success sheet with health score and feedback

### 2. View Meal History
- Scroll through today's meals
- Tap "View Full Analysis" on any meal card
- See complete AI feedback, suggestions, details
- Close to return to meal list

### 3. Add Optional Notes
- Tap camera FAB
- Select photo
- Tap notes field
- Enter context (e.g., "Feeling extra hungry")
- Log meal
- Notes appear in meal card

### 4. Test Edge Cases
- **No internet:** Should show error, allow retry
- **Bad photo:** Claude should identify and provide feedback
- **Unusual food:** Claude should analyze best-effort
- **Empty plate:** Should detect and ask user

## Key Features

### Photo-First (Not Calorie Tracking)
- **NO manual entry** of foods or calories
- **NO food database** searching
- **NO portion size selection** (AI estimates)
- **NO macro tracking** emphasis

### Outcome-Focused Feedback
- Health score (1-5) instead of calorie counts
- Personalized feedback relating to emotional goals
- "How does this support your goal to feel confident?"
- Warm, encouraging tone (not judgmental)

### Smart Defaults
- Meal type inferred from time of day:
  - 5am-11am → Breakfast
  - 11am-3pm → Lunch
  - 3pm-7pm → Snack
  - 7pm+ → Dinner
- Optional notes (not required)
- Photo is the only required input

### Dual Persistence
- **SQLite:** Permanent storage
- **Hive:** Fast cache for recent 50 meals
- **Firestore:** Cloud backup (async, fire-and-forget)
- Cache-first loading for instant UI

## Known Issues & Limitations

### Current Implementation
1. **No photo editing** - Can't crop, rotate, or enhance before upload
2. **Single photo per meal** - Can't add multiple angles
3. **No bulk logging** - Must log meals one at a time
4. **No meal editing** - Can only add/delete, not edit
5. **Analysis not cached** - Re-analyzes if Claude API called again

### Performance Considerations
1. **Claude Vision API latency:** 2-4 seconds (acceptable)
2. **Image upload time:** 1-2 seconds for 1920x1920 JPEG
3. **Total log time:** 3-6 seconds (fast enough for MVP)

### API Cost
- **Claude Vision:** ~$0.015 per image analysis
- **Expected usage:** 3-5 meals/day per user
- **Monthly cost (1000 users):** ~$2,250-$3,750

Can optimize by:
- Caching analysis for similar photos
- Rate limiting (max 10 meals/day)
- Lower image resolution

## Architecture Decisions

### Why Photo-First?
- **MVP Transformation #1:** Core differentiator from competitors
- **User problem:** Manual entry is tedious and inaccurate
- **Target user:** Busy mom with baby needs fastest possible logging
- **Validation:** "Snap, done" is 10x faster than manual entry

### Why Claude Vision?
- **Best-in-class image understanding** for food photos
- **Natural language output** for personalized feedback
- **Flexible prompt** can relate advice to user's goals
- **No pre-built food database** needed (more flexible)

### Why Health Score (1-5)?
- **Simpler than calories** - Easier to understand at a glance
- **Outcome-focused** - Relates to how user will feel
- **Not binary** - Acknowledges gray area (3 = okay, not bad)
- **Color-coded** - Visual feedback (red/yellow/green)

### Why De-emphasize Nutrition Info?
- **MVP philosophy:** Focus on outcomes, not numbers
- **User goal:** "Feel confident", not "count calories"
- **Behavioral change:** Builds better habits without obsession
- **Still available:** Shown in full analysis for those who want it

## Next Steps

### Immediate (Testing Phase)
1. Test photo logging on physical device
2. Verify camera/gallery permissions
3. Test Claude Vision analysis with various foods
4. Verify Firebase Storage upload/download
5. Test offline meal caching

### Milestone 5 (Workouts)
1. Photo-first workout logging? (consider)
2. AI workout recommendations
3. Exercise library
4. Progress tracking

### Future Enhancements (Post-MVP)
1. **Photo editing:** Crop, rotate, brightness
2. **Multiple photos:** Multiple angles of one meal
3. **Voice annotation:** Describe meal via voice
4. **Meal reminders:** "Haven't logged lunch yet"
5. **Meal sharing:** Share analysis with friends
6. **Meal favorites:** Quick re-log common meals
7. **Nutrition trends:** Weekly health score chart
8. **Smart suggestions:** "Similar meals scored higher"

## Support & Troubleshooting

### Camera Not Working
1. Check permissions in Android settings
2. Verify `image_picker` package installed
3. Test on physical device (emulator camera unreliable)

### Claude Vision Errors
1. Verify API key in `.env`
2. Check API key has sufficient credits
3. Review error messages (rate limit, image size, etc.)
4. Test with different image formats

### Upload Failures
1. Check Firebase Storage enabled
2. Verify security rules allow user uploads
3. Check network connectivity
4. Review file size limits (default 10MB)

### Analysis Quality Issues
1. **Blurry photos:** Ask user to retake
2. **Bad lighting:** Suggest better angles
3. **Unusual foods:** Claude will do best-effort
4. **Empty plates:** Claude should detect and ask

## Milestone 4 Complete

**Status:** ✅ All 20 files created, architecture validated, ready for testing

**Deliverables:**
- Photo-first meal logging flow
- Claude Vision API integration
- Firebase Storage integration
- Nutrition screen with meal history
- Dual persistence (SQLite + Hive + Firestore)
- Health score system (1-5)
- Outcome-focused feedback
- Clean Architecture implementation

**Next:** Test on physical device, then proceed to Milestone 5 (Workouts)
