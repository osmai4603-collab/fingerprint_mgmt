@echo off
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "BACKEND_DIR=%SCRIPT_DIR%fingerprint_backend"
set "FRONTEND_DIR=%SCRIPT_DIR%fingerprint_frontend"
set "BUILD_DIR=%SCRIPT_DIR%build"
set "VENV_DIR=%BACKEND_DIR%\venv"
set "POSTGRES_VERSION=16.4"
set "POSTGRES_URL=https://get.enterprisedb.com/postgresql/postgresql-%POSTGRES_VERSION%-1-windows-x64-binaries.zip"

echo [build] Building standalone application...
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

:: Step 1: Setup Python environment
echo [build] Setting up Python environment...
if not exist "%VENV_DIR%" (
    python -m venv "%VENV_DIR%"
)
call "%VENV_DIR%\Scripts\activate.bat"
pip install -q --upgrade pip
pip install -q -r "%BACKEND_DIR%\requirements.txt"
pip install -q pyinstaller

:: Step 2: Build backend with PyInstaller
echo [build] Building backend with PyInstaller...
cd /d "%BACKEND_DIR%"
pyinstaller --clean ^
  --distpath "%BUILD_DIR%\backend_dist" ^
  --workpath "%BUILD_DIR%\backend_build" ^
  backend.spec
cd /d "%SCRIPT_DIR%"

set "BACKEND_EXE_DIR=%BUILD_DIR%\backend_dist\backend_server"

:: Step 3: Download PostgreSQL portable
set "POSTGRES_DIR=%BUILD_DIR%\postgres"
if not exist "%POSTGRES_DIR%\bin" (
    echo [build] Downloading PostgreSQL !POSTGRES_VERSION! portable...
    set "POSTGRES_ZIP=%BUILD_DIR%\postgresql.zip"
    if not exist "!POSTGRES_ZIP!" (
        powershell -Command "Invoke-WebRequest -Uri '%POSTGRES_URL%' -OutFile '!POSTGRES_ZIP!'"
    )
    if exist "!POSTGRES_ZIP!" (
        echo [build] Extracting PostgreSQL...
        powershell -Command "Expand-Archive -Path '!POSTGRES_ZIP!' -DestinationPath '%BUILD_DIR%' -Force"
        if exist "%BUILD_DIR%\pgsql" (
            move "%BUILD_DIR%\pgsql" "%POSTGRES_DIR%"
        )
        del "!POSTGRES_ZIP!" 2>nul
    )
)

:: Step 3.5: Copy backend to frontend assets
echo [build] Copying backend to frontend assets...
set "FRONTEND_ASSETS_DIR=%FRONTEND_DIR%\assets\backend"
if not exist "%FRONTEND_ASSETS_DIR%" mkdir "%FRONTEND_ASSETS_DIR%"
copy /Y "%BUILD_DIR%\backend_dist\backend_server.exe" "%FRONTEND_ASSETS_DIR%\" >nul 2>&1
if not exist "%FRONTEND_ASSETS_DIR%\migrations" mkdir "%FRONTEND_ASSETS_DIR%\migrations"
xcopy /E /I /Y "%BACKEND_DIR%\migrations\*" "%FRONTEND_ASSETS_DIR%\migrations\" >nul 2>&1
echo. > "%FRONTEND_ASSETS_DIR%\.keep"
echo. > "%FRONTEND_ASSETS_DIR%\migrations\.keep"

:: Step 4: Build Flutter and bundle
echo [build] Building Flutter Windows app...
cd /d "%FRONTEND_DIR%"
flutter build windows --release

set "FLUTTER_BUNDLE_DIR=%FRONTEND_DIR%\build\windows\x64\runner\Release"
set "BUNDLE_BACKEND_DIR=%FLUTTER_BUNDLE_DIR%\assets\backend"

if not exist "%BUNDLE_BACKEND_DIR%" mkdir "%BUNDLE_BACKEND_DIR%"
copy /Y "%BUILD_DIR%\backend_dist\backend_server.exe" "%BUNDLE_BACKEND_DIR%\"
xcopy /E /I /Y "%BACKEND_DIR%\migrations\*" "%BUNDLE_BACKEND_DIR%\migrations\"

if exist "%POSTGRES_DIR%\bin" (
    set "BUNDLE_POSTGRES_DIR=%FLUTTER_BUNDLE_DIR%\assets\postgres"
    if not exist "!BUNDLE_POSTGRES_DIR!" mkdir "!BUNDLE_POSTGRES_DIR!"
    xcopy /E /I /Y "%POSTGRES_DIR%\*" "!BUNDLE_POSTGRES_DIR!\"
)

echo [build] Build complete: %FLUTTER_BUNDLE_DIR%
echo Done!
