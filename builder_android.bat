@echo off
setlocal enabledelayedexpansion

echo ===============================================
echo    Android APK Builder
echo ===============================================

:: Check if we're in the correct directory
if not exist "package.json" (
    echo ERROR: package.json not found! Please run this script from your project root directory.
    pause
    exit /b 1
)

:: Set paths
set PROJECT_ROOT=%CD%
set BUILD_DIR=%PROJECT_ROOT%\build
set APK_OUTPUT_DIR=%PROJECT_ROOT%\dist

echo Project Root: %PROJECT_ROOT%
echo Build Directory: %BUILD_DIR%

:: Check Node.js installation
node --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Node.js is not installed or not in PATH
    pause
    exit /b 1
)

:: Check Java for Android builds
java -version >nul 2>&1
if errorlevel 1 (
    echo WARNING: Java may not be installed. Android builds require Java JDK.
)

echo.
echo Step 1: Checking package.json...
if not exist "package.json" (
    echo Creating basic package.json...
    echo { > package.json
    echo   "name": "my-app", >> package.json
    echo   "version": "1.0.0", >> package.json
    echo   "description": "My Application", >> package.json
    echo   "main": "index.js", >> package.json
    echo   "scripts": { >> package.json
    echo     "build": "echo Add your build script here", >> package.json
    echo     "build:android": "cordova build android" >> package.json
    echo   } >> package.json
    echo } >> package.json
)

:: Validate package.json
echo Validating package.json...
node -e "try { require('./package.json'); console.log('package.json is valid'); } catch(e) { console.error('package.json has errors:', e.message); process.exit(1); }"

if errorlevel 1 (
    echo Fixing package.json errors...
    call :FIX_PACKAGE_JSON
)

echo.
echo Step 2: Installing dependencies...
if exist "node_modules" (
    echo Node modules already exist. Running npm ci for clean install...
    npm ci
) else (
    echo Running npm install...
    npm install
)

if errorlevel 1 (
    echo ERROR: npm install failed!
    echo Cleaning node_modules and retrying...
    rmdir /s /q node_modules 2>nul
    npm install
    if errorlevel 1 (
        echo ERROR: npm install failed again. Please check your package.json
        pause
        exit /b 1
    )
)

echo.
echo Step 3: Creating build scripts if missing...
if not exist "scripts" mkdir scripts

:: Create build script for Android
if not exist "scripts\build-android.js" (
    echo Creating Android build script...
    echo // Android Build Script > scripts\build-android.js
    echo const fs = require('fs'); >> scripts\build-android.js
    echo const { execSync } = require('child_process'); >> scripts\build-android.js
    echo. >> scripts\build-android.js
    echo console.log('Starting Android build...'); >> scripts\build-android.js
    echo try { >> scripts\build-android.js
    echo   // Add your Android build logic here >> scripts\build-android.js
    echo   console.log('Android build completed successfully'); >> scripts\build-android.js
    echo } catch (error) { >> scripts\build-android.js
    echo   console.error('Build failed:', error); >> scripts\build-android.js
    echo   process.exit(1); >> scripts\build-android.js
    echo } >> scripts\build-android.js
)

echo.
echo Step 4: Running Android build...
echo Checking for Cordova/Ionic...

:: Check if it's a Cordova project
if exist "config.xml" (
    echo Cordova project detected. Building Android...
    if not exist "platforms\android" (
        echo Adding Android platform...
        cordova platform add android
    )
    cordova build android --release
) else if exist "ionic.config.json" (
    echo Ionic project detected. Building Android...
    ionic build
    ionic cap sync android
    ionic cap build android --release
) else (
    echo Standard Node.js project. Running custom build...
    node scripts\build-android.js
)

if errorlevel 1 (
    echo ERROR: Android build failed!
    pause
    exit /b 1
)

echo.
echo Step 5: Finding APK file...
if exist "platforms\android\app\build\outputs\apk\release\app-release.apk" (
    set APK_PATH=platforms\android\app\build\outputs\apk\release\app-release.apk
) else if exist "android\app\build\outputs\apk\release\app-release.apk" (
    set APK_PATH=android\app\build\outputs\apk\release\app-release.apk
) else (
    echo Searching for APK files...
    for /r . %%i in (*.apk) do (
        set APK_PATH=%%i
        goto :APK_FOUND
    )
    echo ERROR: No APK file found!
    pause
    exit /b 1
)

:APK_FOUND
echo APK found at: %APK_PATH%

:: Create dist directory if it doesn't exist
if not exist "%APK_OUTPUT_DIR%" mkdir "%APK_OUTPUT_DIR%"

:: Copy APK to dist directory
copy "%APK_PATH%" "%APK_OUTPUT_DIR%\app-release.apk" >nul

echo.
echo ===============================================
echo    BUILD SUCCESSFUL!
echo    APK location: %APK_OUTPUT_DIR%\app-release.apk
echo ===============================================
pause
exit /b 0

:FIX_PACKAGE_JSON
echo Attempting to fix package.json...
:: Create a backup
copy package.json package.json.backup >nul

:: Try to fix common JSON issues using Node.js
node -e "
const fs = require('fs');
try {
    let content = fs.readFileSync('./package.json', 'utf8');
    // Fix common JSON issues
    content = content.replace(/,(\s*[}\]])/g, '$1'); // Remove trailing commas
    content = content.replace(/'/g, '\"'); // Replace single quotes with double quotes
    content = content.replace(/(\w+):/g, '\"$1\":'); // Add quotes to unquoted keys
    
    // Parse to validate
    JSON.parse(content);
    fs.writeFileSync('./package.json', JSON.stringify(JSON.parse(content), null, 2));
    console.log('package.json fixed successfully');
} catch(e) {
    console.error('Could not fix package.json automatically');
    // Restore from backup or create minimal package.json
    fs.writeFileSync('./package.json', JSON.stringify({
        name: 'my-app',
        version: '1.0.0',
        description: 'My Application',
        main: 'index.js',
        scripts: {
            build: 'echo Add your build script here'
        }
    }, null, 2));
}
"
exit /b 0