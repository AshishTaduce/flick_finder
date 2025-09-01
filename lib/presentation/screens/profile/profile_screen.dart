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
                                authState.isGuest ? 'Guest User' : 'User',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: AppInsets.xs),
                              Text(
                                authState.isGuest 
                                    ? 'Browsing as guest'
                                    : 'Logged in user',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                ),
                              ),
                              if (authState.userId != null) ...[
                                const SizedBox(height: AppInsets.xs),
                                Text(
                                  'ID: ${authState.userId!.substring(0, 12)}...',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
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
                authState.isGuest ? 'Guest Session' : 'Authenticated User',
              ),
              subtitle: Text(
                authState.isGuest 
                    ? 'Limited features available'
                    : 'Full access to all features',
              ),
            ),

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