# Architecture Overview - MyFriends App

## Version 0.3.0 - Refactored Architecture

This document provides a comprehensive overview of the MyFriends app architecture after the v0.3.0 refactoring.

## 🏗️ Core Architecture

```mermaid
graph TB
    subgraph "Presentation Layer"
        UI[UI Components]
        Pages[Pages]
        Widgets[Standardized Widgets]
        Providers[Riverpod Providers]
    end
    
    subgraph "Core Services v0.3.0"
        NavService[Navigation Service]
        NotifService[Notification Service]
        PrefService[Preferences Service]
        PhotoService[Photo Service]
        LocationService[Location Service]
        DBService[Database Service]
    end
    
    subgraph "Domain Layer"
        Entities[Enhanced Entities]
        Repositories[Repository Interfaces]
        UseCases[Use Cases]
    end
    
    subgraph "Data Layer"
        RepoImpl[Repository Implementations]
        Models[Data Models]
        LocalDB[Local Database/Hive]
    end
    
    UI --> Pages
    Pages --> Providers
    Pages --> NavService
    Pages --> NotifService
    Providers --> UseCases
    Providers --> PrefService
    UseCases --> Repositories
    Repositories --> RepoImpl
    RepoImpl --> Models
    RepoImpl --> LocalDB
    Pages --> PhotoService
    Pages --> LocationService
    RepoImpl --> DBService
```

## 📱 Navigation Flow with History Management

```mermaid
graph LR
    Home[Home Page<br/>PopScope Handler]
    AddFriend[Add Friend<br/>Smart Template]
    FriendsList[Friends List]
    FriendDetail[Friend Detail]
    FriendBooks[Friend Books]
    BookDetail[Book Detail]
    Templates[Templates<br/>Custom Fields]
    
    Home -->|navigateTo| AddFriend
    Home -->|navigateTo| FriendsList
    Home -->|navigateTo| FriendBooks
    Home -->|navigateTo| Templates
    FriendsList -->|navigateTo| FriendDetail
    FriendDetail -->|navigateTo| AddFriend
    FriendBooks -->|navigateTo| BookDetail
    
    AddFriend -.->|navigateBack| Home
    FriendsList -.->|navigateBack| Home
    FriendDetail -.->|navigateBack| FriendsList
    BookDetail -.->|navigateBack| FriendBooks
```

## 🔧 Service Architecture

### 1. Navigation Service

```mermaid
classDiagram
    class NavigationService {
        -ListQueue~String~ navigationHistory
        -String currentRoute
        -int maxHistorySize = 20
        +navigateTo(context, route, extra)
        +navigateBack(context) bool
        +navigateToHome(context)
        +handleBackButton(context) Future~bool~
        +canGoBack() bool
        +clearHistory()
        +initialize(initialRoute)
        -addToHistory(route)
        -removeFromHistory() String
    }
    
    NavigationService --> "1" ListQueue : manages
    NavigationService --> "1" BuildContext : uses
```

**Key Features:**
- ✅ Navigation history stack (max 20 entries)
- ✅ Android back button handling
- ✅ Consistent navigation methods
- ✅ Deep linking support
- ✅ Route restoration

### 2. Notification Service

```mermaid
classDiagram
    class NotificationService {
        -Queue~NotificationMessage~ notificationQueue
        -GlobalKey~ScaffoldMessengerState~ messengerKey
        -bool isShowingNotification
        +showSuccess(message, duration?)
        +showError(message, duration?)
        +showWarning(message, duration?)
        +showInfo(message, duration?)
        +showNotification(message, type, duration, action?, actionLabel?)
        +clearAll()
        -processQueue()
        -showSnackBar(notification)
        -getNotificationColors(type)
        -getNotificationIcon(type)
    }
    
    class NotificationMessage {
        +String message
        +NotificationType type
        +Duration duration
        +VoidCallback? action
        +String? actionLabel
    }
    
    class NotificationType {
        <<enumeration>>
        success
        error
        warning
        info
    }
    
    NotificationService --> "*" NotificationMessage : queues
    NotificationMessage --> "1" NotificationType : has
```

**Key Features:**
- ✅ Centralized notification management
- ✅ Queue system for multiple notifications
- ✅ Consistent positioning below app bar
- ✅ Different types with colors/icons
- ✅ Support for action buttons

### 3. Preferences Service

```mermaid
classDiagram
    class PreferencesService {
        -Box preferencesBox
        +initialize() Future~void~
        +getLastUsedTemplate() String?
        +setLastUsedTemplate(templateId) Future~void~
        +getThemeMode() String
        +setThemeMode(mode) Future~void~
        +getLanguageCode() String
        +setLanguageCode(code) Future~void~
        +isFirstLaunch() bool
        +getPhotoQuality() String
        +setPhotoQuality(quality) Future~void~
        +getAutoSave() bool
        +setAutoSave(autoSave) Future~void~
        +getLastBackupDate() DateTime?
        +setLastBackupDate(date) Future~void~
        +exportPreferences() Map
        +importPreferences(Map) Future~void~
        +clearAll() Future~void~
    }
    
    PreferencesService --> "1" HiveBox : uses
```

## 📋 Enhanced Template System

```mermaid
graph TB
    subgraph "Template Architecture"
        Template[FriendTemplate]
        Classic[Classic Template<br/>Pre-defined Fields]
        Modern[Modern Template<br/>Social Focus]
        Custom[Custom Template<br/>User Defined]
    end
    
    subgraph "Custom Field System"
        CustomField[CustomField Entity]
        Text[Text Field]
        Number[Number Field]
        Date[Date Field]
        Bool[Boolean Field]
        Select[Select Field]
        MultiSelect[Multi-Select Field]
        URL[URL Field]
        Email[Email Field]
    end
    
    Template --> Classic
    Template --> Modern
    Template --> Custom
    Custom --> CustomField
    CustomField --> Text
    CustomField --> Number
    CustomField --> Date
    CustomField --> Bool
    CustomField --> Select
    CustomField --> MultiSelect
    CustomField --> URL
    CustomField --> Email
```

## 🔄 Data Flow with Centralized Services

```mermaid
sequenceDiagram
    participant User
    participant Page
    participant StandardWidget
    participant Service
    participant Provider
    participant Repository
    participant Database
    
    User->>Page: Interact
    Page->>StandardWidget: Use Component
    StandardWidget->>Service: Call Service
    Page->>Provider: Request Data
    Provider->>Repository: Query/Update
    Repository->>Database: Persist/Retrieve
    Database-->>Repository: Return Data
    Repository-->>Provider: Return Result
    Provider-->>Page: Update State
    Service-->>Page: Handle Navigation/Notification
    Page-->>User: Display Result
```

## 🎨 Standardized UI Components

```mermaid
graph TD
    subgraph "Reusable Components v0.3.0"
        StandardAppBar[StandardAppBar<br/>• Back button handling<br/>• Consistent styling<br/>• Subtitle support]
        ConsistentButton[ConsistentActionButton<br/>• 4 style types<br/>• 4 size variants<br/>• Loading states]
        AppToast[AppToast<br/>• Themed colors<br/>• Icons per type<br/>• Action support]
    end
    
    subgraph "Component Features"
        BackNav[Back Navigation<br/>with History]
        ButtonStyles[Primary/Secondary<br/>Danger/Text]
        NotifTypes[Success/Error<br/>Warning/Info]
    end
    
    StandardAppBar --> BackNav
    ConsistentButton --> ButtonStyles
    AppToast --> NotifTypes
```

## 🔀 State Management

```mermaid
graph TB
    subgraph "Provider Architecture"
        CoreProviders[Core Providers<br/>Singleton Services]
        FeatureProviders[Feature Providers<br/>Business Logic]
        StateNotifiers[State Notifiers<br/>Complex State]
    end
    
    subgraph "Core Services"
        NavProvider[navigationServiceProvider]
        NotifProvider[notificationServiceProvider]
        PrefProvider[preferencesServiceProvider]
        MessengerKey[scaffoldMessengerKeyProvider]
    end
    
    subgraph "Feature Services"
        FriendsProvider[friendsProvider]
        TemplateProvider[templateProvider]
        BooksProvider[friendBooksProvider]
    end
    
    CoreProviders --> NavProvider
    CoreProviders --> NotifProvider
    CoreProviders --> PrefProvider
    CoreProviders --> MessengerKey
    
    FeatureProviders --> FriendsProvider
    FeatureProviders --> TemplateProvider
    FeatureProviders --> BooksProvider
```

## 🔙 Android Back Button Handling

```mermaid
flowchart TD
    Start[Back Button Pressed<br/>PopScope Handler]
    CheckHistory{Navigation<br/>History?}
    NavigateBack[Navigate to<br/>Previous Page]
    CheckHome{At Home<br/>Page?}
    ShowToast[Show Exit<br/>Toast Message]
    CheckDouble{Double Tap<br/>Within 2s?}
    ExitApp[Exit<br/>Application]
    StayInApp[Stay in App<br/>Reset Timer]
    
    Start --> CheckHistory
    CheckHistory -->|Has History| NavigateBack
    CheckHistory -->|No History| CheckHome
    CheckHome -->|Yes| ShowToast
    CheckHome -->|No| NavigateBack
    ShowToast --> CheckDouble
    CheckDouble -->|Yes| ExitApp
    CheckDouble -->|No| StayInApp
```

## 📁 Project Structure v0.3.0

```
lib/
├── main.dart                          # Enhanced entry point
├── core/                              # Core functionality
│   ├── navigation/                    # Navigation setup
│   │   └── app_router.dart
│   ├── services/                      # Centralized services (NEW)
│   │   ├── navigation_service.dart    # Navigation with history
│   │   ├── notification_service.dart  # Unified notifications
│   │   ├── preferences_service.dart   # User preferences
│   │   ├── database_service.dart
│   │   ├── location_service.dart
│   │   └── photo_service.dart
│   ├── providers/                     # Core providers (NEW)
│   │   └── core_providers.dart        # Service injection
│   ├── widgets/                       # Standardized widgets (NEW)
│   │   ├── standard_app_bar.dart      # Consistent app bar
│   │   ├── consistent_action_button.dart # Unified buttons
│   │   └── app_toast.dart            # Toast notifications
│   └── theme/                         # Theme configuration
│       ├── app_theme.dart
│       ├── app_colors.dart
│       └── app_typography.dart
├── features/                          # Feature modules
│   ├── friend/                        # Friend management
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── friend.dart
│   │   │   │   └── friend_template.dart # Enhanced with custom fields
│   │   │   └── repositories/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── add_friend_page.dart # Smart template selection
│   │       │   ├── friend_detail_page.dart
│   │       │   └── friends_list_page.dart
│   │       ├── widgets/
│   │       └── providers/
│   ├── home/                          # Home with PopScope
│   │   └── presentation/
│   │       └── pages/
│   │           └── home_page.dart     # Android back handling
│   ├── friendbook/                    # Friend book feature
│   └── template/                      # Template management
│       └── presentation/
│           └── pages/
│               └── template_management_page.dart # Custom fields UI
└── l10n/                              # Localization (DE/EN)
```

## 🚀 Key Improvements in v0.3.0

### Core Services
1. **Navigation Service**: Centralized navigation with history stack
2. **Notification Service**: Unified toast/snackbar system
3. **Preferences Service**: Persistent user settings

### UI/UX Enhancements
1. **Android Back Button**: Proper handling with navigation queue
2. **Consistent Components**: Standardized app bars and buttons
3. **Smart Features**: Last used template auto-selection
4. **Custom Fields**: 8 field types for template customization

### Code Quality
1. **Dependency Injection**: Runtime injection via Riverpod
2. **Separation of Concerns**: Clear service boundaries
3. **Error Handling**: Centralized through notification service
4. **Code Reusability**: Shared components and services

## 💻 Development Guidelines

### Adding New Features

```dart
// 1. Create feature structure
lib/features/new_feature/
├── domain/
├── data/
└── presentation/

// 2. Use centralized services
final navigationService = ref.read(navigationServiceProvider);
final notificationService = ref.read(notificationServiceProvider);
final preferencesService = ref.read(preferencesServiceProvider);

// 3. Use standardized components
StandardAppBar(title: 'Page Title')
ConsistentActionButton(label: 'Action', style: ActionButtonStyle.primary)
```

### Service Usage Examples

```dart
// Navigation with history
navigationService.navigateTo(context, '/route');
navigationService.navigateBack(context);

// Notifications
notificationService.showSuccess('Operation successful');
notificationService.showError('An error occurred');

// Preferences
await preferencesService.setLastUsedTemplate('modern');
final template = preferencesService.getLastUsedTemplate();
```

## 🔒 Security Considerations

- ✅ Local data encryption via platform-specific secure storage
- ✅ No sensitive data in plain preferences
- ✅ Secure photo path resolution
- ✅ Proper permission handling for camera/location

## ⚡ Performance Optimizations

- ✅ Lazy service initialization
- ✅ Navigation history pruning (20 entries max)
- ✅ Notification queue management
- ✅ Efficient state management with Riverpod
- ✅ Widget reusability for reduced rebuilds

## 🔮 Future Enhancements

- [ ] Cloud synchronization service
- [ ] Advanced search with filters
- [ ] Export/Import functionality
- [ ] Additional languages
- [ ] Theme customization UI
- [ ] Offline-first architecture
- [ ] Analytics integration
- [ ] Social sharing features