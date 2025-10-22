# Parse-Textbook.ps1
# Parse textbook and generate structured outline using AI

param(
    [Parameter(Mandatory=$true)]
    [string]$TextbookPath,
    
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

Write-LogInfo "=== Parse Textbook ==="
Write-LogInfo "Textbook: $TextbookPath"

# Step 1: Validate textbook
$validation = Test-Textbook -Path $TextbookPath
if (-not $validation.Valid) {
    Write-LogError "Textbook validation failed:"
    $validation.Errors | ForEach-Object { Write-LogError "  - $_" }
    exit 1
}

Write-LogInfo "Textbook validated: $($validation.Format), $($validation.LineCount) lines, $($validation.HeadingCount) headings"

# Step 2: Read textbook content
try {
    $textbookContent = Get-Content -Path $TextbookPath -Raw
    $textbookName = [System.IO.Path]::GetFileNameWithoutExtension($TextbookPath)
}
catch {
    Write-LogError "Failed to read textbook: $_"
    exit 1
}

# Step 3: Load outline template
$templatePath = "$ProjectRoot/.specify/templates/outline-template.md"
if (-not (Test-Path $templatePath)) {
    Write-LogError "Outline template not found: $templatePath"
    exit 1
}

$template = Read-Markdown -Path $templatePath
Write-LogDebug "Loaded outline template"

# Step 4: Generate output path
if (-not $OutputPath) {
    $outputDir = "$ProjectRoot/data/outlines"
    if (-not (Test-Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $OutputPath = "$outputDir/$textbookName-outline-$timestamp.md"
}

# Step 5: Prepare AI prompt
$aiPrompt = @"
You are an expert educational content analyzer. Your task is to parse the following textbook and generate a structured course outline.

**Requirements:**
1. Identify all chapters and major topics
2. For each chapter, summarize:
   - Chapter number and title
   - Main learning objectives
   - Key concepts covered
   - Estimated difficulty level (beginner/intermediate/advanced)
   - Estimated study time in hours

3. Create a learning path that orders chapters logically

**Output format:** Use the provided template structure with YAML frontmatter.

**Textbook content:**

$textbookContent

---

Generate the outline following the template structure. Include YAML frontmatter with:
- title: Course title
- generated_at: Current timestamp
- source_textbook: Textbook filename
- total_chapters: Number of chapters detected

Then provide:
1. Course Overview (2-3 paragraphs)
2. Chapter Summaries (one section per chapter)
3. Recommended Learning Path
"@

# Step 6: Output prompt for AI processing
# Note: In MVP, we output the prompt for manual processing
# Future versions will integrate with AI SDK

$promptFile = "$ProjectRoot/logs/parse-textbook-prompt-$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
$aiPrompt | Out-File -FilePath $promptFile -Encoding utf8

Write-LogInfo "AI prompt saved to: $promptFile"
Write-LogInfo "=== Manual Processing Required ==="
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Open the prompt file: $promptFile" -ForegroundColor White
Write-Host "2. Use VS Code command: /teacherkit.parse" -ForegroundColor White
Write-Host "3. Paste the textbook content when prompted" -ForegroundColor White
Write-Host "4. Save the AI response to: $OutputPath" -ForegroundColor White
Write-Host ""

# Step 7: Prepare placeholder outline
$placeholderFrontmatter = @{
    title = "Course Outline for $textbookName"
    generated_at = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
    source_textbook = $textbookName
    total_chapters = $validation.HeadingCount
    status = "pending_ai_processing"
}

$placeholderContent = @"
## Course Overview

*This outline is pending AI processing. Use VS Code prompt /teacherkit.parse to complete.*

## Chapter Summaries

*Chapters will be listed here after AI processing.*

## Recommended Learning Path

*Learning path will be generated here after AI processing.*
"@

Write-Markdown -Path $OutputPath -Frontmatter $placeholderFrontmatter -Content $placeholderContent

Write-LogInfo "Placeholder outline created: $OutputPath"
Write-LogInfo "=== Parsing Complete ==="
Write-LogInfo "Use VS Code prompt /teacherkit.parse to complete AI processing"

# Return success
exit 0
