$Mailboxes = Import-Csv "C:\Users\JonathanJ\OneDrive - insightsoftware\Documents\Event1\DistLists\E12ISWGroups.csv"
ForEach ($Mailbox in $Mailboxes){ 
        $Name=$Mailbox.UserPrincipalName
        $Proxy=$Mailbox.ProxyAddresses
        Set-ADUser -Identity $Name `
        -add @{ProxyAddresses=$Proxy}
}




Set-ADUser Adrienne.Williams -add @{ProxyAddresses="smtp:adrienne.williams.mail.onmicrosoft.com"}