#!/usr/bin/env bash
# Publish one platform's Electron installer to Hands from any CI.
# Run once per platform/arch.
# Env: HANDS_BEARER_TOKEN, HANDS_APP_SLUG, VERSION_NAME, VERSION_CODE,
#      PLATFORM (win32|darwin|linux), ARCH, METADATA_PATH (latest*.yml),
#      INSTALLER_PATH, optional BLOCKMAP_PATH, optional HANDS_CHANNEL.
set -euo pipefail
: "${HANDS_BEARER_TOKEN:?}" "${HANDS_APP_SLUG:?}" "${VERSION_NAME:?}" "${VERSION_CODE:?}"
: "${PLATFORM:?}" "${ARCH:?}" "${METADATA_PATH:?}" "${INSTALLER_PATH:?}"
npm install -g @botiverse/hands-cli >/dev/null
git log --no-merges --pretty='- %s' -15 > changelog.txt 2>/dev/null || echo "- release ${VERSION_NAME}" > changelog.txt
hands builds publish-electron "${HANDS_APP_SLUG}" \
  --channel "${HANDS_CHANNEL:-main}" \
  --version-name "${VERSION_NAME}" \
  --version-code "${VERSION_CODE}" \
  --platform "${PLATFORM}" \
  --arch "${ARCH}" \
  --metadata "${METADATA_PATH}" \
  --installer "${INSTALLER_PATH}" \
  ${BLOCKMAP_PATH:+--blockmap "${BLOCKMAP_PATH}"} \
  --changelog-file ./changelog.txt \
  --draft
