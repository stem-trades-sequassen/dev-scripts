<#
STEM/Trades Laptop Deployment Script
- Activates OpenSSH feature and sets service to automatic
- Installs Tailscale and connects to the STEM/Trades Tailnet [To be configured with a yubikey]
- Once Tailscale is installed, installs puppet-agent and connects to the puppetserver running on stem-server
#>
Write-Host "The hostname of this computer is: "
Write-Host $env:computername
$renameImput = Read-Host -Prompt "Do you need to update this hostname? [True/False]"
try 
{
    $renameInput = [System.Convert]:ToBoolean($renameInput)
}
catch 
{
    Write-Host "Invalid Input."
    $renameImput = Read-Host -Prompt "Do you need to update this hostname? [True/False]"
    $renameInput = [System.Convert]:ToBoolean($renameInput)
}
if (renameInput = True)
{
    Write-Host "Renaming Host"
    $hostNewName = Read-Host -Prompt "New Hostname"
    Rename-Computer -NewName $hostNewName
}else{}

<#
SSH SETUP
    ENABLING SSH SERVICE
        IMPORTANT: This will not work unless the OpenSSH service is installed as a Windows component
        Go to [Settings] => [System] => [Optional Features], and install the OpenSSH service
        This cmdlet script will also set the SSH server to run automatically

TODO: Increase verbosity and alerts for end-user
#>

Start-Service sshd
Get-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
Get-NetFirewallRule -Name *ssh*

<#
TAILSCALE SETUP

TODO: Silent installation if possible, as well as secrets management.
Idea is to have a auth keyfile on a secure drive that can be plugged into the laptop for "headless" install of tailscale
Will also research tagging and trying to isolate to their own tags, while still allowing outside access.
#>
$tailScaleDownloadUrl = "https://pkgs.tailscale.com/stable/tailscale-setup-latest.exe"
Invoke-WebRequest $tailScaleDownloadUrl -OutFile "C:\Users\Default\AppData\Local\Temp\tailscale-setup-latest.exe"
Start-Process -FilePath "tailscale-setup-latest.exe" -Wait

$puppetAgentDownloadUrl = "https://downloads.puppetlabs.com/windows/puppet8/puppet-agent-x64-latest.msi" # Puppet does not offer a direct URI to the latest installer, update link every season.
Invoke-WebRequest $puppetAgentDownloadUrl -OutFile "C:\Users\Default\AppData\Local\Temp\puppet-agent-x64-latest.msi"
