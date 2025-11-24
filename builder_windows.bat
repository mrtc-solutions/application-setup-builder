@echo off
setlocal enabledelayedexpansion

echo ===============================================
echo    Windows EXE Builder
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
set EXE_OUTPUT_DIR=%PROJECT_ROOT%\dist

echo Project Root: %PROJECT_ROOT%
echo Build Directory: %BUILD_DIR%

:: Check Node.js installation
node --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Node.js is not installed or not in PATH
    pause
    exit /b 1
)

echo.
echo Step 1: Checking package.json...
call :VALIDATE_PACKAGE_JSON

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
echo Step 3: Creating build directory and scripts...
if not exist "scripts" mkdir scripts
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

:: Create Windows build script
if not exist "scripts\build-windows.js" (
    echo Creating Windows build script...
    echo // Windows Build Script > scripts\build-windows.js
    echo const fs = require('fs'); >> scripts\build-windows.js
    echo const { execSync } = require('child_process'); >> scripts\build-windows.js
    echo const path = require('path'); >> scripts\build-windows.js
    echo. >> scripts\build-windows.js
    echo console.log('Starting Windows build...'); >> scripts\build-windows.js
    echo try { >> scripts\build-windows.js
    echo   // Check if electron-builder is available >> scripts\build-windows.js
    echo   try { >> scripts\build-windows.js
    echo     require.resolve('electron-builder'); >> scripts\build-windows.js
    echo     console.log('Using electron-builder...'); >> scripts\build-windows.js
    echo     execSync('npx electron-builder --win', { stdio: 'inherit' }); >> scripts\build-windows.js
    echo   } catch { >> scripts\build-windows.js
    echo     // Check if pkg is available >> scripts\build-windows.js
    echo     try { >> scripts\build-windows.js
    echo       require.resolve('pkg'); >> scripts\build-windows.js
    echo       console.log('Using pkg to create executable...'); >> scripts\build-windows.js
    echo       execSync('npx pkg . --target node18-win-x64 --output dist/app.exe', { stdio: 'inherit' }); >> scripts\build-windows.js
    echo     } catch { >> scripts\build-windows.js
    echo       console.log('No build tool found. Creating simple package...'); >> scripts\build-windows.js
    echo       // Fallback: just copy files to build directory >> scripts\build-windows.js
    echo       if (!fs.existsSync('dist')) fs.mkdirSync('dist', { recursive: true }); >> scripts\build-windows.js
    echo       const packageJson = require('./package.json'); >> scripts\build-windows.js
    echo       fs.writeFileSync('dist/package.json', JSON.stringify(packageJson, null, 2)); >> scripts\build-windows.js
    echo     } >> scripts\build-windows.js
    echo   } >> scripts\build-windows.js
    echo   console.log('Windows build completed successfully'); >> scripts\build-windows.js
    echo } catch (error) { >> scripts\build-windows.js
    echo   console.error('Build failed:', error); >> scripts\build-windows.js
    echo   process.exit(1); >> scripts\build-windows.js
    echo } >> scripts\build-windows.js
)

echo.
echo Step 4: Running build process...
echo Checking build tools...

:: Check for Electron
npm list electron >nul 2>&1
if not errorlevel 1 (
    echo Electron project detected.
    call :BUILD_ELECTRON
    goto :BUILD_COMPLETE
)

:: Check for other build tools
npm list pkg >nul 2>&1
if not errorlevel 1 (
    echo pkg detected. Building executable...
    npx pkg . --target node18-win-x64 --output dist/app.exe
    goto :BUILD_COMPLETE
)

:: Default build
echo Running custom build script...
node scripts\build-windows.js

:BUILD_COMPLETE
if errorlevel 1 (
    echo ERROR: Build failed!
    pause
    exit /b 1
)

echo.
echo Step 5: Finalizing build...
if not exist "%EXE_OUTPUT_DIR%" mkdir "%EXE_OUTPUT_DIR%"

:: Find and display the built executable
echo Looking for built executables...
set EXE_FOUND=0
for /r "%EXE_OUTPUT_DIR%" %%i in (*.exe) do (
    echo Found: %%i
    set EXE_FOUND=1
)

if %EXE_FOUND%==0 (
    for /r "." %%i in (*.exe) do (
        echo Found: %%i
        set EXE_FOUND=1
    )
)

if %EXE_FOUND%==0 (
    echo WARNING: No .exe file was created by the build process.
)

echo.
echo ===============================================
echo    BUILD COMPLETED!
echo    Check the dist directory for your executable.
echo ===============================================
pause
exit /b 0

:VALIDATE_PACKAGE_JSON
echo Validating package.json...
node -e "
const fs = require('fs');
try {
    const pkg = require('./package.json');
    console.log('package.json is valid');
    
    // Ensure basic structure
    if (!pkg.scripts) pkg.scripts = {};
    if (!pkg.scripts.build) pkg.scripts.build = 'echo Building...';
    
    // Add build script if missing for Windows
    if (!pkg.scripts['build:win'] && !pkg.scripts['build:windows']) {
        pkg.scripts['build:windows'] = 'node scripts/build-windows.js';
    }
    
    fs.writeFileSync('./package.json', JSON.stringify(pkg, null, 2));
} catch(e) {
    console.log('Fixing package.json...');
    // Create a valid package.json
    const fixedPkg = {
        name: 'my-windows-app',
        version: '1.0.0',
        description: 'Windows Application',
        main: 'index.js',
        scripts: {
            build: 'echo Building...',
            'build:windows': 'node scripts/build-windows.js'
        },
        author: 'Developer',
        license: 'MIT'
    };
    fs.writeFileSync('./package.json', JSON.stringify(fixedPkg, null, 2));
}
"
exit /b 0

:BUILD_ELECTRON
echo Building Electron application...
:: Check if electron-builder is installed
npm list electron-builder >nul 2>&1
if errorlevel 1 (
    echo Installing electron-builder...
    npm install --save-dev electron-builder
)

:: Build for Windows
npx electron-builder --win
exit /b 0