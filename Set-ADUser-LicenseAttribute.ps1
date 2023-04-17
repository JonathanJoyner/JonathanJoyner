Import-Module ActiveDirectory
$Users = Import-csv "C:\JB\Femalelist.csv"
Foreach($User in $Users){
    $UserName = $User.SamAccountName
    $Attribute = "E3"
    $UserDisplayName = $User.DisplayName
    $UserExists = Get-ADuser -Identity $UserName
        If($UserExists){
        Write-Host "Setting 'msDS-cloudExtensionAttribute2' attribute for" $UserDisplayName "to" $Attribute
        Set-ADUser -Identity $UserName -Replace @{'msDS-cloudExtensionAttribute2' =$Attribute}
        Start-Sleep 1
    }
        Else {
        Write-Host "User" $UserDisplayName "Does not exist"
        Start-Sleep 1
    }
}



Microsoft Office 365 = "insightsw:SPE_E3"
