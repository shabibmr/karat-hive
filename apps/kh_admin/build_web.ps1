#Requires -Version 5.1
$ErrorActionPreference = 'Continue'

# Locate the kh_admin app directory
$APP_DIR = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$BUILD_DIR = Join-Path $APP_DIR "build"

# Ensure build directory exists
if (-not (Test-Path -LiteralPath $BUILD_DIR)) {
    New-Item -ItemType Directory -Force -Path $BUILD_DIR | Out-Null
}

$TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"
$LATEST_LOG = Join-Path $BUILD_DIR "web_build.log"
$TIMESTAMPED_LOG = Join-Path $BUILD_DIR "web_build_${TIMESTAMP}.log"

$BASE_HREF = if ($env:BASE_HREF) { $env:BASE_HREF } else { "/hive_admin/" }
$API_BASE = if ($env:KH_API_BASE) { $env:KH_API_BASE } else { "https://algoray.cloud/kh_api" }
$FLAVOR = if ($env:KH_FLAVOR) { $env:KH_FLAVOR } else { "prod" }

Write-Host "============================================================"
Write-Host " Building kh_admin for Web"
Write-Host "============================================================"
Write-Host " App Directory : $APP_DIR"
Write-Host " Base HREF     : $BASE_HREF"
Write-Host " API Base      : $API_BASE"
Write-Host " Flavor        : $FLAVOR"
Write-Host " Log Files     : $LATEST_LOG"
Write-Host "                 $TIMESTAMPED_LOG"
Write-Host "============================================================"

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "'flutter' command not found on PATH."
    exit 1
}

Push-Location -LiteralPath $APP_DIR
try {
    # Run flutter build web and stream output to both console and log
    & flutter build web `
        --base-href="$BASE_HREF" `
        "--dart-define=KH_API_BASE=$API_BASE" `
        "--dart-define=KH_FLAVOR=$FLAVOR" `
        @args 2>&1 | Tee-Object -FilePath $LATEST_LOG

    $BUILD_STATUS = if ($null -ne $LASTEXITCODE) { $LASTEXITCODE } else { 0 }

    # Copy the log to a timestamped file for historical tracking
    Copy-Item -Path $LATEST_LOG -Destination $TIMESTAMPED_LOG -Force -ErrorAction SilentlyContinue

    if ($BUILD_STATUS -eq 0) {
        Write-Host ""
        Write-Host "==> Web build succeeded!"
        Write-Host "==> Output artifacts: $(Join-Path $BUILD_DIR 'web')"
        Write-Host "==> Log saved: $LATEST_LOG"
    } else {
        Write-Host ""
        Write-Host "==> Web build failed with exit code $BUILD_STATUS."
        Write-Host "==> Log saved: $LATEST_LOG"
        exit $BUILD_STATUS
    }
}
finally {
    Pop-Location
}
