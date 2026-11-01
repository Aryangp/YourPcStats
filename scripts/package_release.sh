#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:-1.0.0}"
APP_NAME="YourPcStats"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="${PROJECT_DIR}/dist"
BUILD_DIR="${PROJECT_DIR}/build_release"
STAGING_DIR="${PROJECT_DIR}/staging"

echo "========================================="
echo "Packaging ${APP_NAME} v${VERSION} for Release"
echo "========================================="

rm -rf "${DIST_DIR}" "${BUILD_DIR}" "${STAGING_DIR}"
mkdir -p "${DIST_DIR}" "${STAGING_DIR}"

echo "==> Building Release target with xcodebuild..."
xcodebuild -project "${PROJECT_DIR}/${APP_NAME}.xcodeproj" \
  -scheme "${APP_NAME}" \
  -configuration Release \
  -destination "generic/platform=macOS" \
  -derivedDataPath "${BUILD_DIR}" \
  MARKETING_VERSION="${VERSION}" \
  CURRENT_PROJECT_VERSION="${VERSION}" \
  clean build > /dev/null

BUILT_APP="${BUILD_DIR}/Build/Products/Release/${APP_NAME}.app"

if [[ ! -d "${BUILT_APP}" ]]; then
  echo "Error: Built app not found at ${BUILT_APP}"
  exit 1
fi

echo "==> Copying application to staging..."
cp -R "${BUILT_APP}" "${STAGING_DIR}/"

# Re-sign ad-hoc so it runs universally without development profile restrictions
echo "==> Ad-hoc signing binary for universal distribution..."
codesign --force --deep --sign - "${STAGING_DIR}/${APP_NAME}.app"

echo "==> Creating ZIP archive..."
ZIP_NAME="${APP_NAME}-${VERSION}.zip"
ditto -c -k --sequesterRsrc --keepParent "${STAGING_DIR}/${APP_NAME}.app" "${DIST_DIR}/${ZIP_NAME}"

echo "==> Creating DMG disk image..."
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
hdiutil create -volname "${APP_NAME}" -srcfolder "${STAGING_DIR}" -ov -format UDZO "${DIST_DIR}/${DMG_NAME}" > /dev/null

# Clean staging and build artifacts
rm -rf "${STAGING_DIR}" "${BUILD_DIR}"

ZIP_SHA256=$(shasum -a 256 "${DIST_DIR}/${ZIP_NAME}" | awk '{print $1}')
DMG_SHA256=$(shasum -a 256 "${DIST_DIR}/${DMG_NAME}" | awk '{print $1}')

echo ""
echo "========================================="
echo "Packaging Complete!"
echo "Artifacts created in: ${DIST_DIR}"
echo ""
echo "ZIP: ${ZIP_NAME}"
echo "SHA256: ${ZIP_SHA256}"
echo ""
echo "DMG: ${DMG_NAME}"
echo "SHA256: ${DMG_SHA256}"
echo "========================================="
