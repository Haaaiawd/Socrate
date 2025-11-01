# Prepare-Chapters.ps1
# Batch create chapter files from an outline

param(
    [Parameter()]
    [string]$OutlineFile,
    
    [Parameter()]
    [string]$ProjectRoot = (Get-Location).Path
)

# Find outline file if not specified
if (-not $OutlineFile) {
    $outlines = Get-ChildItem "$ProjectRoot/data/outlines/*.md" -ErrorAction SilentlyContinue
    if ($outlines.Count -eq 0) {
        Write-Host "[ERROR] No outline files found in data/outlines/" -ForegroundColor Red
        Write-Host "Run /socrate.outline first to create an outline." -ForegroundColor Yellow
        exit 1
    }
    
    # Use the most recent outline
    $OutlineFile = ($outlines | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName
    Write-Host "[INFO] Using outline: $OutlineFile" -ForegroundColor Cyan
}

# Validate outline file exists
if (-not (Test-Path $OutlineFile)) {
    Write-Host "[ERROR] Outline file not found: $OutlineFile" -ForegroundColor Red
    exit 1
}

# Parse outline file for KP IDs
Write-Host "[INFO] Parsing outline for knowledge points..." -ForegroundColor Cyan

$outlineContent = Get-Content -Path $OutlineFile -Raw
$kpPattern = '\*\*KP-(\d+\.\d+\.\d+)\*\*:\s*(.+?)(?=\r?\n\s*-\s*Difficulty:)'
$kpMatches = [regex]::Matches($outlineContent, $kpPattern)

if ($kpMatches.Count -eq 0) {
    Write-Host "[ERROR] No knowledge points found in outline file" -ForegroundColor Red
    Write-Host "Expected format: **KP-1.1.1**: Concept Name" -ForegroundColor Yellow
    exit 1
}

Write-Host "[INFO] Found $($kpMatches.Count) knowledge points" -ForegroundColor Green

# Create chapters directory
$chaptersDir = "$ProjectRoot/data/chapters"
if (-not (Test-Path $chaptersDir)) {
    New-Item -ItemType Directory -Path $chaptersDir -Force | Out-Null
}

# Process each KP
$created = 0
$skipped = 0

foreach ($match in $kpMatches) {
    $kpId = "KP-$($match.Groups[1].Value)"
    $kpTitle = $match.Groups[2].Value.Trim()
    
    $chapterFile = "$chaptersDir/Chapter-$kpId.md"
    
    # Skip if file already exists
    if (Test-Path $chapterFile) {
        Write-Host "[SKIP] $kpId (file already exists)" -ForegroundColor Yellow
        $skipped++
        continue
    }
    
    # Call Copy-Chapter-Template.ps1
    & "$PSScriptRoot\Copy-Chapter-Template.ps1" -KpId $kpId -Title $kpTitle -ProjectRoot $ProjectRoot
    
    if ($LASTEXITCODE -eq 0) {
        $created++
    }
}

Write-Host ""
Write-Host "[SUMMARY]" -ForegroundColor Green
Write-Host "  Created: $created chapters" -ForegroundColor Cyan
Write-Host "  Skipped: $skipped chapters" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Review chapter files in data/chapters/" -ForegroundColor White
Write-Host "2. Run /socrate.practice to generate exercises" -ForegroundColor White

exit 0
