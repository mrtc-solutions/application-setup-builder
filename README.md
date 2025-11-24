**App Build Automation Scripts**
A collection of batch scripts for automating the build process of Android APK and Windows EXE files from your project root directory.

**📁 Files Overview
1. builder_android.bat**
Purpose: Automates the build process for Android APK files
Supported Frameworks: Cordova, Ionic, React Native, Standard Node.js

**2. builder_windows.bat**
Purpose: Automates the build process for Windows EXE files
Supported Frameworks: Electron, Node.js (using pkg), General applications

3. builder_universal.bat
Purpose: Interactive script that lets you choose between Android, Windows, or both builds

**🚀 Quick Start**
Prerequisites
Node.js (v14 or higher) - Download here

Java JDK (for Android builds) - Download here

Project Dependencies (varies by framework)

Installation
Place the batch files in your project root directory

Ensure your project has a package.json file

Run the desired batch file

bash
# Clone or download these batch files to your project root
your-project/
├── builder_android.bat
├── builder_windows.bat
├── builder_universal.bat
├── package.json
└── (your source files)
📱 Android APK Builder
Usage
cmd
builder_android.bat

**Features**
✅ Automatic package.json validation and repair

✅ Node.js and Java installation checks

✅ Framework detection (Cordova, Ionic, React Native)

✅ Dependency installation (npm install)

✅ Automatic APK file location and copying to dist/ directory

✅ Error handling and recovery

Supported Android Frameworks
Cordova: Automatically adds Android platform and builds

Ionic: Uses Ionic CLI for Capacitor builds

React Native: Executes standard build process

Generic Node.js: Runs custom build scripts

Output
APK files are copied to dist/app-release.apk
**
🖥️ Windows EXE Builder**
Usage
cmd
builder_windows.bat

**Features**
✅ Automatic package.json validation and repair

✅ Multiple build tool support (Electron, pkg, etc.)

✅ Dependency installation and cleanup

✅ Automatic executable detection

✅ Fallback build methods

Supported Windows Frameworks
Electron: Uses electron-builder for distribution

Node.js with pkg: Creates standalone executables

Generic applications: Packages with dependencies

Output
EXE files are created in dist/ directory

🔄 Universal Builder
Usage
cmd
builder_universal.bat
Options
text
1. Build Android APK
2. Build Windows EXE  
3. Build Both
⚙️ Configuration
Automatic Package.json Fixing
The scripts automatically:

Fix JSON syntax errors

Add missing build scripts

Ensure proper structure

Create backups before modifications

**Custom Build Scripts**
If missing, the scripts create:

scripts/build-android.js - Android-specific build logic

scripts/build-windows.js - Windows-specific build logic

**🛠️ Framework-Specific Setup**
For Cordova Projects
json
// Ensure these are in your package.json
{
  "scripts": {
    "build:android": "cordova build android --release"
  }
}
For Ionic Projects
json
{
  "scripts": {
    "build:android": "ionic build && ionic cap sync android && ionic cap build android --release"
  }
}
For Electron Projects
json
{
  "scripts": {
    "build:win": "electron-builder --win"
  }
}

**📂 Project Structure After Build**
text
your-project/
├── dist/                   # Build outputs
│   ├── app-release.apk    # Android APK
│   └── app.exe           # Windows executable
├── scripts/               # Auto-generated build scripts
├── platforms/            # Cordova platforms (Android)
├── node_modules/         # Dependencies
└── build/               # Temporary build files
🐛 Troubleshooting

**Common Issues**
"Node.js not found"

Install Node.js and add to PATH

Restart command prompt after installation

"Java not installed" (Android)

Install Java JDK 8 or higher

Set JAVA_HOME environment variable

**Build failures**

Check framework-specific requirements

Ensure all dependencies are properly installed

Verify package.json has correct build scripts

APK/EXE not found

Check console output for build errors

Verify the build completed successfully

Look in alternative output directories

Debug Mode
Run with specific framework commands to see detailed output:

cmd
# For Cordova
cordova build android --verbose

# For Electron
npx electron-builder --win --debug
🔧 Customization
Modifying Build Scripts
Edit the auto-generated scripts in scripts/ directory:

scripts/build-android.js - Custom Android build logic

scripts/build-windows.js - Custom Windows build logic

**Adding New Frameworks**
Modify the batch files to detect additional frameworks by checking for specific files:

config.xml - Cordova

ionic.config.json - Ionic

electron-builder.json - Electron

**📄 License**
These scripts are provided as-is. Feel free to modify and adapt to your project needs.

**🤝 Contributing**
Feel free to submit issues and enhancement requests!

Note: These scripts are designed to be placed in your project root directory and will automatically detect your project type and build accordingly.
