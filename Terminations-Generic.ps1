#####   This script is intended to perform the AD related termination tasks
#####   Actions: 
#####       Update user's Password
#####       Update user's Expiry Date       
#####       Export CSV of user's Group Memberships
#####       Remove user's AD Group Memberships
#####   CSV Headers: DisplayName,SamAccountName,Password
#####   Created on 4/7/21 for Insightsoftware by Jonathan Joyner
Import-Module ActiveDirectory
$Date = (Get-Date -Format D)
Start-Transcript -path C:\Exports\Terminations\Logs\$Date.txt -append
Write-Host "Verifying Export Paths Exists"
$LogDIR = 'C:\Exports\Terminations\Logs'
if(!(Test-Path -Path $LogDIR )){
    New-Item -ItemType directory -Path $LogDIR
}
$ExportDIR = 'C:\Exports\Terminations\2022'
if(!(Test-Path -Path $ExportDIR )){
    New-Item -ItemType directory -Path $ExportDIR
}
Add-Type -AssemblyName System.Windows.Forms 
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop') } 
$null = $FileBrowser.ShowDialog() 
$FilePath = $FileBrowser.FileName 
$Leavers = Import-csv $FilePath 
foreach($Leaver in $Leavers){
    $UPN = $Leaver.UserPrincipalName
    $User = Get-ADUser -Filter * | Where-Object {($_.UserPrincipalName -eq $UPN)} | Select-Object SamAccountName
    $UserName = $User.SamAccountName
    $UserDisplayName = (Get-ADUser -Identity $UserName | Select-Object Name).Name
    $UserOU = (Get-ADUser -Identity $UserName).DistinguishedName
    $DisabledOU = (Get-ADOrganizationalUnit -Filter 'Name -like "Disabled"').DistinguishedName
    $Password = $Leaver.Password
#   $ExpiryDate = (Get-date).AddDays(90)
    $DisabledDate = (Get-Date)
    $UserExists = Get-ADuser -Identity $UserName
        If($UserExists){
        Write-Host "Updated Password for user:" $UserDisplayName
        Set-ADAccountPassword -Identity $UserName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $Password -Force)
        Start-Sleep 1
#        Write-Host "Updating Expiry for user:" $UserDisplayName "to" $ExpiryDate
#        Set-ADUser -Identity $UserName -AccountExpirationDate $ExpiryDate
#        Start-Sleep 1
        Write-Host "Disabled AD Account  for user:" $UserName "on" $DisabledDate
        Disable-ADAccount -Identity $Username
        Start-Sleep 1
        Write-Host "Exported ADGroup Memberships for user:" $UserDisplayName
        Get-ADPrincipalGroupMembership -Identity $UserName | Select-Object name, groupcategory, groupscope | export-CSV C:\Exports\Terminations\2022\$UserName.csv -Delimiter ";" -NoTypeInformation -Encoding UTF8
        Start-Sleep 1
        Write-Host "Removed ADGroup Memberships for user:" $UserDisplayName
        Get-AdPrincipalGroupMembership -Identity $Username | Where-Object -Property Name -Ne -Value 'Domain Users' | Remove-AdGroupMember -Members $Username -Confirm:$false
        Start-Sleep 1
        Write-Host "Moving User:" $UserDisplayName "to" $DisabledOU
        Move-ADObject -Identity $UserOU -TargetPath $DisabledOU
        }
        Else {
        Write-Host "User" $UPN "Does not exist"
        Start-Sleep 1
        }
}
repadmin.exe /syncall
Start-Sleep 1
Start-ADSyncSyncCycle -PolicyType Delta
Stop-Transcript