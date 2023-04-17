Set-ExecutionPolicy -ExecutionPolicy Unrestricted
$Date = (Get-Date -Format D)
Start-Transcript -path C:\Exports\Logs\AD\$Date.txt -append
Write-Host "Verifying Export Path Exists"
$TARGETDIR = 'C:\Exports\Logs\AD'
if(!(Test-Path -Path $TARGETDIR )){
    New-Item -ItemType directory -Path $TARGETDIR
}
Add-Type -AssemblyName System.Windows.Forms 
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop') } 
$null = $FileBrowser.ShowDialog() 
$FilePath = $FileBrowser.FileName 
$GroupUsers = Import-csv $FilePath 
foreach ($GroupUser in $GroupUsers){
    $UPN = $GroupUser.UserPrincipalName
    $SamAccountName = (Get-ADUser -Filter * | Where-Object {$_.UserPrincipalName -eq $UPN}).SamAccountName
    $UserDisplayName = (Get-ADUser -Identity $SamAccountName).Name
    $Group = $GroupUser.Group
    $ADExists = Get-ADUser -Identity $SamAccountName
    If($ADExists){
        Write-Host "Adding" $UserDisplayName "to group:" $Group
        Add-ADGroupMember -Identity $Group -Members $SamAccountName
        Start-Sleep 1
    }
    Else {
        Write-Host "User:" $UserDisplayName "doesn't exist"
    }
}