<#
STEM/Trades Laptop Deployment Script
- Sets hostname of laptop to match inventory tags
- Activates Administrator account and lowers priveleges of student account
- Installs necessary components for use by scouts

# Future features
- Activates OpenSSH feature and sets service to automatic
- Installs Tailscale and connects to the STEM/Trades Tailnet [To be configured with a yubikey?]
- Once Tailscale is installed, configures SSH & WinRM to allow remote management
- Copy SSH key from deployment drive to proper location for Windows
- Setup from there will be managed by an Ansible playbook for the inventory.
#>

# Hostname Update
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

$adminInput = Read-Host -Prompt "Do you need to update admin/guest accounts? [True/False]"

try 
{
    $adminInput = [System.Convert]::ToBoolean($adminInput)
}
catch 
{
    Write-Host "Invalid Input."
    $adminInput = Read-Host -Prompt "Do you need to update admin/guest accounts? [True/False]"
    $adminInput = [System.Convert]::ToBoolean($adminInput)
}
if ($adminInput -eq $true)
{
    # Prompt for admin password
    $adminPassword = Read-Host "Enter password for Admin account" -AsSecureString

    # Create Admin account
    $adminUsername = "SEQAdmin"
    New-LocalUser -Name $adminUsername -Password $adminPassword -FullName "Administrator Account" -Description "Custom Admin account"
    Add-LocalGroupMember -Group "Administrators" -Member $adminUsername
    Write-Host "Admin account '$adminUsername' created and added to Administrators group."

    # Prompt for guest password
    $guestPassword = Read-Host "Enter password for Guest account" -AsSecureString

    # Create Guest account
    $guestUsername = "SeqUser"
    New-LocalUser -Name $guestUsername -Password $guestPassword -FullName "Guest Account" -Description "Custom Guest account"
    Write-Host "Guest account '$guestUsername' created."
    Remove-LocalGroupMember -Group "Administrators" -Member "SeqUser"
    Add-LocalGroupMember -Group "Guests" -Member "SeqUser"
} else {
    Write-Host "No changes made."
}
winget install -e --id Python.Python.3.11 --scope machine
winget install -e --id Microsoft.VisualStudioCode --scope machine
.\"setup_kerbal_space_program_1.12.5.03190_(64bit)_(60913)"


