#Requires -Version 5.1
param(
    [string]$Device = "192.168.1.5:37527",
    [string]$ConfigFile = "config/dev.json"
)

$ErrorActionPreference = 'Continue'

# Locate the karat_hive app directory
$APP_DIR = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$BUILD_DIR = Join-Path $APP_DIR "build"

# Ensure build directory exists
if (-not (Test-Path -LiteralPath $BUILD_DIR)) {
    New-Item -ItemType Directory -Force -Path $BUILD_DIR | Out-Null
}

$TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"
$LATEST_LOG = Join-Path $BUILD_DIR "run_android.log"
$TIMESTAMPED_LOG = Join-Path $BUILD_DIR "run_android_${TIMESTAMP}.log"

Write-Host "============================================================" -ForegroundColor Green
Write-Host " Running karat_hive on Android ($Device)" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host " App Directory : $APP_DIR"
Write-Host " Device        : $Device"
Write-Host " Config File   : $ConfigFile"
Write-Host " Log Files     : $LATEST_LOG"
Write-Host "                 $TIMESTAMPED_LOG"
Write-Host " Monitor live  : Get-Content -Wait -Tail 30 '$LATEST_LOG'" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Green

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "'flutter' command not found on PATH."
    exit 1
}

Push-Location -LiteralPath $APP_DIR
try {
    # Run flutter on Android device and stream output to both console and log file
    & flutter run -d $Device --dart-define-from-file=$ConfigFile @args 2>&1 | Tee-Object -FilePath $LATEST_LOG

    $RUN_STATUS = if ($null -ne $LASTEXITCODE) { $LASTEXITCODE } else { 0 }

    # Copy the log to a timestamped file for historical tracking
    Copy-Item -Path $LATEST_LOG -Destination $TIMESTAMPED_LOG -Force -ErrorAction SilentlyContinue

    if ($RUN_STATUS -eq 0) {
        Write-Host ""
        Write-Host "==> Session ended cleanly."
        Write-Host "==> Log saved: $LATEST_LOG"
    } else {
        Write-Host ""
        Write-Host "==> Session ended with exit code $RUN_STATUS."
        Write-Host "==> Log saved: $LATEST_LOG"
        exit $RUN_STATUS
    }
}
finally {
    Pop-Location
}
