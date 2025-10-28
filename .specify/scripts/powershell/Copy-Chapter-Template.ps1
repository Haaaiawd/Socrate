#!/usr/bin/env pwsh
# Copy-Chapter-Template.ps1
# Copy chapter template for single KP - AI calls this repeatedly

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$KpId,
    
    [Parameter(Mandatory=$true)]
    [string]$Title,
    
    [Parameter()]
    [string]$ProjectRoot = (Get-Location).Path,
    
    [switch]$Json
)

$ErrorActionPreference = 'Stop'

# Step 1: Ensure chapters directory
$chaptersDir = Join-Path $ProjectRoot "data/chapters"
if (-not (Test-Path $chaptersDir)) {
    New-Item -ItemType Directory -Path $chaptersDir -Force | Out-Null
}

# Step 2: Generate filename
# KP-1.1.1 + "Convolution Basics" → KP-1.1.1-convolution-basics.md
$slug = $Title -replace '\s+', '-' -replace '[^\w\-]', '' | ForEach-Object { $_.ToLower() }
$filename = "$KpId-$slug.md"
$outputPath = Join-Path $chaptersDir $filename

# Step 3: Copy template
$templatePath = Join-Path $ProjectRoot ".specify/templates/chapter-template.md"
if (-not (Test-Path $templatePath)) {
    Write-Error "Chapter template not found: $templatePath"
    exit 1
}

Copy-Item -Path $templatePath -Destination $outputPath -Force

# Step 4: Output
if ($Json) {
    [PSCustomObject]@{
        CHAPTER_FILE = $outputPath
        KP_ID = $KpId
        SLUG = $slug
        STATUS = "template_copied"
    } | ConvertTo-Json -Compress
} else {
    Write-Host "✅ Created: $filename" -ForegroundColor Green
}

exit 0
