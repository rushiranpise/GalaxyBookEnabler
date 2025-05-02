# GalaxyBookEnabler_Uninstaller.ps1
# Run this script as Administrator to remove all components

# Common parameters
$TaskName = "GalaxyBookEnabler"
$Username = [System.Environment]::UserName
$GalaxyBookEnablerDirectory = "C:\Users\$Username\GalaxyBookEnablerScript"
$LogFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'UninstallLog.txt'

# List of all package IDs used in the installer
$packageIds = @(
    # Core packages
    "9P98T77876KZ",  # Samsung Continuity Service
    "9NGW9K44GQ5F",  # Samsung Account
    "9NFWHCHM52HQ",  # Samsung Cloud Assistant
    "9NJNNJTTFL45",  # Samsung Bluetooth Sync
    "9P2TBWSHK6HJ",  # Samsung Settings
    "9NL68DVFP841",  # Samsung Settings Runtime
    "9NQ3HDB99VBF",  # Samsung Update
    
    # Additional packages
    "9NHTLWTKFZNB",  # Galaxy Buds
    "9N3L4FZ03Q99",  # Samsung Multi Control
    "9PCTGDFXVZLJ",  # Quick Share
    "9NBLGGH4XDV0",  # Samsung Device Care
    "9NBLGGH5GB0M",  # Samsung Flow
    "9NBLGGH4N9R9",  # Samsung Gallery
    "9NBLGGH43VHV",  # Samsung Notes
    "9mwjxxlchbgk",   # Samsung Phone
    "9WZDNCRFHWGG",  # Samsung Printer Experience
    "9P5025MM7WDT",  # Samsung Screen Recorder
    "9p312b4tzffh",  # Samsung Studio
    "9PLTXW5DX5KB",  # Second Screen
    "9N3ZBH5V7HX6",   # SmartThings
    "9mvnw0xh7hs5",  # Storage Share
    "9phl04njnt67"   # Nearby Devices
)

function Write-Log {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "$Timestamp - $Message"
    Add-Content -Path $LogFilePath -Value $LogMessage
}

# Check for admin privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Restarting with elevated privileges..."
    Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

try {
    Write-Host "Starting uninstallation process..."
    Write-Log "Uninstallation started"

    # Remove scheduled task
    if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Host "Removed scheduled task: $TaskName"
        Write-Log "Removed scheduled task: $TaskName"
    }

    # Remove installation directory
    if (Test-Path $GalaxyBookEnablerDirectory) {
        Remove-Item -Path $GalaxyBookEnablerDirectory -Recurse -Force
        Write-Host "Removed directory: $GalaxyBookEnablerDirectory"
        Write-Log "Removed directory: $GalaxyBookEnablerDirectory"
    }

    # Uninstall packages
    foreach ($packageId in $packageIds) {
        try {
            Write-Host "Uninstalling package: $packageId"
            winget uninstall --id $packageId --silent --accept-source-agreements
            Write-Log "Successfully uninstalled package: $packageId"
        }
        catch {
            Write-Host "Error uninstalling $packageId - $_"
            Write-Log "Error uninstalling $packageId - $_"
        }
    }

    # Final cleanup
    Write-Host "`nUninstallation complete!"
    Write-Host "The following items were removed:"
    Write-Host "- All scheduled tasks created by the installer"
    Write-Host "- GalaxyBookEnabler program directory"
    Write-Host "- All associated Samsung packages"
    Write-Log "Uninstallation completed successfully"
}
catch {
    Write-Host "Critical error during uninstallation: $_"
    Write-Log "Critical error: $_"
    exit 1
}

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")