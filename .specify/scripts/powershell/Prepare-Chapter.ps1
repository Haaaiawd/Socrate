# Prepare-Chapter.ps1
# Prepare teaching materials for a specific chapter using AI

param(
    [Parameter(Mandatory=$true)]
    [string]$OutlinePath,
    
    [Parameter(Mandatory=$true)]
    [int]$ChapterNumber,
    
    [Parameter()]
    [string]$OutputPath,
    
    [Parameter()]
    [string]$ProjectRoot = (Get-Location).Path
)

# Import common modules
. "$PSScriptRoot/common/logging.ps1"
. "$PSScriptRoot/common/markdown.ps1"
. "$PSScriptRoot/common/validation.ps1"

Initialize-Logger -LogPath "$ProjectRoot/logs/teacherkit.log"

Write-LogInfo "=== Prepare Chapter ==="
Write-LogInfo "Outline: $OutlinePath"
Write-LogInfo "Chapter: $ChapterNumber"

# Step 1: Validate outline file
if (-not (Test-Path $OutlinePath)) {
    Write-LogError "Outline file not found: $OutlinePath"
    exit 1
}

$validation = Test-MarkdownStructure -Path $OutlinePath -RequireFrontmatter
if (-not $validation.Valid) {
    Write-LogError "Outline validation failed:"
    $validation.Errors | ForEach-Object { Write-LogError "  - $_" }
    exit 1
}

Write-LogInfo "Outline validated"

# Step 2: Read outline
try {
    $outline = Read-Markdown -Path $OutlinePath
    
    if (-not $outline.frontmatter) {
        Write-LogError "Outline missing frontmatter"
        exit 1
    }
    
    $textbookName = $outline.frontmatter.source_textbook
    $totalChapters = $outline.frontmatter.total_chapters
    
    Write-LogInfo "Textbook: $textbookName, Total Chapters: $totalChapters"
    
    if ($ChapterNumber -lt 1 -or $ChapterNumber -gt $totalChapters) {
        Write-LogError "Invalid chapter number: $ChapterNumber (valid range: 1-$totalChapters)"
        exit 1
    }
}
catch {
    Write-LogError "Failed to read outline: $_"
    exit 1
}

# Step 3: Extract chapter content from outline
Write-LogDebug "Extracting chapter $ChapterNumber from outline"

# Parse chapter summaries section
$content = $outline.content
$chapterPattern = "(?ms)### Chapter $ChapterNumber[:\s]+(.+?)(?=### Chapter \d+|## Recommended Learning Path|$)"

if ($content -match $chapterPattern) {
    $chapterSummary = $matches[1].Trim()
    Write-LogInfo "Chapter summary extracted ($(($chapterSummary -split "`n").Count) lines)"
}
else {
    Write-LogError "Chapter $ChapterNumber not found in outline"
    Write-LogDebug "Searched pattern: $chapterPattern"
    exit 1
}

# Extract chapter title
$titlePattern = "### Chapter $ChapterNumber[:\s]+(.+)"
if ($content -match $titlePattern) {
    $chapterTitle = $matches[1].Trim()
    # Remove markdown formatting
    $chapterTitle = $chapterTitle -replace '\*\*', '' -replace '\*', ''
    Write-LogInfo "Chapter title: $chapterTitle"
}
else {
    $chapterTitle = "Chapter $ChapterNumber"
    Write-LogWarn "Could not extract chapter title, using default: $chapterTitle"
}

# Step 4: Load chapter template
$templatePath = "$ProjectRoot/.specify/templates/chapter-template.md"
if (-not (Test-Path $templatePath)) {
    Write-LogError "Chapter template not found: $templatePath"
    exit 1
}

$template = Read-Markdown -Path $templatePath
Write-LogDebug "Loaded chapter template"

# Step 5: Load teaching prompt template for context
$teachingTemplatePath = "$ProjectRoot/.specify/templates/teaching-prompt-template.md"
$teachingGuidelines = ""
if (Test-Path $teachingTemplatePath) {
    $teachingTemplate = Read-Markdown -Path $teachingTemplatePath
    $teachingGuidelines = $teachingTemplate.content
    Write-LogDebug "Loaded teaching guidelines"
}

# Step 6: Generate output path
if (-not $OutputPath) {
    $outputDir = "$ProjectRoot/data/chapters"
    if (-not (Test-Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }
    
    # Sanitize chapter title for filename
    $safeTitle = $chapterTitle -replace '[\\/:*?"<>|]', '-'
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $OutputPath = "$outputDir/chapter-$ChapterNumber-$safeTitle-$timestamp.md"
}

# Step 7: Prepare AI prompt
$aiPrompt = @"
You are an expert teaching material designer following Socratic teaching principles.

**Task:** Prepare comprehensive teaching materials for the following chapter.

**Chapter Summary from Outline:**
$chapterSummary

**Teaching Philosophy (from your training):**
$teachingGuidelines

**Your Goal:**
Create detailed teaching materials that will help an AI tutor guide students through this chapter using Socratic questioning and progressive scaffolding.

**Required Output Format:** Follow the chapter-template.md structure with YAML frontmatter.

### YAML Frontmatter Requirements:
```yaml
---
chapter_number: $ChapterNumber
title: "$chapterTitle"
knowledge_points:
  - "KP1: [Specific concept]"
  - "KP2: [Another concept]"
  - ...
difficulty: beginner|intermediate|advanced
estimated_time_hours: X
prepared_at: "$(Get-Date -Format 'yyyy-MM-ddTHH:mm:ss')"
---
```

### Content Structure:

#### 1. Chapter Overview
- Brief introduction (2-3 paragraphs)
- Why this chapter matters
- How it connects to previous/future chapters

#### 2. Knowledge Points (Detailed)
For each knowledge point, provide:

**KP#: [Concept Name]**

*Definition:* Clear, precise definition

*Why It Matters:* Real-world relevance

*Guiding Questions:* (Socratic questions to lead discovery)
- Level 1 (Clarifying): "What do you think X means?"
- Level 2 (Probing): "Why might we need X in this context?"
- Level 3 (Rationale): "How would you explain X to someone else?"
- Level 4 (Application): "Can you think of a situation where X would be useful?"

*Common Misconceptions:* What students often get wrong

*Hint Progression:* (4-level scaffolding)
- Hint 1 (Minimal): Nudge toward key concept
- Hint 2 (Directional): Point to relevant area
- Hint 3 (Structured): Break down into sub-questions
- Hint 4 (Almost There): Near-complete guidance

*Check Understanding:* Questions to verify mastery

#### 3. Practice Exercises
Design 3-5 exercises progressing from easy to challenging:

**Exercise 1: [Title]** (Difficulty: ⭐)
- Problem statement
- Expected approach (for tutor reference)
- Key concepts tested
- Guiding questions if student is stuck

[... continue for all exercises ...]

#### 4. Chapter Summary
- Key takeaways (bullet points)
- Connections to other chapters
- Prerequisites for next chapter

---

**Important Guidelines:**
- Never provide direct answers in guiding questions
- Design questions that build on previous knowledge
- Include 4-level hint progressions for complex concepts
- Ensure exercises test understanding, not memorization
- Use real-world examples where possible

**Generate the complete chapter teaching materials now.**
"@

# Step 8: Output prompt for AI processing
$promptFile = "$ProjectRoot/logs/prepare-chapter-$ChapterNumber-prompt-$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
$aiPrompt | Out-File -FilePath $promptFile -Encoding utf8

Write-LogInfo "AI prompt saved to: $promptFile"
Write-LogInfo "=== Manual Processing Required ==="
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Open VS Code and run command: /teacherkit.prepare" -ForegroundColor White
Write-Host "2. Provide chapter number: $ChapterNumber" -ForegroundColor White
Write-Host "3. Paste the chapter summary when prompted" -ForegroundColor White
Write-Host "4. Save AI response to: $OutputPath" -ForegroundColor White
Write-Host ""

# Step 9: Create placeholder chapter file
$placeholderFrontmatter = @{
    chapter_number = $ChapterNumber
    title = $chapterTitle
    knowledge_points = @("Pending AI processing")
    difficulty = "unknown"
    estimated_time_hours = 0
    prepared_at = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
    status = "pending_ai_processing"
}

$placeholderContent = @"
## Chapter Overview

*This chapter is pending AI processing. Use VS Code prompt /teacherkit.prepare to complete.*

**From Outline:**
$chapterSummary

## Knowledge Points

*Knowledge points will be detailed here after AI processing.*

## Practice Exercises

*Exercises will be generated here after AI processing.*

## Chapter Summary

*Summary will be provided here after AI processing.*
"@

Write-Markdown -Path $OutputPath -Frontmatter $placeholderFrontmatter -Content $placeholderContent

Write-LogInfo "Placeholder chapter created: $OutputPath"
Write-LogInfo "=== Preparation Complete ==="
Write-LogInfo "Use VS Code prompt /teacherkit.prepare to complete AI processing"

# Return success with output path
Write-Output $OutputPath
exit 0
