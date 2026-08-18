# Offline maps

Offline maps are a provider configuration, not a bulk cache of OSM public raster tiles. `MapProvider` is intentionally unconfigured in this repository until a provider that permits offline use is selected.

For production, choose a MapLibre-compatible vector-tile provider or self-hosted/openly licensed packs whose license expressly allows your distribution and offline downloads. Store the provider's pack identifier, region bounds/style version, download time and expiry in `saved_offline_regions`; then expose an in-app download/delete control. Use `OFFLINE_MAP_STYLE_URL` for a non-secret style URL if applicable and include required attribution in the map screen.

Do not bulk-download, scrape, or create an offline archive from `tile.openstreetmap.org`. The current Flutter map screen is a safety-zone visualization, not a substitute for an offline map implementation. This explicit boundary avoids pretending that a demo map is a legal offline-map provider.

