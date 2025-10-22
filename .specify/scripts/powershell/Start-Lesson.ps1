# Start-Lesson.ps1
# Initialize a Socratic teaching session for a chapter

param(
    [Parameter(Mandatory=$true)]
    [int]$ChapterNumber,
    
    [Parameter()]
    [string]$KnowledgePointId,
    
    [Parameter()]
    [string]$ProjectRoot = (Get-Location).Path
)

# Import common modules
. "$PSScriptRoot/common/logging.ps1"
. "$PSScriptRoot/common/markdown.ps1"
. "$PSScriptRoot/common/validation.ps1"

Initialize-Logger -LogPath "$ProjectRoot/logs/teacherkit.log"

Write-LogInfo "=== Start Lesson ==="
Write-LogInfo "Chapter: $ChapterNumber"
if ($KnowledgePointId) {
    Write-LogInfo "Resuming at KP: $KnowledgePointId"
}

# Step 1: Find and validate chapter file
$chapterPattern = "$ProjectRoot/data/chapters/*/chapter-$($ChapterNumber.ToString('00')).md"
$chapterFiles = Get-ChildItem -Path $chapterPattern -ErrorAction SilentlyContinue

if (-not $chapterFiles) {
    Write-LogError "Chapter $ChapterNumber not found. Did you run '/teacherkit.prepare $ChapterNumber' first?"
    Write-Host "`nChapter $ChapterNumber has not been prepared yet." -ForegroundColor Red
    Write-Host "Run this command first: " -NoNewline -ForegroundColor Yellow
    Write-Host "/teacherkit.prepare $ChapterNumber" -ForegroundColor Cyan
    exit 1
}

$chapterFile = $chapterFiles[0].FullName
Write-LogInfo "Chapter file: $chapterFile"

# Step 2: Read and parse chapter
try {
    $chapter = Read-Markdown -Path $chapterFile
    
    if (-not $chapter.frontmatter) {
        Write-LogError "Chapter file missing frontmatter"
        exit 1
    }
    
    $chapterTitle = $chapter.frontmatter.chapter_title
    $totalKPs = $chapter.frontmatter.knowledge_points.Count
    $difficulty = $chapter.frontmatter.difficulty
    
    Write-LogInfo "Chapter: $chapterTitle ($difficulty, $totalKPs KPs)"
}
catch {
    Write-LogError "Failed to read chapter file: $_"
    exit 1
}

# Step 3: Read or create progress file
$progressPath = "$ProjectRoot/data/progress/progress.md"
$progressData = @{
    last_chapter = 0
    last_kp_id = ""
    completed_kps = @()
    sessions = @()
}

if (Test-Path $progressPath) {
    try {
        $progressMd = Read-Markdown -Path $progressPath
        if ($progressMd.frontmatter) {
            if ($progressMd.frontmatter.last_chapter) {
                $progressData.last_chapter = $progressMd.frontmatter.last_chapter
            }
            if ($progressMd.frontmatter.last_kp_id) {
                $progressData.last_kp_id = $progressMd.frontmatter.last_kp_id
            }
            if ($progressMd.frontmatter.completed_kps) {
                $progressData.completed_kps = $progressMd.frontmatter.completed_kps
            }
            if ($progressMd.frontmatter.sessions) {
                $progressData.sessions = $progressMd.frontmatter.sessions
            }
        }
        Write-LogDebug "Progress loaded: Last KP = $($progressData.last_kp_id)"
    }
    catch {
        Write-LogWarn "Failed to read progress file, starting fresh: $_"
    }
}
else {
    Write-LogInfo "No progress file found, creating new session"
    # Create directory if needed
    $progressDir = Split-Path -Parent $progressPath
    if (-not (Test-Path $progressDir)) {
        New-Item -ItemType Directory -Path $progressDir -Force | Out-Null
    }
}

# Step 4: Determine starting knowledge point
$startingKP = $null

if ($KnowledgePointId) {
    # User specified KP, validate it exists
    $kpPattern = "### $KnowledgePointId[:\s]"
    if ($chapter.content -match $kpPattern) {
        $startingKP = $KnowledgePointId
        Write-LogInfo "Starting at specified KP: $startingKP"
    }
    else {
        Write-LogError "Knowledge point $KnowledgePointId not found in chapter"
        Write-Host "`nKnowledge point '$KnowledgePointId' not found in Chapter $ChapterNumber" -ForegroundColor Red
        
        # List available KPs
        $kpMatches = [regex]::Matches($chapter.content, "### (KP-\d+\.\d+): (.+)")
        if ($kpMatches.Count -gt 0) {
            Write-Host "`nAvailable knowledge points:" -ForegroundColor Yellow
            foreach ($match in $kpMatches) {
                Write-Host "  - $($match.Groups[1].Value): $($match.Groups[2].Value)" -ForegroundColor Cyan
            }
        }
        exit 1
    }
}
else {
    # Auto-detect: resume from last KP or start at first incomplete
    if ($progressData.last_chapter -eq $ChapterNumber -and $progressData.last_kp_id) {
        # Try to continue from last KP
        $lastKP = $progressData.last_kp_id
        Write-LogDebug "Last studied KP: $lastKP"
        
        # Extract all KPs from chapter
        $kpMatches = [regex]::Matches($chapter.content, "### (KP-\d+\.\d+):")
        $kpIds = $kpMatches | ForEach-Object { $_.Groups[1].Value }
        
        # Find next incomplete KP
        $foundLast = $false
        foreach ($kpId in $kpIds) {
            if ($foundLast -and $kpId -notin $progressData.completed_kps) {
                $startingKP = $kpId
                Write-LogInfo "Resuming at next incomplete KP: $startingKP"
                break
            }
            if ($kpId -eq $lastKP) {
                $foundLast = $true
            }
        }
        
        # If no next KP found, restart at first incomplete
        if (-not $startingKP) {
            $startingKP = $kpIds | Where-Object { $_ -notin $progressData.completed_kps } | Select-Object -First 1
            if ($startingKP) {
                Write-LogInfo "All KPs after last studied are complete, starting at first incomplete: $startingKP"
            }
            else {
                Write-LogInfo "All KPs completed, restarting from first: $($kpIds[0])"
                $startingKP = $kpIds[0]
            }
        }
    }
    else {
        # First time in this chapter, start at first KP
        $kpMatches = [regex]::Matches($chapter.content, "### (KP-\d+\.\d+):")
        if ($kpMatches.Count -gt 0) {
            $startingKP = $kpMatches[0].Groups[1].Value
            Write-LogInfo "Starting at first KP: $startingKP"
        }
        else {
            Write-LogError "No knowledge points found in chapter"
            exit 1
        }
    }
}

# Step 5: Extract KP details and questions
$kpPattern = "(?s)### $startingKP[^\r\n]*\r?\n(.*?)(?=\r?\n### |\z)"
if ($chapter.content -match $kpPattern) {
    $kpContent = $matches[1].Trim()
    
    # Extract title (first line after heading)
    $kpTitle = ""
    if ($kpContent -match "^\*\*Type\*\*:\s*(.+?)\s*\r?\n\*\*Description\*\*:\s*(.+?)(?=\r?\n|$)") {
        # If we have Type and Description, use Description as title hint
        $kpTitle = $matches[2].Trim()
    }
    elseif ($kpContent -match "^([^\r\n]+)") {
        $kpTitle = $matches[1].Trim()
    }
    
    # Extract description
    $kpDescription = ""
    if ($kpContent -match "(?s)\*\*Description\*\*:\s*(.+?)(?=\r?\n\*\*|$)") {
        $kpDescription = $matches[1].Trim()
    }
    
    # Extract guiding questions
    $guidingQuestions = @()
    if ($kpContent -match "(?s)\*\*Guiding Questions\*\*:\s*(.*?)(?=\r?\n\*\*|\z)") {
        $questionsBlock = $matches[1]
        $questionMatches = [regex]::Matches($questionsBlock, "(?m)^\d+\.\s*(.+?)$")
        foreach ($qMatch in $questionMatches) {
            $q = $qMatch.Groups[1].Value.Trim()
            if ($q) {
                $guidingQuestions += $q
            }
        }
    }
    
    # Extract keywords
    $keywords = @()
    if ($kpContent -match "(?s)\*\*Key Concepts\*\*:\s*(.*?)(?=\r?\n\*\*|$)") {
        $keywordsBlock = $matches[1]
        $keywordMatches = [regex]::Matches($keywordsBlock, "(?m)^[-\*]\s*(.+?)$")
        foreach ($kwMatch in $keywordMatches) {
            $kw = $kwMatch.Groups[1].Value.Trim()
            if ($kw) {
                $keywords += $kw
            }
        }
    }
    
    Write-LogInfo "Extracted $($guidingQuestions.Count) guiding questions"
    Write-LogDebug "Questions: $($guidingQuestions -join '; ')"
}
else {
    Write-LogError "Failed to extract KP content"
    exit 1
}

# Step 6: Calculate progress stats
$completedKPsInChapter = ($progressData.completed_kps | Where-Object { $_ -like "KP-$ChapterNumber.*" }).Count
$chapterProgress = if ($totalKPs -gt 0) { [math]::Round(($completedKPsInChapter / $totalKPs) * 100) } else { 0 }

# Step 7: Generate session ID
$sessionId = "session-$(Get-Date -Format 'yyyy-MM-dd-HH-mm-ss')"

# Step 8: Build output JSON
$textbookName = if ($chapter.frontmatter.source_outline) { $chapter.frontmatter.source_outline } else { "Unknown" }

$output = @{
    status = "success"
    session_id = $sessionId
    lesson_context = @{
        textbook = $textbookName
        chapter_number = $ChapterNumber
        chapter_title = $chapterTitle
        knowledge_point = @{
            id = $startingKP
            title = $kpTitle
            description = $kpDescription
            difficulty = $difficulty
            keywords = $keywords
        }
        guiding_questions = $guidingQuestions
    }
    progress = @{
        last_kp = $progressData.last_kp_id
        completed_kps = $completedKPsInChapter
        total_kps = $totalKPs
        chapter_progress = "$chapterProgress%"
    }
    paths = @{
        chapter_file = $chapterFile
        progress_file = $progressPath
    }
}

# Step 9: Save session start to progress (prepare for later update)
$sessionData = @{
    session_id = $sessionId
    chapter = $ChapterNumber
    kp_id = $startingKP
    started_at = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
    status = "active"
}

# Update progress file frontmatter (temporary, will be finalized on pause/complete)
try {
    $updatedFrontmatter = @{
        last_chapter = $ChapterNumber
        last_kp_id = $startingKP
        completed_kps = $progressData.completed_kps
        current_session = $sessionData
        sessions = $progressData.sessions
    }
    
    # Read existing content if file exists
    $existingContent = ""
    if (Test-Path $progressPath) {
        $existingMd = Read-Markdown -Path $progressPath
        $existingContent = $existingMd.content
    }
    else {
        # Create initial progress content
        $existingContent = @"
# Learning Progress

## Current Session

**Chapter**: $ChapterNumber - $chapterTitle  
**Knowledge Point**: $startingKP  
**Status**: In Progress  
**Started**: $(Get-Date -Format "yyyy-MM-dd HH:mm")

---

## Session History

(Sessions will be recorded here after completion)
"@
    }
    
    Write-Markdown -Path $progressPath -Frontmatter $updatedFrontmatter -Content $existingContent
    Write-LogInfo "Progress file updated with session start"
}
catch {
    Write-LogWarn "Failed to update progress file: $_"
}

# Step 10: Output JSON for prompt consumption
$jsonOutput = $output | ConvertTo-Json -Depth 10 -Compress
Write-Output $jsonOutput

Write-LogInfo "=== Lesson Initialized ==="
Write-LogInfo "Session ID: $sessionId"
Write-LogInfo "Next step: Run prompt '/teacherkit.lesson' in Copilot"

exit 0
