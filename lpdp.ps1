<#
STEM/Trades Laptop Deployment Script
- Activates OpenSSH feature and sets service to automatic
- Installs Tailscale and connects to the STEM/Trades Tailnet [To be configured with a yubikey?]
- Once Tailscale is installed, configures SSH & WinRM to allow remote management
- Setup from there will be managed by an Ansible playbook for the inventory.
#>
Write-Host "The hostname of this computer is: "
Write-Host $env:computername
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
if ($renameInput = True)
{
    Write-Host "Renaming Host"
    $hostNewName = Read-Host -Prompt "New Hostname"
    Rename-Computer -NewName $hostNewName
}else{}
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
Add-WindowsCapabiltiy -Online -Name OpenSSH.Server~~~~0.0.1.0 # Yes, hardcoding the version is necessary. Don't ask, Windows thing.
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
# Start-Process -FilePath "tailscale-setup-latest.exe" -Wait
# Not using the .exe anymore

<# RIP Puppet, you're just too obtuse for my small brain to handle.
$puppetAgentDownloadUrl = "https://downloads.puppetlabs.com/windows/puppet8/puppet-agent-x64-latest.msi" # Puppet does not offer a direct URI to the latest installer, update link every season.
Invoke-WebRequest $puppetAgentDownloadUrl -OutFile "C:\Users\Default\AppData\Local\Temp\puppet-agent-x64-latest.msi"
#>