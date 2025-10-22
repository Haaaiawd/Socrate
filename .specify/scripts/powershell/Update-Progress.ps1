# Update-Progress.ps1
# Update learning progress after a session

param(
    [Parameter(Mandatory=$true)]
    [string]$SessionId,
    
    [Parameter(Mandatory=$true)]
    [int]$ChapterNumber,
    
    [Parameter(Mandatory=$true)]
    [string]$KnowledgePointId,
    
    [Parameter()]
    [ValidateSet("completed", "paused")]
    [string]$Status = "paused",
    
    [Parameter()]
    [int]$QuestionsCompleted = 0,
    
    [Parameter()]
    [int]$HintsGiven = 0,
    
    [Parameter()]
    [string]$ProjectRoot = (Get-Location).Path
)

# Import common modules
. "$PSScriptRoot/common/logging.ps1"
. "$PSScriptRoot/common/markdown.ps1"

Initialize-Logger -LogPath "$ProjectRoot/logs/teacherkit.log"

Write-LogInfo "=== Update Progress ==="
Write-LogInfo "Session: $SessionId"
Write-LogInfo "Chapter: $ChapterNumber, KP: $KnowledgePointId"
Write-LogInfo "Status: $Status"

# Step 1: Locate progress file
$progressPath = "$ProjectRoot/data/progress/progress.md"

if (-not (Test-Path $progressPath)) {
    Write-LogError "Progress file not found: $progressPath"
    Write-LogError "This should have been created by Start-Lesson.ps1"
    exit 1
}

# Step 2: Read current progress
try {
    $progressMd = Read-Markdown -Path $progressPath
    
    if (-not $progressMd.frontmatter) {
        Write-LogError "Progress file missing frontmatter"
        exit 1
    }
    
    $frontmatter = $progressMd.frontmatter
}
catch {
    Write-LogError "Failed to read progress file: $_"
    exit 1
}

# Step 3: Update session in frontmatter
$sessions = if ($frontmatter.sessions) { $frontmatter.sessions } else { @() }
$currentSession = $frontmatter.current_session

if ($currentSession -and $currentSession.session_id -eq $SessionId) {
    # Update existing active session
    $currentSession.completed_at = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
    $currentSession.status = $Status
    $currentSession.questions_completed = $QuestionsCompleted
    $currentSession.hints_given = $HintsGiven
    
    # Calculate duration
    $startTime = [datetime]::ParseExact($currentSession.started_at, "yyyy-MM-ddTHH:mm:ss", $null)
    $endTime = [datetime]::ParseExact($currentSession.completed_at, "yyyy-MM-ddTHH:mm:ss", $null)
    $duration = ($endTime - $startTime).TotalMinutes
    $currentSession.duration_minutes = [math]::Round($duration, 1)
    
    # Move to sessions history
    $sessions += $currentSession
    
    Write-LogInfo "Session updated: $($duration) minutes, $QuestionsCompleted questions"
}
else {
    Write-LogWarn "Active session not found, creating new entry"
    $sessionEntry = @{
        session_id = $SessionId
        chapter = $ChapterNumber
        kp_id = $KnowledgePointId
        started_at = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
        completed_at = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
        status = $Status
        questions_completed = $QuestionsCompleted
        hints_given = $HintsGiven
        duration_minutes = 0
    }
    $sessions += $sessionEntry
}

# Step 4: Update completed KPs (if status is completed)
$completedKPs = if ($frontmatter.completed_kps) { $frontmatter.completed_kps } else { @() }

if ($Status -eq "completed" -and $KnowledgePointId -notin $completedKPs) {
    $completedKPs += $KnowledgePointId
    Write-LogInfo "Marked KP as completed: $KnowledgePointId"
}

# Step 5: Update last_chapter and last_kp_id
$updatedFrontmatter = @{
    last_chapter = $ChapterNumber
    last_kp_id = $KnowledgePointId
    completed_kps = $completedKPs
    sessions = $sessions
    last_updated = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
}

# Remove current_session (it's now in history)
if ($frontmatter.current_session) {
    $updatedFrontmatter.current_session = $null
}

# Step 6: Update content body with summary
$totalSessions = $sessions.Count
$totalTimeMinutes = ($sessions | ForEach-Object { $_.duration_minutes } | Measure-Object -Sum).Sum
$totalTimeHours = [math]::Round($totalTimeMinutes / 60, 1)

$contentBody = @"
# Learning Progress

## Current Status

**Last Session**: $(Get-Date -Format "yyyy-MM-dd HH:mm")  
**Last Chapter**: Chapter $ChapterNumber  
**Last Knowledge Point**: $KnowledgePointId  
**Status**: $($Status.ToUpper())

---

## Overall Statistics

**Total Sessions**: $totalSessions  
**Total Time**: $totalTimeHours hours ($totalTimeMinutes minutes)  
**Knowledge Points Completed**: $($completedKPs.Count)

**Completed Knowledge Points**:
$( if ($completedKPs.Count -gt 0) { 
    $completedKPs | ForEach-Object { "- $_" } | Out-String 
} else { 
    "_No knowledge points completed yet._" 
} )

---

## Recent Sessions

$( if ($sessions.Count -gt 0) {
    $recentSessions = $sessions | Select-Object -Last 5
    $recentSessions | ForEach-Object {
        $sessionStatus = if ($_.status -eq "completed") { "[DONE]" } else { "[PAUSE]" }
        @"
### $sessionStatus $($_.session_id)

**Chapter**: $($_.chapter) | **KP**: $($_.kp_id)  
**Started**: $($_.started_at) | **Duration**: $($_.duration_minutes) min  
**Questions**: $($_.questions_completed) | **Hints**: $($_.hints_given)  
**Status**: $($_.status)

"@
    } | Out-String
} else {
    "_No session history yet._"
} )

---

## Next Steps

Resume your learning with:
``````
/teacherkit.lesson $ChapterNumber
``````

Or check your overall status:
``````
/teacherkit.status
``````
"@

# Step 7: Write updated progress file
try {
    Write-Markdown -Path $progressPath -Frontmatter $updatedFrontmatter -Content $contentBody
    Write-LogInfo "Progress file updated successfully"
}
catch {
    Write-LogError "Failed to write progress file: $_"
    exit 1
}

# Step 8: Display summary to user
Write-Host "`n[Progress Updated]" -ForegroundColor Green
Write-Host "─────────────────────" -ForegroundColor DarkGray
Write-Host "Session: " -NoNewline; Write-Host $SessionId -ForegroundColor Cyan
Write-Host "Status: " -NoNewline; Write-Host $Status.ToUpper() -ForegroundColor $(if ($Status -eq "completed") { "Green" } else { "Yellow" })
Write-Host "Duration: " -NoNewline; Write-Host "$($currentSession.duration_minutes) minutes" -ForegroundColor White
Write-Host ""

if ($Status -eq "completed") {
    Write-Host "[SUCCESS] Knowledge point mastered: $KnowledgePointId" -ForegroundColor Green
    Write-Host "Total completed: $($completedKPs.Count) knowledge points" -ForegroundColor Cyan
}
else {
    Write-Host "[PAUSED] Session paused. Resume anytime with:" -ForegroundColor Yellow
    Write-Host "   /teacherkit.lesson $ChapterNumber" -ForegroundColor White
}

Write-LogInfo "=== Progress Update Complete ==="
exit 0
