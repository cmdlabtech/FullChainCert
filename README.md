# AIO SSL Tool

**The fastest way to turn any server certificate into a complete, trusted chain and ready-to-use PFX — in seconds.**

Now available as a native macOS application and cross-platform desktop tool. Built for sysadmins and DevOps who need perfect SSL certificates without the hassle.

---

## 📥 Download Latest Version (v6.0.0)

| Platform | Download | Size | Requirements |
|----------|----------|------|--------------|
| **🍎 macOS** | [**Download DMG**](https://github.com/cmdlabtech/AIO-SSL-Tool/raw/main/releases/v6.0.0/AIOSSLTool-macOS-v6.0.0.dmg) | 1.5 MB | macOS 14.0+ (Sonoma/Sequoia) |
| **🪟 Windows** | [**Download EXE**](https://github.com/cmdlabtech/AIO-SSL-Tool/raw/main/releases/v6.0.0/AIOSSLTool-Windows-v6.0.0.exe) | 18 MB | Windows 10/11 (64-bit) |

### Installation Notes

**macOS:**
1. Download and open the DMG file
2. Drag "AIO SSL Tool" to your Applications folder
3. **First launch** (the app is unsigned, so macOS Gatekeeper will block it):
   
   **Method 1 - Right-click Open (Recommended):**
   - Right-click (or Control-click) on "AIO SSL Tool" in Applications
   - Select "Open" from the menu
   - Click "Open" in the security dialog that appears
   - The app will now launch and be trusted for future use
   
   **Method 2 - System Settings (if you see "app is damaged" error):**
   - Try to open the app normally (it will be blocked)
   - Go to **System Settings** → **Privacy & Security**
   - Scroll down to the **Security** section
   - You'll see a message: *"AIO SSL Tool" was blocked from use because it is not from an identified developer*
   - Click **"Open Anyway"** button next to this message
   - Confirm by clicking **"Open"** in the dialog
   - The app will launch and be permanently allowed
   
   **Method 3 - Terminal (for advanced users):**
   ```bash
   xattr -cr "/Applications/AIO SSL Tool.app"
   open "/Applications/AIO SSL Tool.app"
   ```

4. **Subsequent launches:** Open normally from Applications or Launchpad

> **Why is this necessary?** The app is ad-hoc signed (free, no Apple Developer account required) rather than notarized by Apple. This is safe but requires manual approval on first launch.

**Windows:**
1. Download the EXE file
2. Run directly - no installation needed
3. Windows Defender may show a warning - click "More info" → "Run anyway"

---

## ✨ Features

- **🔐 CSR Generation**: Create Certificate Signing Requests and Private Keys with an intuitive interface
- **🔗 Full Chain Building**: Automatically constructs complete certificate chains from server certificates
- **📦 PFX/P12 Creation**: Build PFX files with full chain and private key
- **🔓 PFX Extraction**: Extract certificates and private keys from existing PFX files
- **🔒 Privacy First**: All processing happens locally on your machine - no data leaves your computer
- **⚡ Fast & Lightweight**: Native Swift on macOS, efficient Python on Windows/Linux

---

## 🖥️ Platform Details

### Native macOS App
- **Technology**: SwiftUI with modern macOS design
- **Features**: Dark mode support, native file pickers, macOS-style interface
- **Requirements**: macOS 14.0 (Sonoma) or later
- **Architecture**: Universal Binary (Apple Silicon & Intel)

### Windows/Linux App  
- **Technology**: Python 3.11+ with Tkinter
- **Features**: Cross-platform compatibility, portable executable
- **Requirements**: Windows 10/11 or Linux with Python 3.11+

---

## 🚀 Usage

### Chain Builder Workflow
1. **Select Working Directory**: Choose where certificates will be saved
2. **Load Certificate**: Import your server certificate (.cer, .crt, .pem)
3. **Build Chain**: Automatically fetches intermediate certificates
4. **Add Private Key**: Load your private key file (optional passphrase)
5. **Create PFX**: Set a password and generate the PFX file

### CSR Generation
1. Fill in your organization details (Common Name, Organization, etc.)
2. Select key size (2048 or 4096 bit)
3. Generate CSR and Private Key
4. Files saved to your chosen directory

### PFX Extraction
1. Select an existing PFX file
2. Enter the PFX password
3. Extract certificate and private key separately

---

## 🛠️ Development

### Repository Structure
```
AIO-SSL-Tool/
├── macOS/              # Native macOS Swift app
│   └── AIOSSLTool/
│       ├── *.swift     # Swift source files
│       ├── build.sh    # Build script
│       └── Info.plist  # App metadata
├── python/             # Cross-platform Python app
│   ├── aio_ssl_tool.py # Main application
│   └── requirements.txt
├── releases/           # Pre-built binaries
│   └── v6.0.0/
└── README.md
```

### Build from Source

**macOS (Swift):**
```bash
cd macOS/AIOSSLTool
./build.sh release
open "AIO SSL Tool.app"
```

**Windows/Linux (Python):**
```bash
cd python
pip install -r requirements.txt
python aio_ssl_tool.py
```

### Building Executables

**macOS DMG:**
```bash
cd macOS/AIOSSLTool
./build.sh release
hdiutil create -volname "AIO SSL Tool" -srcfolder "AIO SSL Tool.app" -ov -format UDZO AIOSSLTool.dmg
```

**Windows EXE (using PyInstaller):**
```bash
cd python
pip install pyinstaller
pyinstaller --onefile --windowed --name "AIOSSLTool" aio_ssl_tool.py
```

---

## 📋 System Requirements

| Component | macOS | Windows | Linux |
|-----------|-------|---------|-------|
| **OS Version** | 14.0+ (Sonoma) | 10/11 (64-bit) | Ubuntu 20.04+ |
| **RAM** | 512 MB | 512 MB | 512 MB |
| **Disk Space** | 10 MB | 50 MB | 50 MB |
| **Dependencies** | None | None | Python 3.11+ |

---

## 🐛 Troubleshooting

### macOS: "App is damaged or incomplete"
```bash
xattr -cr "/Applications/AIO SSL Tool.app"
```

### Windows: "Windows protected your PC"
Click "More info" → "Run anyway". The app is unsigned but safe.

### General Issues
- Ensure you have write permissions to the working directory
- Check that certificate files are in valid PEM/DER format
- Verify private key matches the certificate

---

## 📝 License

[MIT License](LICENSE) - Copyright © 2026 CMDLAB

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

---

## 📧 Support

For issues or questions, please open an issue on GitHub.

**Made with ❤️ by CMDLAB**
