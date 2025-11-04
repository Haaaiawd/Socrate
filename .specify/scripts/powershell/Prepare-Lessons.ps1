#!/usr/bin/env pwsh
# Prepare-Lessons.ps1 (UbD flow)
# Create UbD lesson plan skeletons and assessment placeholders from an outline

param(
    [Parameter()]
    [string]$OutlineFile,
    
    [Parameter()]
    [string]$ProjectRoot = (Get-Location).Path
)

# Find outline file if not specified
if (-not $OutlineFile) {
    $outlines = Get-ChildItem "$ProjectRoot/outlines/*.md" -ErrorAction SilentlyContinue
    if ($outlines.Count -eq 0) {
        Write-Host "[ERROR] No outline files found in outlines/" -ForegroundColor Red
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

# Ensure target directories
$lessonsDir = Join-Path $ProjectRoot "lessons"
if (-not (Test-Path $lessonsDir)) { New-Item -ItemType Directory -Path $lessonsDir -Force | Out-Null }

# Process each KP → create lesson plan + assessment placeholders
$created = 0
$skipped = 0
$assessCreated = 0

foreach ($match in $kpMatches) {
    $kpId = "KP-$($match.Groups[1].Value)"
    $kpTitle = $match.Groups[2].Value.Trim()

    $lessonFile = Join-Path $lessonsDir ("$kpId-plan.md")

    if (Test-Path $lessonFile) {
        Write-Host "[SKIP] $kpId lesson plan exists" -ForegroundColor Yellow
        $skipped++
    } else {
    $content = @"
# Lesson Plan: $kpId — $kpTitle

## Stage 1: Understanding by Design (UbD)
- Enduring Understandings (EU):
- Essential Questions (EQ):
- SWBAT:
- Misconceptions:
- Prerequisites:

## Runbook
- Opening (activate prior knowledge):
- Probes (Socratic questions + expected indicators):
- CFU checkpoints (3–5) with follow-ups:
- Consolidation (summary/analogy):
- Exit Ticket overview (2–3) + brief Rubric:
"@
        $content | Set-Content -Path $lessonFile -Encoding UTF8
        Write-Host "[OK] Created lesson plan: $lessonFile" -ForegroundColor Green
        $created++
    }

    # Note: Assessments (CFU/Exit Ticket) are embedded in the lesson plan sections above.
}

Write-Host ""
Write-Host "[SUMMARY]" -ForegroundColor Green
Write-Host "  Lesson plans created: $created" -ForegroundColor Cyan
Write-Host "  Lesson plans skipped: $skipped" -ForegroundColor Yellow
Write-Host "  Assessment placeholders created: $assessCreated" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. 完善 lessons 下的 UbD 字段与 Runbook" -ForegroundColor White
Write-Host "2. 使用 /socrate.lesson 细化 CFU/Exit Ticket，并用 /socrate.check 进行质量校验" -ForegroundColor White

exit 0
