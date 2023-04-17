#####   This script is intended to perform the AD related termination tasks
#####   Actions: 
#####       Update user's Password
#####       Update user's Expiry Date       
#####       Export CSV of user's Group Memberships
#####       Remove user's AD Group Memberships
#####   CSV Headers: DisplayName,SamAccountName,Password
#####   To run this script update Line "16" with the path of the csv
#####   Created on 4/7/21 for Insightsoftware by Jonathan Joyner
#####       Updates - Disables instead of set to expire. Create transcript log. 8/11/21
Import-Module ActiveDirectory
$Date = (Get-Date -Format D)
Start-Transcript -path C:\Exports\Terminations\Logs\$Date.txt -append
Write-Host "Verifying Export Path Exists"
$TARGETDIR = 'C:\Exports\Terminations\Logs'
if(!(Test-Path -Path $TARGETDIR )){
    New-Item -ItemType directory -Path $TARGETDIR
}
$Leavers = Import-Csv -Path "C:\Exports\TestTermination.csv"
foreach($Leaver in $Leavers){
    $UserName = $Leaver.SamAccountName
    $UserDisplayName = $Leaver.DisplayName
    $Password = $Leaver.Password
    $ExpiryDate = (Get-date).AddDays(90)
    $DisabledDate = (Get-Date)
    $UserExists = Get-ADuser -Identity $UserName
        If($UserExists){
        Write-Host "Updated Password for user:" $UserDisplayName
        Set-ADAccountPassword -Identity $UserName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $Password -Force)
        Start-Sleep 1
        Write-Host "Disabled AD Account  for user:" $UserName "on" $DisabledDate
        Disable-ADAccount -Identity $Username
        Start-Sleep 1
        Write-Host "Exported ADGroup Memberships for user:" $UserDisplayName
        Get-ADPrincipalGroupMembership -Identity $UserName | Select-Object name, groupcategory, groupscope | export-CSV C:\Exports\Terminations\2022\$UserName.csv -Delimiter ";" -NoTypeInformation -Encoding UTF8
        Start-Sleep 1
        Write-Host "Removed ADGroup Memberships for user:" $UserDisplayName
        Get-AdPrincipalGroupMembership -Identity $Username | Where-Object -Property Name -Ne -Value 'Domain Users' | Remove-AdGroupMember -Members $Username -Confirm:$false
        Start-Sleep 1
        }
        Else {
        Write-Host "User" $UserName "Does not exist"
        Start-Sleep 1
        }
}
repadmin.exe /syncall
Start-Sleep 1
Start-ADSyncSyncCycle -PolicyType Delta
Stop-Transcript