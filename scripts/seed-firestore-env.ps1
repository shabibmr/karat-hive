<#
.SYNOPSIS
    Seeds or updates the app_config/environment document in Firestore with API base URLs.
.PARAMETER DevUrl
    API URL for the dev flavor. Defaults to https://algoray.cloud/kh_api.
.PARAMETER StagingUrl
    API URL for the staging flavor. Defaults to https://staging.algoray.cloud/kh_api.
.PARAMETER ProdUrl
    API URL for the prod flavor. Defaults to https://algoray.cloud/kh_api.
.PARAMETER ProjectId
    Firebase project ID. Defaults to karat-hive-app.
#>
param(
    [string]$DevUrl = "https://algoray.cloud/kh_api",
    [string]$StagingUrl = "https://staging.algoray.cloud/kh_api",
    [string]$ProdUrl = "https://algoray.cloud/kh_api",
    [string]$ProjectId = "karat-hive-app"
)

$ErrorActionPreference = 'Stop'

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " Seeding Firestore app_config/environment" -ForegroundColor Cyan
Write-Host " Project ID : $ProjectId"
Write-Host " Dev URL    : $DevUrl"
Write-Host " Staging URL: $StagingUrl"
Write-Host " Prod URL   : $ProdUrl"
Write-Host "============================================================" -ForegroundColor Cyan

$endpoint = "https://firestore.googleapis.com/v1/projects/$ProjectId/databases/(default)/documents/app_config/environment"

$body = @{
    fields = @{
        api_base_url_dev = @{ stringValue = $DevUrl }
        api_base_url_staging = @{ stringValue = $StagingUrl }
        api_base_url_prod = @{ stringValue = $ProdUrl }
    }
} | ConvertTo-Json -Depth 5

try {
    $response = Invoke-RestMethod -Uri $endpoint -Method Patch -Body $body -ContentType "application/json"
    Write-Host "==> Success! Document written to $ProjectId:" -ForegroundColor Green
    Write-Host ($response | ConvertTo-Json -Depth 5)
} catch {
    Write-Error "Failed to write to Firestore: $_"
    exit 1
}
