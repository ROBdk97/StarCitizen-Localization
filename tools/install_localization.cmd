@echo off
setlocal enabledelayedexpansion

set "localization_url=https://github.com/Dymerz/StarCitizen-Localization/releases/latest/download/Localization.zip"

rem List of languages
set "lang_list[1]=chinese_(simplified)"
set "lang_list[2]=chinese_(traditional)"
set "lang_list[3]=english"
set "lang_list[4]=french_(france)"
set "lang_list[5]=german_(germany)"
set "lang_list[6]=italian_(italy)"
set "lang_list[7]=japanese_(japan)"
set "lang_list[8]=korean_(south_korea)"
set "lang_list[9]=polish_(poland)"
set "lang_list[10]=portuguese_(brazil)"
set "lang_list[11]=spanish_(latin_america)"
set "lang_list[12]=spanish_(spain)"

rem Get the current directory
set "current_directory=%CD%"
set BATCH_PATH=%~dp0
set BATCH_PATH=%BATCH_PATH:~0,-1%

rem Check if the script is executed from the "\StarCitizen\[Live or PTU]\Data" folder
echo %BATCH_PATH% | findstr /I /C:"\StarCitizen\LIVE\data" >nul
if errorlevel 1 (
    echo %BATCH_PATH% | findstr /I /C:"\StarCitizen\PTU\data" >nul
    if errorlevel 1 (
        echo:
        echo This script must be executed from the "\StarCitizen\[LIVE or PTU]\data" folder.
        pause
        exit /b
    )
)

echo Downloading the latest version of the localization files...
curl -L -s -o Localization.zip %localization_url%

echo Extracting the localization files...
powershell -noprofile -executionpolicy bypass -command "Expand-Archive -Path Localization.zip -DestinationPath . -Force"

del Localization.zip

rem Check if the "Localization" folder exists
if not exist "Localization" (
  echo:
  echo The "Localization" folder does not exist.
  pause
  exit /b
)

rem Ask the user to select the language to install
echo Select the language you want to install:
echo 1. Chinese - Simplified
echo 2. Chinese - Traditional
echo 3. English
echo 4. French - France
echo 5. German - Germany
echo 6. Italian - Italy
echo 7. Japanese - Japan
echo 8. Korean - South
echo 9. Polish - Poland
echo 10. Portuguese - Brazil
echo 11. Spanish - Latin
echo 12. Spanish - Spain

set /p lang_choice="Enter the number of the language you want to install, e.g. 3 for English: "

if "!lang_list[%lang_choice%]!" == "" (
  echo:
  echo "The number you entered is not valid."
  pause
  exit /b
)

rem Check if the selected language folder exists
if not exist "Localization\!lang_list[%lang_choice%]!" (
  echo:
  echo The language folder Localization\!lang_list[%lang_choice%]! does not exist.
  echo:
  echo Maybe the language is not available yet, you can check the status of the translations here:
  echo https://github.com/Dymerz/StarCitizen-Localization#supported-languages
  pause
  exit /b
)

set "language_line=g_language = !lang_list[%lang_choice%]!"

rem Delete the user.cfg.new file if it exists
IF EXIST user.cfg.new DEL /F user.cfg.new

rem Check if the ..\user.cfg file exists, if not, create it
if not exist "../user.cfg" (
  echo !language_line! > ../user.cfg
) else (
  rem Replace the language or add it if it does not exist
  for /f "delims=" %%a in (../user.cfg) do (
    set "line=%%a"
    if /i "!line:~0,10!" == "g_language" (
      echo !language_line!>> user.cfg.new
    ) else (
      echo !line!>> user.cfg.new
    )
  )
  move /y user.cfg.new ..\user.cfg > nul
)

echo:
echo You can now enjoy Star Citizen in !lang_list[%lang_choice%]!
pause
endlocal