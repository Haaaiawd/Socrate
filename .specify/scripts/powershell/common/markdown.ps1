# markdown.ps1
# Markdown file I/O and YAML frontmatter parsing functions

<#
.SYNOPSIS
    Read Markdown file and parse YAML frontmatter

.PARAMETER Path
    Path to Markdown file

.OUTPUTS
    Hashtable with 'frontmatter' and 'content' keys
#>
function Read-Markdown {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )
    
    if (-not (Test-Path -Path $Path)) {
        throw "Markdown file not found: $Path"
    }
    
    $content = Get-Content -Path $Path -Raw
    
    # Parse YAML frontmatter
    $frontmatter = @{}
    $bodyContent = $content
    
    if ($content -match '(?s)^---\s*\n(.*?)\n---\s*\n(.*)$') {
        $yamlContent = $matches[1]
        $bodyContent = $matches[2]
        
        # Parse YAML (simple key-value parsing)
        $frontmatter = Parse-FrontMatter -YamlContent $yamlContent
    }
    
    return @{
        frontmatter = $frontmatter
        content = $bodyContent.Trim()
        raw = $content
    }
}

<#
.SYNOPSIS
    Write Markdown file with YAML frontmatter

.PARAMETER Path
    Path to output file

.PARAMETER Content
    Markdown content (body)

.PARAMETER Frontmatter
    Hashtable of frontmatter key-value pairs
#>
function Write-Markdown {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        
        [Parameter(Mandatory)]
        [string]$Content,
        
        [Parameter()]
        [hashtable]$Frontmatter = @{}
    )
    
    # Create directory if it doesn't exist
    $dir = Split-Path -Path $Path -Parent
    if ($dir -and -not (Test-Path -Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    
    # Build output content
    $output = ""
    
    # Add YAML frontmatter if provided
    if ($Frontmatter.Count -gt 0) {
        $output += "---`n"
        foreach ($key in $Frontmatter.Keys) {
            $value = $Frontmatter[$key]
            
            # Handle different value types
            if ($value -is [array]) {
                $output += "${key}:`n"
                foreach ($item in $value) {
                    $output += "  - $item`n"
                }
            }
            elseif ($value -is [hashtable]) {
                $output += "${key}:`n"
                foreach ($subKey in $value.Keys) {
                    $output += "  ${subKey}: $($value[$subKey])`n"
                }
            }
            elseif ($value -is [bool]) {
                $output += "${key}: $($value.ToString().ToLower())`n"
            }
            elseif ($value -is [string] -and $value.Contains("`n")) {
                # Multi-line string
                $output += "${key}: |`n"
                foreach ($line in $value -split "`n") {
                    $output += "  $line`n"
                }
            }
            else {
                # Quote strings with special characters
                if ($value -match '[\:\{\}\[\]\,\&\*\#\?\|\-\<\>\=\!\%\@]') {
                    $output += "${key}: ""$value""`n"
                }
                else {
                    $output += "${key}: $value`n"
                }
            }
        }
        $output += "---`n`n"
    }
    
    # Add content
    $output += $Content
    
    # Write to file
    Set-Content -Path $Path -Value $output -Encoding UTF8
}

<#
.SYNOPSIS
    Parse YAML frontmatter content

.PARAMETER YamlContent
    Raw YAML content (without --- delimiters)

.OUTPUTS
    Hashtable of key-value pairs
#>
function Parse-FrontMatter {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$YamlContent
    )
    
    $result = @{}
    $lines = $YamlContent -split "`n"
    $currentKey = $null
    $currentValue = @()
    $inMultiline = $false
    
    foreach ($line in $lines) {
        $line = $line.Trim()
        
        # Skip empty lines and comments
        if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith('#')) {
            continue
        }
        
        # Handle multi-line values
        if ($inMultiline) {
            if ($line.StartsWith('-') -or $line.StartsWith(' ')) {
                $currentValue += $line.TrimStart('- ').Trim()
                continue
            }
            else {
                # End of multi-line value
                if ($currentValue.Count -eq 1) {
                    $result[$currentKey] = $currentValue[0]
                }
                else {
                    $result[$currentKey] = $currentValue
                }
                $inMultiline = $false
                $currentValue = @()
            }
        }
        
        # Parse key-value pair
        if ($line -match '^([^:]+):\s*(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            
            if ([string]::IsNullOrWhiteSpace($value) -or $value -eq '|' -or $value -eq '[' -or $value -eq '{') {
                # Multi-line or complex value
                $currentKey = $key
                $inMultiline = $true
                $currentValue = @()
            }
            else {
                # Simple value - remove quotes if present
                $value = $value.Trim('"', "'")
                
                # Convert boolean strings
                if ($value -eq 'true') { $value = $true }
                elseif ($value -eq 'false') { $value = $false }
                
                # Convert numbers
                elseif ($value -match '^\d+$') { $value = [int]$value }
                elseif ($value -match '^\d+\.\d+$') { $value = [double]$value }
                
                $result[$key] = $value
            }
        }
    }
    
    # Handle any remaining multi-line value
    if ($inMultiline -and $currentKey) {
        if ($currentValue.Count -eq 1) {
            $result[$currentKey] = $currentValue[0]
        }
        else {
            $result[$currentKey] = $currentValue
        }
    }
    
    return $result
}
