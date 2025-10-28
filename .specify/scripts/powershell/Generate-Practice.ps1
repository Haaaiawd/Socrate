#!/usr/bin/env pwsh
# Generate-Practice.ps1
# Ensure exercises directory exists, AI will create .ipynb files

[CmdletBinding()]
param(
    [Parameter()]
    [string]$ProjectRoot = (Get-Location).Path,
    
    [switch]$Json
)

$ErrorActionPreference = 'Stop'

# Step 1: Check chapters exist
$chaptersDir = Join-Path $ProjectRoot "data/chapters"
if (-not (Test-Path $chaptersDir)) {
    Write-Error "Chapters not found. Run /teacherkit.prepare first."
    exit 1
}

$chapterFiles = Get-ChildItem -Path $chaptersDir -Filter "Chapter*.md"
if ($chapterFiles.Count -eq 0) {
    Write-Error "No Chapter files found. Run /teacherkit.prepare first."
    exit 1
}

# Step 2: Ensure exercises directory
$exercisesDir = Join-Path $ProjectRoot "data/exercises"
if (-not (Test-Path $exercisesDir)) {
    New-Item -ItemType Directory -Path $exercisesDir -Force | Out-Null
}

# Step 3: Output
if ($Json) {
    [PSCustomObject]@{
        CHAPTERS_DIR = $chaptersDir
        EXERCISES_DIR = $exercisesDir
        CHAPTER_COUNT = $chapterFiles.Count
        STATUS = "ready"
    } | ConvertTo-Json -Compress
} else {
    Write-Host "`n✅ Ready to generate exercises" -ForegroundColor Green
    Write-Host "Chapters: $($chapterFiles.Count) files" -ForegroundColor White
    Write-Host "Output: $exercisesDir" -ForegroundColor White
    Write-Host "`nNext: AI generates .ipynb via /teacherkit.practice" -ForegroundColor Cyan
}

exit 0
