#Requires -Version 5.1
$ErrorActionPreference = 'Continue'

$APP_DIR = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }

$API_BASE  = if ($env:KH_API_BASE_URL) { $env:KH_API_BASE_URL } elseif ($env:KH_API_BASE) { $env:KH_API_BASE } else { "https://algoray.cloud/kh_api/" }
$FLAVOR    = if ($env:KH_FLAVOR) { $env:KH_FLAVOR } else { "prod" }
$BASE_HREF = if ($env:BASE_HREF) { $env:BASE_HREF } else { "/karat_hive/" }
$WEB_PORT  = if ($env:WEB_PORT) { [int]$env:WEB_PORT } else { 5000 }
$HOST_ADDR = if ($env:WEB_HOST) { $env:WEB_HOST } else { "0.0.0.0" }

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " Running karat_hive as web-server" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " App Directory : $APP_DIR"
Write-Host " Device        : web-server"
Write-Host " Listening     : http://${HOST_ADDR}:${WEB_PORT}"
Write-Host " Base HREF     : $BASE_HREF"
Write-Host " API Base      : $API_BASE"
Write-Host " Flavor        : $FLAVOR"
Write-Host "============================================================" -ForegroundColor Cyan

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "'flutter' command not found on PATH."
    exit 1
}

Push-Location -LiteralPath $APP_DIR
try {
    & flutter run -d web-server `
        --web-port=$WEB_PORT `
        --web-hostname=$HOST_ADDR `
        --base-href="$BASE_HREF" `
        "--dart-define=KH_API_BASE_URL=$API_BASE" `
        "--dart-define=KH_API_BASE=$API_BASE" `
        "--dart-define=KH_FLAVOR=$FLAVOR" `
        @args
} finally {
    Pop-Location
}
