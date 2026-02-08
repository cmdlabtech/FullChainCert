# AIO SSL Tool

**The fastest way to turn any server certificate into a complete, trusted chain and ready-to-use PFX — in seconds.**

Now available as a native macOS application and cross-platform desktop tool. Built for sysadmins and DevOps who need perfect SSL certificates without the hassle.

### 📥 Download Latest Version

| Platform | Download Link | Type | Notes |
| :--- | :--- | :--- | :--- |
| **macOS** | [**Download for macOS**](https://github.com/cmdlabtech/aio-ssl-tool/releases/latest/download/AIOSSLTool-macOS.tar.gz) | Native App | Requires macOS 14.0+ (Sonoma) |
| **Windows** | [**Download for Windows**](https://github.com/cmdlabtech/aio-ssl-tool/releases/latest/download/AIO-SSL-Tool.exe) | .exe | Single executable, no install needed |
| **Linux** | [**Download for Linux**](https://github.com/cmdlabtech/aio-ssl-tool/releases/latest/download/AIO-SSL-Tool-Linux) | Binary | Executable, requires Python 3.11+ |

---

### Features
- **CSR Generation**: Easily generate CSRs and Private Keys with a clean interface.
- **Full Chain Building**: Automatically builds the full trusted chain.
- **PFX/P12 Extraction**: Extracting private keys from existing PFX files.
- **Privacy First**: All processing happens locally on your machine.
- **Cross-Platform**: 
  - **Native macOS**: Modern, dark-themed SwiftUI experience.
  - **Windows/Linux**: Robust Python-based desktop application.

### Development

#### Project Structure
- `macOS/`: Native Swift source code (Xcode project)
- `python/`: Cross-platform Python source code

#### Build from Source

**macOS:**
```bash
cd macOS/AIOSSLTool
swift build -c release
```

**Windows/Linux (Python):**
```bash
pip install -r python/requirements.txt
python python/aio_ssl_tool.py
```

### License
[MIT](LICENSE)
