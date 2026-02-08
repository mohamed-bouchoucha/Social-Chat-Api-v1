# social_chat_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
## Project Structure
lib/
├── main.dart                      # App entry point
├── core/                          # Core app functionality
│   ├── constants/                 # App constants, routes, themes
│   ├── utils/                     # Helper functions, validators
│   ├── network/                   # API clients, interceptors
│   ├── storage/                   # Local storage (SharedPreferences)
│   └── widgets/                   # Reusable widgets
├── features/                      # Feature-based modules
│   ├── auth/                      # Authentication
│   │   ├── data/                  # Auth data layer
│   │   ├── domain/                # Auth business logic
│   │   └── presentation/          # Auth UI
│   ├── chat/                      # Real-time chat
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── posts/                     # Social posts
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── friends/                   # Friends management
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── profile/                   # User profile
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── notifications/             # Notifications
│       ├── data/
│       ├── domain/
│       └── presentation/
├── shared/                        # Shared components
│   ├── models/                    # Data models
│   ├── repositories/              # Base repositories
│   └── services/                  # Shared services
└── app/                          # App-wide components
    ├── router/                    # Navigation/router
    ├── theme/                     # App theme
    └── state/                     # Global state management

# Social Chat App - Flutter

A modern, production-ready social chat application built with Flutter.

## Features

### ✅ Authentication
- Email/Password login & registration
- Social login (Google, Facebook)
- JWT token-based authentication
- Auto token refresh
- Remember me functionality

### ✅ Real-time Chat
- One-on-one messaging
- Group chats
- Read receipts & typing indicators
- Online status
- Message reactions
- File sharing (images, videos, documents)
- Voice messages
- Location sharing

### ✅ User Management
- User profiles with avatars
- Contact list
- Friend requests
- Block users
- Privacy settings

### ✅ Advanced Features
- Push notifications
- Dark/light theme
- Message search
- Chat backup
- End-to-end encryption (optional)
- Voice/video calls (WebRTC ready)

### ✅ Media Support
- Image/video viewer
- Document preview
- Audio player
- Gallery integration

## Tech Stack

- **Flutter 3.x** - Cross-platform framework
- **Riverpod** - State management
- **Dio** - HTTP client
- **WebSocket** - Real-time communication
- **Freezed** - Data classes
- **Shared Preferences** - Local storage
- **SQLite** - Local database (optional)
- **Firebase** - Push notifications (optional)

## Getting Started

### 1. Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / VS Code
- Java JDK 11+
- Node.js (for some packages)

### 2. Installation
```bash
# Clone the repository
git clone https://github.com/mohamed-bouchoucha/Social-Chat-Api
.git

# Navigate to project
cd social-chat-app

# Install dependencies
flutter pub get

# Generate code (freezed, etc.)
flutter packages pub run build_runner build --delete-conflicting-outputs