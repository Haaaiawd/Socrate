# Generate-Outline.ps1
# Create an empty outline template for a learning topic

param(
    [Parameter(Mandatory=$true)]
    [string]$Topic,
    
    [Parameter()]
    [string]$ProjectRoot = (Get-Location).Path
)

# Normalize topic to filename
$topicSlug = $Topic.ToLower() -replace '[^a-z0-9]+', '-' -replace '^-|-$', ''
$outlineFile = "$ProjectRoot/outlines/$topicSlug-outline.md"

# Ensure directory exists
$outlineDir = Split-Path -Parent $outlineFile
if (-not (Test-Path $outlineDir)) {
    New-Item -ItemType Directory -Path $outlineDir -Force | Out-Null
}

# Check if file already exists
if (Test-Path $outlineFile) {
    Write-Host "[INFO] Outline file already exists: $outlineFile" -ForegroundColor Yellow
    Write-Host "Use this file, or delete it to create a new one." -ForegroundColor Yellow
    exit 0
}

# Create outline template
$templateContent = @"
---
title: "$Topic"
topic: "$Topic"
target_audience: "intermediate"
difficulty: "intermediate"
estimated_total_hours: 0
generated_date: "$(Get-Date -Format 'yyyy-MM-dd')"
---

# Learning Outline: $Topic

## Chapter 1: [Foundational Topic]

### Topic 1.1: [Subtopic Name]

**Overview**: [1-2 sentences describing this topic]

**Knowledge Points**:
- **KP-1.1.1**: [Concept Name]
  - Difficulty: medium
  - Time: 30min
  - Prerequisites: []
  - Introduction: [Question/Scenario/Contrast approach]

- **KP-1.1.2**: [Concept Name]
  - Difficulty: medium
  - Time: 30min
  - Prerequisites: ["KP-1.1.1"]
  - Introduction: [Question/Scenario/Contrast approach]

### Topic 1.2: [Subtopic Name]

**Overview**: [1-2 sentences describing this topic]

**Knowledge Points**:
- **KP-1.2.1**: [Concept Name]
  - Difficulty: medium
  - Time: 30min
  - Prerequisites: ["KP-1.1.2"]
  - Introduction: [Question/Scenario/Contrast approach]

---

## Chapter 2: [Advanced Topic]

### Topic 2.1: [Subtopic Name]

**Overview**: [1-2 sentences describing this topic]

**Knowledge Points**:
- **KP-2.1.1**: [Concept Name]
  - Difficulty: hard
  - Time: 45min
  - Prerequisites: ["KP-1.2.1"]
  - Introduction: [Question/Scenario/Contrast approach]

---

## Review Phase: $Topic Mastery

**Practice Focus**: Apply all concepts to real problems.

### Review 1: [Chapter 1 Integration]
- Combine KP-1.1.1, KP-1.1.2, KP-1.2.1
- Build [mini-project description]
- Time: 2 hours

### Final Project: [Comprehensive Application]
- Integrate all chapters
- Build [complete project description]
- Time: 4-6 hours
"@

# Write template file
try {
    $templateContent | Out-File -FilePath $outlineFile -Encoding UTF8
    Write-Host "[SUCCESS] Outline template created:" -ForegroundColor Green
    Write-Host "  $outlineFile" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Edit the outline file to add your content" -ForegroundColor White
    Write-Host "2. Run /socrate.outline to fill in details" -ForegroundColor White
    exit 0
}
catch {
    Write-Host "[ERROR] Failed to create outline file: $_" -ForegroundColor Red
    exit 1
}
