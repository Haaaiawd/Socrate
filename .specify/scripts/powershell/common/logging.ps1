# logging.ps1
# Common logging functions for TeacherKit PowerShell scripts

<#
.SYNOPSIS
    Initialize logger with log file path

.PARAMETER LogPath
    Path to log file (default: logs/teacherkit.log)

.PARAMETER Level
    Minimum log level (DEBUG, INFO, WARN, ERROR)
#>
function Initialize-Logger {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$LogPath = "logs/teacherkit.log",
        
        [Parameter()]
        [ValidateSet("DEBUG", "INFO", "WARN", "ERROR")]
        [string]$Level = "INFO"
    )
    
    # Create logs directory if it doesn't exist
    $logDir = Split-Path -Path $LogPath -Parent
    if (-not (Test-Path -Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    
    # Store log settings in script scope
    $script:LogFilePath = $LogPath
    $script:LogLevel = $Level
    $script:LogLevels = @{
        "DEBUG" = 0
        "INFO" = 1
        "WARN" = 2
        "ERROR" = 3
    }
    
    Write-Log -Message "Logger initialized" -Level "INFO"
}

<#
.SYNOPSIS
    Write log message to file and console

.PARAMETER Message
    Log message content

.PARAMETER Level
    Log level (DEBUG, INFO, WARN, ERROR)

.PARAMETER NoConsole
    Suppress console output
#>
function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        
        [Parameter()]
        [ValidateSet("DEBUG", "INFO", "WARN", "ERROR")]
        [string]$Level = "INFO",
        
        [Parameter()]
        [switch]$NoConsole
    )
    
    # Initialize if not already done
    if (-not $script:LogFilePath) {
        Initialize-Logger
    }
    
    # Check if message should be logged based on level
    if ($script:LogLevels[$Level] -lt $script:LogLevels[$script:LogLevel]) {
        return
    }
    
    # Format log entry
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    # Write to file
    try {
        Add-Content -Path $script:LogFilePath -Value $logEntry -ErrorAction Stop
    }
    catch {
        Write-Warning "Failed to write to log file: $_"
    }
    
    # Write to console with color
    if (-not $NoConsole) {
        $color = switch ($Level) {
            "DEBUG" { "Gray" }
            "INFO"  { "White" }
            "WARN"  { "Yellow" }
            "ERROR" { "Red" }
        }
        Write-Host $logEntry -ForegroundColor $color
    }
}

<#
.SYNOPSIS
    Write debug log message

.PARAMETER Message
    Debug message
#>
function Write-LogDebug {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Message)
    Write-Log -Message $Message -Level "DEBUG"
}

<#
.SYNOPSIS
    Write info log message

.PARAMETER Message
    Info message
#>
function Write-LogInfo {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Message)
    Write-Log -Message $Message -Level "INFO"
}

<#
.SYNOPSIS
    Write warning log message

.PARAMETER Message
    Warning message
#>
function Write-LogWarn {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Message)
    Write-Log -Message $Message -Level "WARN"
}

<#
.SYNOPSIS
    Write error log message

.PARAMETER Message
    Error message
#>
function Write-LogError {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Message)
    Write-Log -Message $Message -Level "ERROR"
}
