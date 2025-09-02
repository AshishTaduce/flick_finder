import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../../shared/theme/app_insets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppInsets.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppInsets.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Icon(
                            authState.isGuest ? Icons.person : Icons.account_circle,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: AppInsets.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authState.isGuest
                                    ? 'Guest User'
                                    : authState.username ?? 'TMDB User',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: AppInsets.xs),
                              Text(
                                authState.isGuest
                                    ? 'Browsing as guest'
                                    : 'TMDB Account',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppInsets.lg),

            // Account Status
            ListTile(
              leading: Icon(
                authState.isGuest ? Icons.visibility : Icons.verified_user,
                color: authState.isGuest ? Colors.orange : Colors.green,
              ),
              title: Text(
                authState.isGuest ? 'Guest Session' : 'TMDB Account',
              ),
              subtitle: Text(
                authState.isGuest 
                    ? 'Limited features available'
                    : 'Full access to all features',
              ),
            ),

            // Premium Features (only for TMDB users)
            if (!authState.isGuest && authState.isAuthenticated) ...[
              const SizedBox(height: AppInsets.md),
              const Divider(),
              const SizedBox(height: AppInsets.md),
              Text(
                'Your TMDB Features',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppInsets.md),
              
              // Feature tiles
              ListTile(
                leading: const Icon(Icons.bookmark, color: Colors.blue),
                title: const Text('Watchlist'),
                subtitle: const Text('Movies you want to watch'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Navigate to watchlist screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Watchlist screen coming soon!')),
                  );
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.favorite, color: Colors.red),
                title: const Text('Favorites'),
                subtitle: const Text('Movies you love'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Navigate to favorites screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Favorites screen coming soon!')),
                  );
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: const Text('Rated Movies'),
                subtitle: const Text('Movies you\'ve rated'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: Navigate to rated movies screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rated movies screen coming soon!')),
                  );
                },
              ),
            ],

            // Guest upgrade prompt
            if (authState.isGuest) ...[
              const SizedBox(height: AppInsets.md),
              Card(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(AppInsets.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: AppInsets.sm),
                          Text(
                            'Unlock Premium Features',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppInsets.sm),
                      const Text('Login with your TMDB account to:'),
                      const SizedBox(height: AppInsets.xs),
                      const Text('• Rate movies and TV shows'),
                      const Text('• Create and manage watchlists'),
                      const Text('• Mark movies as favorites'),
                      const Text('• Sync data across devices'),
                      const SizedBox(height: AppInsets.md),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await ref.read(authProvider.notifier).logout();
                          },
                          child: const Text('Login with TMDB Account'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const Spacer(),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: Text(
                        authState.isGuest 
                            ? 'Are you sure you want to end your guest session?'
                            : 'Are you sure you want to logout?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );

                  if (shouldLogout == true) {
                    await ref.read(authProvider.notifier).logout();
                  }
                },
                icon: const Icon(Icons.logout),
                label: Text(authState.isGuest ? 'End Guest Session' : 'Logout'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppInsets.md),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: AppInsets.md),
          ],
        ),
      ),
    );
  }
}