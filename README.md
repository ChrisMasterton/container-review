# Container Review

Container Review is a small native macOS utility for inspecting local Docker
containers. It is built with SwiftUI and is especially handy on machines where
Docker runs through Colima instead of Docker Desktop.

The app gives you a lightweight desktop view of what is running, which project
or Compose service a container belongs to, the ports it exposes, and recent
logs for the selected container.

## Features

- Refreshes the local container list every 4 seconds.
- Shows container name, image, state, status, uptime, ports, and Compose labels.
- Displays richer metadata from `docker inspect` when you select a container.
- Shows bounded logs with `docker logs --tail <N> --timestamps`.
- Keeps log following off by default; when enabled, the selected container's log
  tail refreshes every 2 seconds.
- Opens mapped HTTP ports in the browser when Docker reports host bindings.
- Stops only the selected container by calling `docker stop <container-id>`.

## Requirements

- macOS 14 or newer.
- Swift 6 toolchain.
- Docker CLI available locally.
- Optional: Colima, if you use Colima as the Docker backend.

Container Review searches common Homebrew Docker and Colima paths first, then
falls back to `env docker` and `env colima`.

## Run From Source

```bash
swift run
```

Or use the helper script:

```bash
./run.sh
```

## Download A Release

Download the latest `ContainerReview-*-macOS.zip` from the
[GitHub releases page](https://github.com/ChrisMasterton/container-review/releases),
unzip it, and move `Container Review.app` wherever you keep local apps.

The packaged app is currently unsigned and not notarized. macOS may ask you to
confirm that you want to open it. You can also build from source if you prefer
to run a local build.

## Build A macOS App Bundle

```bash
./build-app.sh
open ".build/Container Review.app"
```

The build script compiles the release executable, generates a native app icon,
and writes a clickable `.app` bundle to `.build/Container Review.app`.

To create a release zip locally:

```bash
./package-release.sh 0.1.0
```

This writes `dist/ContainerReview-0.1.0-macOS.zip` and a matching SHA-256 file.

## Safety And Privacy

Container Review is local-only. It does not send container information anywhere.
It shells out to the local Docker CLI for container lists, inspection data, logs,
and stop actions.

The destructive action in the UI is scoped to the currently selected container:
stopping a container calls `docker stop` with that container's ID.

## Development

Useful commands:

```bash
swift build
swift run
./build-app.sh
./package-release.sh 0.1.0
```

The generated build products live under `.build/` and are intentionally ignored
by git. Local release zips live under `dist/`, which is also ignored.

## License

MIT No Attribution. See [LICENSE](LICENSE).
