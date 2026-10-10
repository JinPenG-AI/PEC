@echo off
setlocal EnableExtensions

cd /d "%~dp0"

where node >nul 2>nul
if errorlevel 1 (
  echo Node.js is not installed or is not available in PATH.
  pause
  exit /b 1
)

if not exist "node_modules" (
  echo Installing dependencies...
  call npm install
  if errorlevel 1 (
    echo Dependency installation failed.
    pause
    exit /b 1
  )
)

echo Building production files for /prototype/Rental/ ...
call npm run build -- --base /prototype/Rental/
if errorlevel 1 (
  echo Production build failed.
  pause
  exit /b 1
)

for /f %%I in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd-HHmmss"') do set "STAMP=%%I"
set "ARCHIVE=project-prototype-platform-dist-%STAMP%.zip"

powershell -NoProfile -ExecutionPolicy Bypass -Command "$dist=(Resolve-Path -LiteralPath 'dist').Path; $zip=Join-Path (Get-Location).Path '%ARCHIVE%'; Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::CreateFromDirectory($dist,$zip,[System.IO.Compression.CompressionLevel]::Optimal,$false)"
if errorlevel 1 (
  echo Production archive creation failed.
  pause
  exit /b 1
)

echo.
echo Production package created:
echo %CD%\%ARCHIVE%
echo Upload the contents of this ZIP to the server's /prototype/Rental/ directory.
echo Keep index.html, assets, brand, and projects at the ZIP root.
echo.
pause

endlocal
