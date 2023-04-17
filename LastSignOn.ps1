LastSignOn
Install-Module AzureAD
Install-Module MSOnline
Connect-ExchangeOnline
$MBUsers = Import-csv "C:\Users\jonathanj\OneDrive - insightsoftware\Documents\CSV\LogiADImport.csv"
foreach ($MBUser in $MBUsers){
    $UserName = $MBUser.UserPrincipalName
    $MailboxExists = Get-Mailbox -Identity $MBUser.UserPrincipalName
    $LastLogon = (Get-MailboxStatistics -Identity $UserName).lastlogontime
    If($MailboxExists){
        Write-Host "User" $MBUser.DisplayName "Last logged on at:" $LastLogon
    }
    Else {
        Write-Host "The mailbox for" $MBUser.DisplayName "doesn't exist"
    }
}