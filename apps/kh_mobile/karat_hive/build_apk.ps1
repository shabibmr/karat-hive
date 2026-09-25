#!/usr/bin/env pwsh
# build_apk.ps1 — Build release APK and rename output to karat_hive.v-{version}.apk

$ErrorActionPreference = "Stop"
$ProjectRoot = $PSScriptRoot

# Read version from pubspec.yaml
$pubspec     = Get-Content "$ProjectRoot\pubspec.yaml" | Where-Object { $_ -match "^version:" }
$versionFull = ($pubspec -split ":")[1].Trim()           # e.g. "1.0.0+1"
$version     = $versionFull -split "\+" | Select-Object -First 1  # e.g. "1.0.0"

Write-Host "▶ Building release APK for karat_hive v$version..." -ForegroundColor Cyan

# Run flutter build
flutter build apk --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Build failed." -ForegroundColor Red
    exit 1
}

# Rename output
$apkDir  = "$ProjectRoot\build\app\outputs\flutter-apk"
$source  = "$apkDir\app-release.apk"
$dest    = "$apkDir\karat_hive.v-$version.apk"

if (Test-Path $dest) { Remove-Item $dest -Force }
Rename-Item -Path $source -NewName "karat_hive.v-$version.apk"

Write-Host ""
Write-Host "✓ APK ready: $dest" -ForegroundColor Green
Write-Host "  Size: $([math]::Round((Get-Item $dest).Length / 1MB, 1)) MB"
