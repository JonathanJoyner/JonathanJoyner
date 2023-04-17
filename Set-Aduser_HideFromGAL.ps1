$ErrorActionPreference = "Continue"
###  Setup for Logs and UNC Paths
$Date = (Get-Date -Format D)
Start-Transcript -path C:\Exports\$Date.txt -append
Write-Host "Verifying Log Path Exists"
$TARGETDIR = 'C:\Exports\Logs\AD'
if(!(Test-Path -Path $TARGETDIR )){
    New-Item -ItemType directory -Path $TARGETDIR
}
###  Import Data Set
$ADUsers = Import-csv "C:\Users\jonathanj\OneDrive - insightsoftware\Documents\CSV\Termination\Terminations011022.csv"
foreach ($ADUser in $ADUsers){
    $UserDisplayName = $ADUser.DisplayName
    $UserName = $ADUser.UserPrincipalName
    $Value = 'HideFromGAL'
    $UserExists = Get-Mailbox -Identity $UserName
    If($UserExists){
        Write-Host "Hiding" $UserDisplayName "From the Global Address List"
        Set-ADUser -Identity $Username -Add @{"msDS-cloudExtensionAttribute1" = $Value }
        Start-Sleep 1
    }
    Else {
        ###   Report users with Error for log file
        Write-Host "The account for" $UserDisplayName "doesn't exist"
    }
}
Stop-Transcript