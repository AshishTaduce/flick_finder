# Authentication System

This document describes the comprehensive authentication system implemented in the Flick Finder app, featuring both guest sessions and full TMDB account integration.

## Features

### 1. Login Screen
- TMDB username and password input fields with validation
- "Continue as Guest" option for users who don't want to create an account
- Form validation for username and password requirements
- Loading states and comprehensive error handling
- Signup dialog that redirects users to TMDB's registration page

### 2. Guest Session Management
- Automatic generation of guest tokens when users choose "Continue as Guest"
- Guest tokens are stored locally using SharedPreferences
- Guest sessions include a unique user ID for tracking
- Limited feature access (browsing only)

### 3. TMDB Account Integration
- Full TMDB authentication flow implementation
- Three-step authentication process:
  1. Create request token
  2. Validate with user credentials
  3. Create session with validated token
- Session management with automatic logout
- Account details retrieval and storage

### 4. Premium Features for TMDB Users
- **Movie Rating**: Rate movies from 0.5 to 10.0 stars
- **Watchlist Management**: Add/remove movies from personal watchlist
- **Favorites Management**: Mark movies as favorites
- **Account States**: Track user's interaction with each movie
- **Data Synchronization**: All data syncs with TMDB servers

### 5. Token Management
- Authentication tokens are automatically included in all API requests via Dio interceptor
- Tokens are stored securely using SharedPreferences
- Support for both guest tokens and TMDB session IDs
- Automatic session cleanup on logout

### 6. Authentication State Management
- Uses Riverpod for state management
- AuthProvider manages authentication state across the app
- Real-time updates when authentication state changes
- Comprehensive user data storage (username, account ID, session ID)

## Implementation Details

### Files Structure
```
lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart         # TMDB API endpoints
│   └── services/
│       ├── auth_service.dart          # Core authentication service
│       ├── tmdb_auth_service.dart     # TMDB API integration
│       └── user_features_service.dart # Premium features service
├── presentation/
│   ├── providers/
│   │   └── auth_provider.dart         # Riverpod state management
│   ├── screens/
│   │   ├── auth/
│   │   │   └── login_screen.dart      # Login UI with TMDB integration
│   │   └── profile/
│   │       └── profile_screen.dart    # Enhanced profile with features
│   └── widgets/
│       ├── auth_wrapper.dart          # Authentication wrapper
│       ├── auth_status_widget.dart    # Shows current auth status
│       └── movie_action_buttons.dart  # Watchlist/favorite/rating buttons
```

### AuthService Methods
- `createGuestSession()` - Creates a new guest session with token
- `login(username, password)` - TMDB user login with full authentication flow
- `getToken()` - Retrieves current authentication token
- `getSessionId()` - Gets TMDB session ID for authenticated users
- `getAccountId()` - Gets TMDB account ID for authenticated users
- `getUsername()` - Gets TMDB username for authenticated users
- `isGuest()` - Checks if current session is guest
- `isAuthenticated()` - Checks if user is authenticated
- `logout()` - Clears all authentication data and invalidates TMDB session

### TmdbAuthService Methods
- `createRequestToken()` - Step 1: Create TMDB request token
- `validateWithLogin()` - Step 2: Validate token with credentials
- `createSession()` - Step 3: Create session with validated token
- `login()` - Complete login flow (combines all steps)
- `getAccountDetails()` - Retrieve user account information
- `deleteSession()` - Invalidate TMDB session
- `getMovieAccountStates()` - Get user's interaction with specific movie
- `addToWatchlist()` - Add/remove movie from watchlist
- `addToFavorites()` - Add/remove movie from favorites
- `rateMovie()` - Rate a movie (0.5-10.0)
- `getWatchlist()` - Retrieve user's watchlist
- `getFavorites()` - Retrieve user's favorites
- `getRatedMovies()` - Retrieve user's rated movies

### UserFeaturesService Methods
- `canAccessPremiumFeatures()` - Check if user can access premium features
- `getMovieAccountStates()` - Get movie states for current user
- `toggleWatchlist()` - Add/remove from watchlist with error handling
- `toggleFavorite()` - Add/remove from favorites with error handling
- `rateMovie()` - Rate movie with validation
- `getWatchlist()` - Get user's watchlist with pagination
- `getFavorites()` - Get user's favorites with pagination
- `getRatedMovies()` - Get user's rated movies with pagination

### Dio Integration
The authentication token is automatically included in all HTTP requests through a Dio interceptor:

[//]: # (```dart)

[//]: # (// Add authentication token if available)

[//]: # (final token = await AuthService.instance.getToken&#40;&#41;;)

[//]: # (if &#40;token != null && token.isNotEmpty&#41; {)

[//]: # (  options.headers['Authorization'] = 'Bearer $token';)

[//]: # (})

[//]: # (```)

## Usage

### 1. App Startup
The app automatically checks authentication status on startup and shows the login screen if not authenticated.

### 2. Guest Login
Users can tap "Continue as Guest" to create a guest session without providing credentials.

### 3. Token Storage
All tokens are stored locally using SharedPreferences and persist across app restarts.

### 4. Logout
Users can logout from the Profile screen, which clears all stored authentication data.

## Future Enhancements

1. **User Registration** - Add sign-up functionality
2. **Social Login** - Add Google, Facebook, Apple login options
3. **Token Refresh** - Implement automatic token refresh
4. **Biometric Authentication** - Add fingerprint/face ID support
5. **Account Management** - Add profile editing, password reset
6. **Session Management** - Add session timeout and renewal

## Security Considerations

- Tokens are stored locally using SharedPreferences (consider using secure storage for production)
- Guest tokens are generated with timestamp and random components
- All API requests include authentication headers
- Logout properly clears all stored authentication data

## Testing

The authentication system can be tested by:
1. Running the app and choosing "Continue as Guest"
2. Checking that the auth status widget shows "Guest"
3. Navigating to Profile to see guest session details
4. Logging out and verifying return to login screen
5. Checking that API requests include the Bearer token in headers
## T
MDB Authentication Flow

### Registration Process
1. User clicks "Don't have a TMDB account? Sign up"
2. App shows informational dialog explaining TMDB benefits
3. User is redirected to https://www.themoviedb.org/signup
4. After registration, user returns to app and logs in

### Login Process
1. User enters TMDB username and password
2. App creates request token from TMDB API
3. App validates token with user credentials
4. App creates session with validated token
5. App retrieves and stores account details
6. User gains access to premium features

### Premium Features Access
- **Guest Users**: Can browse movies but cannot rate, favorite, or create watchlists
- **TMDB Users**: Full access to all features including:
  - Rating movies (0.5-10.0 stars)
  - Adding movies to watchlist
  - Marking movies as favorites
  - Viewing personal lists
  - Data synchronization across devices

## UI Components

### MovieActionButtons Widget
Displays interactive buttons for TMDB users on movie cards:
- **Watchlist Button**: Bookmark icon, toggles blue when added
- **Favorite Button**: Heart icon, toggles red when favorited
- **Rating Button**: Star icon, toggles amber when rated
- Shows user's current rating in tooltip
- Automatically loads current states from TMDB API

### Enhanced Profile Screen
- Shows username for TMDB users vs "Guest User"
- Displays account type and available features
- Lists premium features with navigation (coming soon)
- Upgrade prompt for guest users
- Proper logout handling for both user types

### Login Screen Enhancements
- Username field instead of email (TMDB requirement)
- Comprehensive error handling for authentication failures
- Signup dialog with feature explanation
- External browser launch for TMDB registration

## Error Handling

### Authentication Errors
- Invalid credentials: Clear error message
- Network errors: Retry suggestions
- Session expiration: Automatic logout and re-login prompt
- API rate limiting: Graceful degradation

### Feature Access Errors
- Guest users: Informative messages about premium features
- Network failures: Cached data when available
- API errors: User-friendly error messages

## Data Storage

### SharedPreferences Keys
- `auth_token`: Current authentication token
- `session_id`: TMDB session ID for authenticated users
- `account_id`: TMDB account ID
- `username`: TMDB username
- `user_id`: Internal user ID
- `is_guest`: Boolean flag for guest sessions

### Data Persistence
- All authentication data persists across app restarts
- Guest sessions maintain state until logout
- TMDB sessions remain valid until explicit logout
- Automatic cleanup on authentication errors

## Security Considerations

### Token Security
- Session IDs stored locally using SharedPreferences
- Automatic token cleanup on logout
- Session validation on app startup
- Secure transmission over HTTPS

### API Security
- All requests use HTTPS
- API key included in requests
- Session-based authentication for user actions
- Proper error handling to prevent data leaks

## Testing the System

### Guest Flow
1. Launch app → Login screen appears
2. Tap "Continue as Guest" → Creates guest session
3. Navigate to Profile → Shows guest status and upgrade prompt
4. Try to rate a movie → Shows login requirement message

### TMDB User Flow
1. Launch app → Login screen appears
2. Enter TMDB credentials → Authenticates with TMDB
3. Navigate to Profile → Shows username and premium features
4. Rate a movie → Shows rating dialog and saves to TMDB
5. Add to watchlist → Syncs with TMDB account
6. Logout → Clears session and returns to login

### Error Testing
1. Enter invalid credentials → Shows appropriate error
2. Disconnect internet during login → Shows network error
3. Rate movie as guest → Shows upgrade prompt
4. Session expiration → Automatic logout and re-login

## Future Enhancements

### Planned Features
1. **Watchlist Screen**: Dedicated screen for managing watchlist
2. **Favorites Screen**: Browse and manage favorite movies
3. **Rated Movies Screen**: View all rated movies with scores
4. **Recommendations**: Personalized recommendations based on ratings
5. **Social Features**: Share ratings and lists with friends
6. **Offline Support**: Cache user data for offline viewing
7. **Biometric Login**: Fingerprint/Face ID for quick access
8. **Account Management**: Change password, update profile

### Technical Improvements
1. **Token Refresh**: Automatic session renewal
2. **Secure Storage**: Use flutter_secure_storage for sensitive data
3. **Background Sync**: Sync user data in background
4. **Performance**: Cache frequently accessed data
5. **Analytics**: Track feature usage and user engagement