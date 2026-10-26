# Robert Compass

iOS orienteering game (teams walk GPS checkpoints, answer questions, live leaderboard) built for Robert College in 2023 and rebuilt in September 2026 to run entirely on the free Firebase Spark plan. Status: active, version 3.0 build 34. Stack: Swift 5 / UIKit / MapKit (iOS 15+), Firebase Auth + Firestore + App Check via SwiftPM, Node 22 organizer scripts in `backend/`.

Deeper docs: `README.md` (overview, setup) and `docs/OPERATIONS.md` (emulators, Firebase project, course import format, data/authorization model, verification record). Link to them rather than copying.

## Repo map

- `Radventure/` - app sources. The Xcode project, targets, and bundle ID (`com.CanDuru.Radventure`) keep the original `Radventure` name so the app ships as an update to the existing App Store listing. Do not rename them.
  - `Services/Backend.swift` - Firebase configuration, emulator switch, `Backend.call(name, data)` entry point.
  - `Services/FirebaseGameService.swift` - every gameplay/account operation (`syncProfile`, `createTeam`, `joinTeam`, `startGame`, `submitAnswer`, `refreshSession`, `leaveTeam`, `deleteAccount`) as Firestore transactions.
  - `Services/GameStore.swift` - `@MainActor ObservableObject` holding the player's live session; controllers share it.
  - `Models/GameModels.swift` - decoding of Firestore documents; `Login/`, `Home/`, `Score Board/`, `Profile/` - UIKit screens; `Helper/` - App Check, shared UI, location, rules screen.
  - `Configuration/` - holds the git-ignored `FirebaseConfig.plist`.
- `RadventureTests/` - model/deadline unit tests plus two opt-in physical-device tests (`testLiveGameplayOnPhysicalDevice`, `testLiveAppAttestOnPhysicalDevice`). `RadventureUITests/` - setup-screen and full team-activity scenarios.
- `firestore.spark.rules`, `firestore.indexes.json`, `firebase.json` - the whole server side. There are no Cloud Functions.
- `backend/` - `src/domain.js` (pure validation/normalization helpers), `scripts/` (`seed.js`, `prepare-ui.js`, `live-smoke.js`, `device-fixture.js`, `owner-credentials.js`), `test/domain.test.js` (unit), `test/spark.test.js` (rules tests, needs emulators).
- `Extra Files/`, `build/`, `courses/*.private.json` - git-ignored local-only folders (App Store assets; CLI auth and verification evidence; course answers).

## Commands

Backend (Node 22, run from anywhere):

```sh
npm --prefix backend ci
npm --prefix backend run check        # node --check on sources/scripts
npm --prefix backend test             # domain unit tests, no deps needed
backend/node_modules/.bin/firebase emulators:start --config firebase.json --project demo-robert-compass
FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099 npm --prefix backend run test:integration
node backend/scripts/seed.js          # no args: seeds only the local demo emulator
node backend/scripts/prepare-ui.js    # UI-test fixtures (emulator only)
```

Emulators bind 127.0.0.1: Auth 9099, Firestore 8080, UI 4000. Integration tests need Java 21+.

iOS: open `Radventure.xcodeproj`. Schemes: `Radventure` and `Radventure Local` (passes Debug-only `--emulator`). The full simulator `xcodebuild ... test` invocation (derived-data paths, `CODE_SIGN_IDENTITY=-`, location setup via `xcrun simctl`) is in `docs/OPERATIONS.md#local-backend-and-tests`. Use ad hoc signing: `CODE_SIGNING_ALLOWED=NO` breaks Firebase Auth's simulator keychain access.

Deploy (live, owner only, do not run without explicit instruction): rules/indexes via `backend/node_modules/.bin/firebase deploy --config firebase.json --project robert-compass --only firestore:rules,firestore:indexes` (with `XDG_CONFIG_HOME` pointing at `build/firebase-cli`, see OPERATIONS.md); app via Xcode archive. There is no CI.

## Rules and gotchas

- Stay on Spark. Never add Cloud Functions, attach billing, enable Blaze, or add paid services to work around quotas.
- `.firebaserc` defaults to the disposable `demo-robert-compass`; live commands must target `robert-compass` explicitly. `seed.js` refuses a live project while `FIRESTORE_EMULATOR_HOST` is set, only validates a live project unless `--apply` is passed, and never overwrites an existing course ID.
- Every client write must be a transaction that `firestore.spark.rules` validates (exact score delta, completed checkpoint, leaderboard projection together via `getAfter()`). A change to a write in `FirebaseGameService.swift` almost always needs a matching rules change and a `backend/test/spark.test.js` case.
- Answers and entry-code hashes live only in server-only `privateGames`; clients must never be able to read them. Trusted time comes from server timestamps, not the device clock.
- Never commit `FirebaseConfig.plist`, `GoogleService-Info.plist`, `Keys.plist`, `courses/*.private.json` (live course answers), service-account keys, or CLI tokens. `Backend.configure()` rejects the retired `radventure-robert` project and configs for other bundle IDs; keep that guard.
- Do not delete the ignored `build/` folder wholesale: it holds local Firebase CLI authorization (`build/firebase-cli`) and verification evidence.
- CocoaPods is gone; do not run `pod install` or reintroduce `Pods/`. Firebase Apple SDK is pinned to an exact version (12.19.1) in SwiftPM.
- Emulator/demo options in `Backend.swift` are `#if DEBUG` only; Release ignores `--emulator` and `--unconfigured`.
- After Firestore App Check enforcement, `live-smoke.js` is no longer the live check; use the signed iPhone app. Physical-device test procedure is in `docs/OPERATIONS.md#repeating-the-device-test`.
- Conventions: Swift user-facing errors via `GameWriteError("...")` and UI state on `@MainActor`; backend JS is ES modules validating with `ensure(condition, code, message)` from `src/domain.js`.

## Validation placement and reuse (owner update 2026-10-26)

- Follow the global Claude/Codex test policy and `~/Developer/personal/mac-mini/validation-economy/README.md` and `COVERAGE.md`. Focus first; full coverage only when the changed inputs require it. Docs-only policy edits need no application suite or deploy.
- Use `~/Developer/personal/mac-mini/validation-economy/remote-run.py` as the first choice for compatible heavy committed-source Python/Node checks. It defaults to `gaming-pc` and handles connection and bounded Wake-on-LAN automatically; call it directly without a separate online check or asking the owner each time. Match the pinned runtime and locked dependencies, bound actual workers, and preserve repo data-export restrictions. Never export credentials, production data, signing keys or uncommitted work.
- The PC pool shares eight CPU slots and 24 GiB across isolated jobs with zero test swap; retain automatic job cleanup, the 8 GiB package-cache budget and 128 GiB virtual-disk cap. Brain is an explicit secondary route (`--runner brain`) when compatible, capped at two CPUs and 4 GiB together. If the PC remains unavailable after bounded wake/connect, report the blocker; never silently start the same work on the Mini or replay an uncertain submitted job.
- Xcode, Swift, simulator, signing and device checks stay on the Mini. The PC Linux runner has no Apple toolchain; only compatible ancillary Python/Node checks are eligible.
- For work that must run on the Mini: manual heavy commands use `repo-run.py --repo <absolute checkout> --profile <profile> -- <command>` from the shared helper; choose from native for the actual tool. Tiny syntax checks need no reservation. Bound tool workers and reserve separate heavy phases.
- Reuse only supported receipts with matching source, coverage, dependencies, runtime/platform and relevant environment. Preserve passed unaffected batches; count remote results only when the owning gate aggregates them. Receipts do not replace required build artifacts or OS/device/browser proof. Split or offload an impossible reservation instead of waiting indefinitely; only stop your own obsolete jobs. Existing gates need explicit remote routing and matching-result aggregation; this instruction does not automatically move unintegrated commands.
