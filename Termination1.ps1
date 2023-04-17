Import-Module ActiveDirectory
$Leavers = Import-Csv -Path ""
    foreach($Leaver in $Leavers){
    $UserName = $Leaver.SamAccountName
    $UserDisplayName = $Leaver.DisplayName
    $Password = $Leaver.Password
    $ExpiryDate = "07/07/2021 12:00:00 AM"
    $UserExists = Get-ADuser -Identity $UserName
        If($UserExists){
        Write-Host "Updating Password for user:" $UserDisplayName
        Set-ADAccountPassword -Identity $UserName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $Password -Force)
        Start-Sleep 1
        Write-Host "Updating Expiry for user:" $UserDisplayName "to" $ExpiryDate
        Set-ADUser -Identity $UserName -AccountExpirationDate $ExpiryDate
        Start-Sleep 1
        }
        Else {
        Write-Host "User" $UserName "Does not exist"
        Start-Sleep 1
    }
}