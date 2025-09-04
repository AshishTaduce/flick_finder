# Deeplink Testing Guide

## Overview
The Flick Finder app now supports deeplinks using a custom URL scheme for sharing and navigating directly to movie details. **No domain required!**

## Supported Deeplink Format

### Custom Scheme Links (Primary)
```
flickfinder://movie/123
```

**Note**: This implementation uses only custom URL schemes, eliminating the need for a web domain or universal links setup.

## Testing Deeplinks

### Android Testing

1. **Using ADB (Android Debug Bridge)**
   ```bash
   # Test custom scheme deeplink
   adb shell am start -W -a android.intent.action.VIEW -d "flickfinder://movie/550" com.example.flick_finder
   ```

2. **Manual Testing**
   - Send yourself the deeplink via SMS, email, or messaging app
   - Tap the link to test the functionality
   - The app should open and navigate to the movie details

### iOS Testing

1. **Using Simulator**
   ```bash
   # Test custom scheme deeplink
   xcrun simctl openurl booted "flickfinder://movie/550"
   ```

2. **Manual Testing**
   - Send yourself the deeplink via SMS, email, or messaging app
   - Tap the link to test the functionality
   - The app should open and navigate to the movie details

## App Behavior

### When App is Closed
1. Deeplink opens the app
2. Splash screen appears with initialization
3. Auth state is checked
4. If not authenticated → Login screen with snackbar message
5. If authenticated → Home screen → Movie detail screen

### When App is Running
1. Deeplink is handled immediately
2. Navigation stack: Home → Movie Detail (proper stack maintained)

### Authentication Flow
- **Not logged in**: Redirects to login with message "Please login to view movie details"
- **Guest user**: Directly navigates to movie details
- **Authenticated user**: Directly navigates to movie details

## Share Functionality

The movie detail screen includes a share button that:
1. Generates a deeplink for the current movie
2. Creates formatted share text with movie details
3. Uses the system share dialog
4. Recipients can tap the link to open the movie in the app

## Implementation Details

### Key Files
- `lib/core/services/deeplink_service.dart` - **NEW**: Main deep link handling service using app_links
- `lib/core/routes/app_routes.dart` - Route definitions and constants
- `lib/core/routes/route_generator.dart` - Route generation logic with deep link support
- `lib/presentation/screens/splash/splash_screen.dart` - Handles deeplink routing and initialization
- `lib/main.dart` - App setup with named routes and deep link service initialization
- `lib/core/utils/deeplink_utils.dart` - **UPDATED**: Deeplink generation utilities with custom scheme
- `lib/presentation/widgets/share_movie_dialog.dart` - **UPDATED**: Share functionality using custom scheme
- `android/app/src/main/AndroidManifest.xml` - **UPDATED**: Android deeplink configuration for custom scheme
- `ios/Runner/Info.plist` - **UPDATED**: iOS deeplink configuration for custom scheme
- `pubspec.yaml` - **UPDATED**: Added app_links dependency

### Navigation Stack
The app maintains proper navigation stack by:
1. Always going to home first (MainScreen) via named routes
2. Then pushing movie detail screen using named routes
3. This ensures back button works correctly and maintains proper navigation history
4. All navigation uses named routes for consistency

### Route Structure
- `/` - Splash screen (with optional movie ID parameter)
- `/home` - Main app screen with bottom navigation
- `/login` - Login screen
- `/movie?movieId=123` - Movie detail screen
- `/watchlist` - User's watchlist
- `/favorites` - User's favorites
- `/rated` - User's rated movies
- `/settings` - App settings
- `/person?personId=123` - Person movies screen