#Requires -Version 5.1
$ErrorActionPreference = 'Continue'

# Locate the karat_hive app directory
$APP_DIR = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$BUILD_DIR = Join-Path $APP_DIR "build"

# Ensure build directory exists
if (-not (Test-Path -LiteralPath $BUILD_DIR)) {
    New-Item -ItemType Directory -Force -Path $BUILD_DIR | Out-Null
}

$TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"
$LATEST_LOG = Join-Path $BUILD_DIR "run_webserver.log"
$TIMESTAMPED_LOG = Join-Path $BUILD_DIR "run_webserver_${TIMESTAMP}.log"

$BASE_HREF = if ($env:BASE_HREF) { $env:BASE_HREF } else { "/karat_hive/" }
$API_BASE = if ($env:KH_API_BASE_URL) { $env:KH_API_BASE_URL } elseif ($env:KH_API_BASE) { $env:KH_API_BASE } else { "https://algoray.cloud/kh_api/" }
$FLAVOR = if ($env:KH_FLAVOR) { $env:KH_FLAVOR } else { "prod" }
$WEB_PORT = if ($env:WEB_PORT) { [int]$env:WEB_PORT } else { 8082 }
$WEB_HOST = if ($env:WEB_HOST) { $env:WEB_HOST } else { "localhost" }

Write-Host "============================================================" -ForegroundColor Green
Write-Host " Running karat_hive on Web Server" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host " App Directory : $APP_DIR"
Write-Host " Device        : web-server"
Write-Host " Web Host      : $WEB_HOST"
Write-Host " Web Port      : $WEB_PORT (http://${WEB_HOST}:$WEB_PORT${BASE_HREF})"
Write-Host " Base HREF     : $BASE_HREF"
Write-Host " API Base      : $API_BASE"
Write-Host " Flavor        : $FLAVOR"
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
    # Run flutter on web-server and stream output to both console and log file
    & flutter run -d web-server `
        --web-port=$WEB_PORT `
        --web-hostname=$WEB_HOST `
        --base-href="$BASE_HREF" `
        "--dart-define=KH_API_BASE_URL=$API_BASE" `
        "--dart-define=KH_API_BASE=$API_BASE" `
        "--dart-define=KH_FLAVOR=$FLAVOR" `
        @args 2>&1 | Tee-Object -FilePath $LATEST_LOG

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
