#!/usr/bin/env pwsh
# Generate-Outline.ps1
# Copy outline template to data/outlines/ for AI to edit

[CmdletBinding()]
param(
    [Parameter()]
    [string]$ProjectRoot = (Get-Location).Path,
    
    [Parameter()]
    [string]$Topic,
    
    [switch]$Json
)

$ErrorActionPreference = 'Stop'

# Step 1: Ensure directories exist
$outlinesDir = Join-Path $ProjectRoot "data/outlines"
if (-not (Test-Path $outlinesDir)) {
    New-Item -ItemType Directory -Path $outlinesDir -Force | Out-Null
}

# Step 2: Generate filename
if ($Topic) {
    $slug = $Topic -replace '\s+', '-' -replace '[^\w\-]', '' | ForEach-Object { $_.ToLower() }
    $filename = "$slug-outline.md"
} else {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $filename = "outline-$timestamp.md"
}

$outputPath = Join-Path $outlinesDir $filename

# Step 3: Copy template
$templatePath = Join-Path $ProjectRoot ".specify/templates/outline-template.md"
if (-not (Test-Path $templatePath)) {
    Write-Error "Outline template not found: $templatePath"
    exit 1
}

Copy-Item -Path $templatePath -Destination $outputPath -Force

# Step 4: Output result
if ($Json) {
    [PSCustomObject]@{
        OUTLINE_FILE = $outputPath
        OUTLINES_DIR = $outlinesDir
        STATUS = "template_copied"
    } | ConvertTo-Json -Compress
} else {
    Write-Host "`n✅ Outline template created" -ForegroundColor Green
    Write-Host "File: $outputPath" -ForegroundColor White
    Write-Host "`nNext: AI edits this file via /teacherkit.outline" -ForegroundColor Cyan
}

exit 0
