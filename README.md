# AI Health Companion

AI-powered health coach for personalized nutrition, workouts, and wellness guidance.

## Overview

AI Health Companion is not just another calorie tracker. It's your personal AI health coach that helps you achieve your wellness goals through:

- 📸 **Photo-First Meal Logging** - Take a photo, log in 2 seconds
- 🎤 **Voice-First Chat** - Talk to your coach hands-free
- ⚡ **Outcome-Focused Dashboard** - Track energy and emotional goals, not just numbers
- 🎯 **30-Second Onboarding** - Start chatting immediately
- ❤️ **Emotional Goal Framing** - Focus on how you feel, not just weight loss

## Features

### MVP (v1.0)

**Must Have:**
- 🔐 Firebase Authentication (Email/Phone + OTP)
- 💬 AI Chat Interface with Claude API
- 📸 Photo-based meal logging with image recognition
- 🎤 Voice input for conversations
- 🍽️ Nutrition tracking (50+ Sri Lankan foods)
- 💪 Personalized workout recommendations
- 📊 Outcome-focused progress tracking
- 🔔 Smart reminders (water, meals, workouts)
- ⚡ Energy rating (daily 1-5 stars)
- 🎯 Emotional goal setting and tracking

## Tech Stack

- **Framework**: Flutter 3.x
- **Architecture**: Clean Architecture (Domain/Data/Presentation)
- **State Management**: Riverpod 2.x with code generation
- **Database**: SQLite (Drift) for local storage
- **Cache**: Hive for key-value storage
- **Backend**: Firebase (Auth, Firestore, Storage, Crashlytics, Analytics)
- **AI**: Claude API (Anthropic)
- **Navigation**: go_router
- **DI**: GetIt + Injectable

## Project Structure

```
lib/
├── core/                     # Core utilities and constants
│   ├── constants/            # App constants, API endpoints, asset paths
│   ├── di/                   # Dependency injection setup
│   ├── errors/               # Custom exceptions and failures
│   ├── navigation/           # App routing
│   ├── network/              # Network client and connectivity
│   ├── theme/                # Material Design 3 theme
│   └── utils/                # Utility classes
├── data/                     # Data layer
│   ├── local/                # Local data sources
│   │   ├── cache/            # Hive cache manager
│   │   └── database/         # Drift database tables
│   ├── remote/               # Remote data sources
│   ├── models/               # Data models
│   └── repositories/         # Repository implementations
├── domain/                   # Domain layer
│   ├── entities/             # Business entities
│   ├── repositories/         # Repository interfaces
│   └── usecases/             # Business logic
├── presentation/             # Presentation layer
│   ├── auth/                 # Authentication screens
│   ├── dashboard/            # Dashboard screen
│   ├── chat/                 # AI Chat screen
│   ├── nutrition/            # Nutrition screens
│   ├── workout/              # Workout screens
│   ├── profile/              # Profile screens
│   └── shared/               # Shared widgets
├── shared/                   # Shared across layers
│   └── widgets/              # Reusable widgets
├── app.dart                  # App widget
└── main.dart                 # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / VS Code
- Firebase project setup
- Claude API key

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd ai-health-companion
```

2. Install dependencies:
```bash
flutter pub get
```

3. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your API keys
```

4. Generate code:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

5. Run the app:
```bash
flutter run
```

## Development

### Code Generation

Run code generation for Drift, Riverpod, and other generators:
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Testing

Run tests:
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test
```

### Linting

Check code quality:
```bash
flutter analyze
```

## Project Standards

See [docs/PROJECT_STANDARDS.md](docs/PROJECT_STANDARDS.md) for:
- Naming conventions
- File structure
- Architecture patterns
- Error handling
- Git workflow
- Commit message format

## Roadmap

### Milestone 0: Foundation ✅ (Current)
- Project setup
- Clean Architecture structure
- Database schema (10 tables)
- Theme and design system
- Navigation setup

### Milestone 1: Auth & Profile (2 weeks)
- 30-second onboarding
- Firebase Auth integration
- Emotional goal selection
- User profile management

### Milestone 2: Dashboard (2 weeks)
- Energy rating widget
- Outcome-focused metrics
- Weekly summary
- Goal progress visualization

### Milestone 3: AI Chat (2 weeks)
- Voice input integration
- Claude API integration
- Chat message history
- Context management

### Milestone 4: Nutrition (3 weeks)
- Photo-based meal logging
- Image recognition with Claude Vision
- 50+ Sri Lankan foods database
- Calorie estimation

### Milestone 5: Workout (3 weeks)
- Personalized workout recommendations
- Progressive overload algorithm
- Workout tracking
- Feedback loop

## License

[Add license information]

## Contributing

[Add contributing guidelines]

## Contact

[Add contact information]
