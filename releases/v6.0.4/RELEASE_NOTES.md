# AIO SSL Tool v6.0.4

## What's New

### 🎉 Auto-Update System Fully Operational

Version 6.0.4 completes the implementation of the Sparkle-based auto-update system. The app now automatically checks for updates and can install them with a single click.

## Bug Fixes

- ✅ **Fixed critical crash:** Resolved "Library not loaded: @rpath/Sparkle.framework" crash on launch
- 🔧 **Framework loading:** Added proper rpath configuration using install_name_tool
- 🎯 **Update button:** "Check for Updates" button now fully functional and clickable

## Improvements

- ⚡️ Enhanced framework embedding process in build script
- 🔐 Improved code signing sequence (framework signed before app bundle)
- 📦 Sparkle.framework now properly embedded in app bundle
- 🔄 Background update checks enabled (every 24 hours)
- 🔔 Update notifications working correctly

## Technical Changes

- Added `@executable_path/../Frameworks` to rpath
- Updated build.sh to handle framework embedding and signing
- Re-enabled all Sparkle API calls in UpdaterViewModel
- Updated Package.swift with Sparkle 2.8.1 dependency

## Installation

Download `AIOSSLTool-macOS-v6.0.4.dmg` and drag "AIO SSL Tool" to your Applications folder.

**Note:** On first launch, right-click the app and select "Open" to bypass Gatekeeper (ad-hoc signed).

## Upgrading

If you have automatic updates enabled, you'll be notified automatically. Otherwise, download and install this version to replace your existing installation.

---

**Full Changelog**: https://github.com/cmdlabtech/AIO-SSL-Tool/compare/v6.0.2...v6.0.4
