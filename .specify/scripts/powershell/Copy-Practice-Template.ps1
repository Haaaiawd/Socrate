#!/usr/bin/env pwsh
# Copy-Practice-Template.ps1
# Copy ipynb template for practice exercise - AI calls this repeatedly

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Slug,
    
    [Parameter()]
    [string]$ProjectRoot = (Get-Location).Path,
    
    [switch]$Json
)

$ErrorActionPreference = 'Stop'

# Step 1: Ensure exercises directory
$exercisesDir = Join-Path $ProjectRoot "data/exercises"
if (-not (Test-Path $exercisesDir)) {
    New-Item -ItemType Directory -Path $exercisesDir -Force | Out-Null
}

# Step 2: Generate filename
$filename = "practice-$Slug.ipynb"
$outputPath = Join-Path $exercisesDir $filename

# Step 3: Copy template
$templatePath = Join-Path $ProjectRoot ".specify/templates/ipynb-template.ipynb"
if (-not (Test-Path $templatePath)) {
    Write-Error "Practice template not found: $templatePath"
    exit 1
}

Copy-Item -Path $templatePath -Destination $outputPath -Force

# Step 4: Output
if ($Json) {
    [PSCustomObject]@{
        EXERCISE_FILE = $outputPath
        SLUG = $Slug
        STATUS = "template_copied"
    } | ConvertTo-Json -Compress
} else {
    Write-Host "✅ Created: $filename" -ForegroundColor Green
}

exit 0
