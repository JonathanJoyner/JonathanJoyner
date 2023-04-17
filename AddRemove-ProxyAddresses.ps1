$ErrorActionPreference = "Continue"
###  Setup for Logs and UNC Paths
$Date = (Get-Date -Format D)
Start-Transcript -path C:\Exports\$Date.txt -append
Write-Host "Verifying Export Path Exists"
$TARGETDIR = 'C:\Exports\Terminations\Office365'
if(!(Test-Path -Path $TARGETDIR )){
    New-Item -ItemType directory -Path $TARGETDIR
}
$MBUsers = Import-csv "C:\Users\jonathanj\OneDrive - insightsoftware\Documents\CSV\M&A\BizView\BVS-SharedFWDs062122.csv"
foreach ($MBUser in $MBUsers){
    $UserDisplayName = $MBUser.DisplayName
    $UserName = $MBUser.SamAccountName
    $Alias = $MBUsers.Proxyaddresses
    $MailboxExists = Get-ADUser -Identity $UserName
    If($MailboxExists){
        Write-Host "Updating EmailAddresses for" $UserDisplayName
        Set-ADUser -identity $UserName -add @{ProxyAddresses=$Alias}
        Start-Sleep 1
    }
    Else {
    Write-Host "User" $UserName "Does not exist"
    Start-Sleep 1
    }
}