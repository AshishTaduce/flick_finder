# Deep Linking Implementation Guide

## Overview
The Flick Finder app now supports deep linking for sharing movies. Users can share movie links that will open directly to the movie detail page in the app.

## Features Implemented

### 1. Splash Screen with Deep Link Handling
- **File**: `lib/presentation/screens/splash/splash_screen.dart`
- Shows animated splash screen while initializing the app
- Handles deep link parameters and routes to appropriate screens
- Displays "Opening shared movie..." message when a movie ID is detected

### 2. GoRouter Integration
- **File**: `lib/core/router/app_router.dart`
- Replaced Navigator with GoRouter throughout the app
- Supports deep linking with URL patterns
- Handles authentication flow for deep links

### 3. Deep Link Service
- **File**: `lib/core/services/deep_link_service.dart`
- Generates universal links: `https://flickfinder.app/?movie=123`
- Generates app deep links: `flickfinder://movie/123`
- Parses movie IDs from various URL formats

### 4. Updated Share Functionality
- **File**: `lib/presentation/widgets/share_movie_dialog.dart`
- Uses the deep link service to generate shareable links
- Creates universal links that work on both web and mobile

## URL Patterns Supported

### Universal Links (Web + App)
- `https://flickfinder.app/?movie=123` - Opens movie with ID 123
- `https://flickfinder.app/movie/123` - Direct movie URL

### App Deep Links
- `flickfinder://movie/123` - Opens movie with ID 123 in app

## Authentication Flow

### For Authenticated Users
1. Splash screen → Movie detail page directly

### For Unauthenticated Users
1. Splash screen → Login page with redirect parameter
2. After login → Movie detail page

### Guest Users
- Can use "Continue as Guest" to access shared movies
- Full functionality available in guest mode

## Platform Configuration

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<!-- Deep Link Intent Filter -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="flickfinder" />
</intent-filter>

<!-- Universal Link Intent Filter -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" android:host="flickfinder.app" />
</intent-filter>
```

### iOS (`ios/Runner/Info.plist`)
```xml
<!-- Deep Link URL Schemes -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>flickfinder.deeplink</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>flickfinder</string>
        </array>
    </dict>
</array>

<!-- Associated Domains for Universal Links -->
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:flickfinder.app</string>
</array>
```

## Testing Deep Links

### 1. Testing on Android Emulator
```bash
# Test app deep link
adb shell am start -W -a android.intent.action.VIEW -d "flickfinder://movie/550" com.example.flick_finder

# Test universal link
adb shell am start -W -a android.intent.action.VIEW -d "https://flickfinder.app/?movie=550" com.example.flick_finder
```

### 2. Testing on iOS Simulator
```bash
# Test app deep link
xcrun simctl openurl booted "flickfinder://movie/550"

# Test universal link
xcrun simctl openurl booted "https://flickfinder.app/?movie=550"
```

### 3. Testing in Development
- Use the share button in any movie detail screen
- Copy the generated link
- Open the link in a browser or messaging app
- The app should open and navigate to the movie

## Navigation Updates

All navigation throughout the app has been updated to use GoRouter:

### Updated Files
- `lib/shared/widgets/movie_card.dart` - Movie card taps
- `lib/presentation/screens/home/widgets/movie_carousel.dart` - Carousel taps
- `lib/presentation/screens/movie_detail/movie_detail_screen.dart` - Cast member taps
- `lib/presentation/screens/profile/profile_screen.dart` - Profile navigation

### Route Structure
```
/ (splash)
├── /login
├── /home (shell)
├── /search (shell)
├── /watchlist (shell)
├── /profile (shell)
├── /movie/:id (full screen)
├── /person/:id (full screen)
├── /favorites (full screen)
├── /rated (full screen)
└── /settings (full screen)
```

## Error Handling

### Invalid Movie ID
- Shows error screen with "Movie not found" message
- Provides "Go Home" button to return to main app

### Network Errors
- MovieDetailProvider handles loading states
- Shows appropriate error messages
- Allows retry functionality

### Authentication Errors
- Redirects to login with return URL
- Preserves intended destination after login
- Supports guest access for shared content

## Future Enhancements

1. **Web Support**: Add web version at `https://flickfinder.app`
2. **Person Deep Links**: Extend to support actor/director pages
3. **Search Deep Links**: Support deep links to search results
4. **List Sharing**: Support sharing of custom movie lists
5. **Analytics**: Track deep link usage and conversion rates

## Dependencies Added
- `go_router: ^14.6.2` - For routing and deep link handling

## Notes
- The app maintains backward compatibility with existing navigation
- All screens are properly integrated with the new router
- Authentication state is preserved across deep link navigation
- The splash screen provides smooth user experience during app initialization