# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [1.0.0] - 2026-11-01

### Added
- `ScottUk::Cinema.all` and `ScottUk::Cinema.new(id)` for Scott Cinemas' six venues, keyed by feed code, with names, addresses and feed codes from the website's cinema and API pages and coordinates from its cinema finder.
- `ScottUk::Performance.at(id, from:, to:)`, from the venue's public JSON feed, which holds every advertised date, with booking links, variants from the feed's flags, film years from titles and Exmouth Film Festival screenings.
- Fixtures trimmed from a live feed, a live shape test that checks real responses without storing them, and GitHub Actions CI and release workflows.
