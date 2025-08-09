
# MyApp

[![Flutter Version](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Linux%20%7C%20macOS%20%7C%20Windows-brightgreen.svg)](https://flutter.dev/multi-platform)

A cross-platform Flutter application built to demonstrate a complete authentication flow using Firebase and the BLoC pattern (Cubit). It features a clean, modular architecture and a custom-themed, responsive UI with animations.

## ✨ Features

-   **Cross-Platform:** Single codebase for Android, iOS, Web, Linux, macOS, and Windows.
-   **State Management:** Scalable state management using [flutter_bloc (Cubit)](https://bloclibrary.dev/).
-   **Firebase Integration:**
    -   Firebase Authentication (Email/Password & Google Sign-In).
-   **Clean Architecture:** Organized and modular project structure for better maintainability.
-   **Responsive UI:** Adapts to different screen sizes and orientations.
-   **Custom Theming:** Centralized color and text styles for a consistent look and feel.
-   **Animations:** Smooth user experience with custom animations, including [Rive](https://rive.app/).
-   **User Flow:**
    -   Onboarding Screens
    -   Login / Sign Up with form validation
    -   Forgot Password / Password Reset
    -   Profile Screen

## 📸 Screenshots

*(You can replace these placeholder images with actual screenshots of your application to showcase the UI.)*

| Onboarding | Login | Sign Up |
| :--------: | :---: | :-----: |
|  *Add img*  | *Add img* | *Add img* |

## 📂 Project Structure

The project follows a feature-first architectural approach to keep the codebase organized and scalable.

```
lib/
├── core/
│   └── widgets/          # Common widgets used across the app
├── helpers/              # Helper functions, extensions, etc.
├── logic/
│   └── cubit/            # BLoC/Cubit for state management
├── routing/              # AppRouter configuration for navigation
├── screens/              # UI for each feature/screen
│   ├── login/
│   ├── signup/
│   ├── onboarding/
│   └── ...
├── theming/              # App-wide themes, colors, and styles
├── main.dart             # App entry point
└── firebase_options.dart # Firebase configuration
```

## 🚀 Getting Started

### Prerequisites

-   [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.x or higher)
-   A code editor like [Visual Studio Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio).
-   A Firebase project.

### Installation & Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/myapp.git
    cd myapp
    ```

2.  **Set up Firebase:**
    -   Create a new project on the [Firebase Console](https://console.firebase.google.com/).
    -   Follow the instructions to add an Android and/or iOS app to your Firebase project.
    -   **Android:** Download the `google-services.json` file and place it in the `android/app/` directory.
    -   **iOS:** Download the `GoogleService-Info.plist` file and place it in the `ios/Runner/` directory using Xcode.
    -   Enable **Email/Password** and **Google** as sign-in methods in the Firebase Authentication tab.

3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

4.  **Run the application:**
    ```bash
    flutter run
    ```

## 🤝 Contributing

Contributions are welcome! If you have a suggestion that would make this better, please fork the repo and create a pull request.

## 📄 License

Distributed under the MIT License. You should add a `LICENSE` file to your project for clarity.