# Meal Skip Checker - Setup & Testing Guide

## Overview

**What It Does:** AI checks in 3x/day to prevent meal skipping

**Check-In Times:**
- 9:00am (breakfast)
- 12:30pm (lunch)
- 7:00pm (dinner)

**How It Works:**
1. At check-in time, AI checks if user logged a meal in that window
2. If no meal logged → AI sends message: "Have you eaten [meal]?"
3. User responds: "Yes", "Not yet", or sends photo
4. AI records response and learns patterns

---

## Files Created (8 files)

### Domain Layer (1 file)
- `meal_check_in.dart` - Check-in entity with MealPeriod enum

### Services (2 files)
- `meal_check_scheduler.dart` - Schedules check-ins at specific times
- `meal_check_service.dart` - Check-in logic and history tracking

### Presentation (3 files)
- `meal_check_provider.dart` - Riverpod state management
- `meal_check_provider.g.dart` - Generated code
- `meal_check_message.dart` - Chat UI for check-in messages

### Screens (1 file)
- `settings_screen.dart` - Settings + manual testing interface

### Documentation (1 file)
- `MEAL_CHECK_SETUP.md` - This file

---

## Setup Instructions

### 1. Register Services

Update `lib/injection_container.dart`:

```dart
// Add these registrations
getIt.registerSingleton<MealCheckScheduler>(MealCheckScheduler());
getIt.registerSingleton<MealCheckService>(MealCheckService(getIt<Uuid>()));
```

### 2. Code Generation

Run build_runner:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Integrate with Chat Screen

Update `lib/presentation/chat/chat_screen.dart`:

Add at top of file:
```dart
import '../providers/meal_check_provider.dart';
import 'widgets/meal_check_message.dart';
```

In the build method, watch for pending check-ins:
```dart
@override
Widget build(BuildContext context) {
  final chatState = ref.watch(chatProvider);
  final pendingMessage = ref.watch(pendingCheckInMessageProvider);
  final pendingPeriod = ref.watch(pendingCheckInPeriodProvider);

  // ... existing code

  // In the ListView, add check-in message if pending:
  if (pendingMessage != null && pendingPeriod != null) {
    return MealCheckMessage(
      message: pendingMessage,
      period: pendingPeriod,
    );
  }
```

### 4. Integrate with Nutrition Screen

Update `lib/presentation/nutrition/widgets/quick_log_sheet.dart`:

In the `_logMeal` method, after successful meal log:

```dart
// Record meal logged
ref.read(mealCheckNotifierProvider.notifier).recordMealLogged(user.userId);
```

### 5. Add Settings to Navigation

Update router to include settings screen:

```dart
GoRoute(
  path: '/settings',
  name: 'settings',
  builder: (context, state) => const SettingsScreen(),
),
```

Add settings icon to app bar in home screen:

```dart
AppBar(
  actions: [
    IconButton(
      icon: const Icon(Icons.settings),
      onPressed: () => context.go('/settings'),
    ),
  ],
)
```

---

## Testing Instructions

### Manual Testing (Without Waiting for Scheduled Times)

1. **Open Settings Screen**
   - Tap settings icon in app bar
   - Scroll to "Testing (Dev Only)" section

2. **Trigger Manual Check-In**
   - Tap "Breakfast", "Lunch", or "Dinner" button
   - This simulates the scheduled check-in

3. **Navigate to Chat**
   - You'll be redirected automatically
   - See AI check-in message with response buttons

4. **Test Responses**

   **Option A: Reply "Yes, I ate"**
   - Taps "Yes, I ate" button
   - AI responds: "Great! Keep it up 👍"
   - Check-in recorded as eaten

   **Option B: Reply "Not yet"**
   - Taps "Not yet" button
   - AI responds: "Okay, try to eat something in the next 30 minutes"
   - Check-in recorded as skipped

   **Option C: Send Photo**
   - Taps "Send photo" button
   - Redirected to nutrition screen
   - Upload meal photo (normal flow)
   - Check-in automatically marked as eaten

5. **Verify Tracking**
   - Go back to Settings
   - See check-in history (future feature)
   - Verify AI learns patterns

### Automated Testing (Scheduled Times)

**Important:** These only fire at specific times:
- 9:00am - Breakfast check
- 12:30pm - Lunch check
- 7:00pm - Dinner check

**To test naturally:**
1. Keep app running in background
2. At scheduled time, you'll get check-in message
3. Open chat to respond

**For rapid testing:** Use manual triggers in Settings

---

## How the System Works

### Meal Windows

Each meal has a time window:
- **Breakfast:** 6am-10am
- **Lunch:** 11am-2pm
- **Dinner:** 6pm-9pm

### Skip Detection Logic

At check-in time (9am, 12:30pm, 7pm):

```
1. Check last meal photo timestamp
2. If photo was in current meal window → User ate, skip check-in
3. If no photo in window → User didn't eat, send check-in message
4. User responds → Record response
5. Learn pattern for future
```

### Pattern Learning (Future)

After 7 days of data:
- Calculates meal skip rate
- Identifies most skipped meal (breakfast/lunch/dinner)
- Can adjust check-in timing
- More persistent for commonly skipped meals

---

## User Experience Flow

### Scenario 1: User Ate Breakfast

```
7:30am - User takes photo of breakfast
         ↓
         Meal logged automatically
         ↓
9:00am - System checks: "Did user eat breakfast (6am-10am)?"
         ↓
         Yes, photo at 7:30am
         ↓
         No check-in needed
```

### Scenario 2: User Skipped Breakfast

```
9:00am - System checks: "Did user eat breakfast?"
         ↓
         No photo in 6am-10am window
         ↓
         AI sends: "Morning! Have you eaten breakfast?"
         ↓
User responds: "Not yet"
         ↓
         Recorded as skipped
         ↓
         Pattern learned
```

### Scenario 3: User Ate But Didn't Log

```
9:00am - System checks: "Did user eat breakfast?"
         ↓
         No photo found
         ↓
         AI sends: "Morning! Have you eaten breakfast?"
         ↓
User responds: "Yes, I ate"
         ↓
         Recorded as eaten (but not logged)
         ↓
         User educated: "Next time send a photo!"
```

---

## Current Limitations

### What's NOT Implemented Yet:

❌ **Escalating reminders** - "Still waiting..." messages after 10/20 minutes
❌ **Pattern-based timing** - Adjusting check-in times based on user habits
❌ **Notification system** - Currently only in-app messages
❌ **Check-in history UI** - Can't see past check-ins yet
❌ **Skip analytics** - No dashboard showing skip rate
❌ **Smart messaging** - All messages are generic, not personalized

### What IS Implemented:

✅ Scheduled check-ins at 3 fixed times
✅ Meal window detection
✅ Quick response buttons (Yes/Not yet/Photo)
✅ Pattern tracking (backend ready, no UI)
✅ Manual testing interface

---

## Next Steps

### Phase 1 Validation (This Week)
**Goal:** Does this work for YOU personally?

1. Use the app for 7 days
2. Respond to all check-ins honestly
3. Track: Did you skip fewer meals?

**Success Criteria:**
- You respond to 80%+ of check-ins
- You skip 50% fewer meals than baseline
- You find it helpful, not annoying

### Phase 2 Enhancement (If Phase 1 Works)
Add:
- Escalating reminders (10min, 20min)
- Push notifications (not just in-app)
- Pattern-based messaging
- "You always skip Monday lunch" detection
- Check-in history UI

### Phase 3 Expansion (If Phase 2 Works)
Add:
- Portion coach (visual feedback)
- Eating pace timer
- Full behavioral engine

---

## Troubleshooting

### Check-In Not Triggering
- Verify services registered in injection_container.dart
- Check scheduler listener is added
- Ensure app has proper time/date access

### Response Not Recording
- Check user authenticated
- Verify provider state updates
- Review console logs for errors

### Manual Trigger Not Working
- Ensure on Settings screen
- Check navigation to chat works
- Verify provider integration

---

## Technical Architecture

### State Flow

```
MealCheckScheduler
    ↓ (triggers at scheduled times)
MealCheckService
    ↓ (checks if meal logged)
MealCheckNotifier
    ↓ (if skip detected)
MealCheckChat
    ↓ (sends message)
Chat UI
    ↓ (user responds)
MealCheckChat
    ↓ (records response)
MealCheckService
    ↓ (stores history)
Pattern Learning (future)
```

### Data Storage

Currently in-memory (resets on app restart):
- Last meal times
- Check-in history

**Future:** Persist to SQLite for long-term pattern analysis

---

## Success Metrics

### Week 1 Target:
- 80% check-in response rate
- 50% reduction in skipped meals
- Positive user feedback

### If Successful:
- Roll out escalation system
- Add push notifications
- Implement pattern learning

### If Not Successful:
- Interview user: Why didn't it work?
- Test different intervention styles
- Consider alternative approaches

---

## The Real Test

**Does this solve YOUR problem?**

Remember: You skip meals → overeat later → gain weight

If AI check-ins prevent skipping, everything else (portion control, pace timer) becomes easier.

**This is the foundation.**

---

## Status

✅ Core system built
✅ Manual testing ready
⏳ Awaiting real-world validation (YOU testing it)
⏳ Enhancement features queued

**Next:** Test for 1 week, then we review and iterate.
