#####   Purpose of this script: Import CSV of ADUsers and move the user object to the specified OU
#####   CSV Column Names: SamAccountName, mail, UserDisplayName
#####   Update Import Path before proceeding
#####   Update Line 10 with desired target OU
#####   Created on 3/5/21 for Insightsoftware by Jonathan Joyner
Import-Module ActiveDirectory
$Contractors = Import-Csv -Path ""
    foreach($Contractor in $Contractors){
    $UserName = $.SamAccountName
    $TargetOU = "OU=Contractors,OU=Emails,OU=insightsoftware,DC=insightsoftware,DC=lan"
    $UserExists = Get-ADuser -Identity $UserName
        If($UserExists){
        Write-Host "Moving user:" $UserName "to" $TargetOU
        Move-ADOject -Identity $UserName -TargetPath $TargetOU
        Start-Sleep 1
    }
        Else {
        Write-Host "User" $UserName "Does not exist"
        Start-Sleep 1
    }
}