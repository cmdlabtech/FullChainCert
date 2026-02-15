#!/bin/bash

# Build script for AIO SSL Tool macOS app
# This script sets up and builds the Xcode project

set -e

echo "🔧 AIO SSL Tool - macOS Build Script"
echo "===================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "AIOSSLToolApp.swift" ]; then
    echo -e "${RED}❌ Error: Please run this script from the macOS/AIOSSLTool directory${NC}"
    exit 1
fi

echo -e "${BLUE}📦 Step 1: Checking Xcode installation...${NC}"
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Xcode is not installed. Please install Xcode from the App Store.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Xcode found${NC}"
echo ""

echo -e "${BLUE}📦 Step 2: Building with Swift Package Manager...${NC}"
BUILD_TYPE="${1:-release}"

if [ "$BUILD_TYPE" == "debug" ]; then
    echo "Building Debug configuration..."
    swift build -c debug
    BUILD_PATH=".build/debug"
else
    echo "Building Release configuration..."
    swift build -c release
    BUILD_PATH=".build/release"
fi

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Build successful${NC}"
echo ""

echo -e "${BLUE}📦 Step 4: Creating app bundle...${NC}"
APP_NAME="AIO SSL Tool"
APP_BUNDLE="${APP_NAME}.app"
EXECUTABLE_NAME="AIOSSLTool"

# Remove old app bundle if it exists
if [ -d "${APP_BUNDLE}" ]; then
    rm -rf "${APP_BUNDLE}"
fi

# Create app bundle structure
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# Copy executable
cp "${BUILD_PATH}/${EXECUTABLE_NAME}" "${APP_BUNDLE}/Contents/MacOS/"
chmod +x "${APP_BUNDLE}/Contents/MacOS/${EXECUTABLE_NAME}"

# Copy Info.plist
cp Info.plist "${APP_BUNDLE}/Contents/"

# Copy app icon if it exists
if [ -f "AppIcon.icns" ]; then
    cp AppIcon.icns "${APP_BUNDLE}/Contents/Resources/"
fi

echo -e "${GREEN}✓ App bundle created${NC}"
echo ""

echo -e "${BLUE}📦 Step 5: Embedding Sparkle framework...${NC}"
# Create Frameworks directory
mkdir -p "${APP_BUNDLE}/Contents/Frameworks"

# Find and copy Sparkle framework
SPARKLE_FRAMEWORK="${BUILD_PATH}/Sparkle.framework"
if [ -d "${SPARKLE_FRAMEWORK}" ]; then
    cp -R "${SPARKLE_FRAMEWORK}" "${APP_BUNDLE}/Contents/Frameworks/"
    echo -e "${GREEN}✓ Sparkle framework embedded${NC}"
else
    echo -e "${YELLOW}⚠️  Warning: Sparkle.framework not found at ${SPARKLE_FRAMEWORK}${NC}"
    echo -e "${YELLOW}   Checking alternative locations...${NC}"
    
    # Try to find it in the checkouts directory
    SPARKLE_CHECKOUT=$(find .build/checkouts -name "Sparkle.framework" -type d | head -n 1)
    if [ -n "${SPARKLE_CHECKOUT}" ]; then
        cp -R "${SPARKLE_CHECKOUT}" "${APP_BUNDLE}/Contents/Frameworks/"
        echo -e "${GREEN}✓ Sparkle framework embedded from checkouts${NC}"
    else
        echo -e "${YELLOW}⚠️  Warning: Sparkle.framework not found. Auto-update may not work.${NC}"
    fi
fi
echo ""

echo -e "${BLUE}📦 Step 6: Setting framework search path...${NC}"
# Add rpath so the executable can find Sparkle.framework
install_name_tool -add_rpath "@executable_path/../Frameworks" "${APP_BUNDLE}/Contents/MacOS/${EXECUTABLE_NAME}" 2>/dev/null || true
echo -e "${GREEN}✓ Framework search path configured${NC}"
echo ""

echo -e "${BLUE}📦 Step 7: Code signing...${NC}"
# Sign the framework first
if [ -d "${APP_BUNDLE}/Contents/Frameworks/Sparkle.framework" ]; then
    codesign --force --deep --sign - "${APP_BUNDLE}/Contents/Frameworks/Sparkle.framework"
fi

# Then sign the whole app bundle
codesign --force --deep --sign - "${APP_BUNDLE}"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ App signed successfully${NC}"
else
    echo -e "${YELLOW}⚠️  Warning: Code signing failed, but continuing...${NC}"
fi
echo ""

echo -e "${BLUE}📦 Step 8: Removing quarantine attributes...${NC}"
# Remove quarantine attribute that macOS adds
xattr -cr "${APP_BUNDLE}" 2>/dev/null || true
echo -e "${GREEN}✓ Quarantine attributes removed${NC}"
echo ""

echo -e "${GREEN}🎉 Build Complete!${NC}"
echo ""
echo -e "${BLUE}To run the app:${NC}"
echo "  open '${APP_BUNDLE}'"
echo ""
echo -e "${BLUE}Or from terminal:${NC}"
echo "  ./'${APP_BUNDLE}/Contents/MacOS/${EXECUTABLE_NAME}'"
echo ""
echo -e "${YELLOW}Note: If you still see the 'damaged' error:${NC}"
echo "  1. Right-click the app and select 'Open'"
echo "  2. Click 'Open' in the security dialog"
echo "  3. Or run: xattr -cr '${APP_BUNDLE}' && open '${APP_BUNDLE}'"
