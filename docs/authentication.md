# Authentication System

This document describes the authentication system implemented in the Flick Finder app.

## Features

### 1. Login Screen
- Email and password input fields with validation
- "Continue as Guest" option for users who don't want to create an account
- Form validation for email format and password length
- Loading states and error handling

### 2. Guest Session Management
- Automatic generation of guest tokens when users choose "Continue as Guest"
- Guest tokens are stored locally using SharedPreferences
- Guest sessions include a unique user ID for tracking

### 3. Token Management
- Authentication tokens are automatically included in all API requests via Dio interceptor
- Tokens are stored securely using SharedPreferences
- Support for both guest tokens and user authentication tokens

### 4. Authentication State Management
- Uses Riverpod for state management
- AuthProvider manages authentication state across the app
- Real-time updates when authentication state changes

## Implementation Details

### Files Structure
```
lib/
├── core/
│   └── services/
│       └── auth_service.dart          # Core authentication service
├── presentation/
│   ├── providers/
│   │   └── auth_provider.dart         # Riverpod state management
│   ├── screens/
│   │   └── auth/
│   │       └── login_screen.dart      # Login UI
│   │   └── profile/
│   │       └── profile_screen.dart    # Profile with logout
│   └── widgets/
│       ├── auth_wrapper.dart          # Authentication wrapper
│       └── auth_status_widget.dart    # Shows current auth status
```

### AuthService Methods
- `createGuestSession()` - Creates a new guest session with token
- `login(email, password)` - User login (placeholder for future implementation)
- `getToken()` - Retrieves current authentication token
- `isGuest()` - Checks if current session is guest
- `isAuthenticated()` - Checks if user is authenticated
- `logout()` - Clears all authentication data

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