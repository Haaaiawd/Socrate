# Update-Progress.ps1
# Update learning progress for a knowledge point

param(
    [Parameter(Mandatory=$true)]
    [string]$KpId,
    
    [Parameter()]
    [ValidateSet("completed", "in-progress", "not-started")]
    [string]$Status = "completed",
    
    [Parameter()]
    [string]$ProjectRoot = (Get-Location).Path
)

Write-Host "[INFO] Updating progress for: $KpId" -ForegroundColor Cyan
Write-Host "       Status: $Status" -ForegroundColor Cyan

# Locate progress file
$progressPath = "$ProjectRoot/data/progress/progress.md"

if (-not (Test-Path $progressPath)) {
    Write-Host "[ERROR] Progress file not found: $progressPath" -ForegroundColor Red
    Write-Host "Run 'socrate init' to create project structure." -ForegroundColor Yellow
    exit 1
}

# Read current progress
try {
    $content = Get-Content -Path $progressPath -Raw
    
    # Extract YAML frontmatter
    if ($content -match '(?s)^---\s*\n(.*?)\n---') {
        $yamlText = $Matches[1]
        
        # Parse completed_kps array
        $completedKPs = @()
        if ($yamlText -match 'completed_kps:\s*\[(.*?)\]') {
            $kpList = $Matches[1] -replace '"', '' -replace "'", ''
            if ($kpList.Trim()) {
                $completedKPs = $kpList -split ',' | ForEach-Object { $_.Trim() }
            }
        }
        
        # Update completed_kps based on status
        if ($Status -eq "completed" -and $KpId -notin $completedKPs) {
            $completedKPs += $KpId
            Write-Host "[SUCCESS] Marked as completed: $KpId" -ForegroundColor Green
        }
        elseif ($Status -ne "completed" -and $KpId -in $completedKPs) {
            $completedKPs = $completedKPs | Where-Object { $_ -ne $KpId }
            Write-Host "[INFO] Removed from completed: $KpId" -ForegroundColor Yellow
        }
        
        # Update frontmatter
        $kpListStr = ($completedKPs | ForEach-Object { "'$_'" }) -join ', '
        $updatedYaml = $yamlText -replace 'completed_kps:\s*\[.*?\]', "completed_kps: [$kpListStr]"
        $updatedYaml = $updatedYaml -replace 'last_updated:.*', "last_updated: '$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')'"
        
        # Replace frontmatter in content
        $updatedContent = $content -replace '(?s)^---\s*\n.*?\n---', "---`n$updatedYaml`n---"
        
        # Write back
        $updatedContent | Set-Content -Path $progressPath -Encoding UTF8 -NoNewline
        
        Write-Host "[SUCCESS] Progress updated" -ForegroundColor Green
        Write-Host "Total completed: $($completedKPs.Count) knowledge points" -ForegroundColor Cyan
    }
    else {
        Write-Host "[ERROR] Invalid progress file format (missing frontmatter)" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "[ERROR] Failed to update progress: $_" -ForegroundColor Red
    exit 1
}

exit 0
