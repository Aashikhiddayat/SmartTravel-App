/// Provider boundary for a legally licensed MapLibre-compatible offline map pack.
/// This app deliberately never fetches or caches tile.openstreetmap.org tiles.
abstract class MapProvider {
  bool get supportsOfflineRegions;
  Future<void> downloadRegion({required String regionName, required String styleUrl});
}

class UnconfiguredMapProvider implements MapProvider {
  @override
  bool get supportsOfflineRegions => false;
  @override
  Future<void> downloadRegion({required String regionName, required String styleUrl}) async {
    throw StateError('Configure a licensed MapLibre-compatible offline map provider before downloading a region.');
  }
}

