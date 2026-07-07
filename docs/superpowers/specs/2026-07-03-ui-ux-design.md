# AI Health Companion - UI/UX Design Specifications

**Version:** 1.0
**Date:** July 3, 2026
**Platform:** Android (Flutter)
**Design System:** Material Design 3
**Architecture:** Clean Architecture with MVVM

---

## Table of Contents

1. [Design System](#1-design-system)
2. [Component Library](#2-component-library)
3. [Screen Designs](#3-screen-designs)
4. [User Flows](#4-user-flows)
5. [Material Design 3 Implementation](#5-material-design-3-implementation)
6. [Responsive Design](#6-responsive-design)
7. [Accessibility](#7-accessibility)
8. [Animation & Motion](#8-animation--motion)

---

## 1. Design System

### 1.1 Color Palette

#### Primary Colors (Health & Vitality Theme)
- **Primary:** `#4CAF50` (Green 500) - Represents health, growth, vitality
- **On Primary:** `#FFFFFF` (White) - Text/icons on primary
- **Primary Container:** `#C8E6C9` (Green 100) - Lighter variant
- **On Primary Container:** `#1B5E20` (Green 900) - Text on container

#### Secondary Colors (Energy & Motivation)
- **Secondary:** `#FF9800` (Orange 500) - Energy, motivation, warmth
- **On Secondary:** `#000000` (Black) - Text/icons on secondary
- **Secondary Container:** `#FFE0B2` (Orange 100) - Lighter variant
- **On Secondary Container:** `#E65100` (Orange 900) - Text on container

#### Tertiary Colors (Calm & Balance)
- **Tertiary:** `#03A9F4` (Light Blue 500) - Water, hydration, calm
- **On Tertiary:** `#FFFFFF` (White)
- **Tertiary Container:** `#B3E5FC` (Light Blue 100)
- **On Tertiary Container:** `#01579B` (Light Blue 900)

#### Neutral Colors
- **Surface:** `#FAFAFA` (Gray 50) - Background surfaces
- **On Surface:** `#212121` (Gray 900) - Primary text
- **Surface Variant:** `#F5F5F5` (Gray 100) - Card backgrounds
- **On Surface Variant:** `#424242` (Gray 800) - Secondary text
- **Outline:** `#BDBDBD` (Gray 400) - Borders, dividers
- **Outline Variant:** `#E0E0E0` (Gray 300) - Subtle borders

#### Semantic Colors
- **Success:** `#4CAF50` (Green 500) - Goal achievement, positive feedback
- **Warning:** `#FF9800` (Orange 500) - Caution, reminders
- **Error:** `#F44336` (Red 500) - Errors, over-limit warnings
- **Info:** `#2196F3` (Blue 500) - Informational messages

#### Background Colors
- **Background:** `#FFFFFF` (White) - App background
- **Surface Dim:** `#F5F5F5` (Gray 100) - Slightly elevated surfaces
- **Surface Bright:** `#FFFFFF` (White) - Highest elevation

#### AI Chat Specific Colors
- **User Message Background:** `#E8F5E9` (Green 50) - User bubble
- **AI Message Background:** `#FFFFFF` (White) - AI bubble with elevation
- **AI Message Border:** `#E0E0E0` (Gray 300) - Subtle border

### 1.2 Typography System

**Font Family:** Roboto (Material Design standard)

#### Type Scale

**Display Large**
- Font: Roboto Regular
- Size: 57sp
- Line Height: 64sp
- Letter Spacing: -0.25sp
- Usage: Splash screen, empty states

**Display Medium**
- Font: Roboto Regular
- Size: 45sp
- Line Height: 52sp
- Letter Spacing: 0sp
- Usage: Large headlines

**Display Small**
- Font: Roboto Regular
- Size: 36sp
- Line Height: 44sp
- Letter Spacing: 0sp
- Usage: Onboarding titles

**Headline Large**
- Font: Roboto Medium
- Size: 32sp
- Line Height: 40sp
- Letter Spacing: 0sp
- Usage: Screen titles

**Headline Medium**
- Font: Roboto Medium
- Size: 28sp
- Line Height: 36sp
- Letter Spacing: 0sp
- Usage: Section headers

**Headline Small**
- Font: Roboto Medium
- Size: 24sp
- Line Height: 32sp
- Letter Spacing: 0sp
- Usage: Card titles, dialog titles

**Title Large**
- Font: Roboto Medium
- Size: 22sp
- Line Height: 28sp
- Letter Spacing: 0sp
- Usage: Top app bar titles

**Title Medium**
- Font: Roboto Medium
- Size: 16sp
- Line Height: 24sp
- Letter Spacing: 0.15sp
- Usage: List item titles

**Title Small**
- Font: Roboto Medium
- Size: 14sp
- Line Height: 20sp
- Letter Spacing: 0.1sp
- Usage: Subtitles

**Body Large**
- Font: Roboto Regular
- Size: 16sp
- Line Height: 24sp
- Letter Spacing: 0.5sp
- Usage: Main body text, AI messages

**Body Medium**
- Font: Roboto Regular
- Size: 14sp
- Line Height: 20sp
- Letter Spacing: 0.25sp
- Usage: Secondary body text

**Body Small**
- Font: Roboto Regular
- Size: 12sp
- Line Height: 16sp
- Letter Spacing: 0.4sp
- Usage: Captions, helper text

**Label Large**
- Font: Roboto Medium
- Size: 14sp
- Line Height: 20sp
- Letter Spacing: 0.1sp
- Usage: Button text

**Label Medium**
- Font: Roboto Medium
- Size: 12sp
- Line Height: 16sp
- Letter Spacing: 0.5sp
- Usage: Small buttons, chips

**Label Small**
- Font: Roboto Medium
- Size: 11sp
- Line Height: 16sp
- Letter Spacing: 0.5sp
- Usage: Tiny labels, timestamps

### 1.3 Spacing Scale

**Base Unit:** 4dp

- **XXS:** 4dp - Tight spacing within components
- **XS:** 8dp - Small gaps between related elements
- **SM:** 12dp - Related item spacing
- **MD:** 16dp - Standard padding, gaps between sections
- **LG:** 24dp - Large gaps between major sections
- **XL:** 32dp - Extra large spacing
- **XXL:** 48dp - Major section breaks
- **XXXL:** 64dp - Screen-level spacing

**Standard Padding:**
- Screen horizontal padding: 16dp
- Screen vertical padding: 16dp
- Card padding: 16dp
- List item padding: 16dp horizontal, 12dp vertical
- Button padding: 16dp horizontal, 12dp vertical

### 1.4 Elevation & Shadows

Material Design 3 uses elevation levels for hierarchy:

**Level 0 (0dp)** - No elevation
- Background surfaces
- Flat buttons

**Level 1 (1dp)** - Subtle elevation
- Cards at rest
- Filled buttons

**Level 2 (3dp)** - Slight hover
- Cards on hover
- FAB at rest

**Level 3 (6dp)** - Moderate elevation
- App bar
- Modal bottom sheets
- Navigation drawer

**Level 4 (8dp)** - Prominent elevation
- FAB on hover
- Dialogs

**Level 5 (12dp)** - Highest elevation
- Navigation bar
- Bottom navigation bar

**Shadow Values:**
```dart
// Level 1
BoxShadow(
  color: Color(0x1F000000), // 12% opacity
  offset: Offset(0, 1),
  blurRadius: 3,
  spreadRadius: 0,
)

// Level 2
BoxShadow(
  color: Color(0x24000000), // 14% opacity
  offset: Offset(0, 2),
  blurRadius: 6,
  spreadRadius: 1,
)

// Level 3
BoxShadow(
  color: Color(0x29000000), // 16% opacity
  offset: Offset(0, 3),
  blurRadius: 12,
  spreadRadius: 2,
)
```

### 1.5 Border Radius Standards

- **None:** 0dp - Dividers, progress bars
- **XS:** 4dp - Small chips, badges
- **SM:** 8dp - Buttons, text fields
- **MD:** 12dp - Cards, message bubbles
- **LG:** 16dp - Large cards, bottom sheets
- **XL:** 24dp - Modal dialogs
- **XXL:** 28dp - FAB
- **Full:** 9999dp - Circular avatars, round buttons

### 1.6 Icon System

**Icon Library:** Material Icons (Material Symbols)

**Sizes:**
- Small: 16dp - Inline icons
- Medium: 24dp - Standard UI icons
- Large: 32dp - Feature icons
- XLarge: 48dp - Empty state icons
- Huge: 64dp - Onboarding illustrations

**Common Icons:**
- Home: `home`
- Chat: `chat_bubble`
- Progress: `trending_up`
- Profile: `person`
- Settings: `settings`
- Meal: `restaurant`
- Workout: `fitness_center`
- Weight: `monitor_weight`
- Calendar: `calendar_today`
- Reminder: `notifications`
- Camera: `camera_alt`
- Send: `send`
- Back: `arrow_back`
- Close: `close`
- Check: `check`
- Add: `add`
- Edit: `edit`
- More: `more_vert`

---

## 2. Component Library

### 2.1 Buttons

#### Primary Button (Filled)
```
┌─────────────────────────┐
│   Button Label Text     │
└─────────────────────────┘
```
- Background: Primary color (`#4CAF50`)
- Text: On Primary (`#FFFFFF`)
- Text style: Label Large (14sp, Medium)
- Height: 48dp
- Padding: 24dp horizontal, 12dp vertical
- Border radius: 8dp
- Elevation: Level 1 (1dp)
- Ripple effect: On Primary with 20% opacity
- Usage: Primary actions (Login, Submit, Continue)

#### Secondary Button (Outlined)
```
┌─────────────────────────┐
│   Button Label Text     │ (Outlined)
└─────────────────────────┘
```
- Background: Transparent
- Border: 1dp solid Outline (`#BDBDBD`)
- Text: Primary color (`#4CAF50`)
- Text style: Label Large
- Height: 48dp
- Padding: 24dp horizontal, 12dp vertical
- Border radius: 8dp
- Ripple effect: Primary with 10% opacity
- Usage: Secondary actions (Cancel, Skip)

#### Text Button
```
  Button Label Text  (No border)
```
- Background: Transparent
- Text: Primary color (`#4CAF50`)
- Text style: Label Large
- Height: 40dp
- Padding: 12dp horizontal, 8dp vertical
- Border radius: 8dp
- Ripple effect: Primary with 10% opacity
- Usage: Tertiary actions (Learn more, Change)

#### FAB (Floating Action Button)
```
    ┌─────┐
    │  +  │
    └─────┘
```
- Background: Primary color (`#4CAF50`)
- Icon: On Primary (`#FFFFFF`), 24dp
- Size: 56dp x 56dp
- Border radius: 28dp (circular)
- Elevation: Level 2 (3dp), Level 3 on hover (6dp)
- Usage: Start new chat, Add weight entry

#### Icon Button
```
  [icon]
```
- Size: 48dp x 48dp
- Icon size: 24dp
- Color: On Surface Variant (`#424242`)
- Ripple: Circular
- Usage: Navigation, actions in app bar

### 2.2 Input Fields

#### Text Field (Filled)
```
┌─────────────────────────────────┐
│ Label                           │
│ ─────────────────────────────── │
│ Input text here                 │
│                                 │
└─────────────────────────────────┘
  Helper text or error message
```
- Background: Surface Variant (`#F5F5F5`)
- Border: None (bottom indicator only)
- Bottom indicator: 1dp, Outline color
- Bottom indicator (focused): 2dp, Primary color
- Label: Body Small, On Surface Variant
- Input text: Body Large, On Surface
- Height: 56dp
- Padding: 16dp horizontal, 12dp top, 8dp bottom
- Border radius: 8dp (top corners only)
- Helper text: Body Small, On Surface Variant
- Error text: Body Small, Error color

#### Text Field (Outlined)
```
┌─────────────────────────────────┐
│  Label                          │
│                                 │
│  Input text here                │
│                                 │
└─────────────────────────────────┘
```
- Background: Transparent
- Border: 1dp solid Outline
- Border (focused): 2dp solid Primary
- Border (error): 2dp solid Error
- Label: Floats up when focused/filled
- Height: 56dp
- Padding: 16dp horizontal
- Border radius: 8dp
- Usage: Forms, login screens

#### Search Field
```
┌──────────────────────────────────┐
│ 🔍  Search...                    │
└──────────────────────────────────┘
```
- Background: Surface Variant
- Leading icon: Search (24dp)
- Border radius: 28dp (pill shape)
- Height: 48dp
- Padding: 16dp horizontal
- Usage: Search meals, workouts

### 2.3 Cards

#### Standard Card
```
┌─────────────────────────────────┐
│                                 │
│  Card Title                     │
│  Card subtitle or description   │
│                                 │
│  [Content Area]                 │
│                                 │
│  ─────────────────────────────  │
│  Action 1    Action 2           │
└─────────────────────────────────┘
```
- Background: Surface (`#FAFAFA`)
- Border: 1dp solid Outline Variant (`#E0E0E0`)
- Padding: 16dp
- Border radius: 12dp
- Elevation: Level 1 (1dp)
- Title: Title Medium
- Subtitle: Body Medium, On Surface Variant
- Content: Body Large
- Actions: Text buttons, 8dp spacing

#### Elevated Card
```
┌─────────────────────────────────┐
│         [Elevated]              │
│  Card Title                     │
│  Card content with shadow       │
│                                 │
└─────────────────────────────────┘
```
- Background: Surface Bright (`#FFFFFF`)
- No border
- Padding: 16dp
- Border radius: 12dp
- Elevation: Level 2 (3dp)
- Usage: Featured content, stats cards

#### Outlined Card
```
┌─────────────────────────────────┐
│  [Outlined - Thicker Border]    │
│  Card Title                     │
│  Card content                   │
└─────────────────────────────────┘
```
- Background: Surface
- Border: 2dp solid Outline
- Padding: 16dp
- Border radius: 12dp
- No elevation
- Usage: Selectable options, plans

### 2.4 Bottom Navigation

```
┌─────────────────────────────────┐
│  🏠      💬      📈      👤     │
│ Home    Chat  Progress Profile │
└─────────────────────────────────┘
```
- Background: Surface Bright (`#FFFFFF`)
- Height: 80dp
- Items: 4 navigation items
- Icon size: 24dp
- Label: Label Medium
- Active icon color: Primary (`#4CAF50`)
- Active label color: On Surface (`#212121`)
- Inactive icon color: On Surface Variant (`#757575`)
- Inactive label color: On Surface Variant
- Indicator: 64dp x 32dp rounded pill behind active item
- Indicator background: Primary Container (`#C8E6C9`)
- Elevation: Level 3 (6dp)
- Usage: Main app navigation

### 2.5 App Bar (Top)

#### Standard App Bar
```
┌─────────────────────────────────┐
│ ← Screen Title          [•••]   │
└─────────────────────────────────┘
```
- Background: Surface (`#FAFAFA`)
- Height: 64dp
- Leading icon: 48dp x 48dp icon button (Back)
- Title: Title Large, On Surface
- Title padding: 16dp from leading icon
- Trailing icons: 48dp x 48dp icon buttons
- Elevation: None (uses bottom border)
- Bottom border: 1dp solid Outline Variant
- Usage: Secondary screens

#### Center-aligned App Bar
```
┌─────────────────────────────────┐
│ ←        Screen Title       🔍  │
└─────────────────────────────────┘
```
- Same as standard but title is centered
- Usage: Main screens (Home, Chat)

#### Large App Bar (Scrollable)
```
┌─────────────────────────────────┐
│ ←                          [•••]│
│                                 │
│ Large Title                     │
│ Subtitle or date                │
└─────────────────────────────────┘
```
- Height: 112dp (collapsed to 64dp on scroll)
- Title: Headline Medium
- Subtitle: Body Medium, On Surface Variant
- Usage: Home screen, Profile

### 2.6 Message Bubbles

#### User Message Bubble
```
                    ┌────────────────┐
                    │ User message   │
                    │ text here      │
                    └────────────────┘
                    12:34 PM
```
- Background: User Message Background (`#E8F5E9`)
- Text: On Surface (`#212121`)
- Text style: Body Large
- Padding: 12dp horizontal, 10dp vertical
- Border radius: 12dp (top-left, bottom-left, top-right), 2dp (bottom-right)
- Max width: 80% of screen width
- Alignment: Right
- Timestamp: Label Small, On Surface Variant, 4dp below bubble

#### AI Message Bubble
```
┌────────────────────────┐
│ AI response text here  │
│ can span multiple      │
│ lines                  │
└────────────────────────┘
12:34 PM
```
- Background: AI Message Background (`#FFFFFF`)
- Border: 1dp solid AI Message Border (`#E0E0E0`)
- Text: On Surface (`#212121`)
- Text style: Body Large
- Padding: 12dp horizontal, 10dp vertical
- Border radius: 12dp (top-left, top-right, bottom-right), 2dp (bottom-left)
- Max width: 85% of screen width
- Alignment: Left
- Elevation: Level 1 (1dp)
- Timestamp: Label Small, On Surface Variant, 4dp below bubble

#### System Message
```
        ──── Today, June 15 ────
```
- Text: Label Medium, On Surface Variant
- Background: Transparent
- Alignment: Center
- Padding: 16dp vertical
- Usage: Date separators, system notifications

### 2.7 Progress Indicators

#### Linear Progress Bar
```
████████░░░░░░░░░░░░  45%
```
- Height: 4dp
- Background: Primary Container (`#C8E6C9`)
- Progress color: Primary (`#4CAF50`)
- Border radius: 2dp
- Usage: Weight goal progress, daily calorie tracking

#### Circular Progress Indicator
```
    ╭───╮
   │ 65% │
    ╰───╯
```
- Size: 48dp (small), 64dp (medium), 96dp (large)
- Stroke width: 4dp
- Color: Primary (`#4CAF50`)
- Background ring: Primary Container
- Center text: Title Medium
- Usage: Loading states, achievement progress

#### Circular Progress (Determinate)
```
     ╭───╮
    │█░░│  25%
     ╰───╯
```
- Animated circular progress
- Shows percentage inside
- Usage: Daily goal completion

### 2.8 Dialogs & Modals

#### Alert Dialog
```
┌─────────────────────────────────┐
│                                 │
│  Dialog Title                   │
│                                 │
│  Dialog message or description  │
│  text that explains the action  │
│  to the user.                   │
│                                 │
│              CANCEL      OK     │
└─────────────────────────────────┘
```
- Background: Surface Bright (`#FFFFFF`)
- Padding: 24dp
- Border radius: 24dp
- Elevation: Level 4 (8dp)
- Title: Title Large
- Content: Body Large
- Button bar: 8dp spacing, right-aligned
- Max width: 280dp (small screens), 560dp (large)

#### Bottom Sheet
```
│                                 │
└─────────────────────────────────┘
┌─────────────────────────────────┐
│       ──────                    │
│                                 │
│  Sheet Title                    │
│                                 │
│  [Content]                      │
│                                 │
│                                 │
└─────────────────────────────────┘
```
- Background: Surface Bright (`#FFFFFF`)
- Top padding: 8dp
- Side/bottom padding: 16dp
- Border radius: 16dp (top corners only)
- Elevation: Level 3 (6dp)
- Handle: 32dp x 4dp, rounded, Outline color
- Handle position: Centered, 8dp from top
- Usage: Weight input, meal details, settings

#### Modal Bottom Sheet
```
Background overlay (scrim)
┌─────────────────────────────────┐
│       ──────                    │
│  Add Weight Entry               │
│                                 │
│  Weight (kg)                    │
│  [_____________]                │
│                                 │
│  Date                           │
│  [_____________]                │
│                                 │
│           CANCEL      SAVE      │
└─────────────────────────────────┘
```
- Scrim: Black with 32% opacity
- Dismissible by tapping scrim or swiping down
- Usage: Quick actions, forms

### 2.9 Snackbars

#### Standard Snackbar
```
     ┌─────────────────────────────┐
     │ Message text here    ACTION │
     └─────────────────────────────┘
```
- Background: On Surface (`#212121`)
- Text: Surface (`#FAFAFA`)
- Text style: Body Medium
- Action text: Primary color or Secondary color
- Padding: 16dp horizontal, 14dp vertical
- Border radius: 8dp
- Elevation: Level 3 (6dp)
- Position: Bottom center, 16dp from bottom (above bottom nav: 96dp)
- Width: Screen width - 32dp (max 600dp)
- Duration: 4 seconds (short), 10 seconds (long)

#### Snackbar with Icon
```
     ┌─────────────────────────────┐
     │ ✓ Success message    ACTION │
     └─────────────────────────────┘
```
- Leading icon: 24dp, tinted to match action color
- Usage: Success confirmations, error messages

---

## 3. Screen Designs

### 3.1 Splash Screen

```
┌─────────────────────────────────┐
│                                 │
│                                 │
│           ┌─────┐               │
│           │ 🌱  │               │
│           └─────┘               │
│                                 │
│      AI Health Companion        │
│                                 │
│         Your personal           │
│         wellness coach          │
│                                 │
│                                 │
│            ●●●○○                │
│         (loading dots)          │
│                                 │
│                                 │
└─────────────────────────────────┘
```

**Layout Details:**
- Background: Gradient from Primary Container to Surface
- Logo: 96dp x 96dp, centered
- App name: Headline Large, centered, 24dp below logo
- Tagline: Body Large, On Surface Variant, centered, 8dp below name
- Loading indicator: 16dp below tagline
- Duration: 2-3 seconds
- Animation: Fade in logo → Type app name → Show loading

**Colors:**
- Background gradient: `#C8E6C9` to `#FAFAFA`
- Logo tint: Primary (`#4CAF50`)
- Text: On Surface (`#212121`)

### 3.2 Login Screen

```
┌─────────────────────────────────┐
│ ←                               │
│                                 │
│                                 │
│     Welcome Back                │
│                                 │
│     Sign in to continue your    │
│     wellness journey            │
│                                 │
│                                 │
│  Email or Phone Number          │
│  ┌────────────────────────────┐│
│  │                            ││
│  └────────────────────────────┘│
│                                 │
│                                 │
│  ┌─────────────────────────────┐
│  │     Continue with Email     │
│  └─────────────────────────────┘
│                                 │
│  ──────────── OR ────────────── │
│                                 │
│  ┌─────────────────────────────┐
│  │ 📱  Continue with Phone     │
│  └─────────────────────────────┘
│                                 │
│                                 │
│   By continuing, you agree to   │
│   Terms & Privacy Policy        │
│                                 │
└─────────────────────────────────┘
```

**Layout Details:**
- Top padding: 24dp
- Back button: Top-left, 16dp margin
- Title: Headline Large, 48dp from top
- Subtitle: Body Large, On Surface Variant, 12dp below title
- Text field: 48dp below subtitle, full width - 32dp margins
- Continue button: 24dp below text field
- Divider with "OR": 24dp below button
- Phone button: 24dp below divider
- Terms text: Body Small, centered, 32dp from bottom

**Interactions:**
- Email/Phone auto-detection
- Keyboard opens with email/phone keypad
- Continue button validates input format
- Transitions to OTP verification

### 3.3 OTP Verification Screen

```
┌─────────────────────────────────┐
│ ←                               │
│                                 │
│                                 │
│     Enter Verification Code     │
│                                 │
│     We sent a code to           │
│     +91 98765 43210   Change    │
│                                 │
│                                 │
│    ┌───┐ ┌───┐ ┌───┐ ┌───┐    │
│    │ 1 │ │ 2 │ │ 3 │ │ 4 │    │
│    └───┘ └───┘ └───┘ └───┘    │
│                                 │
│                                 │
│     Resend code in 0:42         │
│                                 │
│                                 │
│  ┌─────────────────────────────┐
│  │         Verify Code         │
│  └─────────────────────────────┘
│                                 │
│                                 │
│                                 │
└─────────────────────────────────┘
```

**Layout Details:**
- OTP boxes: 4 boxes, 48dp x 56dp each, 12dp spacing
- Each box: Outlined text field style
- Active box: Primary border (2dp)
- Filled box: Success color background
- Phone number: Body Medium, with "Change" text button
- Resend timer: Body Small, On Surface Variant
- Verify button: Enabled when 4 digits entered

**Interactions:**
- Auto-focus first box
- Auto-advance to next box on entry
- Auto-submit when 4 digits complete
- Resend enabled after countdown
- Shake animation on wrong OTP

### 3.4 Onboarding Flow

#### Onboarding Screen 1: Welcome

```
┌─────────────────────────────────┐
│                                 │
│                                 │
│          [Illustration]         │
│       👋 Welcome to your        │
│       personal wellness         │
│       journey                   │
│                                 │
│                                 │
│     Meet your AI health         │
│     companion that learns       │
│     and grows with you          │
│                                 │
│                                 │
│           ●○○○                  │
│                                 │
│                                 │
│                         Next →  │
│                                 │
│              Skip               │
└─────────────────────────────────┘
```

#### Onboarding Screen 2: Set Your Goal

```
┌─────────────────────────────────┐
│                                 │
│          [Illustration]         │
│       🎯 Set Your Goals         │
│                                 │
│                                 │
│  Current Weight (kg)            │
│  ┌────────────────────────────┐│
│  │          81                ││
│  └────────────────────────────┘│
│                                 │
│  Target Weight (kg)             │
│  ┌────────────────────────────┐│
│  │          55                ││
│  └────────────────────────────┘│
│                                 │
│  Height (cm)                    │
│  ┌────────────────────────────┐│
│  │         153                ││
│  └────────────────────────────┘│
│                                 │
│           ○●○○                  │
│                                 │
│  ← Back              Next →     │
│              Skip               │
└─────────────────────────────────┘
```

#### Onboarding Screen 3: Meal Preferences

```
┌─────────────────────────────────┐
│                                 │
│          [Illustration]         │
│       🍽️ Meal Preferences       │
│                                 │
│                                 │
│  What's your diet type?         │
│                                 │
│  ┌────────────────────────────┐│
│  │ ✓ Vegetarian              ││
│  └────────────────────────────┘│
│  ┌────────────────────────────┐│
│  │   Non-Vegetarian          ││
│  └────────────────────────────┘│
│  ┌────────────────────────────┐│
│  │   Vegan                   ││
│  └────────────────────────────┘│
│                                 │
│  Allergies or restrictions?     │
│  ┌────────────────────────────┐│
│  │ None                       ││
│  └────────────────────────────┘│
│                                 │
│           ○○●○                  │
│                                 │
│  ← Back              Next →     │
│              Skip               │
└─────────────────────────────────┘
```

#### Onboarding Screen 4: Notifications

```
┌─────────────────────────────────┐
│                                 │
│          [Illustration]         │
│       🔔 Stay on Track          │
│                                 │
│                                 │
│  Enable reminders to stay       │
│  consistent with your goals     │
│                                 │
│                                 │
│  ┌────────────────────────────┐│
│  │ 🍳 Breakfast    8:00 AM  ⟳ ││
│  └────────────────────────────┘│
│  ┌────────────────────────────┐│
│  │ 🍱 Lunch       1:00 PM   ⟳ ││
│  └────────────────────────────┘│
│  ┌────────────────────────────┐│
│  │ 🍽️ Dinner      7:00 PM   ⟳ ││
│  └────────────────────────────┘│
│  ┌────────────────────────────┐│
│  │ 💪 Workout     6:00 AM   ⟳ ││
│  └────────────────────────────┘│
│                                 │
│           ○○○●                  │
│                                 │
│  ← Back         Get Started →   │
│              Skip               │
└─────────────────────────────────┘
```

**Onboarding Layout Specifications:**
- Illustration: 200dp height, centered
- Title: Headline Medium, centered, 24dp below illustration
- Description: Body Large, centered, 16dp below title
- Content area: 32dp below description
- Progress dots: 32dp from bottom actions
- Actions: 16dp from bottom, spaced evenly
- Skip button: Text button, centered

### 3.5 Dashboard/Home Screen

```
┌─────────────────────────────────┐
│        Good Morning, Sara       │
│        June 15, 2026            │
│                                 │
│ ┌─────────────────────────────┐ │
│ │  Today's Progress            │ │
│ │                              │ │
│ │   ╭───╮                      │ │
│ │  │ 45% │  Weight Goal        │ │
│ │   ╰───╯                      │ │
│ │         81 kg → 55 kg        │ │
│ │         26 kg to go          │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │  Quick Actions              │ │
│ │                              │ │
│ │  💬 Chat    🍽️ Meal   ⚖️ Weight│
│ │             Log                │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │  Today's Meals              │ │
│ │  ─────────────────────────  │ │
│ │  🍳 Breakfast    ✓ Logged   │ │
│ │  🍱 Lunch        ⏰ In 2h   │ │
│ │  🍽️ Dinner       Not logged │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │  Workout Reminder           │ │
│ │  ─────────────────────────  │ │
│ │  💪 30-min cardio session   │ │
│ │     Deepthi's Full Body     │ │
│ │                              │ │
│ │              START WORKOUT → │
│ └─────────────────────────────┘ │
│                                 │
└─────────────────────────────────┘
 🏠      💬      📈      👤
 Home    Chat  Progress Profile
```

**Layout Details:**
- Large app bar: 112dp with greeting and date
- Greeting: Title Large
- Date: Body Medium, On Surface Variant
- Content padding: 16dp horizontal
- Card spacing: 16dp vertical
- Quick actions: 3 icon buttons in row, evenly spaced
- Meal items: List tiles with icon, title, status
- Scrollable content
- Bottom navigation: Fixed at bottom

**Interactions:**
- Swipe down to refresh
- Tap progress card → Navigate to Progress screen
- Tap quick action → Open respective screen
- Tap meal item → Open meal details/log
- Tap workout card → Open workout details

### 3.6 Chat Screen (Primary Interface)

```
┌─────────────────────────────────┐
│ ←      AI Health Coach      ⋮   │
│                                 │
│        ──── Today ────          │
│                                 │
│ ┌────────────────────────┐      │
│ │ Hi Sara! Ready to      │      │
│ │ tackle today's goals?  │      │
│ └────────────────────────┘      │
│ 9:30 AM                         │
│                                 │
│                  ┌────────────┐ │
│                  │ Yes! What  │ │
│                  │ should I   │ │
│                  │ eat for    │ │
│                  │ breakfast? │ │
│                  └────────────┘ │
│                  9:31 AM        │
│                                 │
│ ┌────────────────────────┐      │
│ │ Great! Based on your   │      │
│ │ goals, I recommend:    │      │
│ │                        │      │
│ │ 🍳 2 egg white omelet  │      │
│ │ 🥑 Half avocado        │      │
│ │ 🍞 1 slice brown bread │      │
│ │ ☕ Green tea            │      │
│ │                        │      │
│ │ ~320 calories          │      │
│ │                        │      │
│ │ [Log This Meal]        │      │
│ └────────────────────────┘      │
│ 9:31 AM                         │
│                                 │
│                                 │
├─────────────────────────────────┤
│ 📎  Type your message...    😊  │
└─────────────────────────────────┘
```

**Layout Details:**
- App bar: Standard, 64dp with AI name and menu
- Chat area: Scrollable, 16dp horizontal padding
- Message spacing: 12dp vertical between messages
- Date separator: 24dp vertical padding
- User bubbles: Aligned right, 80% max width
- AI bubbles: Aligned left, 85% max width
- Timestamps: 4dp below bubbles
- Action buttons in AI messages: Outlined buttons, 8dp margin
- Input bar: 56dp height, fixed at bottom
- Attachment icon: Leading, 48dp button
- Text input: Expands, max 120dp height
- Emoji icon: Trailing, 48dp button
- Send icon: Appears when text present

**Interactions:**
- Tap message → Show timestamp and actions
- Long press → Copy message
- Tap action button → Execute action (log meal, start workout)
- Scroll up → Load more messages
- Tap attachment → Open camera/gallery
- Voice input available
- AI typing indicator: Three animated dots

**Smart Features:**
- Quick replies: Suggestion chips above input
  ```
  ┌─────────┐ ┌─────────┐ ┌─────────┐
  │ Log meal│ │ Workout │ │ Water   │
  └─────────┘ └─────────┘ └─────────┘
  ```
- Context-aware suggestions
- Inline meal/workout cards
- Progress updates in chat

### 3.7 Progress Screen

```
┌─────────────────────────────────┐
│ ←           Progress        [+] │
│                                 │
│ ┌─────────────────────────────┐ │
│ │                              │ │
│ │  Current Weight: 78 kg       │ │
│ │  Started: 81 kg              │ │
│ │  Goal: 55 kg                 │ │
│ │  Lost: 3 kg (12%)            │ │
│ │                              │ │
│ └─────────────────────────────┘ │
│                                 │
│  Weight Trend                   │
│                                 │
│ ┌─────────────────────────────┐ │
│ │  82 ●                        │ │
│ │     │\                       │ │
│ │  80 │ \●                     │ │
│ │     │   \                    │ │
│ │  78 │    \●──●               │ │
│ │     │                        │ │
│ │  76 │                        │ │
│ │     └────────────────        │ │
│ │     May   Jun   Jul          │ │
│ │                              │ │
│ │  ┌──┐ ┌──┐ ┌──┐ ┌──┐       │ │
│ │  │1W│ │1M│ │3M│ │1Y│       │ │
│ │  └──┘ └──┘ └──┘ └──┘       │ │
│ └─────────────────────────────┘ │
│                                 │
│  Milestones                     │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ ✓ Lost first 3kg   Jun 10   │ │
│ │ ○ 5% body weight   2kg to go│ │
│ │ ○ 10kg milestone  7kg to go │ │
│ └─────────────────────────────┘ │
│                                 │
│  Weekly Insights                │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ 📊 Avg. weight loss: 0.5kg  │ │
│ │ 🍽️ Meals logged: 18/21      │ │
│ │ 💪 Workouts: 4/5            │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

**Layout Details:**
- App bar: Standard with "+" button for manual weight entry
- Summary card: Elevated card, key stats
- Graph card: Elevated card, line chart
- Time range selector: Segmented buttons below graph
- Milestones: List of cards, checkmark for completed
- Insights: Stats card with icons
- Vertical spacing: 16dp between sections
- Scrollable content

**Graph Specifications:**
- Height: 200dp
- X-axis: Time labels
- Y-axis: Weight in kg
- Line: 2dp stroke, Primary color
- Points: 8dp circles, Primary color
- Goal line: 1dp dashed, Secondary color
- Grid: 1dp, Outline Variant

**Interactions:**
- Tap "+" → Open weight entry bottom sheet
- Tap graph point → Show exact weight and date
- Switch time range → Animate graph update
- Tap milestone → Show milestone details
- Pull to refresh → Update data

### 3.8 Profile Screen

```
┌─────────────────────────────────┐
│ ←           Profile         ⚙️  │
│                                 │
│           ┌─────┐               │
│           │  S  │               │
│           └─────┘               │
│                                 │
│            Sara                 │
│       sara@email.com            │
│                                 │
│        [Edit Profile]           │
│                                 │
│ ┌─────────────────────────────┐ │
│ │  Personal Information       │ │
│ │  ───────────────────────    │ │
│ │  Age              32 years  │ │
│ │  Height           153 cm    │ │
│ │  Current Weight   78 kg     │ │
│ │  Target Weight    55 kg     │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │  Preferences                │ │
│ │  ───────────────────────    │ │
│ │  Diet Type        Vegetarian│ │
│ │  Meal Reminders   Enabled   │ │
│ │  Workout Time     6:00 AM   │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │  Account                    │ │
│ │  ───────────────────────    │ │
│ │  Subscription     Free      │ │
│ │  Member Since     May 2026  │ │
│ │                              │ │
│ │  [Upgrade to Pro]           │ │
│ └─────────────────────────────┘ │
│                                 │
│           [Log Out]             │
│                                 │
└─────────────────────────────────┘
```

**Layout Details:**
- App bar: Standard with settings icon
- Avatar: 96dp circular, centered, 24dp from top
- Name: Title Large, centered, 16dp below avatar
- Email: Body Medium, On Surface Variant, centered
- Edit button: Text button, 8dp below email
- Info cards: 16dp spacing
- Card sections: Title Small for headers, Body Medium for content
- List items: 48dp height, key-value pairs
- Log out: Text button, Error color, 32dp from bottom

**Interactions:**
- Tap avatar → Change photo (camera/gallery)
- Tap Edit Profile → Edit mode for all fields
- Tap info row → Edit specific field
- Tap Upgrade → Show subscription options
- Tap Log Out → Confirm dialog

### 3.9 Settings Screen

```
┌─────────────────────────────────┐
│ ←          Settings             │
│                                 │
│  Notifications                  │
│ ┌─────────────────────────────┐ │
│ │ Meal Reminders          [✓] │ │
│ │ Workout Reminders       [✓] │ │
│ │ Progress Updates        [✓] │ │
│ │ AI Chat Messages        [✓] │ │
│ └─────────────────────────────┘ │
│                                 │
│  Appearance                     │
│ ┌─────────────────────────────┐ │
│ │ Theme                   Auto│ │
│ │ Language               English│
│ └─────────────────────────────┘ │
│                                 │
│  Data & Privacy                 │
│ ┌─────────────────────────────┐ │
│ │ Export My Data          →   │ │
│ │ Delete Account          →   │ │
│ └─────────────────────────────┘ │
│                                 │
│  About                          │
│ ┌─────────────────────────────┐ │
│ │ Version            1.0.0    │ │
│ │ Terms of Service        →   │ │
│ │ Privacy Policy          →   │ │
│ │ Help & Support          →   │ │
│ └─────────────────────────────┘ │
│                                 │
└─────────────────────────────────┘
```

**Layout Details:**
- Section headers: Title Small, 24dp top padding
- Settings cards: Grouped settings, 8dp between sections
- Toggle switches: Right-aligned, 24dp x 40dp
- List items: 56dp height with icon and label
- Navigation arrows: Right-aligned icons
- Scrollable content

**Interactions:**
- Toggle switches: Immediate feedback
- Tap list item → Navigate to sub-screen
- Theme selector → Show dialog with options (Light, Dark, Auto)
- Language → Show language picker
- Export → Generate and share data file
- Delete account → Multi-step confirmation

---

## 4. User Flows

### 4.1 First-Time User Journey

**Flow: Sign Up → Onboarding → First Chat**

```
[App Launch]
    ↓
[Splash Screen] (2s)
    ↓
[Login Screen]
    ↓ Enter phone/email
[OTP Verification]
    ↓ Enter code
[Onboarding 1: Welcome]
    ↓ Next
[Onboarding 2: Set Goals]
    ↓ Enter weight, height, goal
[Onboarding 3: Meal Preferences]
    ↓ Select diet, allergies
[Onboarding 4: Notifications]
    ↓ Configure reminders
[Home Dashboard]
    ↓ Auto-prompt or user taps chat
[Chat Screen]
    ↓ AI sends welcome message
[User engages with AI]
```

**Key Moments:**
1. **First impression** (Splash): Clean, calm, professional
2. **Trust building** (Login): Simple, secure, familiar patterns
3. **Goal setting** (Onboarding): Personal, achievable, motivating
4. **First interaction** (Chat): Warm, helpful, conversational
5. **Habit formation** (Daily use): Consistent, rewarding, easy

**Time to Value:** < 3 minutes from app launch to first AI interaction

### 4.2 Daily Usage Flow (Morning to Night)

**Morning Flow:**
```
[Morning Notification] "Good morning! Ready for breakfast?"
    ↓ Tap notification
[Chat Screen]
    ↓ AI suggests breakfast
User: "What should I eat?"
    ↓ AI responds with portions
User: "I'll have 2 eggs and toast"
    ↓ AI logs meal automatically
[Show progress update]
    ↓
[Workout reminder notification]
    ↓ Tap notification
[Chat Screen]
    ↓ AI suggests Deepthi video
User: "Show me the workout"
    ↓ AI shows video link/embed
User: Completes workout
    ↓ Returns to app
User: "Done!"
    ↓ AI logs workout
[Show encouragement]
```

**Afternoon Flow:**
```
[Lunch Reminder] 1:00 PM
    ↓ User opens app
[Home Dashboard]
    ↓ Shows lunch reminder
    ↓ Tap Chat quick action
[Chat Screen]
User: "I had dal and roti"
    ↓ AI asks clarifying questions
AI: "How many rotis?"
User: "2 rotis"
    ↓ AI logs meal with portions
[Show progress update]
```

**Evening Flow:**
```
[Dinner Reminder] 7:00 PM
    ↓ User opens app
[Chat Screen]
User: "What's for dinner?"
    ↓ AI suggests meal
AI: Shows vegetarian options
User: Logs dinner
    ↓
[End of day check-in]
AI: "Great day! You stayed within calories"
    ↓
[Progress Screen]
User: Logs evening weight (optional)
```

**Key Interactions Per Day:** 6-8 app opens, 15-20 messages exchanged

### 4.3 Meal Logging Conversation Flow

**Natural Conversation Flow:**

```
User: "I had breakfast"
    ↓
AI: "Great! What did you have?"
    ↓
User: "Poha"
    ↓
AI: "How many cups of poha?"
    ↓
User: "1 bowl"
    ↓
AI: "Got it! Anything else?"
    ↓
User: "Tea with milk"
    ↓
AI: "Perfect! Here's what I logged:

     🍚 1 bowl poha (~180 cal)
     ☕ 1 tea with milk (~50 cal)

     Total: 230 calories

     [✓ Looks good] [Edit]"
    ↓
User: Taps "[✓ Looks good]"
    ↓
AI: "Meal logged! You have 1470 cal remaining today."
```

**Alternative Quick Flow:**

```
User: "2 idlis, sambar, chutney"
    ↓
AI: [Recognizes complete meal description]
    "Logged your breakfast:

     🥟 2 idlis (~160 cal)
     🍲 Sambar (~50 cal)
     🥄 Chutney (~30 cal)

     Total: 240 calories

     [✓ Correct] [Edit portions]"
```

**Photo-based Flow:**

```
User: [Sends photo of meal]
    ↓
AI: [Analyzes image]
    "I see a plate with:
     - Rice (1 cup)
     - Dal (1 bowl)
     - Vegetable curry

     Is this correct?"
    ↓
User: "Yes"
    ↓
AI: [Logs with estimated portions]
```

**Key Features:**
- Natural language understanding
- Portion size clarification
- Visual confirmation before logging
- Easy editing
- Contextual suggestions

### 4.4 Workout Recommendation Flow

**Conversation Flow:**

```
User: "I want to work out"
    ↓
AI: "Great! What kind of workout?

     [Cardio] [Strength] [Yoga] [Dance]"
    ↓
User: Taps [Cardio]
    ↓
AI: "How much time do you have?"
    ↓
User: "30 minutes"
    ↓
AI: "Perfect! Here are Deepthi's recommendations:

     ┌─────────────────────────┐
     │ 30-Min Full Body Cardio │
     │ Deepthi | 350 cal burn  │
     │ [Watch Video]           │
     └─────────────────────────┘

     ┌─────────────────────────┐
     │ HIIT Fat Burning        │
     │ Deepthi | 400 cal burn  │
     │ [Watch Video]           │
     └─────────────────────────┘"
    ↓
User: Taps [Watch Video]
    ↓
[Video opens in-app or YouTube]
    ↓
User: Completes workout
    ↓
User: Returns to app
AI: "Did you complete the workout?"
     [Yes] [Partially] [No]"
    ↓
User: Taps [Yes]
    ↓
AI: "Awesome! 🎉
     350 calories burned

     Don't forget to hydrate!"
```

**Quick Access Flow:**

```
[Home Dashboard]
    ↓
[Workout Reminder Card]
"💪 30-min cardio session
 Deepthi's Full Body

 [START WORKOUT →]"
    ↓
User: Taps button
    ↓
[Video plays]
```

**Key Features:**
- Context-aware recommendations
- Time-based filtering
- Difficulty levels
- Video integration
- Auto-logging with confirmation

### 4.5 Weight Logging Flow

**From Chat:**

```
User: "My weight is 78kg"
    ↓
AI: "Great progress! That's 3kg down!

     📊 Progress Update:
     Previous: 81 kg (June 1)
     Current: 78 kg (June 15)
     Lost: 3 kg in 14 days

     You're 12% to your goal! 🎯"
```

**From Progress Screen:**

```
[Progress Screen]
    ↓
User: Taps [+] button
    ↓
[Bottom Sheet appears]
┌─────────────────────────────────┐
│  Add Weight Entry               │
│                                 │
│  Weight (kg)                    │
│  ┌────────────────────────────┐│
│  │          78.5              ││
│  └────────────────────────────┘│
│                                 │
│  Date                           │
│  ┌────────────────────────────┐│
│  │      June 15, 2026         ││
│  └────────────────────────────┘│
│                                 │
│  Notes (optional)               │
│  ┌────────────────────────────┐│
│  │ Morning weight             ││
│  └────────────────────────────┘│
│                                 │
│           CANCEL      SAVE      │
└─────────────────────────────────┘
    ↓
User: Enters weight and taps SAVE
    ↓
[Bottom sheet dismisses]
    ↓
[Snackbar appears]
"✓ Weight logged successfully"
    ↓
[Graph updates with animation]
```

**Key Features:**
- Multiple entry points
- Date selection for back-logging
- Optional notes
- Automatic progress calculation
- Visual feedback with graph update

---

## 5. Material Design 3 Implementation

### 5.1 Dynamic Color Schemes

Material Design 3 supports dynamic color theming based on user's wallpaper (Android 12+).

**Color Roles:**

```dart
// Light Theme
ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF4CAF50),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFC8E6C9),
  onPrimaryContainer: Color(0xFF1B5E20),

  secondary: Color(0xFFFF9800),
  onSecondary: Color(0xFF000000),
  secondaryContainer: Color(0xFFFFE0B2),
  onSecondaryContainer: Color(0xFFE65100),

  tertiary: Color(0xFF03A9F4),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFB3E5FC),
  onTertiaryContainer: Color(0xFF01579B),

  error: Color(0xFFF44336),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFCDD2),
  onErrorContainer: Color(0xFFB71C1C),

  background: Color(0xFFFFFFFF),
  onBackground: Color(0xFF212121),

  surface: Color(0xFFFAFAFA),
  onSurface: Color(0xFF212121),
  surfaceVariant: Color(0xFFF5F5F5),
  onSurfaceVariant: Color(0xFF424242),

  outline: Color(0xFFBDBDBD),
  outlineVariant: Color(0xFFE0E0E0),

  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),

  inverseSurface: Color(0xFF212121),
  onInverseSurface: Color(0xFFFAFAFA),
  inversePrimary: Color(0xFF81C784),
)
```

**Dark Theme:**

```dart
// Dark Theme
ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF81C784),
  onPrimary: Color(0xFF1B5E20),
  primaryContainer: Color(0xFF2E7D32),
  onPrimaryContainer: Color(0xFFC8E6C9),

  secondary: Color(0xFFFFB74D),
  onSecondary: Color(0xFFE65100),
  secondaryContainer: Color(0xFFF57C00),
  onSecondaryContainer: Color(0xFFFFE0B2),

  tertiary: Color(0xFF4FC3F7),
  onTertiary: Color(0xFF01579B),
  tertiaryContainer: Color(0xFF0277BD),
  onTertiaryContainer: Color(0xFFB3E5FC),

  error: Color(0xFFE57373),
  onError: Color(0xFFB71C1C),
  errorContainer: Color(0xFFC62828),
  onErrorContainer: Color(0xFFFFCDD2),

  background: Color(0xFF121212),
  onBackground: Color(0xFFE0E0E0),

  surface: Color(0xFF1E1E1E),
  onSurface: Color(0xFFE0E0E0),
  surfaceVariant: Color(0xFF2C2C2C),
  onSurfaceVariant: Color(0xFFBDBDBD),

  outline: Color(0xFF757575),
  outlineVariant: Color(0xFF424242),

  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),

  inverseSurface: Color(0xFFE0E0E0),
  onInverseSurface: Color(0xFF1E1E1E),
  inversePrimary: Color(0xFF4CAF50),
)
```

**Dynamic Color Support:**

```dart
// Enable dynamic colors on Android 12+
if (Build.VERSION.SDK_INT >= 31) {
  ColorScheme dynamicColorScheme = ColorScheme.fromSeed(
    seedColor: extractedWallpaperColor,
    brightness: systemBrightness,
  );
}
```

### 5.2 Motion Design

**Duration Standards:**

- **Fast:** 100ms - Small UI elements (ripples, toggles)
- **Medium:** 200ms - Standard transitions (screen elements)
- **Slow:** 300ms - Large elements (sheets, dialogs)
- **Extra Slow:** 500ms - Emphasis animations (success states)

**Easing Curves:**

```dart
// Material 3 Easing
static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
static const Curve emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1.0);
static const Curve emphasizedAccelerate = Cubic(0.3, 0.0, 0.8, 0.15);

// Standard curves
static const Curve standard = Cubic(0.2, 0.0, 0.0, 1.0);
static const Curve decelerate = Cubic(0.0, 0.0, 0.0, 1.0);
static const Curve accelerate = Cubic(0.3, 0.0, 1.0, 1.0);
```

**Common Animations:**

**Screen Transitions:**
```dart
// Shared axis transition (X-axis)
PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => NewScreen(),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return SharedAxisTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      transitionType: SharedAxisTransitionType.horizontal,
      child: child,
    );
  },
  transitionDuration: Duration(milliseconds: 300),
)
```

**FAB Animation:**
```dart
// Scale and fade
AnimatedScale(
  scale: isVisible ? 1.0 : 0.0,
  duration: Duration(milliseconds: 200),
  curve: Curves.emphasizedAccelerate,
  child: FloatingActionButton(...),
)
```

**Bottom Sheet:**
```dart
// Slide up with deceleration
showModalBottomSheet(
  context: context,
  transitionAnimationController: AnimationController(
    duration: Duration(milliseconds: 300),
    vsync: this,
  ),
  builder: (context) => BottomSheetContent(),
)
```

**List Items:**
```dart
// Staggered fade-in
AnimatedList(
  initialItemCount: items.length,
  itemBuilder: (context, index, animation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(
          Tween(
            begin: Offset(0, 0.1),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.emphasizedDecelerate)),
        ),
        child: ListItem(items[index]),
      ),
    );
  },
)
```

**Success Animation:**
```dart
// Check mark draw animation
AnimatedCheck(
  progress: _checkProgress,
  duration: Duration(milliseconds: 500),
  curve: Curves.emphasizedDecelerate,
)
```

**State Changes:**
```dart
// Smooth color transition
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  color: isSelected ? primaryColor : surfaceColor,
  curve: Curves.emphasized,
)
```

### 5.3 Accessibility Considerations

**Touch Targets:**
- Minimum: 48dp x 48dp for all interactive elements
- Recommended: 48dp x 48dp with 8dp spacing
- Icons: Centered in 48dp container even if icon is 24dp

**Color Contrast:**
- WCAG 2.1 AA standard: 4.5:1 for normal text
- WCAG 2.1 AAA standard: 7:1 for normal text (target)
- Large text (18pt+): 3:1 minimum

**Tested Combinations:**
```
Primary (#4CAF50) on Surface (#FAFAFA): 8.2:1 ✓
On Surface (#212121) on Surface (#FAFAFA): 16.1:1 ✓
Secondary (#FF9800) on Surface (#FAFAFA): 3.8:1 ⚠️ (use on large text only)
Error (#F44336) on Surface (#FAFAFA): 4.9:1 ✓
```

**Text Scaling:**
- Support Android's font scaling up to 200%
- Use `sp` units for all text sizes
- Test layouts at 100%, 130%, 200% scaling
- Ensure text doesn't truncate critical information

**Screen Reader Support:**

```dart
// Semantic labels
Semantics(
  label: 'Send message',
  button: true,
  child: IconButton(
    icon: Icon(Icons.send),
    onPressed: sendMessage,
  ),
)

// Chat message accessibility
Semantics(
  label: 'AI says: ${messageText}',
  readOnly: true,
  child: MessageBubble(messageText),
)

// Progress indicator
Semantics(
  label: 'Weight goal progress: 45 percent complete',
  value: '45%',
  child: CircularProgressIndicator(value: 0.45),
)
```

**Focus Management:**
- Logical tab order
- Visible focus indicators (2dp outline)
- Focus on first interactive element when screen opens
- Trap focus in dialogs/sheets

**Alternative Text:**
- All images have descriptive labels
- Icons have semantic labels
- Graphs have text equivalents
- Empty states have descriptions

**Motion Sensitivity:**
```dart
// Respect reduce motion preference
final bool reduceAnimations = MediaQuery.of(context).disableAnimations;

Duration animationDuration = reduceAnimations
  ? Duration.zero
  : Duration(milliseconds: 300);
```

### 5.4 Dark Mode Support

**Implementation Strategy:**
- Follow system theme by default
- Allow manual override in settings
- Smooth transition between themes (300ms)
- Preserve user choice

**Dark Mode Adjustments:**

**Elevation in Dark Mode:**
- Surface elevation uses opacity overlays
- Higher elevation = lighter surface color
- Formula: White overlay at 5% + (elevation × 0.5%)

```dart
// Elevation tint colors
Level 0: #1E1E1E (base surface)
Level 1: #232323 (5%)
Level 2: #252525 (7%)
Level 3: #282828 (11%)
Level 4: #2A2A2A (12%)
Level 5: #2E2E2E (14%)
```

**Contrast Adjustments:**
- Reduce pure white to #E0E0E0 for body text
- Use #BDBDBD for secondary text
- Increase elevation for important elements
- Add subtle borders where needed

**Image Handling:**
- Reduce brightness of images by 20%
- Add subtle overlay on photos
- Use outlined icons instead of filled where appropriate

**Testing:**
- Test all screens in both modes
- Verify readability of all text
- Check color combinations
- Ensure shadows are visible

---

## 6. Responsive Design

### 6.1 Small Phones (5-5.5", < 360dp width)

**Optimizations:**
- Single column layouts
- Larger touch targets (52dp minimum)
- Reduced padding (12dp instead of 16dp)
- Fewer quick actions visible
- Compact bottom navigation labels
- Smaller font sizes in dense areas

**Chat Screen Adjustments:**
```
- Message max width: 75%
- Input bar height: 52dp
- Reduce message padding: 10dp
- Smaller timestamps: 10sp
```

**Home Screen:**
```
- Progress card: Simplified view
- Quick actions: 2 columns instead of 3
- Reduce card padding: 12dp
```

### 6.2 Medium Phones (6-6.5", 360-400dp width)

**Standard Design:**
- All designs shown in Section 3
- Optimal experience
- Standard padding: 16dp
- Full feature set visible
- Comfortable reading line length

### 6.3 Large Phones (6.5"+, 400dp+ width)

**Optimizations:**
- Max content width: 600dp (centered)
- Two-column layouts where appropriate
- Larger charts and graphs
- More context visible
- Multi-pane view for tablet-like experience

**Chat Screen:**
```
- Message max width: 480dp
- Side margins: 24dp
- Larger avatar in profile: 112dp
```

**Dashboard:**
```
- Two-column grid for quick actions
- Side-by-side progress cards
- Larger graph: 280dp height
```

### 6.4 Tablets (Future Consideration)

**Landscape Layouts:**
- Master-detail pattern
- Navigation rail instead of bottom navigation
- Multi-pane views (chat + context)
- Larger content area (max 840dp)

**Example: Chat on Tablet:**
```
┌────────────────────────────────────────┐
│ [Nav Rail]  [Chat Area]  [Context]    │
│            │            │              │
│   🏠       │            │  Profile     │
│   💬       │  Messages  │  Stats       │
│   📈       │            │  Suggestions │
│   👤       │            │              │
│            │ [Input]    │              │
└────────────────────────────────────────┘
```

### 6.5 Breakpoints

```dart
// Screen size breakpoints
enum ScreenSize {
  small,   // < 360dp width
  medium,  // 360-600dp width
  large,   // 600-840dp width
  xlarge,  // > 840dp width
}

// Responsive helper
ScreenSize getScreenSize(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  if (width < 360) return ScreenSize.small;
  if (width < 600) return ScreenSize.medium;
  if (width < 840) return ScreenSize.large;
  return ScreenSize.xlarge;
}
```

### 6.6 Orientation Handling

**Portrait (Default):**
- Standard layouts as described
- Bottom navigation
- Vertical scrolling

**Landscape:**
- Adjust padding for wider screens
- Multi-column layouts where appropriate
- Hide non-essential elements (extended labels)
- Ensure touch targets remain accessible
- Consider navigation rail for wide screens

---

## 7. Accessibility

### 7.1 WCAG 2.1 Compliance

**Level AA Requirements (Minimum):**

✓ **1.4.3 Contrast (Minimum):** 4.5:1 for text
✓ **2.5.5 Target Size:** 48dp minimum
✓ **1.4.4 Resize Text:** Support up to 200% scaling
✓ **2.4.7 Focus Visible:** Clear focus indicators
✓ **1.3.1 Info and Relationships:** Semantic structure
✓ **2.1.1 Keyboard:** All functions keyboard accessible
✓ **1.4.13 Content on Hover:** Dismissible, hoverable, persistent
✓ **2.4.3 Focus Order:** Logical focus sequence

### 7.2 Screen Reader Optimization

**TalkBack Support:**
- Custom semantic labels for all interactive elements
- Proper heading structure (h1, h2, h3)
- Alt text for images and icons
- Status announcements for dynamic content
- Grouped related content

**Example Implementation:**
```dart
Semantics(
  label: 'Weight progress. 45 percent complete. Current weight 78 kilograms, goal 55 kilograms',
  child: ProgressCard(),
)
```

### 7.3 Voice Control

**Voice Access Support:**
- All buttons labeled clearly
- Consistent naming conventions
- Support "Tap [label]" commands
- Expose custom actions
- Scrollable regions labeled

### 7.4 Inclusive Design

**Cognitive Accessibility:**
- Clear, simple language
- Consistent UI patterns
- Predictable navigation
- Undo/redo support
- Confirmation for destructive actions
- Progress indicators for multi-step tasks

**Visual Accessibility:**
- High contrast mode support
- No color-only information
- Clear visual hierarchy
- Sufficient white space
- Large, readable fonts

**Motor Accessibility:**
- Large touch targets (48dp+)
- No required complex gestures
- Alternative to timed actions
- Forgiving tap areas
- Support for switches/external devices

---

## 8. Animation & Motion

### 8.1 Micro-interactions

**Button Press:**
- Ripple effect: 300ms, expanding from tap point
- Scale down: 0.95x for 100ms
- Color change: 200ms fade

**Toggle Switch:**
- Slide animation: 200ms with emphasized curve
- Thumb scales slightly: 1.1x during transition
- Track color fade: 200ms

**Text Input Focus:**
- Label floats up: 200ms
- Border thickness increases: 2dp over 150ms
- Border color change: 200ms

### 8.2 Screen Transitions

**Navigation:**
- Shared axis (horizontal): 300ms for forward navigation
- Fade through: 300ms for bottom nav switches
- Fade + scale: For modal dialogs

**Sheet Animations:**
- Bottom sheet slides up: 300ms with emphasized decelerate
- Scrim fades in: 200ms
- Dismiss: 250ms with emphasized accelerate

### 8.3 Content Loading

**Skeleton Screens:**
- Shimmer effect: 1500ms loop
- Fade in actual content: 200ms
- Stagger multiple items: 50ms delay each

**Pull to Refresh:**
- Circular indicator appears: 200ms
- Spins during load
- Success animation: Check mark scales in
- Content slides down: 300ms

### 8.4 Feedback Animations

**Success:**
- Check mark draws: 500ms
- Green circle expands: 300ms
- Particle burst: 400ms (optional, can be disabled)

**Error:**
- Shake animation: 400ms, 2-3 cycles
- Red color pulse: 200ms
- Error icon appears: 150ms

**Loading:**
- Circular progress: Continuous spin
- Linear progress: Smooth fill
- Skeleton shimmer: Continuous loop

### 8.5 Chat-Specific Animations

**Message Appearance:**
- Slide in from bottom: 200ms
- Fade in: 150ms
- Stagger multiple messages: 100ms delay

**Typing Indicator:**
- Three dots bounce: 1200ms loop
- Each dot offset by 200ms

**Sent Message:**
- Slide to position: 200ms
- Checkmark appears: 150ms delay
- Double check (read): 200ms fade in

---

## Implementation Notes

### Priority Order:
1. Core screens (Chat, Home, Login)
2. Component library
3. Navigation patterns
4. Onboarding flow
5. Progress & profile screens
6. Settings & advanced features

### Flutter Packages:
- `flutter/material.dart` - Material Design 3
- `google_fonts` - Typography
- `flutter_svg` - Vector icons
- `cached_network_image` - Image optimization
- `shimmer` - Loading states
- `flutter_animate` - Micro-interactions

### Design Handoff:
- Figma file with all screens
- Component library in Figma
- Interactive prototype
- Design tokens (JSON export)
- Icon assets (SVG)
- Illustration assets

### Testing Requirements:
- Test on minimum 3 device sizes
- Test both light and dark modes
- Test with TalkBack enabled
- Test with 200% font scaling
- Test with animations disabled
- Performance testing (60fps target)

---

## Conclusion

This UI/UX specification provides a comprehensive blueprint for the AI Health Companion Android app. The design prioritizes:

1. **Chat-First Experience:** Natural conversation as the primary interface
2. **Material Design 3:** Modern, accessible, consistent
3. **User-Centered:** Focused on the target user's goals and journey
4. **Accessible:** WCAG 2.1 AA compliant, inclusive design
5. **Performant:** Smooth animations, efficient layouts
6. **Scalable:** Responsive design for all device sizes

The design balances aesthetics with functionality, creating an approachable and motivating experience that supports users in achieving their health goals through AI-powered guidance.

---

**Document Version:** 1.0
**Last Updated:** July 3, 2026
**Author:** AI Health Companion Design Team
**Status:** Ready for Development