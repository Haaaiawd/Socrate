#!/usr/bin/env pwsh
# Prepare-Chapters.ps1
# Ensure chapters directory exists, AI will create Chapter*.md files

[CmdletBinding()]
param(
    [Parameter()]
    [string]$ProjectRoot = (Get-Location).Path,
    
    [switch]$Json
)

$ErrorActionPreference = 'Stop'

# Step 1: Check outline exists
$outlinesDir = Join-Path $ProjectRoot "data/outlines"
if (-not (Test-Path $outlinesDir)) {
    Write-Error "No outlines found. Run Generate-Outline.ps1 first."
    exit 1
}

$outlineFiles = Get-ChildItem -Path $outlinesDir -Filter "*.md" | Sort-Object LastWriteTime -Descending
if ($outlineFiles.Count -eq 0) {
    Write-Error "No outline files found. Run /teacherkit.outline first."
    exit 1
}

$latestOutline = $outlineFiles[0].FullName

# Step 2: Ensure chapters directory
$chaptersDir = Join-Path $ProjectRoot "data/chapters"
if (-not (Test-Path $chaptersDir)) {
    New-Item -ItemType Directory -Path $chaptersDir -Force | Out-Null
}

# Step 3: Check template
$templatePath = Join-Path $ProjectRoot ".specify/templates/chapter-template.md"
if (-not (Test-Path $templatePath)) {
    Write-Error "Chapter template not found: $templatePath"
    exit 1
}

# Step 4: Output
if ($Json) {
    [PSCustomObject]@{
        OUTLINE_FILE = $latestOutline
        CHAPTERS_DIR = $chaptersDir
        TEMPLATE_PATH = $templatePath
        STATUS = "ready"
    } | ConvertTo-Json -Compress
} else {
    Write-Host "`n✅ Ready to generate chapters" -ForegroundColor Green
    Write-Host "Outline: $latestOutline" -ForegroundColor White
    Write-Host "Output: $chaptersDir" -ForegroundColor White
    Write-Host "`nNext: AI generates Chapter*.md via /teacherkit.prepare" -ForegroundColor Cyan
}

exit 0
