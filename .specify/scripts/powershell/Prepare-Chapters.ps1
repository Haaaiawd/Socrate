# Prepare-Chapters.ps1
# Batch create chapter files from an outline

# [DEPRECATED] This script is deprecated in UbD-only flow.
Write-Host "[DEPRECATED] Prepare-Chapters.ps1 is no longer used. Use Prepare-Lessons.ps1 instead." -ForegroundColor Yellow
Write-Host "Location: .specify/scripts/powershell/Prepare-Lessons.ps1" -ForegroundColor Yellow
return
exit 0

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
#!/usr/bin/env pwsh
# Prepare-Chapters.ps1 (UbD flow)
# Repurposed: Batch create UbD lesson plan skeletons and assessment placeholders from an outline

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

# Ensure target directories
$lessonsDir = Join-Path $ProjectRoot "data/lessons"
if (-not (Test-Path $lessonsDir)) { New-Item -ItemType Directory -Path $lessonsDir -Force | Out-Null }
$assessDir = Join-Path $ProjectRoot "data/assessments"
if (-not (Test-Path $assessDir)) { New-Item -ItemType Directory -Path $assessDir -Force | Out-Null }

# Process each KP → create lesson plan + assessment placeholders
$created = 0
$skipped = 0
$assessCreated = 0

foreach ($match in $kpMatches) {
    $kpId = "KP-$($match.Groups[1].Value)"
    $kpTitle = $match.Groups[2].Value.Trim()

    $lessonFile = Join-Path $lessonsDir ("$kpId-plan.md")
    $cfuFile = Join-Path $assessDir ("$kpId-cfu.md")
    $ticketFile = Join-Path $assessDir ("$kpId-exit-ticket.md")

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

## Links
- CFU file: $([IO.Path]::GetFileName($cfuFile))
- Exit Ticket file: $([IO.Path]::GetFileName($ticketFile))
"@
        $content | Set-Content -Path $lessonFile -Encoding UTF8
        Write-Host "[OK] Created lesson plan: $lessonFile" -ForegroundColor Green
        $created++
    }

    if (-not (Test-Path $cfuFile)) {
        @"# CFU: $kpId — $kpTitle

- Add 3–5 CFU items aligned with SWBAT and misconceptions
- Each item should include expected response indicators and follow-ups
"@ | Set-Content -Path $cfuFile -Encoding UTF8
        $assessCreated++
    }
    if (-not (Test-Path $ticketFile)) {
        @"# Exit Ticket: $kpId — $kpTitle

- Add 2–3 items that give direct evidence of SWBAT
- Include a brief grading rubric
"@ | Set-Content -Path $ticketFile -Encoding UTF8
        $assessCreated++
    }
}

Write-Host ""
Write-Host "[SUMMARY]" -ForegroundColor Green
Write-Host "  Lesson plans created: $created" -ForegroundColor Cyan
Write-Host "  Lesson plans skipped: $skipped" -ForegroundColor Yellow
Write-Host "  Assessment placeholders created: $assessCreated" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. 完善 data/lessons 下的 UbD 字段与 Runbook" -ForegroundColor White
Write-Host "2. 使用 /socrate.lesson 细化 CFU/Exit Ticket，并用 /socrate.check 进行质量校验" -ForegroundColor White

exit 0
