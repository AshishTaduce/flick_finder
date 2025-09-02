import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/settings_service.dart';
import '../../../shared/theme/app_insets.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _selectedLanguage = 'en-US';
  String _selectedRegion = 'US';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final language = await SettingsService.instance.getLanguage();
    final region = await SettingsService.instance.getRegion();
    
    if (mounted) {
      setState(() {
        _selectedLanguage = language;
        _selectedRegion = region;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateLanguage(String language) async {
    await SettingsService.instance.setLanguage(language);
    setState(() {
      _selectedLanguage = language;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Language updated to ${SettingsService.availableLanguages[language]}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _updateRegion(String region) async {
    await SettingsService.instance.setRegion(region);
    setState(() {
      _selectedRegion = region;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Region updated to ${SettingsService.availableRegions[region]}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppInsets.md),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppInsets.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Content Preferences',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppInsets.md),
                        Text(
                          'These settings affect the language and region for movie data from TMDB.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppInsets.md),
                
                // Language Setting
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('Language'),
                    subtitle: Text(SettingsService.availableLanguages[_selectedLanguage] ?? _selectedLanguage),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showLanguageDialog(),
                  ),
                ),
                const SizedBox(height: AppInsets.sm),
                
                // Region Setting
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.public),
                    title: const Text('Region'),
                    subtitle: Text(SettingsService.availableRegions[_selectedRegion] ?? _selectedRegion),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showRegionDialog(),
                  ),
                ),
                const SizedBox(height: AppInsets.lg),
                
                // Info Card
                Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(AppInsets.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: AppInsets.sm),
                            Text(
                              'About These Settings',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppInsets.sm),
                        Text(
                          '• Language affects movie titles, descriptions, and other text content\n'
                          '• Region affects release dates, ratings, and availability information\n'
                          '• Changes take effect immediately for new content',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: SettingsService.availableLanguages.length,
            itemBuilder: (context, index) {
              final entry = SettingsService.availableLanguages.entries.elementAt(index);
              final isSelected = entry.key == _selectedLanguage;
              
              return ListTile(
                title: Text(entry.value),
                subtitle: Text(entry.key),
                leading: Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? Theme.of(context).colorScheme.primary : null,
                ),
                selected: isSelected,
                onTap: () {
                  Navigator.of(context).pop();
                  _updateLanguage(entry.key);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showRegionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Region'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: SettingsService.availableRegions.length,
            itemBuilder: (context, index) {
              final entry = SettingsService.availableRegions.entries.elementAt(index);
              final isSelected = entry.key == _selectedRegion;
              
              return ListTile(
                title: Text(entry.value),
                subtitle: Text(entry.key),
                leading: Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? Theme.of(context).colorScheme.primary : null,
                ),
                selected: isSelected,
                onTap: () {
                  Navigator.of(context).pop();
                  _updateRegion(entry.key);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}