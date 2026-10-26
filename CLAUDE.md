@AGENTS.md

Validation scope, shared capacity and remote execution follow AGENTS.md. Command examples below do not require a full-suite rerun for every edit.

## Claude Code

- `xcodebuild` may fail at package resolution if the shared SwiftPM artifact cache is stale ("already exists in file system"); pass `-clonedSourcePackagesDirPath` under `build/` as in `docs/OPERATIONS.md` rather than clearing global caches.
