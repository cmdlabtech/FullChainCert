# AIO SSL Tool - AI Agent Instructions

## Project Overview

Dual-platform SSL certificate management tool: **native Swift/SwiftUI macOS app** + **Python/CustomTkinter Windows app**. Builds complete certificate chains, generates CSRs, creates PFX files, and extracts private keys—all processed locally without external services.

## Architecture & Key Components

### macOS (Primary Focus)
- **Build System**: Swift Package Manager (`.swift build`), not Xcode projects
- **UI Pattern**: SwiftUI with MVVM - `SSLToolViewModel` is the single source of truth
- **Navigation**: `ContentView` uses `NavigationSplitView` with sidebar for: Home, Chain Builder, CSR Generator, Key Extractor, Settings
- **Certificate Operations**: Uses **macOS Security framework** (`import Security`), NOT OpenSSL - see `Utils/CertificateUtils.swift`
- **Auto-Updates**: Sparkle framework integration exists but is **currently disabled** (commented out in `Package.swift` and `UpdaterViewModel.swift`) due to SPM framework embedding issues

### Windows
- **Tech Stack**: Python 3 + CustomTkinter + cryptography library
- **Entry Point**: `windows/aio_ssl_tool.py`
- **Dependencies**: Listed in `windows/requirements.txt`

### Project Structure
```
macOS/AIOSSLTool/
├── AIOSSLToolApp.swift              # App entry, initializes UpdaterViewModel
├── ContentView.swift                # Main UI with sidebar navigation
├── ViewModels/
│   ├── SSLToolViewModel.swift       # Core business logic for cert operations
│   └── UpdaterViewModel.swift       # Auto-update state (Sparkle disabled)
├── Views/
│   ├── HomeView.swift               # Landing page with quick actions
│   ├── ChainBuilderView.swift       # Full chain creation interface
│   ├── CSRGenerationView.swift      # CSR + key generation
│   ├── ExtractPFXView.swift         # PFX key extraction
│   └── SettingsView.swift           # App settings + update UI
├── Utils/CertificateUtils.swift     # Security framework wrappers
├── Models/CSRDetails.swift          # CSR generation data model
└── Info.plist                       # Version, Sparkle config (SUFeedURL, SUPublicEDKey)
```

## Critical Developer Workflows

### Building macOS App
```bash
cd macOS/AIOSSLTool
./build.sh              # Builds, creates .app bundle, signs with ad-hoc signature
./build.sh debug        # Debug build (default is release)
```
**Output**: `AIO SSL Tool.app` in current directory

### Creating Releases
```bash
cd macOS/AIOSSLTool
./release.sh 6.0.3      # Full automation: version update, build, DMG, signature
```
**What it does**: Updates `Info.plist`, builds app, creates DMG in `../../releases/v6.0.3/`, generates appcast entry, creates release notes template

**Manual GitHub Release** (after release.sh):
```bash
gh release create v6.0.3 releases/v6.0.3/AIOSSLTool-macOS-v6.0.3.dmg \
  --title "v6.0.3" --notes-file releases/v6.0.3/RELEASE_NOTES.md
```

### Auto-Update System Setup (For Future Re-enablement)
```bash
cd macOS/AIOSSLTool
./generate_keys.sh      # Generates EdDSA keys for Sparkle signing
./verify_setup.sh       # Validates all auto-update configuration
```
See `macOS/AUTO_UPDATE_QUICKSTART.md` for complete setup (10 min process).

## Project-Specific Conventions

### Version Management
- **Two version numbers**: `CFBundleShortVersionString` (e.g., "6.0.2") and `CFBundleVersion` (e.g., "6") in `Info.plist`
- **Update both** when releasing: `release.sh` automates this
- **README links**: Update download URLs in root `README.md` after each macOS release

### Certificate Handling
- **Chain building**: Fetches intermediate certs from AIA extensions automatically
- **PFX creation**: Always includes full chain (not just leaf cert)
- **Key formats**: Supports PEM for keys, DER/PEM for certs, PKCS#12 for PFX
- **Security**: All operations use macOS Security framework APIs, not command-line tools

### SwiftUI State Management
- `@StateObject` for ViewModels in parent views only
- `@Published` properties for UI-bound state in ViewModels
- `@MainActor` on ViewModels to ensure UI updates on main thread
- File pickers use `NSOpenPanel`/`NSSavePanel` (AppKit), not SwiftUI's `.fileImporter`

### Build & Release Patterns
- **No Xcode projects committed** - uses SPM exclusively
- **Ad-hoc signing** for local builds (unsigned, requires right-click → Open)
- **DMG distribution** via GitHub Releases (in `releases/vX.Y.Z/` directories)
- **Appcast feed** at `appcast.xml` (root level) for Sparkle updates

## Known Issues & TODOs

### Sparkle Framework Embedding
**Problem**: SPM doesn't automatically embed dynamic frameworks. Sparkle code is written but disabled.

**Current State**:
- `Package.swift`: Sparkle dependency commented out with `// TODO: Re-enable after setting up proper Xcode project`
- `UpdaterViewModel.swift`: All Sparkle API calls wrapped in `/* TODO: Re-enable */` comments
- `AIOSSLToolApp.swift`: UpdaterViewModel initialization exists but doesn't call Sparkle
- **UI is complete and functional** in Settings > Updates (shows version, toggles, check button)

**Solution Path**: Convert to proper Xcode project with framework embedding, or use Xcodeproj-free embedding solution. See `macOS/AIOSSLTool/AUTO_UPDATE_IMPLEMENTATION.md` for details.

### Testing Locally
- App is **unsigned** - users must bypass Gatekeeper (right-click → Open)
- For testing updates: Use local server (`python3 -m http.server 8000`) with modified `SUFeedURL`

## Integration Points

- **GitHub Releases**: Hosts DMG downloads and release metadata
- **GitHub Raw URLs**: Serves `appcast.xml` feed for Sparkle (when re-enabled)
- **AIA Extensions**: Automatically fetches intermediate CA certs from certificate URLs
- **macOS Keychain**: Can access system certificates via Security framework

## When Modifying The Project

### Adding New Features to macOS App
1. Create View in `Views/` directory
2. Add ViewModel if complex state needed (follows `SSLToolViewModel` pattern)
3. Register in `ContentView.Tool` enum for sidebar navigation
4. Update `Package.swift` sources list if new files added

### Updating Auto-Update System
1. **Don't uncomment Sparkle code** until framework embedding is solved
2. UI changes in `SettingsView` are safe (no framework dependency)
3. Configuration changes in `Info.plist` are safe
4. Test with `./verify_setup.sh` before committing

### Release Checklist
1. Run `./release.sh X.Y.Z` from `macOS/AIOSSLTool/`
2. Test DMG: `open releases/vX.Y.Z/AIOSSLTool-macOS-vX.Y.Z.dmg`
3. Create GitHub release: `gh release create vX.Y.Z ...` (see release.sh output)
4. Update `README.md` download link to new version
5. Commit appcast.xml and README.md changes
6. (Optional) Update `appcast.xml` with release entry if Sparkle active

### Windows App Changes
- Rarely modified - Python version is legacy
- Dependencies: Install with `pip install -r windows/requirements.txt`
- Uses `cryptography` library for cert operations (not Security framework)

## File You Should Know

- `macOS/AIOSSLTool/Info.plist` - Version numbers, app metadata, Sparkle config
- `macOS/AIOSSLTool/ViewModels/SSLToolViewModel.swift` - Core certificate operation logic
- `macOS/AIOSSLTool/Utils/CertificateUtils.swift` - Security framework wrapper functions
- `macOS/AIOSSLTool/build.sh` - Complete build process (reference for manual builds)
- `macOS/AIOSSLTool/release.sh` - Release automation (shows full workflow)
- `appcast.xml` - Sparkle update feed (currently unused but configured)
- `README.md` - Update download links here after each macOS release

## Resources

- Sparkle Setup: `macOS/AUTO_UPDATE_QUICKSTART.md` (10-minute guide)
- Full Auto-Update Docs: `macOS/AUTO_UPDATE_GUIDE.md` (comprehensive reference)
- Build Details: `macOS/BUILD_AND_RUN.md` and `macOS/QUICKSTART.md`
