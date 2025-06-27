# Translation App

A powerful and intuitive Flutter application that provides seamless translation and localization features for global communication.

## 🌟 Features

- **Multi-language Support**: Translate text between multiple languages instantly
- **Real-time Translation**: Get instant translations as you type
- **Offline Capability**: Access translations even without internet connection
- **Clean UI/UX**: Beautiful and intuitive user interface built with Flutter
- **Cross-platform**: Runs smoothly on both iOS and Android devices
- **Localization Support**: Full internationalization (i18n) support for the app interface
- **History**: Keep track of your translation history
- **Favorites**: Save frequently used translations

## 📱 Screenshots

_Add your app screenshots here_

## 🚀 Getting Started

### Prerequisites

Before running this application, make sure you have the following installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Latest stable version)
- [Dart SDK](https://dart.dev/get-dart) (Included with Flutter)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/) with Flutter extensions
- Android/iOS device or emulator

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/CPONATO/translation.git
   cd translation
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Generate localization files**

   ```bash
   flutter gen-l10n
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## 🛠️ Configuration

### API Keys

If your app uses external translation services, add your API keys to the configuration:

1. Create a `.env` file in the root directory
2. Add your API keys:
   ```
   GOOGLE_TRANSLATE_API_KEY=your_api_key_here
   MICROSOFT_TRANSLATOR_API_KEY=your_api_key_here
   ```

### Supported Languages

Currently supported languages include:

- English (en)
- Spanish (es)
- French (fr)
- German (de)
- Portuguese (pt)
- Italian (it)
- Russian (ru)
- Chinese (zh)
- Japanese (ja)
- Korean (ko)
- Arabic (ar)
- Hindi (hi)

_To add more languages, update the locale files in `lib/l10n/` directory._

## 📂 Project Structure

```
lib/
├── l10n/                    # Localization files
│   ├── app_en.arb          # English translations
│   ├── app_es.arb          # Spanish translations
│   └── ...
├── models/                  # Data models
├── screens/                 # UI screens
├── services/               # API services and business logic
├── widgets/                # Reusable widgets
├── utils/                  # Utility functions
└── main.dart              # App entry point
```

## 🔧 Built With

- **[Flutter](https://flutter.dev/)** - UI framework
- **[Dart](https://dart.dev/)** - Programming language
- **[flutter_localizations](https://pub.dev/packages/flutter_localizations)** - Localization support
- **[intl](https://pub.dev/packages/intl)** - Internationalization utilities
- **[http](https://pub.dev/packages/http)** - HTTP requests
- **[shared_preferences](https://pub.dev/packages/shared_preferences)** - Local storage
- **[provider](https://pub.dev/packages/provider)** - State management

## 🌍 Localization

This app supports multiple languages through Flutter's internationalization framework:

### Adding New Languages

1. Create a new ARB file in `lib/l10n/` (e.g., `app_fr.arb` for French)
2. Add translations following the existing structure
3. Update `l10n.yaml` to include the new locale
4. Run `flutter gen-l10n` to generate the localization classes

### Switching Languages

Users can switch languages through:

- Settings menu
- Language selector widget
- System language detection

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Contribution Guidelines

- Follow Flutter and Dart best practices
- Write clear commit messages
- Add tests for new features
- Update documentation as needed
- Ensure code is properly formatted (`flutter format .`)

## 🧪 Testing

Run the test suite:

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

## 📋 TODO

- [ ] Voice translation support
- [ ] Camera text translation (OCR)
- [ ] Conversation mode
- [ ] Translation accuracy improvements
- [ ] Dark mode support
- [ ] Widget for quick translation
- [ ] Export translation history

## 🐛 Known Issues

- Translation accuracy may vary depending on the translation service
- Some languages may have limited offline support
- Performance optimization needed for large text translations

## 👨‍💻 Author

**CPONATO**

- GitHub: [@CPONATO](https://github.com/CPONATO)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Google Translate API for translation services
- Open source community for various packages used
- All contributors and testers
