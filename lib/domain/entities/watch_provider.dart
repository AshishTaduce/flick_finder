class WatchProvider {
  final int providerId;
  final String providerName;
  final String logoPath;
  final int displayPriority;

  const WatchProvider({
    required this.providerId,
    required this.providerName,
    required this.logoPath,
    required this.displayPriority,
  });

  String get fullLogoUrl => 'https://image.tmdb.org/t/p/w92$logoPath';
}

class WatchProviders {
  final String? link;
  final List<WatchProvider> flatrate;
  final List<WatchProvider> rent;
  final List<WatchProvider> buy;

  const WatchProviders({
    this.link,
    required this.flatrate,
    required this.rent,
    required this.buy,
  });

  bool get hasAnyProviders => flatrate.isNotEmpty || rent.isNotEmpty || buy.isNotEmpty;
}