# Mobi — Public transit departures for Garmin

A Connect IQ watch app that shows live public-transit departures on Garmin
devices. Data is provided by the open [transitous.org](https://transitous.org)
project (MOTIS backend), so coverage depends on what transitous aggregates
in your region.

## Features

- Up to 10 favorite stations configured in the Connect IQ app settings
- "Nearby stops" via the watch's acquired position
- Filters by transport mode (rail, bus, tram, etc.) via a short prefix syntax
- Real-time vs scheduled departure indicator (`|` vs `¦`)
- Compact paginated departure list with on-screen clock
- Glance view (where supported)
- Cached station IDs so repeated lookups don't re-geocode
- No separate phone companion app is required, favorite stops are configured in the Garmin Connect IQ app

## Supported devices

Declared in [`manifest.xml`](manifest.xml) (`<iq:products>`). Currently targets
all Garmin devices with API level `>=3.0.0`

## Configuration

Open the app's settings in the Garmin Connect mobile app or Connect IQ Store
and fill in `#1` … `#10` with station names.

### Station name syntax

Plain names work fine — they're geocoded against transitous station names:

```
Berlin Hauptbahnhof
King's Cross
```

You can also restrict departures to specific transport modes by prefixing the
name with letter codes separated by `+`. The prefix must be followed by a
single space:

```
S+U Berlin Hbf     # only S-Bahn and U-Bahn (subway) departures
R+S Frankfurt Hbf  # regional rail + S-Bahn
X King's Cross     # express trains only
```

Recognized letters (see `NameFilter.mc` and the bitmask in `Dep.initRequest`):

| Letter | Modes |
|--------|---------------------------------------------|
| `X`    | High-speed / long-distance / night rail     |
| `R`    | Regional rail (fast + standard)             |
| `S`    | Suburban rail (S-Bahn)                      |
| `U`    | Subway / metro (U-Bahn)                     |
| `T`    | Tram                                        |
| `B`    | Bus                                         |
| `C`    | Coach                                       |
| `F`    | Ferry                                       |

A prefix that isn't `Letter(+Letter)*` followed by a space is treated as part
of the station name, not a filter.

## Controls

| Input              | Action                                                        |
|--------------------|---------------------------------------------------------------|
| Menu / Up / Down   | Cycle through favorites (`@` = "stops near me")               |
| Select / Start     | Open the selected favorite or run the nearby-stops query      |
| Back               | Return to the menu                                            |
| Next / Prev page   | Page through departures                                       |
| Menu (in dep view) | Reset cached station ID/result-count for the current favorite |

The first menu entry `@` triggers a location one-shot to find nearby stops; the
result is cached for ~4 minutes (`Position.checkAndDeleteData`) to avoid
re-acquiring a fix on every press.

## Architecture

```
MobiApp                 Application entrypoint / lifecycle.
                        Owns the global $.stationsManager.

StationsManager         Source of truth for the list of stations + current
                        selection. Reads favorites from Properties, persists
                        resolved station IDs to Storage (key STATIONSCACHE).
                        Reconciles cached IDs with current settings on boot.

NameFilter              Parses the "S+U Name" prefix syntax into a name +
                        transport-mode bitmask.

Menu / MenuView         Top-level favorite picker.
StopView / Stop         Geocode lookup maps a name to one or more stop IDs.
Position (extends Stop) Location-based "stops near me" variant of Stop.
StationsSelector        Helper that holds the list of resolved stops and
                        the user's pick within it.
DepView / Dep           Departures view + request with optional mode filter, 
                        formats results.
PageManager             Pagination state for DepView.
BaseView                Shared view base: layout sizes, centered-text
                        "loading"/"error" overlay.
Tools                   Pure helpers (string, time, request headers).
MobiGlanceView          Glance-tile rendering.
```

### Request flow

```
Menu.onSelect
 └─> (favorite)        StopView + Stop.start()
      └─> /geocode      [stop candidates]
           └─> user picks via StationsSelector
                └─> DepView + Dep.start()
                     └─> /stoptimes  [departures]
 └─> (@ position)     StopView + Position.start()
      └─> getPosition (or cached)
           └─> /reverse-geocode  [nearby stops]
                └─> ... same as above
```

### Endpoints

All requests target `https://api.transitous.org`:

- `GET /api/v1/geocode` — name → stop candidates
- `GET /api/v1/reverse-geocode` — coords → nearby stop candidates
- `GET /api/v5/stoptimes` — stop ID → departures

### Persistence

Stored in `Application.Storage`:

| Key              | Owner             | Purpose                                              |
|------------------|-------------------|------------------------------------------------------|
| `stationsCache`  | `StationsManager` | Per-favorite `[name, id, products, nameCleaned, n]` |
| `lastPosition`   | `Position`        | Last coords `[lat, lon]`                        |
| `lastTime`       | `Position`        | Epoch seconds of last position fix                  |
| `lastData`       | `Position`        | Last "nearby stops" result                          |

Cache is invalidated when settings change (`MobiApp.onSettingsChanged` →
`StationsManager.clearCache`) and the position cache expires after ~240 s.

## Building

Requires the [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/)
and a developer key.

```sh
# Debug build for a simulator target
monkeyc -f monkey.jungle \
        -o bin/Mobi.prg \
        -y <path-to-developer_key> \
        -d fenix7_sim

# Run in the simulator
connectiq                          # start the simulator
monkeydo bin/Mobi.prg fenix7_sim
```

Replace `fenix7_sim` with any product ID listed in `manifest.xml`.

### Release build (`.iq` for the store)

```sh
monkeyc -f monkey.jungle \
        -o export/Mobi.iq \
        -y <path-to-developer_key> \
        -e -r
```

## Testing

Unit tests live in `source/Tests.mc` and use the Garmin
[`Test`](https://developer.garmin.com/connect-iq/api-docs/Toybox/Test.html)
framework. They're stripped from non-test builds via the `(:test)` annotation.

```sh
# Build with --unit-test then run with -t
monkeyc -f monkey.jungle \
        -o bin/Mobi-test.prg \
        -y <path-to-developer_key> \
        -d fenix7_sim \
        --unit-test

monkeydo bin/Mobi-test.prg fenix7_sim -t
```

Coverage focuses on pure logic in `Tools.mc`, `PageManager.mc`, and
`NameFilter.mc` — anything that doesn't need a `Dc`, `Storage`, or web mock.
View / IO code is not unit-tested.

## Project layout

```
manifest.xml               Garmin app manifest (id, products, permissions)
monkey.jungle              Build configuration
resources/
  properties.xml           User-facing settings (fav1..fav10)
  drawables/               Launcher icon
source/
  MobiApp.mc               AppBase entrypoint
  Menu.mc / MenuView.mc    Favorite picker
  StationsManager.mc       Favorites + cache
  NameFilter.mc            "S+U Name" prefix parser
  StationsSelector.mc      Selection state for stop candidates
  Stop.mc                  Geocode request
  Position.mc              Position-based geocode (extends Stop)
  StopView.mc              View for picking a stop
  Dep.mc / DepView.mc      Departures request + view
  PageManager.mc           Pagination state
  BaseView.mc              Shared view base
  MobiGlanceView.mc        Glance tile
  Tools.mc                 Helpers (string, time, headers)
  Tests.mc                 Unit tests ((:test) annotated)
```

## Data

Departure and geocoding data are provided by
[transitous.org](https://transitous.org). The app sends a `User-Agent` of
`Mobi for Garmin` on every request. Always respect transitous's usage policy.

## License

See [`LICENSE`](LICENSE).
