@echo off
setlocal enabledelayedexpansion

:: Backup current registry values
set "backupfile=RegistryBackup_%date:~-4%-%date:~-7,2%-%date:~-10,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%.txt"

:: Elevate to admin
set "params=%*" 
cd /d "%~dp0" 
pushd "%~dp0" 
if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" 
fsutil dirty query %systemdrive% 1>nul 2>nul || (
    echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" 
    "%temp%\getadmin.vbs" 
    exit /B
)

:: Create backup
(
    echo Backup created: %date% %time%
    echo ******************************************
    
    echo [HKLM\HARDWARE\DESCRIPTION\System\BIOS]
    for %%k in (
        "BaseBoardManufacturer"
        "BaseBoardProduct"
        "SystemFamily"
        "SystemManufacturer"
        "SystemProductName"
        "SystemSKU"
        "SystemVersion"
    ) do (
        reg query "HKLM\HARDWARE\DESCRIPTION\System\BIOS" /v "%%~k" 2>nul || echo %%k: Not Found
    )
    
    echo.
    echo [HKLM\SYSTEM\ControlSet001\Control\SystemInformation]
    for %%k in (
        "SystemManufacturer"
        "SystemProductName"
    ) do (
        reg query "HKLM\SYSTEM\ControlSet001\Control\SystemInformation" /v "%%~k" 2>nul || echo %%k: Not Found
    )
    
    echo.
    echo [HKLM\SYSTEM\HardwareConfig\Current]
    for %%k in (
        "SystemFamily"
        "SystemManufacturer"
        "SystemProductName"
        "SystemSKU"
        "SystemVersion"
    ) do (
        reg query "HKLM\SYSTEM\HardwareConfig\Current" /v "%%~k" 2>nul || echo %%k: Not Found
    )
) > "%backupfile%"

echo Backup saved to: "%backupfile%"
echo Press any key to exit...
pause >nul