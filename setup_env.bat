@echo off
setlocal EnableDelayedExpansion

:: Navigate to the repository root where this script lives
cd /d "%~dp0"

if not exist requirements.txt (
    echo ERROR: requirements.txt not found in %CD%
    exit /b 1
)

:: Ensure Python is available on PATH
where python >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not available on PATH. Install Python and try again.
    exit /b 1
)

:: Create virtual environment if it does not exist
if exist ".venv\Scripts\python.exe" (
    echo Virtual environment already exists.
) else (
    echo Creating virtual environment in .venv...
    python -m venv .venv
    if errorlevel 1 (
        echo ERROR: Failed to create virtual environment.
        exit /b 1
    )
)

:: Activate virtual environment
call ".venv\Scripts\activate"
if errorlevel 1 (
    echo ERROR: Failed to activate virtual environment.
    exit /b 1
)

echo Installing dependencies from requirements.txt...
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
if errorlevel 1 (
    echo ERROR: Failed to install dependencies from requirements.txt.
    exit /b 1
)

if not exist "ImagesToConvert" (
    echo Creating ImagesToConvert folder...
    mkdir "ImagesToConvert"
)

if not exist "ImagesToConvert\Converted" (
    echo Creating ImagesToConvert\Converted folder...
    mkdir "ImagesToConvert\Converted"
)

set "shortcutDir=%CD%\ImagesToConvert"
set "shortcutPath=%shortcutDir%\Convert.lnk"

dir /b "%shortcutDir%\*.lnk" >nul 2>&1
if errorlevel 1 (
    echo Creating shortcut to run main.py in ImagesToConvert...

    :: Resolve paths before writing VBS to avoid delayed expansion issues inside echo blocks
    set "targetPath=%CD%\.venv\Scripts\python.exe"
    set "scriptPath=%CD%\main.py"
    set "workingDir=%CD%"
    set "tempVbs=%TEMP%\create_shortcut.vbs"

    :: Write each line separately using regular %var% expansion (not delayed !var!)
    :: This avoids the blank-variable bug that occurs inside parenthesised echo blocks
    echo Set shell = CreateObject("WScript.Shell") > "%tempVbs%"
    echo Set shortcut = shell.CreateShortcut("%shortcutPath%") >> "%tempVbs%"
    echo shortcut.TargetPath = "%targetPath%" >> "%tempVbs%"
    echo shortcut.Arguments = """%scriptPath%""" >> "%tempVbs%"
    echo shortcut.WorkingDirectory = "%workingDir%" >> "%tempVbs%"
    echo shortcut.Description = "Run main.py from virtual environment" >> "%tempVbs%"
    echo shortcut.Save >> "%tempVbs%"

    cscript //nologo "%tempVbs%"
    if errorlevel 1 (
        echo ERROR: Failed to create shortcut %shortcutPath%.
        del "%tempVbs%" 2>nul
        exit /b 1
    )

    del "%tempVbs%" 2>nul
) else (
    echo Shortcut already exists in %shortcutDir%.
)

echo.
echo Setup complete.
echo To use the virtual environment, run:
echo     .venv\Scripts\activate
endlocal
