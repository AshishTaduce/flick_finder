import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../shared/theme/app_insets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).login(
        _usernameController.text.trim(),
        _passwordController.text,
      );
      
      if (mounted) {
        SnackbarUtils.showSuccess(
          context,
          'Login successful! Welcome back.',
        );
        // Call the success callback immediately - the auth state is already updated
        widget.onLoginSuccess();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (e.toString().contains('Invalid username or password')) {
          errorMessage = 'Invalid username or password';
        } else if (e.toString().contains('network')) {
          errorMessage = 'Network error. Please check your connection.';
        }
        SnackbarUtils.showError(
          context,
          errorMessage,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGuestLogin() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).createGuestSession();
      if (mounted) {
        SnackbarUtils.showSuccess(
          context,
          'Welcome! You can now browse movies.',
        );
        // Call the success callback immediately - the auth state is already updated
        widget.onLoginSuccess();
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          'Failed to create guest session: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showSignupDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create TMDB Account'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To access premium features like rating movies, creating watchlists, and syncing favorites, you need a TMDB account.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Features available with TMDB account:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Rate movies and TV shows'),
              Text('• Create and manage watchlists'),
              Text('• Mark movies as favorites'),
              Text('• Sync data across devices'),
              Text('• Access personalized recommendations'),
              SizedBox(height: 16),
              Text(
                'You will be redirected to TMDB\'s website to create your account. After registration, return to this app and login with your new credentials.',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Create Account'),
              onPressed: () async {
                Navigator.of(context).pop();
                final uri = Uri.parse('https://www.themoviedb.org/signup');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  if (context.mounted) {
                    SnackbarUtils.showError(
                      context,
                      'Could not open signup page',
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppInsets.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Logo/Title
              Icon(
                Icons.movie,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: AppInsets.md),
              Text(
                'Flick Finder',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppInsets.sm),
              Text(
                'Discover your next favorite movie',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppInsets.xl * 2),

              // Login Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'TMDB Username',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                        helperText: 'Enter your TMDB username (not email)',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your TMDB username';
                        }
                        if (value.length < 3) {
                          return 'Username must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppInsets.md),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'TMDB Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your TMDB password';
                        }
                        if (value.length < 4) {
                          return 'Password must be at least 4 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppInsets.xl),

              // Login Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppInsets.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(height: AppInsets.md),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppInsets.md),
                    child: Text(
                      'OR',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: AppInsets.md),

              // Continue as Guest Button
              OutlinedButton(
                onPressed: _isLoading ? null : _handleGuestLogin,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppInsets.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Continue as Guest',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: AppInsets.lg),

              // Sign up link
              TextButton(
                onPressed: _showSignupDialog,
                child: const Text("Don't have a TMDB account? Sign up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}