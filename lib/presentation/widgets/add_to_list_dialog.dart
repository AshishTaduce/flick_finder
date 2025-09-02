import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/user_features_service.dart';
import '../../core/services/tmdb_lists_service.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../domain/entities/tmdb_list.dart';
import '../providers/auth_provider.dart';
import '../../shared/theme/app_insets.dart';

class AddToListDialog extends ConsumerStatefulWidget {
  final int movieId;
  final String movieTitle;

  const AddToListDialog({
    super.key,
    required this.movieId,
    required this.movieTitle,
  });

  @override
  ConsumerState<AddToListDialog> createState() => _AddToListDialogState();
}

class _AddToListDialogState extends ConsumerState<AddToListDialog> {
  List<TmdbList> _userLists = [];
  Map<String, dynamic>? _accountStates;
  Map<int, bool> _customListStates = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load user lists and account states in parallel
      final futures = await Future.wait([
        TmdbListsService.instance.getUserLists(),
        UserFeaturesService.instance.getMovieAccountStates(widget.movieId),
      ]);
      
      final lists = futures[0] as List<TmdbList>;
      final accountStates = futures[1] as Map<String, dynamic>?;
      
      // Check which custom lists contain this movie
      final customListStates = <int, bool>{};
      for (final list in lists) {
        try {
          final listDetail = await TmdbListsService.instance.getListDetail(list.id);
          final containsMovie = listDetail?.items.any((movie) => movie.id == widget.movieId) ?? false;
          customListStates[list.id] = containsMovie;
        } catch (e) {
          // If we can't check the list detail, assume the movie is not in the list
          customListStates[list.id] = false;
        }
      }
      
      if (mounted) {
        setState(() {
          _userLists = lists;
          _accountStates = accountStates;
          _customListStates = customListStates;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      // If there's an error loading data, still show the dialog but with limited functionality
      if (mounted) {
        setState(() {
          _userLists = [];
          _accountStates = null;
          _customListStates = {};
          _isLoading = false;
          _error = null; // Don't show error for unauthenticated users
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return AlertDialog(
      title: Text('Manage "${widget.movieTitle}" Lists'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (authState.isGuest || !authState.isAuthenticated) ...[
              Icon(
                Icons.info_outline,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppInsets.md),
              Text(
                'Please login with your TMDB account to add movies to your lists.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ] else ...[ 
              // Quick actions section
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.trailing,
                secondary: const Icon(Icons.bookmark, color: Colors.blue),
                title: const Text('Watchlist'),
                subtitle: const Text('TMDB default watchlist'),
                value: _accountStates?['watchlist'] ?? false,
                onChanged: (bool? value) async {
                  if (value != null) {
                    await _toggleWatchlist(value);
                  }
                },
              ),
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.trailing,
                secondary: const Icon(Icons.favorite, color: Colors.red),
                title: const Text('Favorites'),
                subtitle: const Text('TMDB favorites'),
                value: _accountStates?['favorite'] ?? false,
                onChanged: (bool? value) async {
                  if (value != null) {
                    await _toggleFavorites(value);
                  }
                },
              ),
              const Divider(),
              
              // Custom lists section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Custom Lists',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _showCreateListDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Create'),
                  ),
                ],
              ),
              const SizedBox(height: AppInsets.sm),
              
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppInsets.md),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(AppInsets.md),
                  child: Column(
                    children: [
                      Text(
                        'Error loading lists: $_error',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppInsets.sm),
                      TextButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else if (_userLists.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppInsets.md),
                  child: Text(
                    'No custom lists yet. Create your first list!',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _userLists.length,
                    itemBuilder: (context, index) {
                      final list = _userLists[index];
                      final isInList = _customListStates[list.id] ?? false;
                      return CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.trailing,
                        secondary: const Icon(Icons.list, color: Colors.green),
                        title: Text(list.name),
                        subtitle: Text('${list.itemCount} movies'),
                        value: isInList,
                        onChanged: (bool? value) async {
                          if (value != null) {
                            await _toggleCustomList(list, value);
                          }
                        },
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        if (authState.isGuest || !authState.isAuthenticated)
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(authProvider.notifier).logout();
            },
            child: const Text('Login'),
          )
        else
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
      ],
    );
  }

  Future<void> _toggleWatchlist(bool addToWatchlist) async {
    try {
      final success = await UserFeaturesService.instance.toggleWatchlist(
        widget.movieId,
        addToWatchlist,
      );
      
      if (success && mounted) {
        setState(() {
          _accountStates = {
            ..._accountStates ?? {},
            'watchlist': addToWatchlist,
          };
        });
        
        SnackbarUtils.showSuccess(
          context,
          addToWatchlist 
            ? 'Added "${widget.movieTitle}" to watchlist'
            : 'Removed "${widget.movieTitle}" from watchlist',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  Future<void> _toggleFavorites(bool addToFavorites) async {
    try {
      final success = await UserFeaturesService.instance.toggleFavorite(
        widget.movieId,
        addToFavorites,
      );
      
      if (success && mounted) {
        setState(() {
          _accountStates = {
            ..._accountStates ?? {},
            'favorite': addToFavorites,
          };
        });
        
        SnackbarUtils.showSuccess(
          context,
          addToFavorites 
            ? 'Added "${widget.movieTitle}" to favorites'
            : 'Removed "${widget.movieTitle}" from favorites',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  Future<void> _toggleCustomList(TmdbList list, bool addToList) async {
    try {
      final success = addToList
        ? await TmdbListsService.instance.addMovieToList(
            listId: list.id,
            movieId: widget.movieId,
          )
        : await TmdbListsService.instance.removeMovieFromList(
            listId: list.id,
            movieId: widget.movieId,
          );
      
      if (success && mounted) {
        setState(() {
          _customListStates[list.id] = addToList;
        });
        
        SnackbarUtils.showSuccess(
          context,
          addToList 
            ? 'Added "${widget.movieTitle}" to ${list.name}'
            : 'Removed "${widget.movieTitle}" from ${list.name}',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  void _showCreateListDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New List'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'List Name',
                hintText: 'e.g., Action Movies',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppInsets.md),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Describe your list...',
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                SnackbarUtils.showError(context, 'Please enter a list name');
                return;
              }
              
              Navigator.of(context).pop();
              await _createListAndAddMovie(
                nameController.text.trim(),
                descriptionController.text.trim(),
              );
            },
            child: const Text('Create & Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _createListAndAddMovie(String name, String description) async {
    try {
      final newList = await TmdbListsService.instance.createList(
        name: name,
        description: description.isEmpty ? 'Custom movie list' : description,
      );
      
      if (newList != null) {
        final success = await TmdbListsService.instance.addMovieToList(
          listId: newList.id,
          movieId: widget.movieId,
        );
        
        if (success && mounted) {
          // Update the UI with the new list
          setState(() {
            _userLists.add(newList);
            _customListStates[newList.id] = true;
          });
          
          SnackbarUtils.showSuccess(
            context,
            'Created "$name" and added "${widget.movieTitle}"',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }}
