@echo off
reg add "HKLM\HARDWARE\DESCRIPTION\System\BIOS" /v BaseBoardManufacturer /t REG_SZ /d "SAMSUNG ELECTRONICS CO., LTD." /f
reg add "HKLM\HARDWARE\DESCRIPTION\System\BIOS" /v BaseBoardProduct /t REG_SZ /d "NP960XGL-XG1US" /f
reg add "HKLM\HARDWARE\DESCRIPTION\System\BIOS" /v SystemProductName /t REG_SZ /d "NP960XGL-XG1US" /f
reg add "HKLM\HARDWARE\DESCRIPTION\System\BIOS" /v SystemFamily /t REG_SZ /d "Galaxy Book4 Ultra" /f
reg add "HKLM\HARDWARE\DESCRIPTION\System\BIOS" /v SystemManufacturer /t REG_SZ /d "SAMSUNG ELECTRONICS CO., LTD." /f
