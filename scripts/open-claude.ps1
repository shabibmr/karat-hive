#Requires -Version 7
<#
.SYNOPSIS
    Launch the Claude Code CLI rooted at a directory (default: current).
.DESCRIPTION
    If the first argument is an existing directory, the session is rooted there
    and that argument is consumed; every remaining argument is passed straight
    through to `claude`.
.EXAMPLE
    pwsh -File scripts/open-claude.ps1
    pwsh -File scripts/open-claude.ps1 E:\work\other
    pwsh -File scripts/open-claude.ps1 --resume
    pwsh -File scripts/open-claude.ps1 E:\work\other -p "hello"
#>

$rest = @($args)
$target = (Get-Location).Path

if ($rest.Count -gt 0 -and (Test-Path -LiteralPath $rest[0] -PathType Container)) {
    $target = (Resolve-Path -LiteralPath $rest[0]).Path
    $rest = @($rest | Select-Object -Skip 1)
}

if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Error "'claude' CLI not found on PATH. Install: npm i -g @anthropic-ai/claude-code"
    exit 1
}

Set-Location -LiteralPath $target
Write-Host "Launching Claude Code in $target" -ForegroundColor Cyan
& claude @rest
exit $LASTEXITCODE
