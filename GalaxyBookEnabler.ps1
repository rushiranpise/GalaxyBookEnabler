Import-Module ScheduledTasks

# Define the script directory
$Username = [System.Environment]::UserName
$UserFolder = "C:\Users\$Username"
$GalaxyBookEnablerDirectory = Join-Path -Path $UserFolder -ChildPath 'GalaxyBookEnablerScript'
$BatchFilePath = Join-Path -Path $GalaxyBookEnablerDirectory -ChildPath 'Galaxy_Book4_Ultra_Spoofer.bat'
$firstrun = $true
$TaskName = "GalaxyBookEnabler"

# Set up a log file path
$LogFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'InstallScriptLog.txt'
$ScriptDirectory = $PSScriptRoot

#Task details
$TaskAction = New-ScheduledTaskAction -Execute $BatchFilePath
$TaskTrigger = New-ScheduledTaskTrigger -AtStartup
$TaskPrincipal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount
$TaskTrigger.Repetition = $null  # Remove the repetition settings
$TaskTrigger.ExecutionTimeLimit = 'PT1M'
$TaskTrigger.Enabled = $true
$TaskTrigger = New-ScheduledTaskTrigger -AtStartup
$TaskCondition = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries
$TaskDescription = "This spoofs a working Samsung Galaxy Book for QuickShare and other Samsung features."
$TaskPrincipal.RunLevel = "Highest"

# Function to install a package
function InstallPackage($packageName, $packageId) {
    try {
        Write-Output "Installing $packageName..."
        winget install --accept-source-agreements --accept-package-agreements --id $packageId
        Write-Output "Installation of $packageName completed successfully."
    } catch {
        Write-Output "Error installing $packageName $_"
        Write-Log "Error installing $packageName $_"
    }
} 

# Function to install all packages
function InstallAllPackages {
    InstallPackage 'Galaxy Buds' '9NHTLWTKFZNB'
    InstallPackage 'Samsung Multi Control' '9N3L4FZ03Q99'
    InstallPackage 'Quick Share' '9PCTGDFXVZLJ'
    InstallPackage 'Samsung Device Care' '9NBLGGH4XDV0'
    InstallPackage 'Samsung Flow' '9NBLGGH5GB0M'
    InstallPackage 'Samsung Gallery' '9NBLGGH4N9R9'
    InstallPackage 'Samsung Notes' '9NBLGGH43VHV'
    InstallPackage 'Samsung Phone' '9mwjxxlchbgk'
    InstallPackage 'Samsung Printer Experience' '9WZDNCRFHWGG'
    InstallPackage 'Samsung Screen Recorder' '9P5025MM7WDT'
    InstallPackage 'Samsung Studio' '9p312b4tzffh'
    InstallPackage 'Second Screen' '9PLTXW5DX5KB'
    InstallPackage 'SmartThings' '9N3ZBH5V7HX6'
    InstallPackage 'Storage Share' '9mvnw0xh7hs5'
    InstallPackage 'Nearby Devices' '9phl04njnt67'
}

# Function to log messages
function Write-Log {
    param (
        [string]$Message
    )

    # Get the current timestamp
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Format the log message
    $LogMessage = "$Timestamp - $Message"

    # Append the log message to the log file
    Add-Content -Path $LogFilePath -Value $LogMessage
}

# Check if the script is running with administrative privileges
$isAdmin = ([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544" -or ([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-18"

if (-not $isAdmin) {
    # Explain the importance of running the script with administrative privileges
    Write-Output "Please note that this script needs administrative privileges to perform these tasks."
    Write-Output ""
    # Prompt user for consent
    $confirmation = Read-Host "Do you want to run this script with administrative privileges? Press 'Y' to agree, or any other key to exit"
    
    if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
        try {
            Start-Process -FilePath "powershell" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs -ErrorAction Stop
            # Exit the current instance of the script after triggering the relaunch
            exit
        } catch {
            Write-Output "Error relaunching the script as an administrator: $_"
            Write-Log "Error relaunching the script as an administrator: $_"
            Write-Output "Exiting..."
            Write-Output ""
            exit 1
        }
    } else {
        exit 0
    }
} else {
    Write-Output "Script is running with administrative privileges."
    Write-Output "" 
}

# Check if the Galaxy_Book4_Ultra_Spoofer.bat file already exists in the GalaxyBookEnabler directory
if (Test-Path -Path $BatchFilePath) {
    Write-Output "The Galaxy_Book4_Ultra_Spoofer.bat file is already present in the GalaxyBookEnabler directory."
    Write-Log "The Galaxy_Book4_Ultra_Spoofer.bat file is already present in the GalaxyBookEnabler directory."
    $firstrun = $false
}

# Check if the scheduled task with the name "GalaxyBookEnabler" already exists
$task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

if ($task) {
    Write-Output "The scheduled task with the name 'GalaxyBookEnabler' is already present."
    Write-Log "The scheduled task with the name 'GalaxyBookEnabler' is already present."
    $firstrun = $false
}

if ($firstrun -ne $true) {
    Write-Output ""
    Write-Output "This script has already been run. Skipping the initial setup steps."
    Write-Output ""
    $userchoice = Read-Host "Press (C) to continue with the installation of software packages,
(D) to delete the GalaxyBookEnabler directory and remove the scheduled task, or any other key to exit."
    Write-Output ""
    if ($userchoice -eq'D')
    {
        try {
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
            Remove-Item $GalaxyBookEnablerDirectory -Recurse -Force -ErrorAction SilentlyContinue
            Write-Output "Scheduled task and GalaxyBookEnabler directory have been removed."
            Write-Log "Scheduled task and GalaxyBookEnabler directory have been removed."
            #Ask to exit or continue with the script
            $userchoice2 = Read-Host "Press (C) to continue with the installation of software packages, or any other key to exit."
            if ($userchoice2 -eq 'C') {
                Write-Output "Continuing with the installation of software packages..."
                Write-Output ""
            } else {
                Write-Output "Exiting..."
                Write-Output ""
                exit 0
            }

        } catch {
            Write-Output "Error removing scheduled task and GalaxyBookEnabler directory: $_"
            Write-Log "Error removing scheduled task and GalaxyBookEnabler directory: $_"
        }
    } elseif ($userchoice -eq 'C') {
        Write-Output "Continuing with the installation of software packages..."
    } else {
        Write-Output "Exiting..."
        Write-Output ""
        exit 0
    }
}

# Inform the user about the purpose of the script and ask for consent
Write-Output "This script is designed to automate the installation of certain software packages on your system."
Write-Output "It will also create a scheduled task to run a batch file at startup for software installation."
Write-Output "" 
Write-Output "Please read and understand the actions it will perform before proceeding."
Write-Output ""

# Provide a brief description of the script's actions
Write-Output "Actions to be performed:"
Write-Output "1. Creation of 'GalaxyBookEnabler' directory in your user folder."
Write-Output "2. Scheduling a task to run a batch file at startup for software installation."
Write-Output "3. Prompting you to select and install software packages."
Write-Output ""

# Ask for user consent
$confirmation = Read-Host "Do you consent to run this script? (Type 'Y' for Yes, or any other key to exit)"

# Check if the user consents
if ($confirmation -ne 'Y' -and $confirmation -ne 'y') {
    Write-Output "You chose not to run the script. Exiting..."
    Write-Output ""
    exit 1
}else{
    Write-Log "User consent obtained." }
    

# Create a new directory 'GalaxyBookEnabler' if it doesn't exist
try {
    if (-not (Test-Path $GalaxyBookEnablerDirectory -PathType Container)) {
        New-Item -Path $GalaxyBookEnablerDirectory -ItemType Directory -ErrorAction Stop
    }
} catch {
    Write-Output "Error creating directory: $_"
    Write-Output "Exiting..."
    Write-Output ""
    Write-Log "Error creating directory: $_"
    exit 1
}

# Define the source path for the batch file (assuming it's in the same directory as the script)
$SourceBatchFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'Galaxy_Book4_Ultra_Spoofer.bat'
$BatchFilePath = Join-Path -Path $GalaxyBookEnablerDirectory -ChildPath 'Galaxy_Book4_Ultra_Spoofer.bat'

# Check if the source and destination paths are the same if second time running
$sourceContentHash = Get-FileHash -Path $SourceBatchFilePath -Algorithm SHA256 | Select-Object -ExpandProperty Hash
if (Test-Path $BatchFilePath) {
    $destinationContentHash = Get-FileHash -Path $BatchFilePath -Algorithm SHA256 | Select-Object -ExpandProperty Hash

    if ((Test-Path $SourceBatchFilePath) -and (Test-Path $BatchFilePath) -and ($sourceContentHash -eq $destinationContentHash)) {
        Write-Output "Source and destination file contents are the same. No need to copy."
    } else {
        # Prompt user for confirmation to replace the file
        $replaceConfirmation = Read-Host "Destination file already exists and has different contents. Do you want to replace it? (Y/N)"

        if ($replaceConfirmation -eq 'Y') {
            try {
                # Copy the batch file to the 'GalaxyBookEnabler' directory
                Copy-Item -Path $SourceBatchFilePath -Destination $BatchFilePath -Force -ErrorAction Stop
                Write-Output "Batch file copied successfully."
                Write-Output ""
                Write-Log "Batch file copied successfully."
            } catch {
                Write-Output "Error copying batch file: $_"
                Write-Log "Error copying batch file: $_"
                Write-Output "Exiting..."
                Write-Output ""
                exit 1
            }
        } else {
            Write-Output "User chose not to replace the file. Exiting..."
            Write-Log "User chose not to replace the file. Exiting..."
            Write-Output ""
            break
        }
    }
} else {
    # Destination file doesn't exist, proceed with copying
    try {
        Copy-Item -Path $SourceBatchFilePath -Destination $BatchFilePath -Force -ErrorAction Stop
        Write-Output "Batch file copied successfully."
        Write-Output ""
        Write-Log "Batch file copied successfully."
    } catch {
        Write-Output "Error copying batch file: $_"
        Write-Log "Error copying batch file: $_"
        Write-Output "Exiting..."
        Write-Output ""
        exit 1
    }
}

Clear-Host

try {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
    Register-ScheduledTask -TaskName $TaskName -Action $TaskAction -Trigger $TaskTrigger -Principal $TaskPrincipal -Settings $TaskCondition -Description $TaskDescription -ErrorAction Stop
    Write-Output "Scheduled task registered successfully."
    Write-Output ""
} catch {
    Write-Output "Error registering scheduled task: $_"
    Write-Log "Error registering scheduled task: $_"
    Write-Output "Exiting..."
    Write-Output ""
    exit 1
}
 
try{
    Start-ScheduledTask -TaskName $TaskName

    # Wait for the task to complete, checking its status directly
    $taskCompleted = $false
    while (-not $taskCompleted) {
        $taskStatus = Get-ScheduledTask -TaskName $TaskName | Select-Object -ExpandProperty State
        if ($taskStatus -eq 'Ready') {
            $taskCompleted = $true
        } else {
            Start-Sleep -Seconds 5  # Wait for a few seconds before checking again
        }
    }

    if ($taskCompleted) {
        Write-Output "The scheduled task completed successfully."
        Write-Output ""
        Clear-Host
        Write-Output "For most of the Samsung Services to work, the following need to be installed."
        # Initialize variables
        $CoreInstall = $false
        $AltInstall = $false

        # Define software package options
        $packageOptions = [ordered]@{
            '1' = @{
                Name = "Samsung Continuity Service"
                Id = "9P98T77876KZ"
            }
            '2' = @{
                Name = "Samsung Account"
                Id = "9NGW9K44GQ5F"
            }
            '3' = @{
                Name = "Samsung Cloud Assistant"
                Id = "9NFWHCHM52HQ"
            }
            '4' = @{
                Name = "Samsung Bluetooth Sync"
                Id = "9NJNNJTTFL45"
            }
            '5' = @{
                Name = "Samsung Settings Runtime"
                Id = "9NL68DVFP841"
            }
            '6' = @{
                Name = "Samsung Settings"
                Id = "9P2TBWSHK6HJ"
            }
            '7' = @{
                Name = "Samsung Update"
                Id = "9NQ3HDB99VBF"
            }
        }

        # Display package options
        Write-Output ""
        Write-Output "Please select the packages to install:"
        foreach ($option in $packageOptions.Keys) {
            Write-Output "$option. $($packageOptions[$option].Name)"
        }

        # Get user input
        $UserPrompt = Read-Host "Do you want to proceed with the installation? (Y)es or (N)o:"
        Write-Output ""

        # Validate user input
        if ($UserPrompt -eq 'Y' -or $UserPrompt -eq 'y') {
                $CoreInstall = $true
                $selectedPackage = $packageOptions[$UserPrompt]
                Write-Output "Installing $($selectedPackage.Name)..."                
                try {
                    # Install all the packages with for loop
                    foreach ($packageKey in $packageOptions.Keys) {
                        $selectedPackage = $packageOptions[$packageKey]
                        InstallPackage $selectedPackage.Name $selectedPackage.Id
                        Write-Log  "Installation of $($selectedPackage.Name) completed successfully."
                        Write-Output ""
                    }
                } catch {
                    # Handle installation errors
                    Write-Output ""
                    $ErrorMessage = "Error installing $($selectedPackage.Name): $_"
                    Write-Output $ErrorMessage
                    Write-Log $ErrorMessage
                }

        } else {
            Write-Output "No valid option selected. If needed, you can install the apps from the Microsoft Store or an alternative source."
            Write-Output ""
        }

# If core packages were installed, offer the option to install additional packages
if ($CoreInstall) {
    $selectedPackages = @()
    do {
        Clear-Host  # Clear the console screen
        
        # Print currently selected packages
        Write-Output "Selected packages: $($selectedPackages -join ', ')"
        Write-Output ""         
        $packageOptions = @{
            '1'  = 'Galaxy Buds'
            '2'  = 'Samsung Multi Control'
            '3'  = 'Quick Share'
            '4'  = 'Samsung Device Care'
            '5'  = 'Samsung Flow'
            '6'  = 'Samsung Gallery'
            '7'  = 'Samsung Notes'
            '8'  = 'Samsung Phone'
            '9'  = 'Samsung Printer Experience'
            '10' = 'Samsung Screen Recorder'
            '11' = 'Samsung Studio'
            '12' = 'Second Screen'
            '13' = 'SmartThings'
            '14' = 'Storage Share'
            '15' = 'Nearby Devices'
            '16' = 'All'
            '17' = 'Finish selection'
        }

        foreach ($key in ($packageOptions.Keys | Sort-Object { [int]$_ })) {
            Write-Output "$key. $($packageOptions[$key])"
        }

        $UserPrompt = Read-Host "Select packages to install ( Press 17 to finish selection)"

        # Validate user input
        if ($UserPrompt -in $packageOptions.Keys){
            switch ($UserPrompt) {
                '1' {
                    if ('Galaxy Buds' -in $selectedPackages) {
                        $selectedPackages = $selectedPackages -ne 'Galaxy Buds'
                    } else {
                        $selectedPackages += 'Galaxy Buds'
                    }
                }
                '2' {
                    if ('Samsung Multi Control' -in $selectedPackages) {
                        $selectedPackages = $selectedPackages -ne 'Samsung Multi Control'
                    } else {
                        $selectedPackages += 'Samsung Multi Control'
                    }
                }
                '3' {
                    if ('Quick Share' -in $selectedPackages) {
                        $selectedPackages = $selectedPackages -ne 'Quick Share'
                    } else {
                        $selectedPackages += 'Quick Share'
                    }
                }
                '4' {
                    if ('Samsung Device Care' -in $selectedPackages) {
                        $selectedPackages = $selectedPackages -ne 'Samsung Device Care'
                    } else {
                        $selectedPackages += 'Samsung Device Care'
                    }
                }
                '5' {
                    if ('Samsung Flow' -in $selectedPackages) {
                        $selectedPackages = $selectedPackages -ne 'Samsung Flow'
                    } else {
                        $selectedPackages += 'Samsung Flow'
                    }
                }
                '6' {
                    if ('Samsung Gallery' -in $selectedPackages) {
                        $selectedPackages = $selectedPackages -ne 'Samsung Gallery'
                    } else {
                        $selectedPackages += 'Samsung Gallery'
                    }
                }
                '7' {
                    if ('Samsung Notes' -in $selectedPackages) {
                        $selectedPackages = $selectedPackages -ne 'Samsung Notes'
                    } else {
                        $selectedPackages += 'Samsung Notes'
                    }
                }
                '8' {
                    if ('Samsung Phone' -in $selectedPackages) {
                        $selectedPackages = $selectedPackages -ne 'Samsung Phone'
                    } else {
                        $selectedPackages += 'Samsung Phone'
                    }
                }
                '9' {
                    if ('Samsung Printer Experience' -in $selectedPackages) {
                        $selectedPackages = $selectedPackages -ne 'Samsung Printer Experience'
                    } else {
                        $selectedPackages += 'Samsung Printer Experience'
                    }
                }
                '10' {
                    if ('Samsung Screen Recorder' -in $selectedPackages) {
                        $selectedPackages = $selectedPackages -ne 'Samsung Screen Recorder'
                    } else {
                        $selectedPackages += 'Samsung Screen Recorder'
                    }
                }
                '11' {
                    if ('Samsung Studio' -in $selectedPackages) {
                        $selectedPackages = $selectedPackages -ne 'Samsung Studio'
                    } else {
                        $selectedPackages += 'Samsung Studio'
                    }
                }
                '12' {
                    if ('Second Screen' -in $selectedPackages) {
                        $selectedPackages = $selectedPackages -ne 'Second Screen'
                    } else {
                        $selectedPackages += 'Second Screen'
                    }
                }
                '13' {
                    if ('SmartThings' -in $selectedPackages) {
                        $selectedPackages = $selectedPackages -ne 'SmartThings'
                    } else {
                        $selectedPackages += 'SmartThings'
                    }
                }
                '14' {
                    if ('Storage Share' -in $selectedPackages) {
                        $selectedPackages = $selectedPackages -ne 'Storage Share'
                    } else {
                        $selectedPackages += 'Storage Share'
                    }
                }
                '15' {
                    if ('Nearby Devices' -in $selectedPackages) {
                        $selectedPackages = $selectedPackages -ne 'Nearby Devices'
                    } else {
                        $selectedPackages += 'Nearby Devices'
                    }
                }
                '16' {
                    $allPackages = @(
                        'Galaxy Buds', 'Samsung Multi Control', 'Quick Share',
                        'Samsung Device Care', 'Samsung Flow', 'Samsung Gallery',
                        'Samsung Notes', 'Samsung Phone', 'Samsung Printer Experience',
                        'Samsung Screen Recorder', 'Samsung Studio', 'Second Screen',
                        'SmartThings', 'Storage Share', 'Nearby Devices'
                    )
                    foreach ($package in $allPackages) {
                        if ($package -notin $selectedPackages) {
                            $selectedPackages += $package
                        }
                    }
                }
                '17' { Write-Output "Finishing package selection." }
            }
        }
    } while ($UserPrompt -ne '17')

    # Install selected packages
    if ($selectedPackages.Count -gt 0) {
        Clear-Host 
        Write-Output "Installing selected packages..."
        foreach ($package in $selectedPackages) {
            switch ($package) {
                'Galaxy Buds' {
                    InstallPackage 'Galaxy Buds' '9NHTLWTKFZNB'
                }
                'Samsung Multi Control' {
                    InstallPackage 'Samsung Multi Control' '9N3L4FZ03Q99'
                }
                'Quick Share' {
                    InstallPackage 'Quick Share' '9PCTGDFXVZLJ'
                }
                'Samsung Device Care' {
                    InstallPackage 'Samsung Device Care' '9NBLGGH4XDV0'
                }
                'Samsung Flow' {
                    InstallPackage 'Samsung Flow' '9NBLGGH5GB0M'
                }
                'Samsung Gallery' {
                    InstallPackage 'Samsung Gallery' '9NBLGGH4N9R9'
                }
                'Samsung Notes' {
                    InstallPackage 'Samsung Notes' '9NBLGGH43VHV'
                }
                'Samsung Phone' {
                    InstallPackage 'Samsung Phone' '9mwjxxlchbgk'
                }
                'Samsung Printer Experience' {
                    InstallPackage 'Samsung Printer Experience' '9WZDNCRFHWGG'
                }
                'Samsung Screen Recorder' {
                    InstallPackage 'Samsung Screen Recorder' '9P5025MM7WDT'
                }
                'Samsung Studio' {
                    InstallPackage 'Samsung Studio' '9p312b4tzffh'
                }
                'Second Screen' {
                    InstallPackage 'Second Screen' '9PLTXW5DX5KB'
                }
                'SmartThings' {
                    InstallPackage 'SmartThings' '9N3ZBH5V7HX6'
                }
                'Storage Share' {
                    InstallPackage 'Storage Share' '9mvnw0xh7hs5'
                }
                'Nearby Devices' {
                    InstallPackage 'Nearby Devices' '9phl04njnt67'
                }
            }
        }
    } else {
        Write-Output "No additional packages were selected for installation."
    }
} else {
    Write-Output "No core packages were installed, skipping additional package installation."
}

    # Final message
    if ($AltInstall -or $CoreInstall) {
        Write-Output "You have successfully installed the selected packages."
        } else {
            Write-Output "No packages were installed."
        }       
    } else {
        Write-Output "The scheduled task did not complete successfully. Current working directory has been left as is."
    }
    Write-Log "Script execution completed."

    Write-Output "Please delete the Script directory after the installation is complete."
    $deleteConfirmation = Read-Host
    } catch {
        Write-Output "Error checking task completion: $_"
        Write-Log "Error checking task completion: $_"
}

Write-Output "Press any key to exit..."
$null = Read-Host