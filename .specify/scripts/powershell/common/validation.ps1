# validation.ps1
# Prerequisite checks and textbook validation functions

. "$PSScriptRoot/logging.ps1"

<#
.SYNOPSIS
    Test system prerequisites for TeacherKit

.OUTPUTS
    Hashtable with test results
#>
function Test-Prerequisites {
    [CmdletBinding()]
    param()
    
    Write-LogInfo "Checking system prerequisites..."
    
    $results = @{
        Python = $false
        PowerShell = $false
        Git = $false
        VSCode = $false
        Errors = @()
        Warnings = @()
    }
    
    # Check Python 3.11+
    try {
        $pythonVersion = python --version 2>&1
        if ($pythonVersion -match 'Python (\d+)\.(\d+)') {
            $major = [int]$matches[1]
            $minor = [int]$matches[2]
            
            if ($major -ge 3 -and $minor -ge 11) {
                $results.Python = $true
                Write-LogInfo "✓ Python $major.$minor detected"
            }
            else {
                $results.Errors += "Python 3.11+ required (found $major.$minor)"
                Write-LogError "✗ Python 3.11+ required (found $major.$minor)"
            }
        }
    }
    catch {
        $results.Errors += "Python not found in PATH"
        Write-LogError "✗ Python not found in PATH"
    }
    
    # Check PowerShell 7+
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        $results.PowerShell = $true
        Write-LogInfo "✓ PowerShell $($PSVersionTable.PSVersion) detected"
    }
    else {
        $results.Errors += "PowerShell 7+ required (found $($PSVersionTable.PSVersion))"
        Write-LogError "✗ PowerShell 7+ required (found $($PSVersionTable.PSVersion))"
    }
    
    # Check Git
    try {
        $gitVersion = git --version 2>&1
        if ($gitVersion -match 'git version') {
            $results.Git = $true
            Write-LogInfo "✓ Git detected: $gitVersion"
        }
    }
    catch {
        $results.Warnings += "Git not found (optional for MVP)"
        Write-LogWarn "⚠ Git not found (optional for MVP)"
    }
    
    # Check VS Code
    $vscodeCommand = if ($IsWindows) { 'code.cmd' } else { 'code' }
    try {
        $vscodeVersion = & $vscodeCommand --version 2>&1 | Select-Object -First 1
        if ($vscodeVersion) {
            $results.VSCode = $true
            Write-LogInfo "✓ VS Code detected: $vscodeVersion"
        }
    }
    catch {
        $results.Warnings += "VS Code not found (required for prompt commands)"
        Write-LogWarn "⚠ VS Code not found (required for prompt commands)"
    }
    
    # Summary
    $passed = $results.Python -and $results.PowerShell
    if ($passed) {
        Write-LogInfo "✓ Core prerequisites met"
    }
    else {
        Write-LogError "✗ Missing required prerequisites"
    }
    
    return $results
}

<#
.SYNOPSIS
    Validate textbook file format and structure

.PARAMETER Path
    Path to textbook file

.OUTPUTS
    Hashtable with validation results
#>
function Test-Textbook {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    
    Write-LogInfo "Validating textbook: $Path"
    
    $results = @{
        Valid = $false
        Format = $null
        Size = 0
        LineCount = 0
        HasHeadings = $false
        HeadingCount = 0
        Errors = @()
        Warnings = @()
    }
    
    # Check file exists
    if (-not (Test-Path -Path $Path)) {
        $results.Errors += "File not found: $Path"
        Write-LogError "File not found: $Path"
        return $results
    }
    
    # Get file info
    $file = Get-Item -Path $Path
    $results.Size = $file.Length
    
    # Check file size (warn if >10MB)
    if ($results.Size -gt 10MB) {
        $sizeMB = [math]::Round($results.Size / 1MB, 2)
        $results.Warnings += "Large file detected ($sizeMB MB) - parsing may take time"
        Write-LogWarn "Large file detected ($sizeMB MB)"
    }
    
    # Detect format
    $extension = $file.Extension.ToLower()
    if ($extension -eq '.md' -or $extension -eq '.markdown') {
        $results.Format = 'markdown'
    }
    elseif ($extension -eq '.txt') {
        $results.Format = 'text'
    }
    else {
        $results.Errors += "Unsupported file format: $extension (use .md or .txt)"
        Write-LogError "Unsupported format: $extension"
        return $results
    }
    
    # Read and validate content
    try {
        $content = Get-Content -Path $Path -Raw
        $lines = Get-Content -Path $Path
        $results.LineCount = $lines.Count
        
        # Check for headings (Markdown chapters)
        $headings = [regex]::Matches($content, '^#+\s+.+$', 'Multiline')
        $results.HeadingCount = $headings.Count
        $results.HasHeadings = $headings.Count -gt 0
        
        if ($results.HeadingCount -eq 0) {
            $results.Warnings += "No Markdown headings found - outline may be less structured"
            Write-LogWarn "No headings found in textbook"
        }
        else {
            Write-LogInfo "Found $($results.HeadingCount) headings"
        }
        
        # Check encoding (warn if not UTF-8)
        $encoding = [System.Text.Encoding]::Default
        $bytes = [System.IO.File]::ReadAllBytes($Path)
        if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            Write-LogInfo "UTF-8 encoding detected (with BOM)"
        }
        elseif ($content -match '[^\x00-\x7F]') {
            $results.Warnings += "File may not be UTF-8 encoded - special characters may display incorrectly"
            Write-LogWarn "Non-ASCII characters detected - check encoding"
        }
        
        $results.Valid = $true
        Write-LogInfo "✓ Textbook validation passed"
    }
    catch {
        $results.Errors += "Failed to read file: $_"
        Write-LogError "Failed to read file: $_"
    }
    
    return $results
}

<#
.SYNOPSIS
    Validate Markdown file structure

.PARAMETER Path
    Path to Markdown file

.PARAMETER RequireFrontmatter
    Whether YAML frontmatter is required

.OUTPUTS
    Hashtable with validation results
#>
function Test-MarkdownStructure {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        
        [Parameter()]
        [switch]$RequireFrontmatter
    )
    
    $results = @{
        Valid = $false
        HasFrontmatter = $false
        FrontmatterValid = $false
        Errors = @()
    }
    
    if (-not (Test-Path -Path $Path)) {
        $results.Errors += "File not found: $Path"
        return $results
    }
    
    $content = Get-Content -Path $Path -Raw
    
    # Check for frontmatter
    if ($content -match '(?s)^---\s*\n(.*?)\n---') {
        $results.HasFrontmatter = $true
        $yamlContent = $matches[1]
        
        # Basic YAML validation
        $lines = $yamlContent -split "`n"
        $validLines = $lines | Where-Object { $_ -match '^\s*[a-zA-Z_][a-zA-Z0-9_]*\s*:' -or [string]::IsNullOrWhiteSpace($_) }
        
        if ($validLines.Count -eq $lines.Count) {
            $results.FrontmatterValid = $true
        }
        else {
            $results.Errors += "Invalid YAML frontmatter syntax"
        }
    }
    elseif ($RequireFrontmatter) {
        $results.Errors += "YAML frontmatter required but not found"
    }
    
    $results.Valid = (-not $RequireFrontmatter -or $results.HasFrontmatter) -and $results.Errors.Count -eq 0
    
    return $results
}
