@echo off

:: Dynamically get the current user's home directory
set target_dir=%USERPROFILE%\dd
set video_file=%~dp0YourVideo.mp4
set bat_file=%~dp0play_video.bat
set vbs_file=%~dp0run_silently.vbs

:: Create the target directory
if not exist "%target_dir%" (
    mkdir "%target_dir%"
)

:: Check if the video file exists
if exist "%video_file%" (
    echo Video file found.
) else (
    echo Video file not found. Ensure "YourVideo.mp4" is in the same folder as the installer.bat.
    pause
    exit /b
)

:: Create play_video.bat with fullscreen video and touch disable logic
echo @echo off > "%target_dir%\play_video.bat"
echo :: Set a timeout for re-enabling touch input (in seconds) >> "%target_dir%\play_video.bat"
echo set timeout_duration=30  :: Disable touch input for 30 seconds >> "%target_dir%\play_video.bat"
echo. >> "%target_dir%\play_video.bat"
echo :: Disable touch input using PowerShell >> "%target_dir%\play_video.bat"
echo echo Disabling touch input... >> "%target_dir%\play_video.bat"
echo powershell -Command "Get-PnpDevice -Class HID | Where-Object { $_.FriendlyName -like '*Touch Screen*' } | Disable-PnpDevice -Confirm:$false" >> "%target_dir%\play_video.bat"
echo. >> "%target_dir%\play_video.bat"
echo :: Wait for 3 minutes (180 seconds) before starting video >> "%target_dir%\play_video.bat"
echo timeout /t 180 >nul >> "%target_dir%\play_video.bat"
echo. >> "%target_dir%\play_video.bat"
echo :: Play the video in fullscreen mode with Windows Media Player >> "%target_dir%\play_video.bat"
echo start "" "wmplayer.exe" /fullscreen "%target_dir%\YourVideo.mp4" >> "%target_dir%\play_video.bat"
echo. >> "%target_dir%\play_video.bat"
echo :: Wait for the set timeout duration (30 seconds) >> "%target_dir%\play_video.bat"
echo echo Waiting for 30 seconds... >> "%target_dir%\play_video.bat"
echo timeout /t %timeout_duration% >nul >> "%target_dir%\play_video.bat"
echo. >> "%target_dir%\play_video.bat"
echo :: Re-enable touch input after the set time >> "%target_dir%\play_video.bat"
echo echo Enabling touch input... >> "%target_dir%\play_video.bat"
echo powershell -Command "Get-PnpDevice -Class HID | Where-Object { $_.FriendlyName -like '*Touch Screen*' } | Enable-PnpDevice -Confirm:$false" >> "%target_dir%\play_video.bat"
echo. >> "%target_dir%\play_video.bat"
echo :: Exit the script >> "%target_dir%\play_video.bat"
echo exit >> "%target_dir%\play_video.bat"

:: Create run_silently.vbs to run play_video.bat silently
echo Set objShell = CreateObject("WScript.Shell") > "%target_dir%\run_silently.vbs"
echo objShell.Run "cmd /c ^""%target_dir%\play_video.bat^""", 0, False >> "%target_dir%\run_silently.vbs"

:: Move the video file to the target directory (%USERPROFILE%\dd)
move "%video_file%" "%target_dir%" >nul

:: Add run_silently.vbs to the current user's Startup folder
set startup_folder=%appdata%\Microsoft\Windows\Start Menu\Programs\Startup
copy "%target_dir%\run_silently.vbs" "%startup_folder%\run_silently.vbs" /Y >nul

:: Run play_video.bat silently via run_silently.vbs
wscript "%target_dir%\run_silently.vbs"

:: Delete the installer.bat file
del "%~f0"

:: Confirmation message (this won't show due to self-deletion)
echo Installation complete! Files are set up in "%target_dir%".
echo The video will play after every system reboot with a 3-minute delay, and touch input will be disabled for 30 seconds when the video plays.
pause
