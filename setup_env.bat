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

:: Crear acceso directo usando PowerShell (más confiable)
set "shortcutDir=%CD%\ImagesToConvert"
set "shortcutPath=%shortcutDir%\Convert.lnk"

if exist "%shortcutDir%" (
    if not exist "%shortcutPath%" (
        echo Creando acceso directo con PowerShell...
        powershell -Command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut('%shortcutPath%');$s.TargetPath='%CD%\.venv\Scripts\python.exe';$s.Arguments='%CD%\main.py';$s.WorkingDirectory='%CD%';$s.Save()"
        if errorlevel 1 (
            echo ERROR: No se pudo crear el acceso directo.
        ) else (
            echo Acceso directo creado en "%shortcutPath%"
        )
    ) else (
        echo El acceso directo ya existe.
    )
) else (
    echo AVISO: La carpeta "%shortcutDir%" no existe. No se creará el acceso directo.
)

echo.
echo Setup complete.
echo To use the virtual environment, run:
echo     .venv\Scripts\activate
endlocal
