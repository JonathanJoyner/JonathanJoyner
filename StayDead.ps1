Import-Module ActiveDirectory
$Date = (Get-Date -Format D)
Start-Transcript -path C:\Scripts\ScriptLogs\$Date.txt -append
Write-Host "Verifying Export Path Exists"
$TARGETDIR = 'C:\Scripts\ScriptLogs'
if(!(Test-Path -Path $TARGETDIR )){
    New-Item -ItemType directory -Path $TARGETDIR
}
$DisabledOUUsers = Get-ADUser -Filter * | Where-Object {($_.enabled -eq $True) -AND ($_.distinguishedname -match "OU=Disabled")}
foreach ($DisabledOUUser in $DisabledOUUsers){
    $UserDisplayName = $DisabledOUUser.Name
    $UserName = $DisabledOUUser.SamAccountName
    Write-Host "Disabling" $UserDisplayName
    Disable-ADAccount -Identity $Username
}
Stop-Transcript