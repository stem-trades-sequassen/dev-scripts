<#
STEM/Trades Laptop Deployment Script
- Activates OpenSSH feature and sets service to automatic
- Installs Tailscale and connects to the STEM/Trades Tailnet [To be configured with a yubikey?]
- Once Tailscale is installed, configures SSH & WinRM to allow remote management
- Copy SSH key from deployment drive to proper location for Windows
- Setup from there will be managed by an Ansible playbook for the inventory.
#>
Write-Host "The hostname of this computer is: $env:computername"
$renameInput = Read-Host -Prompt "Do you need to update this hostname? [True/False]"
try 
{
    $renameInput = [System.Convert]::ToBoolean($renameInput)
}
catch 
{
    Write-Host "Invalid Input."
    $renameInput = Read-Host -Prompt "Do you need to update this hostname? [True/False]"
    $renameInput = [System.Convert]::ToBoolean($renameInput)
}
if ($renameInput -eq $true)
{
    Write-Host "Renaming Host"
    $hostNewName = Read-Host -Prompt "New Hostname"
    Rename-Computer -NewName $hostNewName
} else {
    Write-Host "No changes made."
}
<# 
Network Configuration
Necessary for WinRM stuff.
 #>
$connectionProfile = Get-NetConnectionProfile
$networkSSID = $connectionProfile.name
Set-NetConnectionProfile -Name $networkSSID -NetworkCategory Private
<#
SSH SETUP
    ENABLING SSH SERVICE
        IMPORTANT: This will not work unless the OpenSSH service is installed as a Windows component
        Go to [Settings] => [System] => [Optional Features], and install the OpenSSH service
        This cmdlet script will also set the SSH server to run automatically

TODO: Increase verbosity and alerts for end-user
#>
<# This #>
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 # Yes, hardcoding the version is necessary. Don't ask, Windows thing.
Start-Service sshd
Get-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
Get-NetFirewallRule -Name *ssh*

<# WinRM Setup #>
winrm quickconfig
<#
TAILSCALE SETUP

TODO: Silent installation if possible, as well as secrets management.
Idea is to have a auth keyfile on a secure drive for the season that can be plugged into the laptop for "headless" install of tailscale
Will also research tagging and trying to isolate to their own tags, while still allowing outside access.
#>
$tailScaleDownloadUrl = "https://pkgs.tailscale.com/stable/tailscale-setup-1.76.0-amd64.msi" # Hardcoded for now
Invoke-WebRequest $tailScaleDownloadUrl -OutFile "C:\Users\Default\AppData\Local\Temp\tailscale-setup-1.76.0-amd64.msi"
msiexec /i "C:\Users\Default\AppData\Local\Temp\tailscale-setup-1.76.0-amd64.msi" /quiet /passive /qn

<#
In the same working directory as this script, create a extensionless file named 'authkey' with the content containing only your authkey.
Once done, uncomment the following code block
#>
<#
$authKeyFile = Get-Content -Path (Join-Path $PSScriptRoot "authkey")
& 'C:\Program Files\Tailscale\tailscale.exe' up --authkey $authKeyFile
#>

<# Creating the Student User #>
New-LocalUser -Name 'SeqUser' -Description 'Student account' -NoPassword
Add-LocalGroupMember -Group 'Users' -Member 'SeqUser'

<#
In the same working directory as this script, copy your public SSH key and update the command below to match its name.
Once done, uncomment the following code block
#>
<#
$sshPubKey = Join-Path $PSScriptRoot "id_ed25519.pub") # Change 'id_ed25519.pub' to whatever name you have for your public key file. Make sure it's in the same directory as the script
Copy-Item -Path $sshPubKey -Destination "C:\ProgramData\ssh\administrators_authorized_keys"
icacls.exe "C:\ProgramData\ssh\administrators_authorized_keys" /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F"
#>