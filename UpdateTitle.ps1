#Requires -Module ActiveDirectory

param (
    [Parameter(Mandatory)]
    [ValidateScript({if (Test-Path $_) {
                        if ((Get-Item $_ | Select-Object -ExpandProperty Extension) -eq '.csv') {$true}}})]
    $FilePath
)

Import-Module ActiveDirectory
$NewUsersList=Import-CSV $FilePath
# $NewUsersList=Import-CSV "C:\Users\admin.jonathan\Documents\LogiADImportTest.csv"

ForEach ($User in $NewUsersList) {
    $Title = $User.Title
    $SamAccountName = $User.SamAccountName
    $UserExists = Get-ADUser -Identity $SamAccountName

    If($UserExists){
        Write-Host "Setting Title attribute for " $SamAccountName
        Set-ADUser -Identity $SamAccountName -Title $Title
        Get-ADuser -Identity $SamAccountName | Format-List Title
    }
    Else {
        Write-Host "User does not exist:" $SamAccountName
    }
}