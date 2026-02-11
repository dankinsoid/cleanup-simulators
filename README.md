# Cleanup Simulators

A macOS app and CLI tool for managing Xcode simulators and reclaiming disk space.

- Delete unavailable/orphaned simulators
- Clear Preview Simulators, IB Support, and Simulator Caches
- Boot, shutdown, reboot, and launch simulators
- One-command auto-cleanup

## Install

### Homebrew

```bash
brew tap dankinsoid/cleanup-simulators https://github.com/dankinsoid/cleanup-simulators
brew install --cask cleanup-simulators
```

### Download

Grab the latest DMG from [Releases](https://github.com/dankinsoid/cleanup-simulators/releases/latest).

### CLI (`simclean`)

The CLI tool is included in the app bundle:

```bash
alias simclean="/Applications/CleanupSimulators.app/Contents/MacOS/simclean"
```

Usage:

```
simclean list              # List simulators
simclean storage           # Show storage breakdown
simclean auto-clean        # Clean everything at once
simclean delete <id>       # Delete a specific simulator
simclean delete-unavailable # Remove orphaned simulators
```

Run `simclean --help` for all commands.

## Requirements

macOS 14.0+

## License

MIT
