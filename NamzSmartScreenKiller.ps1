# PowerShell script to disable all types of SmartScreen without elevation prompt

# Function to check if the script is running as administrator
function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole($adminRole)
}

# If the script is not running as administrator, relaunch it with elevated privileges without prompting
if (-not (Test-Admin)) {
    Start-Process -FilePath "powershell" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Hidden
    exit
}

# Disable all types of SmartScreen

# Disable SmartScreen for apps and downloaded files
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\SmartScreen" -Name "ConfigureAppInstallControl" -Value 0 -Force

# Disable SmartScreen for Microsoft Edge
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\MicrosoftEdge\PhishingFilter" -Name "EnabledV9" -Value 0 -Force

# Disable SmartScreen for Microsoft Store apps
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost" -Name "EnableWebContentEvaluation" -Value 0 -Force

# Disable SmartScreen for executable files (Application Reputation)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "SmartScreenEnabled" -Value "Off" -Force

# Disable SmartScreen for downloaded files (Attachment Manager)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" -Name "SaveZoneInformation" -Value 1 -Force

# Disable Windows Defender SmartScreen
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SmartScreenSettings" -Name "SmartScreenEnabled" -Value 0 -Force

# Restart Windows Defender service to apply changes
Stop-Service -Name windefend -Force
Start-Service -Name windefend
