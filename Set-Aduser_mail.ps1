#####   Purpose of this script: Import CSV of ADUsers and set the 'mail' attribute
#####   CSV Column Names: SamAccountName, mail, UserDisplayName
#####   Update Import Path before proceeding
#####   Created on 3/5/21 for Insightsoftware by Jonathan Joyner
Import-Module ActiveDirectory
$Users = Import-csv "C:\JB\Femalelist.csv"
Foreach($User in $Users){
    $UserName = $User.SamAccountName
    $UserMail = $User.mail
    $UserDisplayName = $User.UserDisplayName
    $UserExists = Get-ADuser -Identity $UserName
        If($UserExists){
        Write-Host "Setting mail attribute for" $UserDisplayName "to" $UserMail
        Set-ADUser -Identity $UserName -email $UserMail
        Start-Sleep 1
    }
        Else {
        Write-Host "User" $UserDisplayName "Does not exist"
        Start-Sleep 1
    }
}