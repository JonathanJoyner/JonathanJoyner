##  This file is intended to import a csv from Namely's Employee Directory
##  Then update ADUser Properties with attributes from Namely using the Set-ADUser cmdlet
##  At Import the script converts the headers from the Namely Export to usable headers for Active Directory
##  Then creates variables for the new headers
##  Then cross references the directory to verify users from the CSV exist within the directory 
##  Then sets attributes for ADUsers imported from Namely
##  Written by Jonathan Joyner
##  4-29-2020
##  InsightSoftware
{
[Array]$UserData = Import-Csv "C:\Users\Jonathan.Joyner\Documents\NamelyTestCSV.csv" | Select-object `
    @{n='DisplayName';e={$_.'Full Name'}}, `
    @{n='Title';e={$_.'Job Title'}}, `
    @{n='OfficePhone';e={$_.'Office Phone'}}, `
    @{n='StreetAddress1';e={$_.'Office Address Location Address 1'}}, `
    @{n='StreetAddress2';e={$_.'Office Address Location Address 2'}}, `
    @{n='City';e={$_.'Office Address Location City'}}, `
    @{n='PostalCode';e={$_.'Office Address Location Zip'}}, `
    @{n='State';e={$_.'Office Address Location State ID'}}, `
    @{n='Country';e={$_.'Office Address Location Country ID'}}, `
    @{n='Office';e={$_.'Office Location'}}, `
    @{n='Manager';e={$_.'Reports to'}}, `
    @{n='UserPrincipalName';e={$_.'Company email'}} `
    | Where-Object `
        { ($User.DisplayName | ForEach-Object {$User.DisplayName}) -ne $null}, `
        { ($User.Title | ForEach-Object {$User.Title}) -ne $null}, `
        { ($User.OfficePhone | ForEach-Object {$User.OfficePhone}) -ne $null}, `
        { ($User.StreetAddress1 | ForEach-Object {$User.StreetAddress1}) -ne $null}, `
        { ($User.StreetAddress2 | ForEach-Object {$User.StreetAddress2}) -ne $null}, `
        { ($User.StreetAddress | ForEach-Object {$User.StreetAddress}) -ne $null}, `
        { ($User.City | ForEach-Object {$User.City}) -ne $null}, `
        { ($User.PostalCode | ForEach-Object {$User.PostalCode}) -ne $null}, `
        { ($User.State | ForEach-Object {$User.State}) -ne $null}, `
        { ($User.Country | ForEach-Object {$User.Country}) -ne $null}, `
        { ($User.Office | ForEach-Object {$User.Office}) -ne $null}, `
        { ($User.Manager | ForEach-Object {$User.Manager}) -ne $null} 
ForEach($User in $UserData){
    $DisplayName = $User.DisplayName
    $Title = $User.Title
    $OfficePhone = $User.OfficePhone
    $StreetAddress1 = $User.StreetAddress1
    $StreetAddress2 = $User.StreetAddress2
    $StreetAddress = $StreetAddress1 + ' ' + $StreetAddress2
    $City = $User.City
    $PostalCode = $User.PostalCode
    $State = $User.State
    $Country = $User.Country
    $Office = $User.Office
    $Manager = $User.Manager
    $UPN = ($User.UserPrincipalName).split('@')[0]
    $ADUserExists = Get-ADUser -Identity $UPN
    }
    If($ADUserExists){
        Write-Host "Updating attributes for" $User.DisplayName
        Set-ADUser -Identity $UPN `
            -DisplayName $DisplayName `
            -Title $Title `
            -StreetAddress $StreetAddress `
            -OfficePhone $OfficePhone `
            -City $City `
            -PostalCode $PostalCode `
            -State $State `
            -Country $Country `
            -Office $Office `
            -Manager $Manager
        Start-Sleep 1
    }
    Else {
        Write-Host "The ADUser for" $User_.DisplayName "doesn't exist"
    }
}
