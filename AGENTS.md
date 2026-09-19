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
