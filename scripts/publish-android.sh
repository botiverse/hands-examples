#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: publish-android.sh --app SLUG --apk FILE --channel CHANNEL \
  --version-name VERSION --version-code CODE [--changelog FILE] [--publish]

Required environment:
  HANDS_BEARER_TOKEN  App-scoped publisher deploy token.

Optional environment:
  HANDS_API           Defaults to https://hands.build.
  HANDS_CLI_VERSION   Defaults to 0.5.1.
USAGE
}

app=""
apk=""
channel="preview"
version_name=""
version_code=""
changelog=""
draft=1

while [ "$#" -gt 0 ]; do
  case "$1" in
    --app) app="$2"; shift 2 ;;
    --apk) apk="$2"; shift 2 ;;
    --channel) channel="$2"; shift 2 ;;
    --version-name) version_name="$2"; shift 2 ;;
    --version-code) version_code="$2"; shift 2 ;;
    --changelog) changelog="$2"; shift 2 ;;
    --publish) draft=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

: "${HANDS_BEARER_TOKEN:?Set HANDS_BEARER_TOKEN to an app-scoped publisher token}"
test -n "$app" || { echo "--app is required" >&2; exit 2; }
test -s "$apk" || { echo "--apk must point to a non-empty file" >&2; exit 2; }
test -n "$version_name" || { echo "--version-name is required" >&2; exit 2; }
test -n "$version_code" || { echo "--version-code is required" >&2; exit 2; }

export HANDS_API="${HANDS_API:-https://hands.build}"
cli_version="${HANDS_CLI_VERSION:-0.5.1}"

if ! command -v hands >/dev/null 2>&1; then
  npm install --global "@botiverse/hands-cli@${cli_version}"
fi

args=(
  builds publish-android "$app"
  --apk "$apk"
  --channel "$channel"
  --version-name "$version_name"
  --version-code "$version_code"
)
test -z "$changelog" || args+=(--changelog-file "$changelog")
test "$draft" -eq 0 || args+=(--draft)

hands "${args[@]}"

