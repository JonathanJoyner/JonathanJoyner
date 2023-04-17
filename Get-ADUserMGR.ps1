Import-Module Active Directory
$ErrorActionPreference = "Continue"
$Date = (Get-Date -Format D)
Write-Host "Verifying Export Path Exists"
$TARGETDIR = 'C:\Exports\Terminations\Office365'
if(!(Test-Path -Path $TARGETDIR )){
    New-Item -ItemType directory -Path $TARGETDIR
}
Start-Transcript -path C:\Exports\$Date.txt -append
Add-Type -AssemblyName System.Windows.Forms 
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop') } 
$null = $FileBrowser.ShowDialog() 
$FilePath = $FileBrowser.FileName 
$ADUsers = Import-csv $FilePath
foreach ($ADUser in $ADUsers){
    $UPN = $ADUser.UserPrincipalName
    $User = (Get-ADUser -Filter * | Where-Object {($_.UserPrincipalName -eq $UPN)} | Select-Object SamAccountName).SamAccountName
    $DisplayName = (Get-ADUser -Identity $User | Select-Object Name).Name
    $MGRDN = (Get-ADUser -Identity $User -properties * | Select-Object Manager).Manager
    $MGRName = (Get-ADObject -Identity $MGRDN -Properties * | Select-Object Name).Name
    $MGRAddress = (Get-ADObject -Identity $MGRDN -Properties * | Select-Object UserPrincipalName).UserPrincipalName
    $ADUserExists = Get-ADUser -Identity $UserName
    If($ADUserExists){
        Write-Host "Getting User properties for" $DisplayName
        $report = New-Object psobject
        $report | Add-Member -MemberType NoteProperty -name UserPrincipalName -Value $UPN
        $report | Add-Member -MemberType NoteProperty -name UserDisplayName -Value $DisplayName
        $report | Add-Member -MemberType NoteProperty -name ManagerName -Value $MGRName
        $report | Add-Member -MemberType NoteProperty -name ManagerAddress -Value $MGRAddress
        $report | export-csv C:\Exports\TestMGRExport.csv -NoTypeInformation
        Start-Sleep 1 
    }
    Else {
        Write-Host "The Account for" $DisplayName "doesn't exist"
    }
}
Stop-Transcript
