@AGENTS.md

Compatible heavy committed-source checks prefer the gaming PC through `remote-run.py`, which handles bounded wake/connect automatically. Follow AGENTS.md for runtime/data exceptions, native checks and matching-result reuse. Do not ask for PC availability each time or silently fall back to the Mini.

## Claude Code

- `xcodebuild` may fail at package resolution if the shared SwiftPM artifact cache is stale ("already exists in file system"); pass `-clonedSourcePackagesDirPath` under `build/` as in `docs/OPERATIONS.md` rather than clearing global caches.
