# Container Review

Small native macOS utility for keeping track of local Docker containers, especially when Docker is backed by Colima instead of Docker Desktop.

## Run

```bash
swift run
```

Or use the helper:

```bash
./run.sh
```

To build a clickable app bundle:

```bash
./build-app.sh
open ".build/Container Review.app"
```

The app bundle includes a native Dock/Finder icon generated during the build.

## Behavior

- The sidebar refreshes `docker ps` every 4 seconds.
- Selecting a container runs `docker inspect` for richer metadata.
- Logs are bounded with `docker logs --tail <N> --timestamps`.
- Log following is off by default. When enabled, the selected container's bounded tail refreshes every 2 seconds.
- Stopping a container calls `docker stop <container-id>` only for the selected container.

The app searches common Homebrew Docker and Colima paths first, then falls back to `env docker` and `env colima`.
