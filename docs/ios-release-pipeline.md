# iOS Release Pipeline (TestFlight -> App Store)

This project uses a two-step iOS release pipeline:

1. Upload a signed build to TestFlight.
2. Manually submit that uploaded build to App Store review.

## Workflows

- `ios-testflight.yml`
  - Trigger: tag push `ios/v*` or manual dispatch.
  - Purpose: build and upload iOS release build to TestFlight.
  - GitHub Environment: `testflight`.

- `ios-appstore-submit.yml`
  - Trigger: manual dispatch only.
  - Inputs: `app_version`, `build_number`.
  - Purpose: submit an already-uploaded TestFlight build to App Store review.
  - GitHub Environment: `appstore`.

## Signing and Auth

- Code signing is managed with `fastlane match` (`appstore`, read-only in CI).
- App Store Connect auth uses API key (`ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_API_KEY_P8`).

## Required GitHub Secrets

Configure these in both `testflight` and `appstore` environments (unless noted):

- `ASC_KEY_ID`
- `ASC_ISSUER_ID`
- `ASC_API_KEY_P8` (raw `.p8` content)
- `MATCH_GIT_URL`
- `MATCH_PASSWORD`
- `MATCH_GIT_BASIC_AUTHORIZATION` (or equivalent credentials for match repo)
- `APPLE_TEAM_ID`
- `APP_BUNDLE_ID`
- `APPSTORE_APPLE_ID` (numeric App Store Connect app id; required for submit)

Optional:

- `MATCH_GIT_BRANCH`

## Fastlane Lanes

Located in `iosApp/fastlane/Fastfile`:

- `beta`
  - Sync signing (`match`, readonly)
  - Increment build number from `GITHUB_RUN_NUMBER` when available
  - Build/archive for App Store distribution
  - Upload to TestFlight

- `submit`
  - Requires `app_version` and `build_number`
  - Submits existing build to App Store review
  - Binary-only automation (`skip_binary_upload: true`, metadata/screenshots skipped)

## Operational Flow

### 1) TestFlight upload

- Push release tag, e.g. `ios/v1.0.0` (or run workflow manually).
- Wait for `ios-testflight.yml` to succeed.
- Verify the uploaded build appears in App Store Connect -> TestFlight.

### 2) App Store submission

- Start `ios-appstore-submit.yml` manually.
- Provide:
  - `app_version` (e.g. `1.0`)
  - `build_number` (e.g. `42`)
- Confirm workflow succeeds and build status moves to review queue.

## Notes

- This pipeline does not auto-release after review approval (`automatic_release: false`).
- Metadata/screenshots are managed in App Store Connect UI.
- Keep `AGENTS.md` and `CLAUDE.md` mirrored when release process changes.
