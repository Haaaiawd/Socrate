# Generate-Practice.ps1
# Create an exercise notebook template using ipynb-template.ipynb

param(
    [Parameter(Mandatory=$true)]
    [string]$Topic,
    
    [Parameter()]
    [int]$PartNumber = 1,
    
    [Parameter()]
    [string]$ProjectRoot = (Get-Location).Path
)

# Normalize topic to filename
$topicSlug = $Topic.ToLower() -replace '[^a-z0-9]+', '-' -replace '^-|-$', ''
$exerciseFile = "$ProjectRoot/data/exercises/practice-$topicSlug-part-$PartNumber.ipynb"

# Ensure directory exists
$exerciseDir = Split-Path -Parent $exerciseFile
if (-not (Test-Path $exerciseDir)) {
    New-Item -ItemType Directory -Path $exerciseDir -Force | Out-Null
}

# Check if file already exists
if (Test-Path $exerciseFile) {
    Write-Host "[INFO] Exercise file already exists: $exerciseFile" -ForegroundColor Yellow
    Write-Host "Use this file, or delete it to create a new one." -ForegroundColor Yellow
    exit 0
}

# Locate template
$templatePath = "$ProjectRoot/.specify/templates/ipynb-template.ipynb"
if (-not (Test-Path $templatePath)) {
    Write-Host "[ERROR] Template not found: $templatePath" -ForegroundColor Red
    Write-Host "Run 'socrate init' to create project structure." -ForegroundColor Yellow
    exit 1
}

# Copy and customize template
try {
    Copy-Item -Path $templatePath -Destination $exerciseFile -Force
    
    # Read template content
    $content = Get-Content -Path $exerciseFile -Raw
    
    # Replace placeholders with topic and part number
    $content = $content -replace '\[TOPIC\]', $Topic
    $content = $content -replace '\[PART_NUMBER\]', $PartNumber
    
    # Write customized content
    $content | Set-Content -Path $exerciseFile -Encoding UTF8 -NoNewline
    
    Write-Host "[SUCCESS] Exercise notebook created:" -ForegroundColor Green
    Write-Host "  $exerciseFile" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Open the notebook in Jupyter or VS Code" -ForegroundColor White
    Write-Host "2. Fill in the exercise details" -ForegroundColor White
    Write-Host "3. Students can work through the exercises" -ForegroundColor White
    exit 0
}
catch {
    Write-Host "[ERROR] Failed to create exercise file: $_" -ForegroundColor Red
    exit 1
}
