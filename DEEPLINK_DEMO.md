# Deep Link Demo for FlickFinder

## Overview
FlickFinder now supports deep linking using a custom URL scheme `flickfinder://` to share movie details pages.

## Custom URL Scheme
- **Scheme**: `flickfinder://`
- **Movie Deep Link Format**: `flickfinder://movie/{movieId}`

## Example Deep Links
- `flickfinder://movie/550` - Opens Fight Club movie details
- `flickfinder://movie/13` - Opens Forrest Gump movie details
- `flickfinder://movie/680` - Opens Pulp Fiction movie details

## How It Works

### 1. Sharing Movies
- Open any movie detail page in the app
- Tap the "Share" button
- The app generates a deep link like `flickfinder://movie/123`
- Share via any platform (SMS, email, social media, etc.)

### 2. Opening Deep Links
- When someone taps a `flickfinder://` link:
  - If the app is installed, it opens directly to the movie details page
  - If not authenticated, user is prompted to login first
  - The movie details are loaded automatically

### 3. Platform Support
- **Android**: Configured in `android/app/src/main/AndroidManifest.xml`
- **iOS**: Configured in `ios/Runner/Info.plist`

## Testing Deep Links

### Android Testing
```bash
# Test via ADB
adb shell am start \
  -W -a android.intent.action.VIEW \
  -d "flickfinder://movie/550" \
  com.example.flick_finder
```

### iOS Testing (Simulator)
```bash
# Test via Simulator
xcrun simctl openurl booted "flickfinder://movie/550"
```

### Manual Testing
1. Build and install the app on a device
2. Open any movie detail page
3. Tap "Share" and copy the generated link
4. Send the link to yourself via SMS or email
5. Tap the link to test the deep link functionality

## Implementation Details

### Key Files Modified
- `pubspec.yaml` - Added `app_links: ^6.3.2` dependency
- `lib/core/services/deeplink_service.dart` - Main deep link handling service
- `lib/core/utils/deeplink_utils.dart` - Utility functions for generating and parsing deep links
- `lib/presentation/widgets/share_movie_dialog.dart` - Updated to use custom URL scheme
- `lib/main.dart` - Initialize deep link service and routing
- `android/app/src/main/AndroidManifest.xml` - Android deep link configuration
- `ios/Runner/Info.plist` - iOS deep link configuration

### Navigation Flow
1. Deep link received → `DeepLinkService`
2. Parse movie ID from URL
3. Navigate to splash screen with movie ID
4. Check authentication status
5. Navigate to movie details or login screen
6. Load movie details automatically

## Benefits
- **No Domain Required**: Uses custom URL scheme instead of web domain
- **Native App Experience**: Direct navigation to specific content
- **Offline Capable**: Works without internet for navigation
- **Cross-Platform**: Works on both Android and iOS
- **Secure**: No external dependencies or web redirects