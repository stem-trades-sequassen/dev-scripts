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

# Optional: Disable guest account (uncomment if needed)
# Disable-LocalUser -Name $guestUsername
# Write-Host "Guest account '$guestUsername' has been disabled."

