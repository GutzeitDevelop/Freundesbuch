# MyFriends App

## 📱 Overview
MyFriends is a mobile application designed to help you keep track of all the amazing people you meet throughout your life. The app works offline-first and allows you to document new connections with customizable templates, photos, and location data.

## 🎯 Key Features
- **Offline-First**: Full functionality without internet connection
- **Friend Management**: Create detailed entries for people you meet
- **Customizable Templates**: Multiple input templates (Classic, Modern, Custom)
- **Profile Sharing**: One-click profile sharing for app users
- **Friend Books**: Organize friends into different circles
- **Location Tracking**: Automatically save where you first met
- **Photo Memories**: Capture the moment with photos
- **Multi-language**: German and English support

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart SDK
- Android Studio / Xcode (for platform-specific builds)
- Git

### Installation

1. Clone the repository:
```bash
git clone [repository-url]
cd Freundesbuch
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For iOS
flutter run -d ios

# For Android
flutter run -d android
```

## 🏗️ Architecture

The app follows Clean Architecture principles with clear separation of concerns:

- **Presentation Layer**: UI components, state management (Riverpod)
- **Domain Layer**: Business logic, use cases, entities
- **Data Layer**: Local storage (Hive), repositories, data sources

See [ARCHITECTURE_OVERVIEW.md](ARCHITECTURE_OVERVIEW.md) for detailed information.

## 🔒 Security

Security is our top priority:
- End-to-end encryption for sensitive data
- Secure local storage using platform-specific encryption
- No data leaves the device without explicit user consent
- Regular security audits
- OWASP Mobile Security Guidelines compliance

## 📋 Requirements

### Minimum OS Versions
- iOS 12.0+
- Android API 21+ (Android 5.0)

### Permissions Required
See [PERMISSIONS.md](PERMISSIONS.md) for detailed permission requirements.

## 🧪 Testing

Run tests with:
```bash
flutter test
```

For coverage report:
```bash
flutter test --coverage
```

## 📦 Build & Release

### Development Build
```bash
flutter build apk --debug  # Android
flutter build ios --debug  # iOS
```

### Production Build
```bash
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## 🌍 Internationalization

The app supports:
- 🇩🇪 German (Primary)
- 🇬🇧 English

## 📝 Documentation

- [ARCHITECTURE_OVERVIEW.md](ARCHITECTURE_OVERVIEW.md) - System architecture
- [IMPLEMENTATION_LOG.md](IMPLEMENTATION_LOG.md) - Development progress
- [ERROR_HANDLING.md](ERROR_HANDLING.md) - Error handling guide
- [PERMISSIONS.md](PERMISSIONS.md) - Permission requirements
- [PROJECT_ROADMAP.md](PROJECT_ROADMAP.md) - Future features

## 🎨 Design System

The app uses a consistent color scheme and Material Design principles. See the design system in `lib/core/theme/`.

## 📄 License

This project is proprietary and confidential.

## 👥 Team

Developed with the 4-Eye Principle:
- Main Developer: Claude AI
- Reviewer: Project Owner

## 📞 Support

For issues or questions, please refer to the documentation or contact the development team.

---

**Version**: 0.1.0  
**Last Updated**: August 2025