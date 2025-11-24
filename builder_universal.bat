@echo off
setlocal enabledelayedexpansion

echo ===============================================
echo    Universal App Builder
echo ===============================================
echo 1. Build Android APK
echo 2. Build Windows EXE
echo 3. Build Both
echo.
set /p choice="Choose option (1-3): "

if "%choice%"=="1" goto BUILD_ANDROID
if "%choice%"=="2" goto BUILD_WINDOWS
if "%choice%"=="3" goto BUILD_BOTH

echo Invalid choice!
pause
exit /b 1

:BUILD_ANDROID
call builder_android.bat
exit /b 0

:BUILD_WINDOWS
call builder_windows.bat
exit /b 0

:BUILD_BOTH
echo Building both Android and Windows...
call builder_android.bat
if errorlevel 1 (
    echo Android build failed. Skipping Windows build.
    pause
    exit /b 1
)
call builder_windows.bat
exit /b 0