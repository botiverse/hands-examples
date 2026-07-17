#!/usr/bin/env bash
# Publish a signed Android APK to Hands from any CI.
# Env: HANDS_BEARER_TOKEN (deploy token), HANDS_APP_SLUG, APK_PATH,
#      VERSION_NAME, VERSION_CODE, optional HANDS_CHANNEL (default preview).
set -euo pipefail
: "${HANDS_BEARER_TOKEN:?}" "${HANDS_APP_SLUG:?}" "${APK_PATH:?}" "${VERSION_NAME:?}" "${VERSION_CODE:?}"
npm install -g @botiverse/hands-cli >/dev/null
git log --no-merges --pretty='- %s' -15 > changelog.txt 2>/dev/null || echo "- release ${VERSION_NAME}" > changelog.txt
hands builds publish-android "${HANDS_APP_SLUG}" \
  --apk "${APK_PATH}" \
  --channel "${HANDS_CHANNEL:-preview}" \
  --version-name "${VERSION_NAME}" \
  --version-code "${VERSION_CODE}" \
  --changelog-file ./changelog.txt \
  --draft
