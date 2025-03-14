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

:: Check if archive URL was found
if not defined ARCHIVE_URL (
    echo No compatible archive found for %OS%.
    exit /b 1
)

:: Download the archive
echo Downloading the release...
curl -L !ARCHIVE_URL! -o "%TEMP%\code.zip"

:: Unpack the archive based on OS
echo Extracting the archive...
if "%OS%"=="Windows" (
    powershell -Command "Expand-Archive -Path '%TEMP%\code.zip' -DestinationPath '%TEMP%\code'"
)

:: Variables for paths
set "EXECUTABLE=%TEMP%\code.exe"
set "WRAPPER_SCRIPT=%TEMP%\code.bat"
set "INSTALL_DIR=%ProgramFiles%\code"

:: Make directory
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

:: Install executable and wrapper script
echo Installing executable...
copy /Y "%EXECUTABLE%" "%INSTALL_DIR%\code.exe"

echo Installing wrapper script...
copy /Y "%WRAPPER_SCRIPT%" "%INSTALL_DIR%\code.bat"

:: Ensure the script is executable
icacls "%INSTALL_DIR%\code.exe" /grant Everyone:RX
icacls "%INSTALL_DIR%\code.bat" /grant Everyone:RX

:: Clean up
echo Cleaning up...
del "%TEMP%\code.zip"

echo Installation complete. You can now run the program using 'code' from the terminal.
endlocal