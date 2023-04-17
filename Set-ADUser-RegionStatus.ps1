Import-Module ActiveDirectory
$Date = Get-Date -Format "MM.dd.yyyy.HH.mm"
Write-Host "Verifying Export Path Exists"
$TARGETDIR = 'C:\Exports\Logs\AD'
if(!(Test-Path -Path $TARGETDIR )){
    New-Item -ItemType directory -Path $TARGETDIR
}
Start-Transcript -path C:\Exports\Logs\AD\$Date.txt -append
Add-Type -AssemblyName System.Windows.Forms 
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop') } 
$null = $FileBrowser.ShowDialog() 
$FilePath = $FileBrowser.FileName 
$Users = Import-csv $FilePath 
Foreach($User in $Users){
    $UPN = $User.UserPrincipalName
    $SAM = (Get-ADUser -Filter * | Where-Object {($_.UserPrincipalName -eq $UPN)} | Select-Object SamAccountName).SamAccountName
    $UserDisplayName = (Get-ADUser -Identity $SAM | Select-Object Name).Name
    $Region = $User.Region
    $EmpStatus = $User.EmpStatus
    $UserExists = Get-ADuser -Identity $SAM
        If($UserExists){
        Write-Host "Setting 'msDS-cloudExtensionAttribute3' attribute for" $UserDisplayName "to" $Region
        Set-ADUser -Identity $SAM -Replace @{'msDS-cloudExtensionAttribute3' =$Region}
        Write-Host "Setting 'msDS-cloudExtensionAttribute4' attribute for" $UserDisplayName "to" $EmpStatus
        Set-ADUser -Identity $SAM -Replace @{'msDS-cloudExtensionAttribute4' =$EmpStatus}
    }
        Else {
        Write-Host "User" $UPN "Does not exist"
    }
}
Stop-Transcript