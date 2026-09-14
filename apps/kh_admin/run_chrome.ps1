#Requires -Version 5.1
[CmdletBinding()]
param (
    [Parameter(Position = 0)]
    [int]$Port = $(if ($env:WEB_PORT) { [int]$env:WEB_PORT } else { 5000 }),

    [Parameter(Position = 1)]
    [string]$BaseHref = $(if ($env:BASE_HREF) { $env:BASE_HREF } else { "/" }),

    [string]$ApiBase = $(if ($env:KH_API_BASE) { $env:KH_API_BASE } else { "https://algoray.cloud/kh_api/" }),
    [string]$Flavor = $(if ($env:KH_FLAVOR) { $env:KH_FLAVOR } else { "prod" }),

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$AdditionalArgs
)

$ErrorActionPreference = 'Continue'

# Locate the kh_admin app directory
$APP_DIR = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$BUILD_DIR = Join-Path $APP_DIR "build"

# Ensure build directory exists
if (-not (Test-Path -LiteralPath $BUILD_DIR)) {
    New-Item -ItemType Directory -Force -Path $BUILD_DIR | Out-Null
}

$TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"
$LATEST_LOG = Join-Path $BUILD_DIR "run_chrome.log"
$TIMESTAMPED_LOG = Join-Path $BUILD_DIR "run_chrome_${TIMESTAMP}.log"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " Running kh_admin on Chrome" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " App Directory : $APP_DIR"
Write-Host " Device        : chrome"
Write-Host " Web Port      : $Port (http://localhost:$Port)"
Write-Host " Base HREF     : $BaseHref"
Write-Host " API Base      : $ApiBase"
Write-Host " Flavor        : $Flavor"
Write-Host " Log Files     : $LATEST_LOG"
Write-Host "                 $TIMESTAMPED_LOG"
Write-Host " Monitor live  : Get-Content -Wait -Tail 30 '$LATEST_LOG'" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "'flutter' command not found on PATH."
    exit 1
}

# Clean stale lockfiles if present
$FLUTTER_LOCK = "E:\flutter\bin\cache\lockfile"
$FLUTTER_BAT_LOCK = "E:\flutter\bin\cache\flutter.bat.lock"
if (Test-Path -LiteralPath $FLUTTER_LOCK) {
    Remove-Item -LiteralPath $FLUTTER_LOCK -Force -ErrorAction SilentlyContinue
}
if (Test-Path -LiteralPath $FLUTTER_BAT_LOCK) {
    Remove-Item -LiteralPath $FLUTTER_BAT_LOCK -Force -ErrorAction SilentlyContinue
}

Push-Location -LiteralPath $APP_DIR
try {
    # Initialize log file
    "[$TIMESTAMP] Launching kh_admin on Chrome at http://localhost:$Port" | Out-File -FilePath $LATEST_LOG -Encoding utf8

    $flutterArgs = @(
        "run",
        "-d", "chrome",
        "--web-port=$Port",
        "--base-href=$BaseHref",
        "--web-browser-flag=--disable-web-security",
        "--web-browser-flag=--disable-site-isolation-trials",
        "--dart-define=KH_API_BASE=$ApiBase",
        "--dart-define=KH_FLAVOR=$Flavor"
    )

    if ($AdditionalArgs -and $AdditionalArgs.Count -gt 0) {
        $flutterArgs += $AdditionalArgs
    }

    # Run flutter on Chrome and stream output to both console and log file
    & flutter @flutterArgs 2>&1 | Tee-Object -FilePath $LATEST_LOG -Append

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
