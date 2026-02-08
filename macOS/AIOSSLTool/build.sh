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

echo -e "${BLUE}📦 Step 2: Checking for Xcode project...${NC}"
if [ ! -f "AIOSSLTool.xcodeproj/project.pbxproj" ]; then
    echo -e "${YELLOW}⚠️  Xcode project not found. Creating from Swift Package...${NC}"
    
    # Generate Xcode project from Package.swift
    swift package generate-xcodeproj
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Xcode project generated${NC}"
    else
        echo -e "${RED}❌ Failed to generate Xcode project${NC}"
        echo ""
        echo -e "${YELLOW}Manual setup required:${NC}"
        echo "1. Open Xcode"
        echo "2. File → New → Project"
        echo "3. Select 'App' under macOS"
        echo "4. Product Name: AIOSSLTool"
        echo "5. Interface: SwiftUI"
        echo "6. Add all .swift files to the project"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Xcode project found${NC}"
fi
echo ""

echo -e "${BLUE}📦 Step 3: Building...${NC}"
BUILD_TYPE="${1:-debug}"

if [ "$BUILD_TYPE" == "release" ]; then
    echo "Building Release configuration..."
    xcodebuild -project AIOSSLTool.xcodeproj \
               -scheme AIOSSLTool \
               -configuration Release \
               -derivedDataPath .build \
               CODE_SIGN_IDENTITY="-" \
               CODE_SIGNING_REQUIRED=NO \
               CODE_SIGNING_ALLOWED=NO
else
    echo "Building Debug configuration..."
    xcodebuild -project AIOSSLTool.xcodeproj \
               -scheme AIOSSLTool \
               -configuration Debug \
               -derivedDataPath .build \
               CODE_SIGN_IDENTITY="-" \
               CODE_SIGNING_REQUIRED=NO \
               CODE_SIGNING_ALLOWED=NO
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Build successful${NC}"
    echo ""
    echo -e "${GREEN}🎉 Build Complete!${NC}"
    echo ""
    echo -e "${BLUE}To run the app:${NC}"
    echo "  open .build/Build/Products/${BUILD_TYPE}/AIOSSLTool.app"
    echo ""
    echo -e "${BLUE}Or open in Xcode:${NC}"
    echo "  open AIOSSLTool.xcodeproj"
else
    echo -e "${RED}❌ Build failed${NC}"
    echo ""
    echo -e "${YELLOW}Troubleshooting:${NC}"
    echo "1. Open the project in Xcode: open AIOSSLTool.xcodeproj"
    echo "2. Select your development team in Signing & Capabilities"
    echo "3. Build with: ⌘B"
    exit 1
fi
