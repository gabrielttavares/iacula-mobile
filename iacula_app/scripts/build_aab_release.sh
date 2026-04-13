#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_DIR="$PROJECT_DIR/android"
KEY_PROPERTIES="$ANDROID_DIR/key.properties"
ARTIFACT="$PROJECT_DIR/build/app/outputs/bundle/release/app-release.aab"

cd "$PROJECT_DIR"

echo "==> Iacula Android release build (.aab)"

if ! command -v flutter >/dev/null 2>&1; then
  echo "ERROR: flutter not found in PATH."
  exit 1
fi

if [[ ! -f "$KEY_PROPERTIES" ]]; then
  cat <<'EOF'
ERROR: Missing android/key.properties
Create it with:
  storePassword=...
  keyPassword=...
  keyAlias=...
  storeFile=...   # path relative to android/ (recommended) or absolute
EOF
  exit 1
fi

# Parse key.properties safely.
store_password=""
key_password=""
key_alias=""
store_file=""
while IFS='=' read -r k v; do
  [[ -z "${k// }" ]] && continue
  [[ "$k" =~ ^[[:space:]]*# ]] && continue
  k="$(echo "$k" | xargs)"
  v="$(echo "$v" | sed 's/^[[:space:]]*//')"
  case "$k" in
    storePassword) store_password="$v" ;;
    keyPassword) key_password="$v" ;;
    keyAlias) key_alias="$v" ;;
    storeFile) store_file="$v" ;;
  esac
done < "$KEY_PROPERTIES"

if [[ -z "$store_password" || -z "$key_password" || -z "$key_alias" || -z "$store_file" ]]; then
  echo "ERROR: android/key.properties is missing one or more required keys (storePassword, keyPassword, keyAlias, storeFile)."
  exit 1
fi

if [[ "$store_file" = /* ]]; then
  keystore_path="$store_file"
else
  keystore_path="$ANDROID_DIR/$store_file"
fi

if [[ ! -f "$keystore_path" ]]; then
  echo "ERROR: keystore file not found: $keystore_path"
  exit 1
fi

echo "==> Using keystore: $keystore_path"

# Show Java in use.
echo "==> Java version"
java -version 2>&1 | head -n 2 || true

echo "==> flutter pub get"
flutter pub get

echo "==> flutter build appbundle --release"
flutter build appbundle --release

if [[ ! -f "$ARTIFACT" ]]; then
  echo "ERROR: Build finished but artifact not found at: $ARTIFACT"
  exit 1
fi

echo ""
echo "SUCCESS: AAB generated"
echo "$ARTIFACT"
ls -lh "$ARTIFACT"
