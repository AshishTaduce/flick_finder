# 🎬 FlickFinder

A modern Flutter movie discovery app that brings the power of The Movie Database (TMDB) to your fingertips. Discover, explore, and manage your favorite movies with a beautiful, intuitive interface.

## ✨ Features

### 🔍 Movie Discovery
- **Browse Popular Movies**: Discover trending and popular movies
- **Advanced Search**: Find movies by title, genre, or keywords
- **Detailed Movie Information**: Cast, crew, ratings, reviews, and more
- **High-Quality Images**: Cached movie posters and backdrops

### 👤 User Authentication
- **TMDB Account Integration**: Full authentication with TMDB accounts
- **Guest Mode**: Browse without registration
- **Secure Session Management**: Token-based authentication with automatic cleanup

### 🌟 Premium Features (TMDB Users)
- **Movie Ratings**: Rate movies from 0.5 to 10.0 stars
- **Personal Watchlist**: Save movies to watch later
- **Favorites Collection**: Mark and organize favorite movies
- **Cross-Device Sync**: All data syncs with your TMDB account

### 🔗 Deep Linking
- **Custom URL Scheme**: Share movies using `flickfinder://movie/{id}` links
- **Direct Navigation**: Open specific movie details from external links
- **Cross-Platform Support**: Works on both Android and iOS

### 🎨 Modern UI/UX
- **Material Design 3**: Clean, modern interface following latest design guidelines
- **Dark/Light Theme**: Automatic theme switching based on system preferences
- **Responsive Design**: Optimized for different screen sizes
- **Smooth Animations**: Fluid transitions and loading states
- **Network Status Indicator**: Real-time connectivity feedback

## 🏗️ Architecture

Built with **Clean Architecture** principles for maintainability and scalability:

```
lib/
├── core/                 # Core functionality
│   ├── constants/        # API endpoints and app constants
│   ├── errors/          # Error handling and exceptions
│   ├── network/         # HTTP client configuration
│   ├── routes/          # Navigation and routing
│   ├── services/        # Core services (auth, cache, etc.)
│   └── utils/           # Utility functions
├── data/                # Data layer
│   ├── datasources/     # API and local data sources
│   ├── models/          # Data models and serialization
│   └── repositories/    # Repository implementations
├── domain/              # Business logic layer
│   ├── entities/        # Business entities
│   ├── repositories/    # Repository interfaces
│   └── usecases/        # Business use cases
├── presentation/        # UI layer
│   ├── providers/       # State management (Riverpod)
│   ├── screens/         # App screens and pages
│   └── widgets/         # Reusable UI components
└── shared/              # Shared resources
    ├── theme/           # App theming and styling
    └── widgets/         # Common widgets
```

## 🛠️ Tech Stack

### Core Framework
- **Flutter 3.8+**: Cross-platform mobile development
- **Dart**: Programming language

### State Management
- **Riverpod**: Reactive state management with code generation
- **Riverpod Annotation**: Type-safe providers with code generation

### Networking & Data
- **Dio**: HTTP client with interceptors and retry logic
- **JSON Annotation**: Automatic JSON serialization
- **Hive**: Fast, local NoSQL database
- **Shared Preferences**: Simple key-value storage

### UI & Navigation
- **Go Router**: Declarative routing with deep linking support
- **Cached Network Image**: Efficient image loading and caching
- **Shimmer**: Loading skeleton animations
- **Material Design 3**: Modern UI components

### Platform Integration
- **App Links**: Deep linking support
- **URL Launcher**: External link handling
- **Share Plus**: Native sharing functionality
- **Connectivity Plus**: Network status monitoring

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code with Flutter extensions
- TMDB API key (for development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/flick_finder.git
   cd flick_finder
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   dart packages pub run build_runner build
   ```

4. **Configure API Key**
   - Get your API key from [TMDB](https://www.themoviedb.org/settings/api)
   - Add it to your environment or configuration file

5. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Deep Linking

FlickFinder supports custom URL scheme deep linking:

### Format
```
flickfinder://movie/{movieId}
```

### Examples
- `flickfinder://movie/550` - Opens Fight Club details
- `flickfinder://movie/13` - Opens Forrest Gump details

### Testing Deep Links

**Android (ADB)**
```bash
adb shell am start -W -a android.intent.action.VIEW -d "flickfinder://movie/550" com.example.flick_finder
```

**iOS (Simulator)**
```bash
xcrun simctl openurl booted "flickfinder://movie/550"
```

## 🧪 Testing

Run the test suite:
```bash
flutter test
```

Run tests with coverage:
```bash
flutter test --coverage
```

## 📦 Building

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format` before committing
- Ensure all tests pass
- Add tests for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [The Movie Database (TMDB)](https://www.themoviedb.org/) for providing the movie data API
- Flutter team for the amazing framework
- Riverpod team for excellent state management
- All contributors and the Flutter community

## 📞 Support

If you have any questions or need help:
- Open an issue on GitHub
- Check the [documentation](docs/)
- Review the [authentication guide](docs/authentication.md)
- See [deep linking setup](DEEPLINK_DEMO.md)

---

**Made with ❤️ using Flutter**
