@echo off
setlocal enabledelayedexpansion

:: Detect the OS
set OS=Windows_NT
for /f "delims=" %%i in ('ver') do set OS_VER=%%i
echo %OS_VER% | findstr /i "Windows" >nul
if %errorlevel%==0 (
    set OS=Windows
) else (
    set OS=Other
)

:: GitHub repository details
set REPO=https://api.github.com/repos/<owner>/<repo>/releases/latest
set ARCHIVE_URL=

:: Get the latest release URL using GitHub API
echo Fetching the latest release from GitHub...
for /f "tokens=*" %%i in ('curl -s %REPO%') do set RESPONSE=%%i

:: Extract the URL of the archive based on OS
if "%OS%"=="Windows" (
    echo Parsing response for Windows archive...
    for /f "delims=" %%j in ('echo %RESPONSE% ^| findstr /i "code-windows.zip"') do (
        set ARCHIVE_URL=%%j
        set ARCHIVE_URL=!ARCHIVE_URL:*"browser_download_url": "=!
        set ARCHIVE_URL=!ARCHIVE_URL:~0,-1!
    )
)

if "%OS%"=="Linux" (
    echo Parsing response for Linux archive...
    for /f "delims=" %%j in ('echo %RESPONSE% ^| findstr /i "code-linux.tar.gz"') do (
        set ARCHIVE_URL=%%j
        set ARCHIVE_URL=!ARCHIVE_URL:*"browser_download_url": "=!
        set ARCHIVE_URL=!ARCHIVE_URL:~0,-1!
    )
)

if "%OS%"=="Darwin" (
    echo Parsing response for MacOS archive...
    for /f "delims=" %%j in ('echo %RESPONSE% ^| findstr /i "code-macos.tar.gz"') do (
        set ARCHIVE_URL=%%j
        set ARCHIVE_URL=!ARCHIVE_URL:*"browser_download_url": "=!
        set ARCHIVE_URL=!ARCHIVE_URL:~0,-1!
    )
)

:: Check if archive URL was found
if not defined ARCHIVE_URL (
    echo No compatible archive found for %OS%.
    exit /b 1
)

:: Download the archive
echo Downloading the release...
curl -L !ARCHIVE_URL! -o "%TEMP%\code.tar.gz"

:: Unpack the archive based on OS
echo Extracting the archive...
if "%OS%"=="Windows" (
    powershell -Command "Expand-Archive -Path '%TEMP%\code.zip' -DestinationPath '%TEMP%\code'"
) else (
    tar -xzvf "%TEMP%\code.tar.gz" -C "%TEMP%\code"
)

:: Install executable
set EXECUTABLE=%TEMP%\code\bin\code.exe
set WRAPPER_SCRIPT=%TEMP%\code\bin\code.bat
set INSTALL_DIR=C:\Program Files\MyApp

:: Check if the script is running as Administrator (required for installation in Program Files)
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires Administrator privileges. Please run as Administrator.
    exit /b 1
)

echo Installing executable...
copy "%EXECUTABLE%" "%INSTALL_DIR%\code.exe"

echo Installing wrapper script...
copy "%WRAPPER_SCRIPT%" "%INSTALL_DIR%\code.bat"

:: Clean up
echo Cleaning up...
del "%TEMP%\code.tar.gz"

echo Installation complete. You can now run the program using 'code' from the terminal.
