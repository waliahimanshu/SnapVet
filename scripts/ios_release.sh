#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IOS_DIR="$ROOT_DIR/iosApp"
PROJECT_PATH="$IOS_DIR/iosApp.xcodeproj"
SCHEME="iosApp"
CONFIGURATION="Release"
TEAM_ID_DEFAULT="SD7657Z4F3"
BUILD_DIR="$IOS_DIR/build/ios"
ARCHIVE_PATH="$BUILD_DIR/SnapVet.xcarchive"
EXPORT_PATH="$BUILD_DIR/export"
EXPORT_OPTIONS_PLIST="$BUILD_DIR/ExportOptions.plist"
IPA_PATH="$EXPORT_PATH/SnapVet.ipa"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: required command '$1' not found."
    exit 1
  fi
}

prompt_default() {
  local prompt="$1"
  local default="$2"
  local value
  read -r -p "$prompt [$default]: " value
  if [[ -z "${value// }" ]]; then
    echo "$default"
  else
    echo "$value"
  fi
}

prompt_required() {
  local prompt="$1"
  local value
  while true; do
    read -r -p "$prompt: " value
    if [[ -n "${value// }" ]]; then
      echo "$value"
      return
    fi
    echo "Value is required."
  done
}

prompt_secret_required() {
  local prompt="$1"
  local value
  while true; do
    read -r -s -p "$prompt: " value
    echo
    if [[ -n "${value// }" ]]; then
      echo "$value"
      return
    fi
    echo "Value is required."
  done
}

main() {
  require_cmd xcodebuild
  require_cmd xcrun

  if [[ ! -d "$PROJECT_PATH" ]]; then
    echo "Error: Xcode project not found at $PROJECT_PATH"
    exit 1
  fi

  echo "SnapVet iOS Release (Archive -> Export -> Upload)"
  echo

  local team_id
  local auth_choice
  local api_key
  local api_issuer
  local apple_id
  local app_password

  team_id="$(prompt_default "Apple Team ID" "$TEAM_ID_DEFAULT")"

  echo
  echo "Upload authentication method:"
  echo "1) App Store Connect API Key (recommended)"
  echo "2) Apple ID + app-specific password"
  while true; do
    read -r -p "Choose 1 or 2 [1]: " auth_choice
    auth_choice="${auth_choice:-1}"
    if [[ "$auth_choice" == "1" || "$auth_choice" == "2" ]]; then
      break
    fi
    echo "Please choose 1 or 2."
  done

  if [[ "$auth_choice" == "1" ]]; then
    api_key="$(prompt_required "ASC API Key ID")"
    api_issuer="$(prompt_required "ASC API Issuer ID")"
  else
    apple_id="$(prompt_required "Apple ID email")"
    app_password="$(prompt_secret_required "App-specific password")"
  fi

  echo
  echo "Preparing build directories..."
  rm -rf "$ARCHIVE_PATH" "$EXPORT_PATH"
  mkdir -p "$BUILD_DIR"

  cat >"$EXPORT_OPTIONS_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>app-store</string>
  <key>signingStyle</key>
  <string>automatic</string>
  <key>teamID</key>
  <string>$team_id</string>
  <key>destination</key>
  <string>export</string>
</dict>
</plist>
EOF

  echo "Archiving iOS app..."
  xcodebuild \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination "generic/platform=iOS" \
    -archivePath "$ARCHIVE_PATH" \
    archive

  echo
  echo "Exporting IPA..."
  xcodebuild \
    -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS_PLIST" \
    -exportPath "$EXPORT_PATH"

  if [[ ! -f "$IPA_PATH" ]]; then
    echo "Error: IPA not found at $IPA_PATH"
    exit 1
  fi

  echo
  echo "Uploading to App Store Connect..."
  if [[ "$auth_choice" == "1" ]]; then
    xcrun altool --upload-app \
      -f "$IPA_PATH" \
      -t ios \
      --apiKey "$api_key" \
      --apiIssuer "$api_issuer"
  else
    xcrun altool --upload-app \
      -f "$IPA_PATH" \
      -t ios \
      -u "$apple_id" \
      -p "$app_password"
  fi

  echo
  echo "Done."
  echo "Archive: $ARCHIVE_PATH"
  echo "IPA: $IPA_PATH"
}

main "$@"
