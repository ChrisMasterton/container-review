# Release Notes

## v0.1.1 - 2026-07-07

### Fixed

- Stopping a container now verifies Docker's post-stop state before reporting success.

### Improved

- Added the source install helper and moved app bundle builds under `scripts/`.
- Release packages now stamp the app bundle with the current release version from `VERSION`.
