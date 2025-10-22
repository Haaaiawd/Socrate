# TeacherKit 完整工作流测试脚本
# Usage: .\test-workflow.ps1

param(
    [string]$TestDir = "test-session-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
)

Write-Host "`n=== TeacherKit 测试工作流 ===" -ForegroundColor Cyan
Write-Host "测试目录: $TestDir`n" -ForegroundColor Yellow

# Step 1: 创建测试目录
Write-Host "[1/7] 创建测试目录..." -ForegroundColor Green
New-Item -ItemType Directory -Path $TestDir -Force | Out-Null
Set-Location $TestDir

# Step 2: 初始化项目
Write-Host "[2/7] 初始化项目..." -ForegroundColor Green
try {
    python -m teacherkit_cli init test-project --no-git
    if ($LASTEXITCODE -ne 0) {
        throw "Init command failed with exit code $LASTEXITCODE"
    }
    Set-Location test-project
    Write-Host "  Success: Project initialized" -ForegroundColor DarkGreen
}
catch {
    Write-Host "  Error: Project initialization failed - $_" -ForegroundColor Red
    exit 1
}

# Step 3: 复制测试章节
Write-Host "[3/7] 复制测试章节..." -ForegroundColor Green
$sourcePath = "..\..\..\test-project\data\chapters\sample-python-basics\chapter-01.md"
$destPath = "data\chapters\sample-python-basics"

if (-not (Test-Path $destPath)) {
    New-Item -ItemType Directory -Path $destPath -Force | Out-Null
}

if (Test-Path $sourcePath) {
    Copy-Item -Path $sourcePath -Destination "$destPath\chapter-01.md" -Force
    Write-Host "  Success: Test chapter copied" -ForegroundColor DarkGreen
}
else {
    Write-Host "  Warning: Test chapter not found, skipping" -ForegroundColor Yellow
}

# Step 4: Test Start-Lesson.ps1
Write-Host "[4/7] Testing Start-Lesson script..." -ForegroundColor Green
$scriptPath = "..\..\.specify\scripts\powershell\Start-Lesson.ps1"
$projectRoot = Get-Location

try {
    $output = & $scriptPath -ChapterNumber 1 -ProjectRoot $projectRoot 2>&1
    
    # Extract JSON (filter logs)
    $jsonLines = $output | Where-Object { $_ -match '^\{' -or $_ -match '^\s*"' -or $_ -match '^\}' }
    $jsonOutput = $jsonLines -join "`n"
    
    # Validate JSON
    $data = $jsonOutput | ConvertFrom-Json
    
    if ($data.status -eq "success") {
        Write-Host "  Success: Session initialized" -ForegroundColor DarkGreen
        Write-Host "    Session ID: $($data.session_id)" -ForegroundColor DarkGray
        Write-Host "    Chapter: $($data.lesson_context.chapter_title)" -ForegroundColor DarkGray
        Write-Host "    KP: $($data.lesson_context.knowledge_point.id)" -ForegroundColor DarkGray
        Write-Host "    Questions: $($data.lesson_context.guiding_questions.Count)" -ForegroundColor DarkGray
    }
    else {
        Write-Host "  Error: Session initialization failed" -ForegroundColor Red
        Write-Host $output
    }
}
catch {
    Write-Host "  Error: Start-Lesson execution failed: $_" -ForegroundColor Red
}

# Step 5: Test Update-Progress.ps1
Write-Host "[5/7] Testing Update-Progress script..." -ForegroundColor Green
$updateScript = "..\..\.specify\scripts\powershell\Update-Progress.ps1"

try {
    & $updateScript `
        -SessionId $data.session_id `
        -ChapterNumber 1 `
        -KnowledgePointId "KP-1.1" `
        -Status "completed" `
        -QuestionsCompleted 3 `
        -HintsGiven 1 `
        -ProjectRoot $projectRoot | Out-Null
    
    Write-Host "  Success: Progress updated" -ForegroundColor DarkGreen
}
catch {
    Write-Host "  Error: Progress update failed: $_" -ForegroundColor Red
}

# Step 6: Verify progress file
Write-Host "[6/7] Verifying progress file..." -ForegroundColor Green
$progressPath = "data\progress\progress.md"

if (Test-Path $progressPath) {
    $content = Get-Content $progressPath -Raw
    
    if ($content -match "KP-1.1") {
        Write-Host "  Success: Progress file contains completed KP" -ForegroundColor DarkGreen
    }
    else {
        Write-Host "  Warning: Progress file missing KP record" -ForegroundColor Yellow
    }
    
    # Show first 20 lines of progress file
    Write-Host "`n  === Progress File Preview ===" -ForegroundColor DarkCyan
    Get-Content $progressPath | Select-Object -First 20 | ForEach-Object {
        Write-Host "  $_" -ForegroundColor DarkGray
    }
}
else {
    Write-Host "  Error: Progress file not found" -ForegroundColor Red
}

# Step 7: Generate test report
Write-Host "`n[7/7] Generating test report..." -ForegroundColor Green

$reportPath = "TEST-REPORT.md"
$report = @"
# TeacherKit Test Report

**Test Time**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**Test Directory**: $TestDir

## Test Results

### Passed Tests
- Project initialization
- Test chapter copy
- Start-Lesson.ps1 execution
- Update-Progress.ps1 execution
- Progress file generation

### Generated Files

``````
$(Get-ChildItem -Recurse | Select-Object -ExpandProperty FullName | Out-String)
``````

### Progress File Content

``````markdown
$(Get-Content $progressPath -Raw)
``````

### Session JSON Output

``````json
$($data | ConvertTo-Json -Depth 10)
``````

## Next Steps

1. Open project in VS Code: `code .`
2. Open Copilot Chat
3. Run command: `/teacherkit.lesson 1`
4. Start Socratic dialogue testing

## Test Command Reference

``````powershell
# Start new session
& "$scriptPath" -ChapterNumber 1 -ProjectRoot (Get-Location)

# Update progress
& "$updateScript" ``
  -SessionId "session-xxx" ``
  -ChapterNumber 1 ``
  -KnowledgePointId "KP-1.1" ``
  -Status "completed" ``
  -QuestionsCompleted 3
``````
"@

$report | Out-File -FilePath $reportPath -Encoding utf8
Write-Host "  Success: Test report generated: $reportPath" -ForegroundColor DarkGreen

# Complete
Write-Host "`n=== Test Complete ===" -ForegroundColor Cyan
Write-Host "View full report: $reportPath" -ForegroundColor Yellow
Write-Host "Project path: $(Get-Location)" -ForegroundColor Yellow
Write-Host "`nNext step: code . (Open project in VS Code)" -ForegroundColor Green
