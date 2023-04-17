Import-Module ActiveDirectory
$Date = (Get-Date -Format D)
Start-Transcript -path C:\Scripts\ScriptLogs\$Date.txt -append
Write-Host "Verifying Export Path Exists"
$TARGETDIR = 'C:\Scripts\ScriptLogs'
if(!(Test-Path -Path $TARGETDIR )){
    New-Item -ItemType directory -Path $TARGETDIR
}
Add-Type -AssemblyName System.Windows.Forms 
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop') } 
$null = $FileBrowser.ShowDialog() 
$FilePath = $FileBrowser.FileName 
$Users = Import-csv $FilePath 
foreach ($User in $Users){
#   $UPN = $User.UPN
#   $UserName = Get-ADUser -Filter * | Where-Object {($_.UserPrincipalName -eq $UPN)} | Select-Object SamAccountName
    $UserName = $User.SamAccountName
    $UserDisplayName = (Get-ADUser -Identity $UserName | Select-Object Name).Name
    $UserOU = (Get-ADUser -Identity $UserName).DistinguishedName
    $DestinationOU = "OU=Users,OU=Cubeware,OU=Users,OU=insightsoftware,DC=insightsoftware,DC=lan"
    Write-Host "Moving User:" $UserDisplayName "from" $UserOU "to" $DestinationOU
    If( $UserOU -ne $DestinationOU)
    {
        Move-ADObject -Identity $UserOU -TargetPath $DestinationOU
    }
    Else {
        Write-Host "User" $UserDisplayName "Does not exist"
        Start-Sleep 1
        }
}